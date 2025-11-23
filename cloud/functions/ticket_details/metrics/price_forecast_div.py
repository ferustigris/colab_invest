from financial_metric import FinancialMetric
import logging

logger = logging.getLogger(__name__)


class PriceForecastDiv(FinancialMetric):
    def __init__(self, stock_details=None):
        super().__init__(
            "priceForecastDiv",
            0,
            "Price forecast based on dividend discount model",
            0,
            "1970-01-01T00:00:00Z"
        , stock_details, None)
    
    def get_load_for_ticker(self):
        logger.info(f"Loading data for {self.name} metric for ticker {self.stock_details.ticker}")
        # Use current price and dividend for forecast
        # =2/3*E2*V2/(1-1/(1+Trands!$D$3))
        price = self.stock_details.current_price.value
        div = self.stock_details.dividend.value
        
        if price is None or div is None:
            self.value = 0
            self.data_quality = 0.0
            self.comment += f"\n - Invalid price ({price}) or dividend ({div}) value"
            return
            
        self.value = 2/3 * price * div / (1 - 1/(1 + 0.026))
        self.data_quality = self.stock_details.current_price.data_quality * self.stock_details.dividend.data_quality
        self.comment += f"\n - current data quality: {self.data_quality:.2f}"
