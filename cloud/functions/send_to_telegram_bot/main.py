from encodings import utf_8
import os

from firebase_utils import firebase_user_required
from flask_cors import cross_origin
import requests
from general_utils import cors_headers, exception_logger
from gcp_utils import get_secret


@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Authentication error in send_to_telegram_bot function", code=401)
@firebase_user_required
@exception_logger(log_message="Error in send_to_telegram_bot function")
def send_to_telegram_bot(request, user):
    """Google Cloud Function to send notifications via Telegram bot."""
    TOKEN = get_secret("colab-invest-telegram-token")

    data = request.json
    chat_id = data["chat_id"]
    text = data["message"]

    response = requests.post(f"https://api.telegram.org/bot{TOKEN}/sendMessage", json={
        "chat_id": chat_id,
        "text": f"{user['email']}:{user['uid']}: {text}"
    })

    return response.json(), response.status_code
