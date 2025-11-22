import json
import logging
from stock_details_compositor import StockDetailsCompositor
from yahoo_data import YahooData
from firebase_utils import firebase_user_or_anonim
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
import requests
from pathlib import Path
from urllib.parse import urlparse
from stock_details import StockDetails
import os

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


def _get_stock_details(ticker):
    logger.info(f"Processing ticker: {ticker}")
    details_from_sources = []

    yahoo_url = os.environ.get("YAHOO_URL")
    url = f"{yahoo_url}/{ticker}"
    bb_provider_specific_data = _fetch_provider_specific_data(url, {})
    unified_data = YahooData.from_dict(bb_provider_specific_data, provider='yfinance')
    stock_details = StockDetails(ticker, unified_data)
    details_from_sources.append(stock_details)

    logger.debug(f"Yahoo stock details: {stock_details.to_json()}")
    
    for provider in ['yfinance', 'finviz', 'fmp']:
        try:
            bb_yahoo_url = os.environ.get("BB_URL")
            url = f"{bb_yahoo_url}/{ticker}/{provider}"
            bb_provider_specific_data = _fetch_provider_specific_data(url, {})
            unified_data = YahooData.from_dict(bb_provider_specific_data, provider=f"bb_{provider}")
            stock_details = StockDetails(ticker, unified_data)
            details_from_sources.append(stock_details)

            logger.debug(f"BB {provider} stock details: {json.dumps(stock_details.to_json(), indent=2)}")
        except Exception as e:
            logger.warning(f"Error fetching BB {provider} data for ticker {ticker}: {e}")

    stock_info_composed = StockDetailsCompositor(ticker, details_from_sources, unified_data)
    stock_info_composed.update_from_yahoo_data()
    return stock_info_composed

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
    logger.info(f"Processing ticket_details for {ticker}")
    stock_info_composed = _get_stock_details(ticker)

    return stock_info_composed.to_json()

def _fetch_provider_specific_data(url, headers):
    """Fetch Yahoo data for given ticker"""
    logger.debug(f"Fetching data from URL: {url}")
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    logger.debug(f"Received response : {json.dumps(response.json(), indent=2)}")
    return response.json()


if __name__ == "__main__":
    from dotenv import load_dotenv
    load_dotenv()

    ticker = "AAPL"

    stock_info_composed = _get_stock_details(ticker)

    print(json.dumps(stock_info_composed.to_json(), indent=2))

