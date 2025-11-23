import os

from gcp_utils import get_json_from_blob, store_json_to_blob
from general_utils import cors_headers, exception_logger
from flask_cors import cross_origin
from pathlib import Path
from urllib.parse import urlparse



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
        resulting_history = store_json_to_blob(blob_name, bucket_name, request.get_json())
    else:
        resulting_history = get_json_from_blob(blob_name, bucket_name)
    return resulting_history, 200

