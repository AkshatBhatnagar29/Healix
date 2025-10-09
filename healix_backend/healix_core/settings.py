from pathlib import Path
import os
from dotenv import load_dotenv

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# Load Environment Variables from the .env file in your project root
load_dotenv(os.path.join(BASE_DIR, '.env'))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv('SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True
# healix_core/settings.py

ALLOWED_HOSTS = ['127.0.0.1', '10.0.2.2','192.168.185.226','172.16.216.107']


# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Third-party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    # Your apps
    'api',
]

# ... (Middleware, ROOT_URLCONF, TEMPLATES remain the same) ...
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
ROOT_URLCONF = 'healix_core.urls'
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]
WSGI_APPLICATION = 'healix_core.wsgi.application'


# --- DATABASE CONFIGURATION FOR POSTGRESQL ---
# This block tells Django how to connect to your PostgreSQL server
# using the credentials stored securely in your .env file.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME'),
        'USER': os.getenv('DB_USER'),
        'PASSWORD': os.getenv('DB_PASSWORD'),
        'HOST': os.getenv('DB_HOST'),
        'PORT': os.getenv('DB_PORT'),
    }
}
# --- END OF DATABASE CONFIGURATION ---


# Point to your custom User model
AUTH_USER_MODEL = 'api.User'

# ... (REST_FRAMEWORK, EMAIL, and other settings remain the same) ...
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    )
}
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp-relay.brevo.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = os.getenv('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = os.getenv('EMAIL_HOST_PASSWORD')
# healix_core/settings.py
# ...
DEFAULT_FROM_EMAIL = os.getenv('EMAIL_HOST_USER')

# Password validation
AUTH_PASSWORD_VALIDATORS = [ ... ] # Default validators
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True
STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
CORS_ALLOW_ALL_ORIGINS = True
# ### Why is `db.sqlite3` in the `.gitignore` file?

# This is an excellent question. The `.gitignore` file you have is a standard template for Django projects. It includes `db.sqlite3` as a preventative measure.

# Even though your project is configured for PostgreSQL, if you ever ran a command like `python manage.py migrate` *before* your PostgreSQL settings were perfectly configured, Django would have created a `db.sqlite3` file by default as a fallback.

# Including it in `.gitignore` simply ensures that this temporary, local-only database file is **never accidentally committed** to your GitHub repository. It's a best practice that keeps your repository clean, regardless of which database you are using for development or production.

# ### How to Make it Work: A Clear Checklist

# 1.  **Install the PostgreSQL Driver:** Make sure your Python environment has the necessary package to talk to PostgreSQL.
#     ```bash
#     pip install psycopg2-binary
#     ```
# 2.  **Fill in `.env`:** Ensure your `.env` file in the project root has the correct credentials for your PostgreSQL server.
#     ```ini
#     # .env file
#     DB_NAME='healix_db'
#     DB_USER='your_postgres_user'
#     DB_PASSWORD='your_postgres_password'
#     DB_HOST='localhost'
#     DB_PORT='5432'
#     ```
# 3.  **Update `settings.py`:** Replace the entire contents of your `healix_core/settings.py` with the corrected code provided above.
# 4.  **Run Migrations:** Now, you can apply your table schema to the PostgreSQL database.
#     ```bash
#     python manage.py makemigrations
#     python manage.py migrate
    

