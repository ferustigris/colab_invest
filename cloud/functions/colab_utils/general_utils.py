
from datetime import datetime, timedelta
import os
from urllib.parse import urlparse

import requests


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


def cache(cache_hours=48):
    def decorator(func):
        def wrapper(request, user, *args, **kwargs):
            if request.method == "GET":
                # Implement caching logic here (e.g., check if response is cached)
                path = request.url.replace('http://', '').replace('https://', '').replace('/', '_')
                blob_name = f"cache_{path}_{user['uid']}.json"
                historizer_url = os.environ.get("HISTORIZER_URL")

                response = requests.get(f"{historizer_url}/{blob_name}", headers=request.headers)
                response.raise_for_status()
                data = response.json().get(f"data", {})
                data_last_update = response.json().get("lastUpdate", "1970-01-01T00:00:00Z")
                result = data

                if not is_valid_cache(data_last_update, cache_hours):
                    result = func(request, user, *args, **kwargs)
                    data_last_update = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")

                    response = requests.post(f"{historizer_url}/{blob_name}", headers=request.headers, json={
                        "data": result, "lastUpdate": data_last_update})
                    response.raise_for_status()
                return result
            else:
                return func(request, user, *args, **kwargs)
        return wrapper
    return decorator

def get_from_rest_or_cache(url, headers, user, cache_hours=48):
    """Fetch data from REST API with caching"""
    path = url.replace('http://', '').replace('https://', '').replace('/', '_')
    blob_name = f"cache_{path}_{user['uid']}.json"
    historizer_url = os.environ.get("HISTORIZER_URL")

    response = requests.get(f"{historizer_url}/{blob_name}", headers=headers)
    response.raise_for_status()
    data = response.json().get("data", {})
    data_last_update = response.json().get("lastUpdate", "1970-01-01T00:00:00Z")
    result = data

    if not is_valid_cache(data_last_update, cache_hours):
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        result = response.json()
    return result

def get_from_rest_or_cache_anonymous(url, headers, cache_hours=48):
    return get_from_rest_or_cache(url, headers, {'uid': 'anonymous'}, cache_hours)
