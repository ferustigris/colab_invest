# Import all metric classes from individual files
from metrics.metrics_compositor import MetricsCompositor
from stock_details import StockDetails
from typing import List

class StockDetailsCompositor(StockDetails):
    def __init__(self, ticker: str, tickets: List[StockDetails]):
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
            [t.profit_growth_10_years for t in tickets])
        self.current_price = MetricsCompositor(
            first_ticket.current_price.name,
            first_ticket.current_price.value,
            first_ticket.current_price.comment,
            first_ticket.current_price.data_quality,
            first_ticket.current_price.last_update,
            [t.current_price for t in tickets])
        self.shares = MetricsCompositor(
            first_ticket.shares.name,
            first_ticket.shares.value,
            first_ticket.shares.comment,
            first_ticket.shares.data_quality,
            first_ticket.shares.last_update,
            [t.shares for t in tickets])
        self.sma_10_years = MetricsCompositor(
            first_ticket.sma_10_years.name,
            first_ticket.sma_10_years.value,
            first_ticket.sma_10_years.comment,
            first_ticket.sma_10_years.data_quality,
            first_ticket.sma_10_years.last_update,
            [t.sma_10_years for t in tickets])
        self.market_cap = MetricsCompositor(
            first_ticket.market_cap.name,
            first_ticket.market_cap.value,
            first_ticket.market_cap.comment,
            first_ticket.market_cap.data_quality,
            first_ticket.market_cap.last_update,
            [t.market_cap for t in tickets])
        self.revenue = MetricsCompositor(
            first_ticket.revenue.name,
            first_ticket.revenue.value,
            first_ticket.revenue.comment,
            first_ticket.revenue.data_quality,
            first_ticket.revenue.last_update,
            [t.revenue for t in tickets])
        self.net_income = MetricsCompositor(
            first_ticket.net_income.name,
            first_ticket.net_income.value,
            first_ticket.net_income.comment,
            first_ticket.net_income.data_quality,
            first_ticket.net_income.last_update,
            [t.net_income for t in tickets])
        self.ebitda = MetricsCompositor(
            first_ticket.ebitda.name,
            first_ticket.ebitda.value,
            first_ticket.ebitda.comment,
            first_ticket.ebitda.data_quality,
            first_ticket.ebitda.last_update,
            [t.ebitda for t in tickets])
        self.nta = MetricsCompositor(
            first_ticket.nta.name,
            first_ticket.nta.value,
            first_ticket.nta.comment,
            first_ticket.nta.data_quality,
            first_ticket.nta.last_update,
            [t.nta for t in tickets])
        self.pe = MetricsCompositor(
            first_ticket.pe.name,
            first_ticket.pe.value,
            first_ticket.pe.comment,
            first_ticket.pe.data_quality,
            first_ticket.pe.last_update,
            [t.pe for t in tickets])
        self.fpe = MetricsCompositor(
            first_ticket.fpe.name,
            first_ticket.fpe.value,
            first_ticket.fpe.comment,
            first_ticket.fpe.data_quality,
            first_ticket.fpe.last_update,
            [t.fpe for t in tickets])
        self.ps = MetricsCompositor(
            first_ticket.ps.name,
            first_ticket.ps.value,
            first_ticket.ps.comment,
            first_ticket.ps.data_quality,
            first_ticket.ps.last_update,
            [t.ps for t in tickets])
        self.ev_ebitda = MetricsCompositor(
            first_ticket.ev_ebitda.name,
            first_ticket.ev_ebitda.value,
            first_ticket.ev_ebitda.comment,
            first_ticket.ev_ebitda.data_quality,
            first_ticket.ev_ebitda.last_update,
            [t.ev_ebitda for t in tickets])
        self.total_debt = MetricsCompositor(
            first_ticket.total_debt.name,
            first_ticket.total_debt.value,
            first_ticket.total_debt.comment,
            first_ticket.total_debt.data_quality,
            first_ticket.total_debt.last_update,
            [t.total_debt for t in tickets])
        self.debt_ebitda = MetricsCompositor(
            first_ticket.debt_ebitda.name,
            first_ticket.debt_ebitda.value,
            first_ticket.debt_ebitda.comment,
            first_ticket.debt_ebitda.data_quality,
            first_ticket.debt_ebitda.last_update,
            [t.debt_ebitda for t in tickets])
        self.cash = MetricsCompositor(
            first_ticket.cash.name,
            first_ticket.cash.value,
            first_ticket.cash.comment,
            first_ticket.cash.data_quality,
            first_ticket.cash.last_update,
            [t.cash for t in tickets])
        self.dividend = MetricsCompositor(
            first_ticket.dividend.name,
            first_ticket.dividend.value,
            first_ticket.dividend.comment,
            first_ticket.dividend.data_quality,
            first_ticket.dividend.last_update,
            [t.dividend for t in tickets])
        self.free_cash_flow = MetricsCompositor(
            first_ticket.free_cash_flow.name,
            first_ticket.free_cash_flow.value,
            first_ticket.free_cash_flow.comment,
            first_ticket.free_cash_flow.data_quality,
            first_ticket.free_cash_flow.last_update,
            [t.free_cash_flow for t in tickets])
        self.buyback = MetricsCompositor(
            first_ticket.buyback.name,
            first_ticket.buyback.value,
            first_ticket.buyback.comment,
            first_ticket.buyback.data_quality,
            first_ticket.buyback.last_update,
            [t.buyback for t in tickets])
        self.buyback_percent = MetricsCompositor(
            first_ticket.buyback_percent.name,
            first_ticket.buyback_percent.value,
            first_ticket.buyback_percent.comment,
            first_ticket.buyback_percent.data_quality,
            first_ticket.buyback_percent.last_update,
            [t.buyback_percent for t in tickets])
        self.free_cash_flow_per_stock = MetricsCompositor(
            first_ticket.free_cash_flow_per_stock.name,
            first_ticket.free_cash_flow_per_stock.value,
            first_ticket.free_cash_flow_per_stock.comment,
            first_ticket.free_cash_flow_per_stock.data_quality,
            first_ticket.free_cash_flow_per_stock.last_update,
            [t.free_cash_flow_per_stock for t in tickets])
        # Computed price forecasts
        self.price_forecast_div = MetricsCompositor(
            first_ticket.price_forecast_div.name,
            first_ticket.price_forecast_div.value,
            first_ticket.price_forecast_div.comment,
            first_ticket.price_forecast_div.data_quality,
            first_ticket.price_forecast_div.last_update,
            [t.price_forecast_div for t in tickets])
        self.price_forecast_div_buyback = MetricsCompositor(
            first_ticket.price_forecast_div_buyback.name,
            first_ticket.price_forecast_div_buyback.value,
            first_ticket.price_forecast_div_buyback.comment,
            first_ticket.price_forecast_div_buyback.data_quality,
            first_ticket.price_forecast_div_buyback.last_update,
            [t.price_forecast_div_buyback for t in tickets])
        self.price_forecast_pe = MetricsCompositor(
            first_ticket.price_forecast_pe.name,
            first_ticket.price_forecast_pe.value,
            first_ticket.price_forecast_pe.comment,
            first_ticket.price_forecast_pe.data_quality,
            first_ticket.price_forecast_pe.last_update,
            [t.price_forecast_pe for t in tickets])
        self.price_forecast_fpe = MetricsCompositor(
            first_ticket.price_forecast_fpe.name,
            first_ticket.price_forecast_fpe.value,
            first_ticket.price_forecast_fpe.comment,
            first_ticket.price_forecast_fpe.data_quality,
            first_ticket.price_forecast_fpe.last_update,
            [t.price_forecast_fpe for t in tickets])
        self.price_forecast_equity = MetricsCompositor(
            first_ticket.price_forecast_equity.name,
            first_ticket.price_forecast_equity.value,
            first_ticket.price_forecast_equity.comment,
            first_ticket.price_forecast_equity.data_quality,
            first_ticket.price_forecast_equity.last_update,
            [t.price_forecast_equity for t in tickets])

