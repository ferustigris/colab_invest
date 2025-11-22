from functools import reduce
import os
from gcp_utils import get_secret
from firebase_utils import firebase_user_or_anonim
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
from datetime import datetime, timedelta
import requests
from urllib.parse import urlparse
from openbb import obb

def is_valid_cache(data_last_update, data, cache_hours=24):
    """
    Check if cached Yahoo data is still valid
    
    Args:
        yahoo_data_last_update: Last update timestamp string
        yahoo_data: Yahoo data object
        cache_hours: Cache validity period in hours (default 24)
    
    Returns:
        bool: True if cache is valid, False if needs refresh
    """
   
    try:
        data_last_update_dt = datetime.strptime(data_last_update, "%Y-%m-%dT%H:%M:%SZ")
        now = datetime.now()
        return now - data_last_update_dt <= timedelta(hours=cache_hours)
    except ValueError:
        # If date parsing fails, consider cache invalid
        return False

@cors_headers
@cross_origin(methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in bb function", code=401)
@firebase_user_or_anonim
@exception_logger(log_message="Error in bb function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in bb function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in bb function")
def bb(request, user):
    print("BB function called")
    historizer_url = os.environ.get("HISTORIZER_URL")

    now = datetime.now()
    now_timestamp = datetime.strftime(now, "%Y-%m-%dT%H:%M:%SZ")

    print(f"bb called for user {user['uid']} at {now_timestamp}")

    path = urlparse(request.url).path
    print(f"this is the path: {path}, request.url: {request.url}")
    provider = os.path.basename(path)
    ticker = os.path.basename(os.path.dirname(path))

    print(f"this is the ticker: {ticker}, provider: {provider}")

    blob_name = f"bb_{ticker}_{provider}_data.json"
    print(f"blob_name: {blob_name}")
    response = requests.get(f"{historizer_url}/{blob_name}", headers=request.headers)
    response.raise_for_status()
    data = response.json().get(f"{provider}_data", {})   
    data_last_update = response.json().get("lastUpdate", "1970-01-01T00:00:00Z")
    result = data
    result['lastUpdate'] = data_last_update

    if not is_valid_cache(data_last_update, data):
        print(f"Cache invalid or expired, fetching fresh data for ticker {ticker}")
        
        result = _bb_yfinance_metrics_response(provider, ticker) | _bb_yfinance_profile_response(provider, ticker)
        print(f"Ticker info: {result}")

        response = requests.post(f"{historizer_url}/{blob_name}", headers=request.headers, json={
            f"{provider}_data": result, "lastUpdate": now_timestamp})
        response.raise_for_status()

        result['lastUpdate'] = now_timestamp

    print(f"Using cached data for ticker {ticker}")
    return result

def _setup_fmp_credentials():
    """Setup FMP API credentials if available in environment"""
    fmp_api_key = get_secret("fmp-api-key")

    if fmp_api_key:
        obb.user.credentials.fmp_api_key = fmp_api_key
        print(f"FMP API key set from environment")
    else:
        print("No FMP_API_KEY in environment, will try without authentication")

def _bb_yfinance_profile_response(provider, symbol):
    print(f"\nFetching data from OpenBB for provider: {provider}, symbol: {symbol}")  
    _setup_fmp_credentials()
    print("OpenBB imported successfully")
    
    # Get historical price data
    print("\nTrying to get historical price data...")
    try:
        profile_data = obb.equity.profile(
            symbol=symbol,
            provider=provider
        )
        print("Price data fetched successfully!")
        
        if not profile_data.results:
            print(f"No profile data returned for {symbol}")
            return {}
        
        # Save data to JSON
        results = list(map (lambda item: {k: str(v) if not isinstance(v, (int, float, bool, type(None))) else v 
                 for k, v in item.__dict__.items()}, profile_data.results))
        
        if not results:
            return {}
        
        return reduce(lambda x, y: x | y, results, {})
    except Exception as e:
        print(f"Error fetching profile data: {e}")
        return {}
    
def _bb_yfinance_metrics_response(provider, symbol):
    print(f"\nFetching data from OpenBB for provider: {provider}, symbol: {symbol}")
    _setup_fmp_credentials()

    # Get fundamental metrics (P/E, etc.)
    print("\nTrying to get fundamental metrics...")
    try:
        metrics_data = obb.equity.fundamental.metrics(
            symbol=symbol,
            provider=provider
        )
        print("Metrics data fetched successfully!")
        
        if not metrics_data.results:
            print(f"No metrics data returned for {symbol}")
            return {}
        
        # Save data to JSON
        results = list(map (lambda item: {k: str(v) if not isinstance(v, (int, float, bool, type(None))) else v 
                 for k, v in item.__dict__.items()}, metrics_data.results))
        
        if not results:
            return {}
        
        return reduce(lambda x, y: x | y, results, {})
    except Exception as e:
        print(f"Error fetching metrics data: {e}")
        return {}
