class YahooData:
    """Data class for Yahoo Finance compatible data structure - only fields used by metrics"""
    
    def __init__(self):
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
        self.enterpriseToEbitda = None
        
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
    def from_dict(cls, data_dict):
        """Create YahooData from dictionary"""
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
            'enterpriseToEbitda': data_dict.get('enterpriseToEbitda'),
            
            # Financial health
            'totalDebt': data_dict.get('totalDebt'),
            'totalCash': data_dict.get('totalCash'),
            'freeCashflow': data_dict.get('freeCashflow'),
            'ebitda': data_dict.get('ebitda'),
            
            # Dividends
            'fiveYearAvgDividendYield': data_dict.get('fiveYearAvgDividendYield'),
            
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
            'priceToSalesTrailing12Months': data_dict.get('priceToSalesTrailing12Months'),
            'enterpriseToEbitda': data_dict.get('enterpriseToEbitda'),
            
            # Financial health
            'totalDebt': data_dict.get('totalDebt'),
            'totalCash': data_dict.get('totalCash'),
            'freeCashflow': data_dict.get('freeCashflow'),
            'ebitda': data_dict.get('ebitda'),
            
            # Dividends
            'fiveYearAvgDividendYield': data_dict.get('fiveYearAvgDividendYield'),
            
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
