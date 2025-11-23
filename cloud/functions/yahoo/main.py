from general_utils import cache
from firebase_utils import firebase_user_or_anonim
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
from datetime import datetime
import requests
import yfinance as yf
from pathlib import Path
from urllib.parse import urlparse

@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in sales_ask_chat function", code=401)
@firebase_user_or_anonim
@cache(cache_hours=48, func_name="yahoo")
@exception_logger(log_message="Error in sales_ask_chat function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in sales_ask_chat function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in sales_ask_chat function")
def yahoo(request, user):
    print("yahoo function called")

    now = datetime.now()
    now_timestamp = datetime.strftime(now, "%Y-%m-%dT%H:%M:%SZ")

    print(f"ask_chat called for user {user['uid']} at {now_timestamp}")
    path = urlparse(request.url).path
    ticker = Path(path).name
    print("this is the ticker:", ticker)
        
    yahoo_data = yf.Ticker(ticker)
    print("Ticker info:", yahoo_data.info)
    result = yahoo_data.info

    result['lastUpdate'] = now_timestamp

    print(f"Using cached data for ticker {ticker}")
    return result
