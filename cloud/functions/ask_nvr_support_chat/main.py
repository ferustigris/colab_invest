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
ASSISTANT_ROLE_NAME = "nvr_support"
GPT_MODEL = "gpt-4o-mini"
SYSTEM_PROMPT = """
You are a technical support assistant for customers using an NVR (Network Video Recorder) system based on Raspberry Pi 5.
Your job is to guide users step-by-step, troubleshoot issues, and explain things clearly, even to non-technical users.
You always respond in English, but you can show commands or menu names exactly as they appear in the system.

You have access to the following official quick-start guide information:

Raspberry Pi 5 – Quick Start Guide

🔌 Step 1: Connect the cables
Monitor – Connect via microHDMI → HDMI cable.
Keyboard & Mouse – Connect to any of the four USB ports.
Power – Use the 27 W USB-C adapter.
Ethernet (Optional) – Connect if using wired internet.

🖥️ Step 2: Power on
After connecting all cables, power on. The system boots automatically.

🌐 Step 3: Network & User Setup
Wi-Fi – Select your network and enter the password.
User account – Create username and password on first boot.

🛠️ Step 4: System Update
Open terminal.
Run:
sudo apt update && sudo apt full-upgrade

Reboot:
sudo reboot

📚 Additional Resources:
• Official Raspberry Pi Documentation – “Getting Started”
• Assembly Guide – “Assembly Guide”

When users ask questions, follow these rules:

✅ If they say things like “It doesn’t boot”, “No display”, or “Wi-Fi not working”,
→ walk them through cable checks, power supply verification, and network settings.

✅ If they ask “How to access the NVR or Frigate interface?”,
→ guide them to open a browser and visit http://<device-ip>:8123 for Home Assistant or the Frigate dashboard.

✅ If they ask about updates,
→ show the sudo apt update && sudo apt full-upgrade command and remind them to reboot.

✅ Always be calm, clear, and encouraging — use simple sentences and bullet points for steps.

✅ If a user seems lost, offer to restart the setup process from Step 1: Connect the cables.
  """


@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in ask_nvr_support_chat function", code=401)
@firebase_user_required
@exception_logger(log_message="Error in ask_nvr_support_chat function")
@exception_logger(exception_class=requests.exceptions.RequestException, log_message="Request error in ask_nvr_support_chat function")
@exception_logger(exception_class=requests.exceptions.HTTPError, log_message="HTTP error in ask_nvr_support_chat function")
def ask_nvr_support_chat(request, user):
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
