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

logger = logging.getLogger(__name__)

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
    logger.info(f"Processing ticker: {ticker}")
    details_from_sources = []

    yahoo_url = os.environ.get("YAHOO_URL")
    url = f"{yahoo_url}/{ticker}"
    bb_finviz_data = _fetch_data(url, request.headers)
    data = YahooData.from_yahoo_dict(bb_finviz_data)
    stock_details = _get_stock_details(ticker, data)
    details_from_sources.append(stock_details)

    logger.debug(f"Yahoo stock details: {stock_details.to_json()}")

    try:
        bb_yahoo_url = os.environ.get("BB_URL")
        url = f"{bb_yahoo_url}/{ticker}/yfinance"
        bb_finviz_data = _fetch_data(url, request.headers)
        data = YahooData.from_bb_yahoo_dict(bb_finviz_data)
        stock_details = _get_stock_details(ticker, data)
        details_from_sources.append(stock_details)

        logger.debug(f"BB Yahoo stock details: {stock_details.to_json()}")
    except Exception as e:
        logger.warning(f"Error fetching BB Yahoo data for ticker {ticker}: {e}")

    try:
        bb_finviz_url = os.environ.get("BB_URL")
        url = f"{bb_finviz_url}/{ticker}/finviz"
        bb_finviz_data = _fetch_data(url, request.headers)
        data = YahooData.from_bb_finviz_dict(bb_finviz_data)
        stock_details = _get_stock_details(ticker, data)
        details_from_sources.append(stock_details)

        logger.debug(f"BB Finviz stock details: {stock_details.to_json()}")
    except Exception as e:
        logger.warning(f"Error fetching BB finviz data for ticker {ticker}: {e}")

    try:
        bb_fmp_url = os.environ.get("BB_URL")
        url = f"{bb_fmp_url}/{ticker}/fmp"
        bb_finviz_data = _fetch_data(url, request.headers)
        data = YahooData.from_bb_fmp_dict(bb_finviz_data)
        stock_details = _get_stock_details(ticker, data)
        details_from_sources.append(stock_details)

        logger.debug(f"BB FMP stock details: {stock_details.to_json()}")
    except Exception as e:
        logger.warning(f"Error fetching BB FMP data for ticker {ticker}: {e}")

    return StockDetailsCompositor(ticker, details_from_sources).to_json()

def _fetch_data(url, headers):
    """Fetch Yahoo data for given ticker"""
    logger.debug(f"Fetching data from URL: {url}")
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def _get_stock_details(ticker, yahoo_data):
    # Create stock details instance and return JSON
    stock_details = StockDetails(ticker)

    stock_details.update_from_yahoo_data(yahoo_data)
    return stock_details


if __name__ == "__main__":
    # with open('func_yahoo_apple.json', 'r') as f:
    #     yahoo_json_data = json.load(f)["yahoo_data"]
    # stock_details_original = _get_stock_details("AAPL", yahoo_json_data)

    # with open('stock_details_apple.json', 'w') as f:
    #     f.write(json.dumps(stock_details_original.to_json(), indent=2))

    # Test loading from Yahoo dict
    # with open('func_yahoo_apple.json', 'r') as f:
    #     yahoo_data = YahooData.from_yahoo_dict(json.load(f)["yahoo_data"])

    # Test loading from BB Yahoo dict
    # with open('func_bb_yahoo_apple.json', 'r') as f:
    #     yahoo_data = YahooData.from_bb_yahoo_dict(json.load(f)["yahoo_data"])

    # Test loading from BB fmp dict
    with open('func_bb_fmp_apple.json', 'r') as f:
        fmp_data = YahooData.from_bb_fmp_dict(json.load(f)["fmp_data"])

    # Test loading from BB finviz dict
    with open('func_bb_finviz_apple.json', 'r') as f:
        finviz_data = YahooData.from_bb_finviz_dict(json.load(f)["finviz_data"])

    stock_details = _get_stock_details("AAPL", finviz_data)

    with open('stock_details_apple.json', 'r') as f:
        reference = json.load(f)
    
    logger.info("Comparing stock details with reference data...")
    stock_details_json = stock_details.to_json()
    logger.debug("Stock details JSON:")
    logger.debug(json.dumps(stock_details_json, indent=2))
    for key in reference:
        if key not in stock_details_json:
            logger.warning(f"Key '{key}' missing in stock details JSON")
            continue
        if stock_details_json[key] != reference[key]:
            logger.warning(f"Mismatch in key '{key}':")
            logger.warning(f"  Original: {stock_details_json[key]}")
            logger.warning(f"  Reference: {reference[key]}")
