from datetime import datetime
from encodings import utf_8
import os

from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
import requests

@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Error in telegram_bot_handler function")
def telegram_bot_handler(request):
    """Google Cloud Function to receive incoming messages from Telegram bot."""
    historizer_url = os.environ.get("HISTORIZER_URL")

    data = request.json
    message = data.get("message")
    
    if not message:
        return {"error": "No message found"}, 400
    
    chat_id = message["chat"]["id"]
    text = message.get("text", "")
    from_user = message.get("from", {})
    user_name = from_user.get("first_name", "Unknown")
    is_bot = from_user.get("is_bot", False)

    if is_bot:
        return {"ok": True, "message": "Bot message received and ignored"}, 204

    # Check if message is a reply
    reply_to_message = message.get("reply_to_message")
    
    if reply_to_message:
        # This is a reply to a message
        reply_text = reply_to_message.get("text", "")
        reply_from = reply_to_message.get("from", {})
        reply_is_bot = reply_from.get("is_bot", False)
        
        if reply_is_bot and ":" in reply_text:
            # Bot text contains username in format "user: message"
            original_user = reply_text.split(":")[1].strip()
            print(f"Reply from {user_name} to {original_user}: {text}")

            historizer_headers = {
                "Content-Type": "application/json"
            }
            response = requests.get(f"{historizer_url}/chat_history.{original_user}.json", headers=historizer_headers)
            response.raise_for_status()
            history = response.json().get("chat_history", [])

            history.append({
                "role": "assistant",
                "content": text,
                "timestamp": datetime.strftime(datetime.now(), "%Y-%m-%d %H:%M:%S.%f")
            })
            print(f"Storing updated history with {history} items")
            response = requests.post(f"{historizer_url}/chat_history.{original_user}.json", headers=historizer_headers, json={"chat_history": history})
            response.raise_for_status()

            return {"ok": True, "message": "Reply processed"}, 200
 
    return {"ok": True, "message": "Instruction sent"}, 202
