import json
import os
from ai_utils import create_openai_payload, prepare_openai_context
from firebase_utils import firebase_user_required, firebase_user_or_anonim
from gcp_utils import get_secret
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
from datetime import datetime, timedelta
import requests
import yfinance as yf
from pathlib import Path
from urllib.parse import urlparse

def is_valid_cache(yahoo_data_last_update, yahoo_data, cache_hours=24):
    """
    Check if cached Yahoo data is still valid
    
    Args:
        yahoo_data_last_update: Last update timestamp string
        yahoo_data: Yahoo data object
        cache_hours: Cache validity period in hours (default 24)
    
    Returns:
        bool: True if cache is valid, False if needs refresh
    """
    if not yahoo_data_last_update or not yahoo_data:
        return False
    
    try:
        yahoo_data_last_update_dt = datetime.strptime(yahoo_data_last_update, "%Y-%m-%dT%H:%M:%SZ")
        now = datetime.now()
        return now - yahoo_data_last_update_dt <= timedelta(hours=cache_hours)
    except ValueError:
        # If date parsing fails, consider cache invalid
        return False

@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in sales_ask_chat function", code=401)
@firebase_user_or_anonim
@exception_logger(log_message="Error in sales_ask_chat function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in sales_ask_chat function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in sales_ask_chat function")
def yahoo(request, user):
    print("yahoo function called")
    historizer_url = os.environ.get("HISTORIZER_URL")

    now = datetime.now()
    now_timestamp = datetime.strftime(now, "%Y-%m-%dT%H:%M:%SZ")

    print(f"ask_chat called for user {user['uid']} at {now_timestamp}")
    path = urlparse(request.url).path
    ticker = Path(path).name
    print("this is the ticker:", ticker)

    blob_name = f"{ticker}_yahoo_data.json"
    response = requests.get(f"{historizer_url}/{blob_name}", headers=request.headers)
    response.raise_for_status()
    yahoo_data = response.json().get("yahoo_data", {})   
    yahoo_data_last_update = response.json().get("lastUpdate", {})   
    
    if not is_valid_cache(yahoo_data_last_update, yahoo_data):
        print(f"Cache invalid or expired, fetching fresh data for ticker {ticker}")
        
        yahoo_data = yf.Ticker(ticker)
        print("Ticker info:", yahoo_data.info)

        response = requests.post(f"{historizer_url}/{blob_name}", headers=request.headers, json={
            "yahoo_data": yahoo_data.info, "lastUpdate": now_timestamp})
        response.raise_for_status()

        result = json.loads(yahoo_data)
        result['lastUpdate'] = now_timestamp
        return result

    print(f"Using cached data for ticker {ticker}")
    yahoo_data['lastUpdate'] = yahoo_data_last_update
    return yahoo_data
