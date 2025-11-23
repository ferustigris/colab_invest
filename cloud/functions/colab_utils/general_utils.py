
from datetime import datetime, timedelta
import os
from urllib.parse import urlparse

import requests

from gcp_utils import get_json_from_blob, store_json_to_blob


def cors_headers(func):
    def wrapper(request, *args, **kwargs):
        if request.method == "OPTIONS":
            headers = {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization',
                'Access-Control-Max-Age': '3600'
            }
            return '', 204, headers
        return func(request, *args, **kwargs)
    return wrapper


def exception_logger(exception_class=Exception, log_message="An error occurred", code=500):
    def decorator(func):
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except exception_class as e:
                print(f'Error: {e}')
                print(log_message)
                return {log_message}, code
        return wrapper
    return decorator


def is_valid_cache(data_last_update, cache_hours=48):
    """
    Check if cached Yahoo data is still valid
    
    Args:
        yahoo_data_last_update: Last update timestamp string
        yahoo_data: Yahoo data object
        cache_hours: Cache validity period in hours (default 24)
    
    Returns:
        bool: True if cache is valid, False if needs refresh
    """
   
    try:
        data_last_update_dt = datetime.strptime(data_last_update, "%Y-%m-%dT%H:%M:%SZ")
        now = datetime.now()
        return now - data_last_update_dt <= timedelta(hours=cache_hours)
    except ValueError:
        # If date parsing fails, consider cache invalid
        return False


def cache(cache_hours=48, func_name=None):
    def decorator(func):
        def wrapper(request, user, *args, **kwargs):
            if request.method == "GET":
                # Implement caching logic here (e.g., check if response is cached)
                print(f"this is the request.url: {request.url}")
                print(f"this is the request.path: {request.path}")
                path = urlparse(request.url).path.replace('//', '/').replace('/', '_')
                if func_name and not path.startswith(f"_{func_name}"):
                    path = f"_{func_name}{path}"
                print(f"this is the path: {path}")

                blob_name = f"cache_{path}_{user['uid']}.json"
                bucket_name = os.environ.get("CHAT_HISTORY_BUCKET")

                response_json = get_json_from_blob(blob_name, bucket_name)
                data = response_json.get(f"data", {})
                data_last_update = response_json.get("lastUpdate", "1970-01-01T00:00:00Z")
                result = data

                if not is_valid_cache(data_last_update, cache_hours):
                    result = func(request, user, *args, **kwargs)
                    data_last_update = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")

                    store_json_to_blob(blob_name, bucket_name, {"data": result, "lastUpdate": data_last_update})
                return result
            else:
                return func(request, user, *args, **kwargs)
        return wrapper
    return decorator

def get_from_rest_or_cache(url, headers, user, cache_hours=48):
    """Fetch data from REST API with caching"""
    print(f"this is the request.url: {url}")
    path = urlparse(url).path.replace('//', '/').replace('/', '_')
    print(f"this is the path: {path}")
    blob_name = f"cache_{path}_{user['uid']}.json"
    bucket_name = os.environ.get("CHAT_HISTORY_BUCKET")

    response_json = get_json_from_blob(blob_name, bucket_name)

    data = response_json.get("data", {})
    data_last_update = response_json.get("lastUpdate", "1970-01-01T00:00:00Z")
    result = data

    if not is_valid_cache(data_last_update, cache_hours):
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        result = response.json()
    return result

def get_from_rest_or_cache_anonymous(url, headers, cache_hours=48):
    return get_from_rest_or_cache(url, headers, {'uid': 'anonymous'}, cache_hours)
