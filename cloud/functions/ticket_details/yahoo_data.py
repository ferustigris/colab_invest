import logging

logger = logging.getLogger(__name__)
class YahooData:
    """Data class for Yahoo Finance compatible data structure - only fields used by metrics"""
    
    @staticmethod
    def parse_abbreviated_number(value):
        """Parse abbreviated numbers like '14.77B', '115.56M', '4.05T' to float
        
        Args:
            value: String or numeric value
            
        Returns:
            float: Parsed numeric value or None if parsing fails
        """
        if value is None or value == '':
            return None
            
        if isinstance(value, (int, float)):
            return float(value)
            
        if not isinstance(value, str):
            return None
            
        value = value.strip().upper()
        
        # Remove any commas
        value = value.replace(',', '')
        
        # Check for suffix
        multipliers = {
            'K': 1_000,
            'M': 1_000_000,
            'B': 1_000_000_000,
            'T': 1_000_000_000_000,
        }
        
        for suffix, multiplier in multipliers.items():
            if value.endswith(suffix):
                try:
                    num = float(value[:-1])
                    return num * multiplier
                except ValueError:
                    return None
        
        # Try to parse as plain number
        try:
            return float(value)
        except ValueError:
            return None
    
    def __init__(self):
        self.provider = "default"
        # Timestamp - most important field used by all metrics
        self.lastUpdate = None
        
        # Company info
        self.longName = None
        
        # Price and market data
        self.currentPrice = None
        self.marketCap = None
        
        # Revenue and income
        self.totalRevenue = None
        self.netIncomeToCommon = None
        
        # Valuation metrics
        self.trailingPE = None
        self.forwardPE = None
        self.ps = None
        
        # Financial health
        self.totalDebt = None
        self.totalCash = None
        self.freeCashflow = None
        self.ebitda = None
        
        # Dividends
        self.fiveYearAvgDividendYield = None
        
        # Shares
        self.sharesOutstanding = None
        self.impliedSharesOutstanding = None
        
        # Book value
        self.bookValue = None
        
        # Technical indicators
        self.twoHundredDayAverage = None
    
    def get(self, key, default=None):
        """Dictionary-like get method for backward compatibility"""
        return getattr(self, key, default)
    
    def __getitem__(self, key):
        """Dictionary-like access for backward compatibility"""
        return getattr(self, key)
    
    def __setitem__(self, key, value):
        """Dictionary-like setting for backward compatibility"""
        setattr(self, key, value)
    
    def __contains__(self, key):
        """Dictionary-like 'in' operator for backward compatibility"""
        return hasattr(self, key)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {k: v for k, v in self.__dict__.items() if not k.startswith('_')}
    
    @classmethod
    def from_dict(cls, data_dict, provider=None):
        """Create YahooData from dictionary"""
        match provider:
            case 'yfinance':
                yahoo_data = cls.from_yahoo_dict(data_dict)
            case 'bb_yfinance':
                yahoo_data = cls.from_bb_yahoo_dict(data_dict)
            case 'bb_fmp':
                yahoo_data = cls.from_bb_fmp_dict(data_dict)
            case 'bb_finviz':
                yahoo_data = cls.from_bb_finviz_dict(data_dict)
            case _:
                yahoo_data = cls()
                for key, value in data_dict.items():
                    if hasattr(yahoo_data, key):
                        setattr(yahoo_data, key, value)
        return yahoo_data
    
    @classmethod
    def from_yahoo_dict(cls, data_dict, last_update=None):
        """Create YahooData from Yahoo Finance dictionary with only required fields
        
        Args:
            data_dict: Dictionary with yahoo data fields
            last_update: Optional lastUpdate timestamp, if not provided will try to get from data_dict
        """
        yahoo_data = cls()
        
        # Required fields mapping - only fields actually used by metrics
        required_fields = {
            'provider': 'yfinance',
            # Timestamp - used by all metrics for validation
            'lastUpdate': last_update if last_update is not None else data_dict.get('lastUpdate'),
            
            # Company info
            'longName': data_dict.get('longName'),
            
            # Price and market data
            'currentPrice': data_dict.get('currentPrice'),
            'marketCap': data_dict.get('marketCap'),
            
            # Revenue and income
            'totalRevenue': data_dict.get('totalRevenue'),
            'netIncomeToCommon': data_dict.get('netIncomeToCommon'),
            
            # Valuation metrics
            'trailingPE': data_dict.get('trailingPE'),
            'forwardPE': data_dict.get('forwardPE'),
            'ps': data_dict.get('priceToSalesTrailing12Months'),
            
            # Financial health
            'totalDebt': data_dict.get('totalDebt'),
            'totalCash': data_dict.get('totalCash'),
            'freeCashflow': data_dict.get('freeCashflow'),
            'ebitda': data_dict.get('ebitda'),
            
            # Dividends
            'fiveYearAvgDividendYield': data_dict.get('fiveYearAvgDividendYield') / 100 if data_dict.get('fiveYearAvgDividendYield') is not None else None,  # Already percentage
            'dividendYield': data_dict.get('dividendYield') / 100.0 if data_dict.get('dividendYield') is not None else None,  # Convert percentage to decimal,
            'trailingAnnualDividendYield': data_dict.get('trailingAnnualDividendYield'),
            'forwardAnnualDividendYield': data_dict.get('forwardAnnualDividendYield') / 100 if data_dict.get('forwardAnnualDividendYield') is not None else None,  # Already percentage,
            
            # Shares
            'sharesOutstanding': data_dict.get('sharesOutstanding'),
            'impliedSharesOutstanding': data_dict.get('impliedSharesOutstanding'),
            
            # Book value
            'bookValue': data_dict.get('bookValue'),
            
            # Technical indicators
            'twoHundredDayAverage': data_dict.get('twoHundredDayAverage'),
        }
        
        # Set only the required fields
        for key, value in required_fields.items():
            setattr(yahoo_data, key, value)
        
        return yahoo_data


    @classmethod
    def from_bb_yahoo_dict(cls, data_dict, last_update=None):
        """Create YahooData from Yahoo Finance dictionary with only required fields
        
        Args:
            data_dict: Dictionary with yahoo data fields
            last_update: Optional lastUpdate timestamp, if not provided will try to get from data_dict
                        If still not found, will use current timestamp
        """
        from datetime import datetime
        
        yahoo_data = cls()
        
        # Determine lastUpdate value
        if last_update is None:
            last_update = data_dict.get('lastUpdate')
        if last_update is None:
            # Use current timestamp if still not provided
            last_update = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        # Required fields mapping - only fields actually used by metrics
        required_fields = {
            # Timestamp - always set to ensure it's not None
            'lastUpdate': last_update,
            'provider': 'bb_yfinance',
            'currency': data_dict.get('currency'),
            
            # Company info
            'longName': data_dict.get('name'),
            
            # Price and market data
            'currentPrice': data_dict.get('currentPrice'),
            'marketCap': data_dict.get('market_cap'),
            
            # Revenue and income
            'totalRevenue': data_dict.get('totalRevenue'),
            'netIncomeToCommon': data_dict.get('netIncomeToCommon'),
            
            # Valuation metrics
            'trailingPE': data_dict.get('pe_ratio'),
            'forwardPE': data_dict.get('forward_pe'),
            'ps': None,
            
            # Financial health
            'totalDebt': None,
            'totalCash': data_dict.get('cash_per_share') * data_dict.get('shares_outstanding') if data_dict.get('cash_per_share') and data_dict.get('shares_outstanding') else None,
            'freeCashflow': None,
            'ebitda': None,
            
            # Dividends
            'dividendYield': data_dict.get('dividend_yield'),
            'fiveYearAvgDividendYield': data_dict.get('dividend_yield_5y_avg'),
            
            # Shares
            'sharesOutstanding': data_dict.get('shares_outstanding'),
            'impliedSharesOutstanding': data_dict.get('shares_implied_outstanding'),
            
            # Book value
            'bookValue': data_dict.get('book_value'),
            
            # Technical indicators
            'twoHundredDayAverage': data_dict.get('twoHundredDayAverage'),
        }
        
        # Set only the required fields
        for key, value in required_fields.items():
            setattr(yahoo_data, key, value)
        
        return yahoo_data


    @classmethod
    def from_bb_fmp_dict(cls, data_dict, last_update=None):
        """Create YahooData from FMP dictionary with only required fields
        
        Args:
            data_dict: Dictionary with yahoo data fields
            last_update: Optional lastUpdate timestamp, if not provided will try to get from data_dict
                        If still not found, will use current timestamp
        """
        from datetime import datetime
        
        yahoo_data = cls()
        
        # Determine lastUpdate value
        if last_update is None:
            last_update = data_dict.get('lastUpdate')
        if last_update is None:
            # Use current timestamp if still not provided
            last_update = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        # Required fields mapping - only fields actually used by metrics
        required_fields = {
            # Timestamp - always set to ensure it's not None
            'lastUpdate': last_update,
            'provider': 'bb_fmp',
            'currency': data_dict.get('currency'),

            # Company info
            'longName': data_dict.get('name'),
            
            # Price and market data
            'currentPrice': data_dict.get('last_price'),
            'marketCap': data_dict.get('market_cap'),
            
            # Revenue and income
            'totalRevenue': data_dict.get('revenue'),
            'netIncomeToCommon': data_dict.get('net_income') or data_dict.get('consolidated_net_income'),
            
            # Valuation metrics
            'trailingPE': data_dict.get('pe_ratio'),#TODO: verify
            'forwardPE': data_dict.get('forward_pe'),#TODO: verify
            
            # Financial health
            'totalDebt': data_dict.get('net_debt_to_ebitda') * data_dict.get('ebitda') if data_dict.get('net_debt_to_ebitda') and data_dict.get('ebitda') else None,
            'totalCash': data_dict.get('cash_per_share') * data_dict.get('weighted_average_basic_shares_outstanding') if data_dict.get('cash_per_share') and data_dict.get('weighted_average_basic_shares_outstanding') else None,
            'freeCashflow': data_dict.get('free_cash_flow') or (data_dict.get('free_cash_flow_yield') * data_dict.get('market_cap') if data_dict.get('free_cash_flow_yield') and data_dict.get('market_cap') else None),
            'ebitda': data_dict.get('ebitda'),
            
            # Dividends
            'dividendYield': data_dict.get('annualized_dividend_amount') / data_dict.get('last_price') if data_dict.get('annualized_dividend_amount') and data_dict.get('last_price') else None,
            'fiveYearAvgDividendYield': None,
            
            # Shares
            'sharesOutstanding': data_dict.get('weighted_average_basic_shares_outstanding'),
            'impliedSharesOutstanding': data_dict.get('weighted_average_diluted_shares_outstanding'),
            
            # Book value
            'bookValue': data_dict.get('tangible_asset_value') / data_dict.get('weighted_average_basic_shares_outstanding') if data_dict.get('tangible_asset_value') and data_dict.get('weighted_average_basic_shares_outstanding') else None,
            
            # Technical indicators
            'twoHundredDayAverage': data_dict.get('twoHundredDayAverage'),
        }
        
        # Set only the required fields
        for key, value in required_fields.items():
            setattr(yahoo_data, key, value)
        
        return yahoo_data


    @classmethod
    def from_bb_finviz_dict(cls, data_dict, last_update=None):
        """Create YahooData from finviz dictionary with only required fields
        
        Args:
            data_dict: Dictionary with finviz data fields
            last_update: Optional lastUpdate timestamp, if not provided will try to get from data_dict
                        If still not found, will use current timestamp
        """
        from datetime import datetime
        
        yahoo_data = cls()
        
        # Determine lastUpdate value
        if last_update is None:
            last_update = data_dict.get('lastUpdate')
        if last_update is None:
            # Use current timestamp if still not provided
            last_update = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        shares_outstanding = cls.parse_abbreviated_number(data_dict.get('shares_outstanding'))
        shares_float = cls.parse_abbreviated_number(data_dict.get('shares_float'))
        market_cap = cls.parse_abbreviated_number(data_dict.get('market_cap'))
        # Required fields mapping - only fields actually used by metrics
        required_fields = {
            # Timestamp - always set to ensure it's not None
            'lastUpdate': last_update,
            'provider': 'bb_finviz',
            # Company info
            'longName': data_dict.get('name'),
            'currency': data_dict.get('currency'),
            
            # Price and market data
            'currentPrice': data_dict.get('last_price'),
            'marketCap': market_cap,
            
            # Revenue and income
            'totalRevenue': data_dict.get('revenue'),
            'netIncomeToCommon': data_dict.get('consolidated_net_income'),
            
            # Valuation metrics
            'trailingPE': data_dict.get('pe_ratio'),
            'forwardPE': data_dict.get('foward_pe'),
            
            # Financial health
            'totalDebt': data_dict.get('net_debt_to_ebitda') * data_dict.get('ebitda') if data_dict.get('net_debt_to_ebitda') and data_dict.get('ebitda') else None,
            'totalCash': data_dict.get('cash_per_share') * shares_outstanding if data_dict.get('cash_per_share') and shares_outstanding else None,
            'freeCashflow': None,
            'ebitda': data_dict.get('ebitda'),
            
            # Dividends
            'dividendYield': data_dict.get('dividend_yield'),
            'fiveYearAvgDividendYield': data_dict.get('dividend_yield_5y_avg'),
            
            # Shares
            'sharesOutstanding': shares_outstanding,
            'impliedSharesOutstanding': shares_float,
            
            # Book value
            'bookValue': data_dict.get('book_value_per_share'),
            
            # Technical indicators
            'twoHundredDayAverage': data_dict.get('twoHundredDayAverage'),
        }
        
        # Set only the required fields
        for key, value in required_fields.items():
            setattr(yahoo_data, key, value)
        
        return yahoo_data
