from firebase_utils import firebase_user_required
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
import requests
from pathlib import Path
from urllib.parse import urlparse

@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in tickets function", code=401)
@firebase_user_required
@exception_logger(log_message="Error in tickets function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in tickets function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in tickets function")
def tickets(request, user):
    """
    Returns list of available stock tickers
    """

    path = urlparse(request.url).path
    last_element = Path(path).name
    print("this is the last element:", last_element)

    # List of stock tickers as strings
    stock_tickers = [
        "VOW", "KHC", "HPK", "INTC", "JD", "DOW", "BAS", "PFE", "BIDU", "EHLD", 
        "TGT", "KSA", "SAN1", "SHELL", "RIO", "PYPL", "SOLV", "OXY", "SWR", "BAYN", 
        "TTE", "OKE", "ULTA", "BBWI", "SIRI", "BMW", "NVS", "AAPL", "IBE", "VZ", 
        "ORA", "HAFN", "REP", "USB", "DAL", "GOOGL", "AXP", "MSFT", "ALV", "BABA", 
        "BAC", "IAG", "ESEA", "METC", "HOT", "META", "TSM"
    ]
    
    return stock_tickers
