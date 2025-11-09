import os
from ai_utils import create_openai_payload, prepare_openai_context
from firebase_utils import firebase_user_required
from gcp_utils import get_secret
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
from datetime import datetime, timedelta
import requests

CONTEXT_LENGTH_MAX_INTERACTIONS = 10  # interaction is a user message with chatbot's response
CONTEXT_MAX_TIME_INTERVAL_HOURS = 24
GPT_MODEL = "gpt-5"
SYSTEM_PROMPT = """
You are a friendly and knowledgeable finance assistant helping users with their financial questions.

If user asks for overall company information/report/summary/analysis, Create a company description following strictly one sentence per bullet point:
- A brief description of the company business.
- The main source of revenue, expressed as a percentage of total profit.
- The average profit growth over the last 10 years, in percent.
- A list of advantages, disadvantages, and weak points.
- Whether there were share buybacks or share dilution, expressed as a percentage of market capitalization.
- The ratio of free cash flow to capitalization.
- The ratio long-term debt to capitalization.

Always be clear, helpful, and upbeat, using simple English and short messages.
  """


@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in sales_ask_chat function", code=401)
@firebase_user_required
@exception_logger(log_message="Error in sales_ask_chat function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in sales_ask_chat function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in sales_ask_chat function")
def ask_finance_assistent_chat(request, user):
    openai_api_key = get_secret("chatgpt-api-key")
    
    openai_api = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {openai_api_key}",
    }
    history = request.get_json().get("chat_history", [])

    # Use ai_utils to prepare context
    context = prepare_openai_context(
        history=history,
        max_interactions=CONTEXT_LENGTH_MAX_INTERACTIONS,
        max_time_interval_hours=CONTEXT_MAX_TIME_INTERVAL_HOURS
    )

    # Create OpenAI payload
    data = create_openai_payload(
        context=context,
        model=GPT_MODEL,
        system_prompt=SYSTEM_PROMPT
    )

    print(f"Sending request to OpenAI with {data['messages']} messages")
    response = requests.post(openai_api, headers=headers, json=data)
    response.raise_for_status()
    return response.json().get("choices", [])[0]["message"]['content']
