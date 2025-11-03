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

    # List of stock tickers as objects
    stock_tickers = [
        {"ticker": "VOW"}, {"ticker": "KHC"}, {"ticker": "HPK"}, {"ticker": "INTC"}, {"ticker": "JD"}, 
        {"ticker": "DOW"}, {"ticker": "BAS"}, {"ticker": "PFE"}, {"ticker": "BIDU"}, {"ticker": "EHLD"}, 
        {"ticker": "TGT"}, {"ticker": "KSA"}, {"ticker": "SAN1"}, {"ticker": "SHELL"}, {"ticker": "RIO"}, 
        {"ticker": "PYPL"}, {"ticker": "SOLV"}, {"ticker": "OXY"}, {"ticker": "SWR"}, {"ticker": "BAYN"}, 
        {"ticker": "TTE"}, {"ticker": "OKE"}, {"ticker": "ULTA"}, {"ticker": "BBWI"}, {"ticker": "SIRI"}, 
        {"ticker": "BMW"}, {"ticker": "NVS"}, {"ticker": "AAPL"}, {"ticker": "IBE"}, {"ticker": "VZ"}, 
        {"ticker": "ORA"}, {"ticker": "HAFN"}, {"ticker": "REP"}, {"ticker": "USB"}, {"ticker": "DAL"}, 
        {"ticker": "GOOGL"}, {"ticker": "AXP"}, {"ticker": "MSFT"}, {"ticker": "ALV"}, {"ticker": "BABA"}, 
        {"ticker": "BAC"}, {"ticker": "IAG"}, {"ticker": "ESEA"}, {"ticker": "METC"}, {"ticker": "HOT"}, 
        {"ticker": "META"}, {"ticker": "TSM"}
    ]
    
    return stock_tickers
