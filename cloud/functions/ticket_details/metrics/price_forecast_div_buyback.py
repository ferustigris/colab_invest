from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class PriceForecastDivBuyback(FinancialMetric):
    def __init__(self, stock_details=None, yahoo_data=None):
        super().__init__(
            "priceForecastDivBuyback",
            0,
            "Price forecast based on dividend discount model with buyback consideration",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, yahoo_data)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        # Use current price, dividend and buyback for forecast
        # =2/3*E2*(V2+buyback)/(1-1/(1+Trands!$D$3))
        price = self.stock_details.current_price.value
        div = self.stock_details.dividend.value
        buyback_percent = self.stock_details.buyback_percent.value

        logger.debug(f"Calculating {self.name} with price={price}, dividend={div}, buyback_percent={buyback_percent}")
        
        if price is None or div is None or buyback_percent is None:
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Invalid price ({price}), dividend ({div}), or buyback_percent ({buyback_percent}) value"
            return
            
        self.value = 2.0/3 * price * (div + buyback_percent) / (1 - 1/(1 + 0.026))

        self.data_quality = self.stock_details.current_price.data_quality * self.stock_details.dividend.data_quality * self.stock_details.buyback_percent.data_quality
        self.comment += f"\n - price: {price:.2f}, dividend: {div:.2f}, buyback: {buyback_percent:.2f}"
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
