from firebase_utils import firebase_user_required, firebase_user_or_anonim
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
import requests
from pathlib import Path
from urllib.parse import urlparse
from stock_details import StockDetails

@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in ticket_details function", code=401)
@firebase_user_or_anonim
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

    # Create stock details instance and return JSON
    stock_details = StockDetails(ticker)
    
    return stock_details.to_json()

