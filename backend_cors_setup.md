# Django Backend CORS Setup Guide

To fix CORS issues properly, configure your Django backend:

## Option 1: Install django-cors-headers (Recommended)

1. Install the package:
```bash
pip install django-cors-headers
```

2. Add to INSTALLED_APPS in settings.py:
```python
INSTALLED_APPS = [
    ...
    'corsheaders',
    ...
]
```

3. Add middleware (must be at the top):
```python
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Add this first!
    'django.middleware.common.CommonMiddleware',
    ...
]
```

4. Configure allowed origins in settings.py:
```python
# Allow all origins (development only)
CORS_ALLOW_ALL_ORIGINS = True

# OR specify allowed origins (production)
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8000",
    "https://your-flutter-web-domain.com",
]

# Allow credentials (cookies, authorization headers)
CORS_ALLOW_CREDENTIALS = True

# Allowed headers
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'x-session-key',  # Your custom header
]
```

## Option 2: Manual CORS Middleware

Add this to your Django project:

```python
# cors_middleware.py
class CORSMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        response['Access-Control-Allow-Origin'] = '*'
        response['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
        response['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Session-Key'
        return response
```

Add to MIDDLEWARE in settings.py:
```python
MIDDLEWARE = [
    'your_app.cors_middleware.CORSMiddleware',
    ...
]
```

## For Dev Tunnels (devtunnels.ms)

If using VS Code Dev Tunnels, you may need to configure the tunnel settings to allow CORS headers.
