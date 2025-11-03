from firebase_utils import firebase_user_required
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
import requests
from pathlib import Path
from urllib.parse import urlparse

@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in ticket_details function", code=401)
@firebase_user_required
@exception_logger(log_message="Error in ticket_details function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in ticket_details function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in ticket_details function")
def ticket_details(request, user):
    """
    Returns detailed information for a specific stock ticker
    """

    path = urlparse(request.url).path
    ticker = Path(path).name
    print("this is the ticker:", ticker)

    # Mock data for stock details - in real implementation this would come from API
    stock_details = {
        "name": f"Company {ticker}",
        "profitGrowth10Years": 15.5,
        "currentPrice": 125.75,
        "sharesOutstanding": 1000000000,
        "sma10Years": 110.25,
        "priceForecastDiv": 135.50,
        "priceForecastPE": 142.30,
        "priceForecastEquity": 138.75,
        "marketCap": 125750000000,
        "revenue": 50000000000,
        "netIncome": 7500000000,
        "ebitda": 12000000000,
        "nta": 25000000000,
        "pe": 16.77,
        "ps": 2.51,
        "evEbitda": 10.48,
        "totalDebt": 15000000000,
        "debtEbitda": 1.25,
        "cash": 8000000000,
        "dividendYield": 2.85,
        "peRatio": 16.77,
        "fpe": 15.25,
        "freeCashFlow": 5000000000,
        "buyback": 2000000000,
        "buybackPercent": 3.5,
        "freeCashFlowPerStock": 5.0
    }
    
    return stock_details
