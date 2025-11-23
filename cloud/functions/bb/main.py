from functools import reduce
import json
import os
from general_utils import cache
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

@cors_headers
@cross_origin(methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in bb function", code=401)
@firebase_user_or_anonim
@cache(cache_hours=48)
@exception_logger(log_message="Error in bb function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in bb function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in bb function")
def bb(request, user):
    logger.debug("BB function called")

    now = datetime.now()
    now_timestamp = datetime.strftime(now, "%Y-%m-%dT%H:%M:%SZ")

    logger.info(f"bb called for user {user['uid']} at {now_timestamp}")

    path = urlparse(request.url).path
    logger.debug(f"this is the path: {path}, request.url: {request.url}")
    provider = os.path.basename(path)
    ticker = os.path.basename(os.path.dirname(path))

    logger.info(f"this is the ticker: {ticker}, provider: {provider}")

    _setup_fmp_credentials()
    result = _bb_yfinance_metrics_response(provider, ticker)
    logger.debug(f"Ticker info: {result}")

    result['lastUpdate'] = now_timestamp
    return result

def _setup_fmp_credentials():
    """Setup FMP API credentials if available in environment"""
    fmp_api_key = get_secret("fmp-api-key")
    polygon_api_key = get_secret("polygon-api-key")

    if polygon_api_key:
        obb.user.credentials.polygon_api_key = polygon_api_key
    else:
        logger.warning("No POLYGON_API_KEY in environment, will try without authentication")

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
                        for k, v in item.__dict__.items() if v is not None}
                results.append(filtered)
        except Exception as e:
            logger.warning(f"Error fetching metrics data: {e}")
        try:
            income_data = obb.equity.fundamental.income(
                symbol=symbol,
                period="annual", 
                limit=1,
                provider=provider if provider != "finviz" else "polygon"
            )
            for item in income_data.results:
                filtered = {k: (str(v) if not isinstance(v, (int, float, bool, type(None))) else v) 
                        for k, v in item.__dict__.items() if v is not None}
                results.append(filtered)
        except Exception as e:
            logger.warning(f"Error fetching metrics data: {e}")
        try:
            cash_data = obb.equity.fundamental.cash(
                symbol=symbol,
                period="annual", 
                limit=1,
                provider=provider if provider != "finviz" else "polygon"
            )
            for item in cash_data.results:
                filtered = {k: (str(v) if not isinstance(v, (int, float, bool, type(None))) else v) 
                        for k, v in item.__dict__.items() if v is not None}
                results.append(filtered)
        except Exception as e:
            logger.warning(f"Error fetching fundamental data: {e}")
        try:
            profile_data = obb.equity.profile(
                symbol=symbol,
                provider=provider
            )
            for item in profile_data.results:
                filtered = {k: (str(v) if not isinstance(v, (int, float, bool, type(None))) else v) 
                        for k, v in item.__dict__.items() if v is not None}
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
    provider = "finviz"
    fmp_api_key = os.getenv("FMP_API_KEY")
    intrinio_api_key = os.getenv("intrinio_api_key")
    obb.user.credentials.fmp_api_key = fmp_api_key
    obb.user.credentials.intrinio_api_key = intrinio_api_key
    obb.user.credentials.polygon_api_key = os.getenv("POLYGON_API_KEY")
    stock_info_composed = _bb_yfinance_metrics_response(provider, ticker)
    
    print(json.dumps(stock_info_composed, indent=2))

    # with open("bb_khc_yfinance_data.json", "w") as f:
    #     json.dump(stock_info_composed1, f, indent=2)
