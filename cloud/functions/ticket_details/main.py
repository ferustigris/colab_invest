import json
from yahoo_data import YahooData
from firebase_utils import firebase_user_or_anonim
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
import requests
from pathlib import Path
from urllib.parse import urlparse
from stock_details import StockDetails
import os

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
    yahoo_url = os.environ.get("YAHOO_URL")

    path = urlparse(request.url).path
    ticker = Path(path).name
    print("this is the ticker:", ticker)

    response = requests.get(f"{yahoo_url}/{ticker}", headers=request.headers)
    response.raise_for_status()
    yahoo_data = response.json()

    stock_details = _get_stock_details(ticker, yahoo_data)    
    return stock_details.to_json()

def _get_stock_details(ticker, yahoo_data):
    # Create stock details instance and return JSON
    stock_details = StockDetails(ticker)

    stock_details.update_from_yahoo_data(yahoo_data)
    return stock_details


if __name__ == "__main__":
    from dotenv import load_dotenv
    load_dotenv()
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

    stock_details = _get_stock_details("AAPL", fmp_data)

    with open('stock_details_apple.json', 'r') as f:
        reference = json.load(f)
    
    print("Comparing stock details with reference data...")
    stock_details_json = stock_details.to_json()
    print("printing stock details json:")
    print(json.dumps(stock_details_json, indent=2))
    for key in reference:
        if key not in stock_details_json:
            print(f"Key '{key}' missing in stock details JSON")
            continue
        if stock_details_json[key] != reference[key]:
            print(f"Mismatch in key '{key}':")
            print(f"  Original: {stock_details_json[key]}")
            print(f"  Reference: {reference[key]}")
