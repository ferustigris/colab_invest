import os
from firebase_utils import firebase_user_required
from gcp_utils import get_secret
from general_utils import cors_headers, exception_logger
from ai_utils import prepare_openai_context, create_openai_payload, create_chat_history_entry
from flask_cors import cross_origin
from datetime import datetime, timedelta
import requests

CONTEXT_LENGTH_MAX_INTERACTIONS = 10  # interaction is a user message with chatbot's response
CONTEXT_MAX_TIME_INTERVAL_HOURS = 24
ASSISTANT_ROLE_NAME = "assistant"
USER_ROLE_NAME = "user"
GPT_MODEL = "gpt-4o-mini"
SYSTEM_PROMPT = """
  You should classify user request into 4 categories: 
  - Sales assistant (e.g., product inquiries, pricing), 
  - NVR support (e.g., how-to questions), 
  - Human support (when a human agent is required),
  - other (what you cannot classify).
  Your response is only one word: "Sales assistant", "NVR support", "Human support", or "other".
  """


"""
history data structure:

[
  {
    "role": "user"|"assistant",
    "content": "content text",
    "timestamp": "%Y-%m-%d %H:%M:%S.%f"
  }
]

"""


@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in ask_chat function", code=401)
@firebase_user_required
@exception_logger(log_message="Error in ask_chat function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in ask_chat function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in ask_chat function")
def ask_chat(request, user):
    openai_api_key = get_secret("chatgpt-api-key")
    
    openai_api = "https://api.openai.com/v1/chat/completions"
    historizer_url = os.environ.get("HISTORIZER_URL")
    SALES_BOT_URL = os.environ.get("SALES_BOT_URL")
    NVR_SUPPORT_URL = os.environ.get("NVR_SUPPORT_URL")
    HUMAN_SUPPORT_URL = os.environ.get("HUMAN_SUPPORT_URL")
    TELEGRAM_CHAT_ID = os.environ.get("TELEGRAM_CHAT_ID")

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {openai_api_key}",
    }
    body = request.get_json()
    messages = body['messages']
    message = messages[-2:][0]
    promptRelay = messages[-1:][0]  # IMPORTANT! See the call in frontend code

    now = datetime.now()
    now_timestamp = datetime.strftime(now, "%Y-%m-%d %H:%M:%S.%f")
    message["timestamp"] = now_timestamp


    print(f"ask_chat called for user {user['uid']} at {now_timestamp}")
    historizer_headers = {
        "uid": user["uid"]
    }
    response = requests.get(historizer_url, headers=historizer_headers)
    response.raise_for_status()
    history = response.json().get("chat_history", [])   
    history.append(message)

    print(f"Retrieved history with {len(history)} items with promptRelay: {promptRelay}")
    
    # Use ai_utils to prepare context
    context = prepare_openai_context(
        history=history,
        prompt_relay=promptRelay,
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
    request_class = response.json().get("choices", [])[0]["message"]['content']
    
    bot_response = "I'm sorry, but I cannot assist with that request. Do you want me to connect you to a human?"  # default

    match request_class:
        case "Sales assistant":
            print("Classified as sales")
            response = requests.post(SALES_BOT_URL, headers=request.headers, json={"chat_history": history, "prompt_relay": promptRelay})
            response.raise_for_status()
            bot_response = response.text
        case "NVR support":
            print("Classified as NVR support")
            response = requests.post(NVR_SUPPORT_URL, headers=request.headers, json={"chat_history": history, "prompt_relay": promptRelay})
            response.raise_for_status()
            bot_response = response.text
        case "Human support":
            print("Classified as Human support")
            data = {"chat_history": history, "prompt_relay": promptRelay, "chat_id": TELEGRAM_CHAT_ID, "message": message["content"]}
            response = requests.post(HUMAN_SUPPORT_URL, headers=request.headers, json=data)
            response.raise_for_status()
            bot_response = response.text
        case "other":
            print("Classified as other")
            bot_response = "I'm sorry, but I cannot assist with that request. Do you want me to connect you to a human?"
        case _:  # default case
            print(f"Unknown classification: {request_class}")
            bot_response = "I'm sorry, but I cannot assist with that request. Do you want me to connect you to a human?"

    # Add assistant response to history using ai_utils
    assistant_entry = create_chat_history_entry(
        role=ASSISTANT_ROLE_NAME,
        content=bot_response
    )
    history.append(assistant_entry)

    print(f"Storing updated history with {history} items")
    response = requests.post(historizer_url, headers=historizer_headers, json={"chat_history": history})
    response.raise_for_status()

    return bot_response
