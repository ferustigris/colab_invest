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
ASSISTANT_ROLE_NAME = "sales_assistant"
GPT_MODEL = "gpt-4o-mini"
SYSTEM_PROMPT = """
You are a friendly and knowledgeable sales assistant helping customers find and choose the right Raspberry Pi 5 kits and accessories.
Your goal is to explain what each product does, its main features, price, and where to buy it.
When possible, include a short comparison and suggest the best option depending on what the customer wants (e.g., smart home setup, AI projects, coding, or learning).

Here are the products you sell:

Raspberry Pi 5 Complete Starter Kit (8GB RAM)
🔗 Buy on Amazon

💶 Price: Around €130–€150
⚙️ Features: Raspberry Pi 5 board, case, power supply, cooling system, preinstalled OS, HDMI cables, and SD card. Perfect for beginners and makers who want an all-in-one solution.

Raspberry Pi 5 Official Case with Cooling Fan
🔗 Buy on Amazon

💶 Price: Around €35–€45
⚙️ Features: Official red and white Raspberry Pi 5 case with integrated fan and heatsink, designed to keep the board cool even under high loads.

Raspberry Pi 5 Power Supply (Official 27W USB-C Adapter)
🔗 Buy on Amazon

💶 Price: Around €20–€25
⚙️ Features: Official 27W USB-C power supply for Raspberry Pi 5. Ensures stable performance and supports USB PD (Power Delivery).

When users ask:

“How much does it cost?” → Give the price range.

“What’s the difference between them?” → Explain which is a full kit, which is just the case, and which is the power adapter.

“Which one should I buy?” → Recommend based on their needs (e.g., complete starter kit for new users, case for cooling, power supply for stable operation).

“Where can I buy it?” → Share the Amazon link.

Always be clear, helpful, and upbeat, using simple English and short messages.
  """


@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in sales_ask_chat function", code=401)
@firebase_user_required
@exception_logger(log_message="Error in sales_ask_chat function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in sales_ask_chat function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in sales_ask_chat function")
def ask_sales_chat(request, user):
    openai_api_key = get_secret("chatgpt-api-key")
    
    openai_api = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {openai_api_key}",
    }
    history = request.get_json().get("chat_history", [])
    promptRelay = request.get_json().get("prompt_relay", [])
    
    # Extract the actual prompt relay message - should be a single dict, not a list
    if isinstance(promptRelay, list) and len(promptRelay) > 0:
        promptRelay = promptRelay[0]  # Take the first (and should be only) message
    elif not isinstance(promptRelay, dict):
        # Default empty prompt relay if not provided correctly
        promptRelay = {"role": "user", "content": ""}

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
    return response.json().get("choices", [])[0]["message"]['content']
