import os
from pathlib import Path
from urllib.parse import urlparse
from ai_utils import create_openai_payload, USER_ROLE_NAME, create_chat_history_entry
from firebase_utils import firebase_user_or_anonim
from general_utils import cache
from gcp_utils import get_secret
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
from datetime import datetime, timedelta
import requests

CONTEXT_LENGTH_MAX_INTERACTIONS = 10  # interaction is a user message with chatbot's response
CONTEXT_MAX_TIME_INTERVAL_HOURS = 24
ASSISTANT_ROLE_NAME = "nvr_support"
GPT_MODEL = "gpt-4.1-mini"
SYSTEM_PROMPT = """
You are looking for available finance metrics and stock information in internet.
You must return the response in the format of 2 number separated by "|": 
First number is relevant metric, the second number is your estimation of the quality of the data expressed in a number from 0 to 1. 

Example of the response: '0.25|0.8'
  """


@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@firebase_user_or_anonim
@cache(cache_hours=240, func_name="get_metric")
@exception_logger(log_message="Error in get_metric function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in get_metric function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in get_metric function")
def get_metric(request, user):
    openai_api_key = get_secret("chatgpt-api-key")
    
    openai_api = "https://api.openai.com/v1/chat/completions"
    ai_headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {openai_api_key}",
    }
    
    path = urlparse(request.url).path
    metric = os.path.basename(path)
    ticker = os.path.basename(os.path.dirname(path))
    
    print("this is the ticker:", ticker)
    print("this is the metric:", metric)

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

    return {
        "value": result,
        "rawData": raw_answer,
        "dataQuality": quality
    }
