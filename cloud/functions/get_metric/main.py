import os
from pathlib import Path
from urllib.parse import urlparse
from ai_utils import create_openai_payload, USER_ROLE_NAME, create_chat_history_entry
from gcp_utils import get_secret
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
from datetime import datetime, timedelta
import requests

CONTEXT_LENGTH_MAX_INTERACTIONS = 10  # interaction is a user message with chatbot's response
CONTEXT_MAX_TIME_INTERVAL_HOURS = 24
ASSISTANT_ROLE_NAME = "nvr_support"
GPT_MODEL = "gpt-4.1-nano"
SYSTEM_PROMPT = """
You are looking for available finance metrics and stock information in internet.
You must return the response in the format of 2 number separated by "|": 
First number is relevant metric, the second number is your estimation of the quality of the data expressed in a number from 0 to 1. 

Example of the response: '0.25|0.8'
  """


def is_valid_cache(last_update, data, quality, cache_hours=240):
    """
    Check if cached Yahoo data is still valid
    
    Args:
        last_update: Last update timestamp string
        data: data object
        cache_hours: Cache validity period in hours (default 24)
    
    Returns:
        bool: True if cache is valid, False if needs refresh
    """
    print(f"Validating cache with last_update: {last_update} and data: {data}")
    if not last_update or not data or not quality or float(quality) < 0.4:
        return False
    
    try:
        value = int(data)
        print(f"Cached data value: {value}")
        yahoo_data_last_update_dt = datetime.strptime(last_update, "%Y-%m-%dT%H:%M:%SZ")
        now = datetime.now()
        return now - yahoo_data_last_update_dt <= timedelta(hours=cache_hours)
    except (ValueError, TypeError) as e:
        # If int conversion or date parsing fails, consider cache invalid
        print(f"Cache validation failed: {e}")
        return False


@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Error in get_metric function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in get_metric function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in get_metric function")
def get_metric(request):
    openai_api_key = get_secret("chatgpt-api-key")
    
    openai_api = "https://api.openai.com/v1/chat/completions"
    ai_headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {openai_api_key}",
    }
    history_headers = {
        "Content-Type": "application/json"
    }
    
    path = urlparse(request.url).path
    metric = os.path.basename(path)
    ticker = os.path.basename(os.path.dirname(path))
    
    print("this is the ticker:", ticker)
    print("this is the metric:", metric)

    historizer_url = os.environ.get("HISTORIZER_URL")

    now = datetime.now()
    now_timestamp = datetime.strftime(now, "%Y-%m-%dT%H:%M:%SZ")

    blob_name = f"{ticker}_{metric}_ai_data.json"
    response = requests.get(f"{historizer_url}/{blob_name}", headers=history_headers)
    response.raise_for_status()
    result = response.json().get("value", 0)
    quality = response.json().get("dataQuality", 0)
    last_update = response.json().get("lastUpdate", None)
    raw_answer = response.json().get("rawData", "No data")

    if not is_valid_cache(last_update, result, quality):
        print(f"Cache invalid or expired, fetching fresh data for ticker {ticker}")

        prompt = "Provide me " + metric + " for company with ticker " + ticker
        print("this is the prompt:", prompt)

        # Use ai_utils to prepare context
        context = create_chat_history_entry(
            role=USER_ROLE_NAME,
            content=prompt,
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
        )

        # Create OpenAI payload
        ai_context_data = create_openai_payload(
            context=[context],
            model=GPT_MODEL,
            system_prompt=SYSTEM_PROMPT
        )

        print(f"Sending request to OpenAI with {ai_context_data['messages']} messages")
        response = requests.post(openai_api, headers=ai_headers, json=ai_context_data)
        response.raise_for_status()

        raw_answer = response.json().get("choices", [])[0]["message"]['content']
        print("this is the raw answer:", raw_answer)
        try:
            result, quality = raw_answer.split("|")
            result = float(result)
            quality = float(quality)
        except ValueError:
            print(f"Failed to parse AI response: {raw_answer}")
            result, quality = 0, 0.0
    
        print(f"Saving cache for ticker {ticker} and metric {metric} : {result}")
        response = requests.post(f"{historizer_url}/{blob_name}", headers=history_headers, json={
            "value": result, "dataQuality": quality, "lastUpdate": now_timestamp})
        response.raise_for_status()

    return {
        "value": result,
        "rawData": raw_answer,
        "dataQuality": quality
    }
