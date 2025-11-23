# Import all metric classes from individual files
from metrics.price_forecast_div import PriceForecastDiv
from metrics.price_forecast_div_buyback import PriceForecastDivBuyback
from metrics.price_forecast_equity import PriceForecastEquity
from metrics.price_forecast_fpe import PriceForecastFPE
from metrics.price_forecast_pe import PriceForecastPE
from yahoo_data import YahooData
from metrics.metrics_compositor import MetricsCompositor
from stock_details import StockDetails
from typing import List
import logging

logger = logging.getLogger(__name__)

class StockDetailsCompositor(StockDetails):
    def __init__(self, ticker: str, tickets: List[StockDetails], data: YahooData):
        super().__init__(ticker, data)
        self.ticker = ticker
        self.name = f"Company {ticker}"
        self.summary = f"Summary about company {ticker}"
        self.currency = "USD"
        
        # Use first ticket as reference for metric names and initial values
        first_ticket = tickets[0]
        
        # Financial metrics with initialized default values
        self.profit_growth_10_years = MetricsCompositor(
            first_ticket.profit_growth_10_years.name, 
            first_ticket.profit_growth_10_years.value, 
            first_ticket.profit_growth_10_years.comment, 
            first_ticket.profit_growth_10_years.data_quality, 
            first_ticket.profit_growth_10_years.last_update, 
            [t.profit_growth_10_years for t in tickets],
            self,
            data)
        self.current_price = MetricsCompositor(
            first_ticket.current_price.name,
            first_ticket.current_price.value,
            first_ticket.current_price.comment,
            first_ticket.current_price.data_quality,
            first_ticket.current_price.last_update,
            [t.current_price for t in tickets],
            self,
            data)
        self.shares = MetricsCompositor(
            first_ticket.shares.name,
            first_ticket.shares.value,
            first_ticket.shares.comment,
            first_ticket.shares.data_quality,
            first_ticket.shares.last_update,
            [t.shares for t in tickets],
            self,
            data)
        self.sma_10_years = MetricsCompositor(
            first_ticket.sma_10_years.name,
            first_ticket.sma_10_years.value,
            first_ticket.sma_10_years.comment,
            first_ticket.sma_10_years.data_quality,
            first_ticket.sma_10_years.last_update,
            [t.sma_10_years for t in tickets],
            self,
            data)
        self.market_cap = MetricsCompositor(
            first_ticket.market_cap.name,
            first_ticket.market_cap.value,
            first_ticket.market_cap.comment,
            first_ticket.market_cap.data_quality,
            first_ticket.market_cap.last_update,
            [t.market_cap for t in tickets],
            self,
            data)
        self.revenue = MetricsCompositor(
            first_ticket.revenue.name,
            first_ticket.revenue.value,
            first_ticket.revenue.comment,
            first_ticket.revenue.data_quality,
            first_ticket.revenue.last_update,
            [t.revenue for t in tickets],
            self,
            data)
        self.net_income = MetricsCompositor(
            first_ticket.net_income.name,
            first_ticket.net_income.value,
            first_ticket.net_income.comment,
            first_ticket.net_income.data_quality,
            first_ticket.net_income.last_update,
            [t.net_income for t in tickets],
            self,
            data)
        self.ebitda = MetricsCompositor(
            first_ticket.ebitda.name,
            first_ticket.ebitda.value,
            first_ticket.ebitda.comment,
            first_ticket.ebitda.data_quality,
            first_ticket.ebitda.last_update,
            [t.ebitda for t in tickets],
            self,
            data)
        self.nta = MetricsCompositor(
            first_ticket.nta.name,
            first_ticket.nta.value,
            first_ticket.nta.comment,
            first_ticket.nta.data_quality,
            first_ticket.nta.last_update,
            [t.nta for t in tickets],
            self,
            data)
        self.pe = MetricsCompositor(
            first_ticket.pe.name,
            first_ticket.pe.value,
            first_ticket.pe.comment,
            first_ticket.pe.data_quality,
            first_ticket.pe.last_update,
            [t.pe for t in tickets],
            self,
            data)
        self.fpe = MetricsCompositor(
            first_ticket.fpe.name,
            first_ticket.fpe.value,
            first_ticket.fpe.comment,
            first_ticket.fpe.data_quality,
            first_ticket.fpe.last_update,
            [t.fpe for t in tickets],
            self,
            data)
        self.ps = MetricsCompositor(
            first_ticket.ps.name,
            first_ticket.ps.value,
            first_ticket.ps.comment,
            first_ticket.ps.data_quality,
            first_ticket.ps.last_update,
            [t.ps for t in tickets],
            self,
            data)
        self.total_debt = MetricsCompositor(
            first_ticket.total_debt.name,
            first_ticket.total_debt.value,
            first_ticket.total_debt.comment,
            first_ticket.total_debt.data_quality,
            first_ticket.total_debt.last_update,
            [t.total_debt for t in tickets],
            self,
            data)
        self.cash = MetricsCompositor(
            first_ticket.cash.name,
            first_ticket.cash.value,
            first_ticket.cash.comment,
            first_ticket.cash.data_quality,
            first_ticket.cash.last_update,
            [t.cash for t in tickets],
            self,
            data)
        self.dividend = MetricsCompositor(
            first_ticket.dividend.name,
            first_ticket.dividend.value,
            first_ticket.dividend.comment,
            first_ticket.dividend.data_quality,
            first_ticket.dividend.last_update,
            [t.dividend for t in tickets],
            self,
            data)
        self.buyback = MetricsCompositor(
            first_ticket.buyback.name,
            first_ticket.buyback.value,
            first_ticket.buyback.comment,
            first_ticket.buyback.data_quality,
            first_ticket.buyback.last_update,
            [t.buyback for t in tickets],
            self,
            data)
        self.buyback_percent = MetricsCompositor(
            first_ticket.buyback_percent.name,
            first_ticket.buyback_percent.value,
            first_ticket.buyback_percent.comment,
            first_ticket.buyback_percent.data_quality,
            first_ticket.buyback_percent.last_update,
            [t.buyback_percent for t in tickets],
            self,
            data)
        # Computed price forecasts
        self.price_forecast_div = PriceForecastDiv(self)
        self.price_forecast_div_buyback = PriceForecastDivBuyback(self)
        self.price_forecast_pe = PriceForecastPE(self)
        self.price_forecast_fpe = PriceForecastFPE(self)
        self.price_forecast_equity = PriceForecastEquity(self)


