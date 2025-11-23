import os
from google.cloud import secretmanager
from google.cloud import storage
import json

def get_project_id():
    return os.environ.get("GCLOUD_PROJECT_NUMBER")


def get_secret(secret_id):
    client = secretmanager.SecretManagerServiceClient()
    project_id = get_project_id()

    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(name=name)
    return response.payload.data.decode("UTF-8")


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

def get_json_from_blob(blob_name, bucket_name):
    # Get chat history
    print("Getting history from blob:", blob_name)
    current_chat_history = _read_text_from_gcs(bucket_name, blob_name)
    try:
        resulting_history = json.loads(current_chat_history) if current_chat_history else {}
    except json.JSONDecodeError:
        resulting_history = {}
    return resulting_history


def store_json_to_blob(blob_name, bucket_name, body):
    print("Storing history to blob:", blob_name)
    _write_text_to_gcs(bucket_name, blob_name, json.dumps(body))
    return body
