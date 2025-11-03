
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
