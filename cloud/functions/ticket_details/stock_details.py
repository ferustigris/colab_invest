# Import all metric classes from individual files
from yahoo_data import YahooData
from metrics.profit_growth_10_years import ProfitGrowth10Years
from metrics.current_price import CurrentPrice
from metrics.shares import Shares
from metrics.sma_10_years import Sma10Years
from metrics.price_forecast_div import PriceForecastDiv
from metrics.price_forecast_div_buyback import PriceForecastDivBuyback
from metrics.price_forecast_pe import PriceForecastPE
from metrics.price_forecast_fpe import PriceForecastFPE
from metrics.price_forecast_equity import PriceForecastEquity
from metrics.market_cap import MarketCap
from metrics.revenue import Revenue
from metrics.net_income import NetIncome
from metrics.ebitda import Ebitda
from metrics.nta import Nta
from metrics.pe import Pe
from metrics.fpe import Fpe
from metrics.ps import Ps
from metrics.total_debt import TotalDebt
from metrics.cash import Cash
from metrics.dividend import Dividend
from metrics.buyback import Buyback
from metrics.buyback_percent import BuybackPercent
import logging

logger = logging.getLogger(__name__)


class StockDetails:
    def __init__(self, ticker: str, data: YahooData):
        self.data = data
        self.ticker = ticker
        self.name = f"Company {ticker}"
        self.summary = f"Summary about company {ticker}"
        self.currency = "USD"
        # Financial metrics with initialized default values
        self.profit_growth_10_years = ProfitGrowth10Years(self, data)
        self.current_price = CurrentPrice(self, data)
        self.shares = Shares(self, data)
        self.sma_10_years = Sma10Years(self, data)
        self.market_cap = MarketCap(self, data)
        self.revenue = Revenue(self, data)
        self.net_income = NetIncome(self, data)
        self.ebitda = Ebitda(self, data)
        self.nta = Nta(self, data)
        self.pe = Pe(self, data)
        self.fpe = Fpe(self, data)
        self.ps = Ps(self, data)
        self.total_debt = TotalDebt(self, data)
        self.cash = Cash(self, data)
        self.dividend = Dividend(self, data)
        self.buyback = Buyback(self, data)
        self.buyback_percent = BuybackPercent(self, data)
        # Computed price forecasts
        self.price_forecast_div = PriceForecastDiv(self, data)
        self.price_forecast_div_buyback = PriceForecastDivBuyback(self, data)
        self.price_forecast_pe = PriceForecastPE(self, data)
        self.price_forecast_fpe = PriceForecastFPE(self, data)
        self.price_forecast_equity = PriceForecastEquity(self, data)

    def to_json(self):
        logger.debug(f"Starting to_json() for ticker: {self.ticker}")
        
        def serialize_value(obj):
            """Helper function to handle complex numbers and other non-serializable objects"""
            # print(f"Serializing object of type: {type(obj).__name__}")
            if isinstance(obj, complex):
                logger.debug(f"Found complex number: {str(obj)}, converting to string")
                return str(obj)
            elif hasattr(obj, 'to_json'):
                # print(f"Object has to_json method, calling it")
                result = obj.to_json()
                return result
            else:
                return obj
        
        logger.debug("Building JSON dictionary...")
        result = {
            "ticker": self.ticker,
            "currency": self.currency,
            "name": self.name,
            "summary": self.summary,
            "profitGrowth10Years": serialize_value(self.profit_growth_10_years),
            "currentPrice": serialize_value(self.current_price),
            "shares": serialize_value(self.shares),
            "sma10Years": serialize_value(self.sma_10_years),
            "priceForecastDiv": serialize_value(self.price_forecast_div),
            "priceForecastDivBuyback": serialize_value(self.price_forecast_div_buyback),
            "priceForecastPE": serialize_value(self.price_forecast_pe),
            "priceForecastFPE": serialize_value(self.price_forecast_fpe),
            "priceForecastEquity": serialize_value(self.price_forecast_equity),
            "marketCap": serialize_value(self.market_cap),
            "revenue": serialize_value(self.revenue),
            "netIncome": serialize_value(self.net_income),
            # "ebitda": serialize_value(self.ebitda),
            "nta": serialize_value(self.nta),
            "pe": serialize_value(self.pe),
            "fpe": serialize_value(self.fpe),
            # "ps": serialize_value(self.ps),
            "totalDebt": serialize_value(self.total_debt),
            "cash": serialize_value(self.cash),
            "dividend": serialize_value(self.dividend),
            "buyback": serialize_value(self.buyback),
            "buybackPercent": serialize_value(self.buyback_percent)
        }
        
        logger.debug(f"Completed to_json() for ticker: {self.ticker}, result keys: {result}")
        return result
    
    def update_from_yahoo_data(self):
        """
        Update financial metrics from Yahoo data
        """
        logger.debug(f"Updating StockDetails for ticker: {self.ticker} from Yahoo data")
        import requests

        self.name = self.data.get("longName", self.name)
        self.currency = self.data.get("currency", "USD")
        
        # Create array of all metric objects
        metrics = [
            self.profit_growth_10_years,
            self.current_price,
            self.shares,
            self.sma_10_years,
            self.market_cap,
            self.revenue,
            self.net_income,
            self.ebitda,
            self.nta,
            self.pe,
            self.fpe,
            self.ps,
            self.total_debt,
            self.cash,
            self.dividend,
            self.buyback
        ]
        
        # Process all basic metrics
        for metric in metrics:
            try:
                metric.get_load_for_ticker()
                # print(f"Successfully loaded metric: {metric.__class__.__name__}")
            except (requests.exceptions.HTTPError, ValueError, TypeError) as e:
                logger.error(f"Error loading metric {metric.__class__.__name__}: {e}")
                continue
        
        # Process computed price forecasts (these depend on previously loaded metrics)
        # The order here matters if there are dependencies among the forecasts
        forecast_metrics = [
            self.buyback_percent,
            self.price_forecast_div,
            self.price_forecast_div_buyback,
            self.price_forecast_pe,
            self.price_forecast_fpe,
            self.price_forecast_equity
        ]
        
        for metric in forecast_metrics:
            try:
                metric.get_load_for_ticker()
                # print(f"Successfully loaded forecast metric: {metric.__class__.__name__}")
            except (requests.exceptions.HTTPError, ValueError, TypeError) as e:
                logger.warning(f"Error loading forecast metric {metric.__class__.__name__}: {e}")
                continue
        
