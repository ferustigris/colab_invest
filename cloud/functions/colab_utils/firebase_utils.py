import firebase_admin
from firebase_admin import auth, credentials


# Initialize Firebase Admin SDK (ensure this is only done once)
if not firebase_admin._apps:
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred)

def get_firebase_user(request):
    """Verify Firebase ID token and return user info (uid, email)"""
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Bearer '):
        return None
    id_token = auth_header.split('Bearer ')[1]
    try:
        decoded_token = auth.verify_id_token(id_token)
        return {
            "uid": decoded_token.get("uid"),
            "email": decoded_token.get("email")
        }
    except Exception:
        return None

def firebase_user_required(func):
    def wrapper(request, *args, **kwargs):
        user = get_firebase_user(request)
        if not user:
            return {"error": "Unauthorized"}, 401
        return func(request, user, *args, **kwargs)
    return wrapper

def firebase_user_or_anonim(func):
    def wrapper(request, *args, **kwargs):
        user = get_firebase_user(request) or {"uid": "anonymous", "email": None}
        return func(request, user, *args, **kwargs)
    return wrapper
