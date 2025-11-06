from encodings import utf_8
import os

from firebase_utils import firebase_user_or_anonim
from general_utils import cors_headers, exception_logger
from google.cloud import secretmanager
from flask_cors import cross_origin
import requests
from google.cloud import storage
import json
from pathlib import Path
from urllib.parse import urlparse


def _write_text_to_gcs(bucket_name, blob_name, text):
    """Write a text object to Google Cloud Storage"""
    print("Writing to GCS:", bucket_name, blob_name)
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    blob.upload_from_string(text, content_type='text/plain')

def _read_text_from_gcs(bucket_name, blob_name):
    """Read a text object from Google Cloud Storage"""
    print("Reading from GCS:", bucket_name, blob_name)
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    try:
        return blob.download_as_text()
    except Exception:
        # Blob does not exist or other error
        return ""


@cors_headers
@cross_origin(allowed_methods=['POST', 'GET', 'OPTIONS'], origins='*')
@exception_logger(log_message="Error in history function")
def history(request):
    """Google Cloud Function to save/get history"""
    bucket_name = os.environ.get("CHAT_HISTORY_BUCKET")
    path = urlparse(request.url).path
    blob_name = Path(path).name
    print("this is the blob_name:", blob_name)

    if request.method == "POST":
        resulting_history = _store_history(blob_name, bucket_name, request.get_json())
    else:
        resulting_history = _get_history(blob_name, bucket_name)
    return resulting_history, 200


def _get_history(blob_name, bucket_name):
    # Get chat history
    print("Getting history from blob:", blob_name)
    current_chat_history = _read_text_from_gcs(bucket_name, blob_name)
    try:
        resulting_history = json.loads(current_chat_history) if current_chat_history else {}
    except json.JSONDecodeError:
        resulting_history = {}
    return resulting_history


def _store_history(blob_name, bucket_name, body):
    print("Storing history to blob:", blob_name)
    _write_text_to_gcs(bucket_name, blob_name, json.dumps(body))
    return body
