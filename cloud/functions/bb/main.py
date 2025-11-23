from functools import reduce
import json
import os
from gcp_utils import get_secret
from firebase_utils import firebase_user_or_anonim
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
from datetime import datetime, timedelta
import requests
from urllib.parse import urlparse
from openbb import obb
import logging

logger = logging.getLogger(__name__)

def is_valid_cache(data_last_update, data, cache_hours=48):
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
    logger.debug("BB function called")
    historizer_url = os.environ.get("HISTORIZER_URL")

    now = datetime.now()
    now_timestamp = datetime.strftime(now, "%Y-%m-%dT%H:%M:%SZ")

    logger.info(f"bb called for user {user['uid']} at {now_timestamp}")

    path = urlparse(request.url).path
    logger.debug(f"this is the path: {path}, request.url: {request.url}")
    provider = os.path.basename(path)
    ticker = os.path.basename(os.path.dirname(path))

    logger.info(f"this is the ticker: {ticker}, provider: {provider}")

    blob_name = f"bb_{ticker}_{provider}_data.json"
    logger.debug(f"blob_name: {blob_name}")
    response = requests.get(f"{historizer_url}/{blob_name}", headers=request.headers)
    response.raise_for_status()
    data = response.json().get(f"{provider}_data", {})   
    data_last_update = response.json().get("lastUpdate", "1970-01-01T00:00:00Z")
    result = data
    result['lastUpdate'] = data_last_update

    if not is_valid_cache(data_last_update, data):
        logger.info(f"Cache invalid or expired, fetching fresh data for ticker {ticker}")
        _setup_fmp_credentials()

        result = _bb_yfinance_metrics_response(provider, ticker)
        logger.debug(f"Ticker info: {result}")

        response = requests.post(f"{historizer_url}/{blob_name}", headers=request.headers, json={
            f"{provider}_data": result, "lastUpdate": now_timestamp})
        response.raise_for_status()

        result['lastUpdate'] = now_timestamp
    else:
        logger.info(f"Using cached data for ticker {ticker}")
    return result

def _setup_fmp_credentials():
    """Setup FMP API credentials if available in environment"""
    fmp_api_key = get_secret("fmp-api-key")

    if fmp_api_key:
        obb.user.credentials.fmp_api_key = fmp_api_key
        logger.debug(f"FMP API key set from environment")
    else:
        logger.warning("No FMP_API_KEY in environment, will try without authentication")


def _bb_yfinance_metrics_response(provider, symbol):
    logger.info(f"Fetching data from OpenBB for provider: {provider}, symbol: {symbol}")
    # Get fundamental metrics (P/E, etc.)
    logger.debug("Trying to get fundamental metrics...")
    try:
        results = []
        try:
            metrics_data = obb.equity.fundamental.metrics(
                symbol=symbol,
                period="annual", 
                limit=1,
                provider=provider
            )
            for item in metrics_data.results:
                filtered = {k: (str(v) if not isinstance(v, (int, float, bool, type(None))) else v) 
                        for k, v in item.__dict__.items() if True or k in needed_fields}
                results.append(filtered)
        except Exception as e:
            logger.warning(f"Error fetching metrics data: {e}")
        try:
            income_data = obb.equity.fundamental.income(
                symbol=symbol,
                period="annual", 
                limit=1,
                provider=provider
            )
            needed_fields = ["currency", "book_value", "dividend_yield", "dividend_yield_5y_avg", "revenue_per_share", "cash_per_share", "symbol", 
    "market_cap", "pe_ratio", "forward_pe", "eps_ttm", "price_to_book", "net_income", "revenue", "ebitda", "tangible_asset_value", "free_cash_flow_yield", 
    "weighted_average_basic_shares_outstanding", "weighted_average_diluted_shares_outstanding", "operating_cash_flow"]
            for item in income_data.results:
                filtered = {k: (str(v) if not isinstance(v, (int, float, bool, type(None))) else v) 
                        for k, v in item.__dict__.items() if True or k in ["net_income"]}
                results.append(filtered)
        except Exception as e:
            logger.warning(f"Error fetching metrics data: {e}")
        try:
            cash_data = obb.equity.fundamental.cash(
                symbol=symbol,
                period="annual", 
                limit=1,
                provider=provider
            )
            for item in cash_data.results:
                filtered = {k: (str(v) if not isinstance(v, (int, float, bool, type(None))) else v) 
                        for k, v in item.__dict__.items() if True or k in ["free_cash_flow"]}
                results.append(filtered)
        except Exception as e:
            logger.warning(f"Error fetching fundamental data: {e}")
        try:
            profile_data = obb.equity.profile(
                symbol=symbol,
                provider=provider
            )
            needed_fields = ['name', 'shares_outstanding', 'shares_float', 'shares_implied_outstanding', 'shares_short']
            for item in profile_data.results:
                filtered = {k: (str(v) if not isinstance(v, (int, float, bool, type(None))) else v) 
                        for k, v in item.__dict__.items() if True or k in needed_fields}
                results.append(filtered)
        except Exception as e:
            logger.warning(f"Error fetching profile data: {e}")
        logger.info("Metrics data fetched successfully!")
        
        if not results:
            return {}
        
        return reduce(lambda x, y: x | y, results, {})
    except Exception as e:
        logger.warning(f"Error fetching metrics data: {e}")
        return {}


if __name__ == "__main__":
    from dotenv import load_dotenv
    load_dotenv()

    ticker = "KHC"
    provider = "yfinance"
    fmp_api_key = os.getenv("FMP_API_KEY")
    intrinio_api_key = os.getenv("intrinio_api_key")
    obb.user.credentials.fmp_api_key = fmp_api_key
    obb.user.credentials.intrinio_api_key = intrinio_api_key
    stock_info_composed = _bb_yfinance_metrics_response(provider, ticker)
    
    print(json.dumps(stock_info_composed, indent=2))

    # with open("bb_khc_yfinance_data.json", "w") as f:
    #     json.dump(stock_info_composed1, f, indent=2)
