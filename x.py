"""
x.py - Utility functions and validation for X 

This module contains:
- Database connection
- Input validation (email, username, password, posts, files)
- Email sending
- Language/translation support
- Security helpers (no_cache decorator)
"""

# -------------------- IMPORTS --------------------
from flask import request, make_response, render_template
from functools import wraps
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import mysql.connector
import smtplib
import json
import re
import dictionary
import traceback
from icecream import ic
ic.configureOutput(prefix=f'----- | ', includeContext=True)


# -------------------- LANGUAGE CONFIGURATION --------------------
allowed_languages = ["english", "danish", "spanish"]
default_language = "english"
google_spread_sheet_key = "1uKk3qc3sQihW1VmnWle57LDaLJZYiygSsEmONfBTeO0"

def lans(key):
    """
    Load translation from dictionary.json

    """
    with open("dictionary.json", 'r', encoding='utf-8') as file:
        data = json.load(file)
    return data[key][default_language]


# -------------------- FILE UPLOAD CONFIGURATION --------------------
UPLOAD_ITEM_FOLDER = './images'

# Avatar uploads (profile pictures only)
ALLOWED_IMAGE_UPLOAD = {'png', 'jpg', 'jpeg', 'webp'}
MAX_IMAGE_UPLOAD_SIZE = 1 * 1024 * 1024  # 1 MB

# Post media (images + videos + gifs)
ALLOWED_POST_MEDIA = ALLOWED_IMAGE_UPLOAD | {'gif', 'mp4', 'mov'}
MAX_POST_MEDIA_SIZE = 30 * 1024 * 1024  # 30 MB

# Max image dimensions (like Instagram)
MAX_IMAGE_WIDTH = 1080
MAX_IMAGE_HEIGHT = 1080


# -------------------- DATABASE --------------------
def db():
    """
    Create database connection
    Returns:
        tuple: (database_connection, cursor)
    Raises:
        Exception: If connection fails
    """
    try:
        db = mysql.connector.connect(
            host="mariadb",
            user="root",  
            password="password",
            database="x"
        )
        cursor = db.cursor(dictionary=True)
        return db, cursor
    except Exception as e:
        print(e, flush=True)
        raise Exception("Twitter exception - Database under maintenance", 500)


# -------------------- SECURITY & HELPERS --------------------
def no_cache(view):
    """
    Decorator to prevent browser caching
    Used for pages that should always reload (login, profile, etc.)
    
    Usage:
        @app.get("/profile")
        @x.no_cache
        def profile():
            ...
    """
    @wraps(view)
    def no_cache_view(*args, **kwargs):
        response = make_response(view(*args, **kwargs))
        response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "0"
        return response
    return no_cache_view


def format_timestamp(timestamp):
    """
    Convert Unix timestamp to readable date format

    Example:
        1732829454 > "November 2023"
    """
    if not timestamp or timestamp == 0:
        return "Unknown"
    
    try:
        date = datetime.fromtimestamp(timestamp)
        return date.strftime("%B %Y")  # "November 2023"
    except:
        return "Unknown"

# -------------------- VALIDATION RULES --------------------
# Email
REGEX_EMAIL = "^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$"

# Username
USER_USERNAME_MIN = 2
USER_USERNAME_MAX = 20
REGEX_USER_USERNAME = f"^.{{{USER_USERNAME_MIN},{USER_USERNAME_MAX}}}$"

# First name
USER_FIRST_NAME_MIN = 2
USER_FIRST_NAME_MAX = 20
REGEX_USER_FIRST_NAME = f"^.{{{USER_FIRST_NAME_MIN},{USER_FIRST_NAME_MAX}}}$"

# Password
USER_PASSWORD_MIN = 6
USER_PASSWORD_MAX = 50
REGEX_USER_PASSWORD = f"^.{{{USER_PASSWORD_MIN},{USER_PASSWORD_MAX}}}$"

# Post
POST_MIN_LEN = 2
POST_MAX_LEN = 250
REGEX_POST = f"^.{{{POST_MIN_LEN},{POST_MAX_LEN}}}$"

# comment
COMMENT_MIN_LEN = 1
COMMENT_MAX_LEN = 200
REGEX_COMMENT = f"^.{{{COMMENT_MIN_LEN},{COMMENT_MAX_LEN}}}$"

# UUID patterns
REGEX_UUID4 = "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
REGEX_UUID4_WITHOUT_DASHES = "^[0-9a-f]{8}[0-9a-f]{4}4[0-9a-f]{3}[89ab][0-9a-f]{3}[0-9a-f]{12}$"

# -------------------- USER VALIDATION --------------------
# Email
def validate_user_email(lan="en"):
    """
    Validate email from form input
    """
    user_email = request.form.get("user_email", "").strip()
    if not re.match(REGEX_EMAIL, user_email): 
        raise Exception(dictionary.invalid_email[lan], 400)
    return user_email

# Username
def validate_user_username(lan="en"):
    """
    Validate username from form input
    """
    user_username = request.form.get("user_username", "").strip()
    error = f"username min {USER_USERNAME_MIN} max {USER_USERNAME_MAX} characters"
    if len(user_username) < USER_USERNAME_MIN: 
        raise Exception(error, 400)
    if len(user_username) > USER_USERNAME_MAX: 
        raise Exception(error, 400)
    return user_username

# Firs name
def validate_user_first_name(lan="en"):
    """
    Validate first name from form input
    """
    user_first_name = request.form.get("user_first_name", "").strip()
    error = f"first name min {USER_FIRST_NAME_MIN} max {USER_FIRST_NAME_MAX} characters"
    if not re.match(REGEX_USER_FIRST_NAME, user_first_name): 
        raise Exception(error, 400)
    return user_first_name

# password
def validate_user_password(lan="en"):
    """
    Validate password from form input
    """
    user_password = request.form.get("user_password", "").strip()
    if not re.match(REGEX_USER_PASSWORD, user_password): 
        raise Exception(dictionary.invalid_password[lan], 400)
    return user_password

# password confirm
def validate_user_password_confirm():
    """
    Validate password confirmation from form input
    """
    user_password = request.form.get("user_password_confirm", "").strip()
    if not re.match(REGEX_USER_PASSWORD, user_password): 
        raise Exception("Twitter exception - Invalid confirm password", 400)
    return user_password




# -------------------- POST VALIDATION --------------------
def validate_post(post="", allow_empty=False):
    """
    Validate post/tweet message
    """
    post = post.strip()
    
    # Allow empty if allow_empty=True (for posts with only media)
    if allow_empty and not post:
        return post
    
    # Validate length (min 2, max 250 characters)
    if not re.match(REGEX_POST, post): 
        raise Exception(f"Post must be between {POST_MIN_LEN} and {POST_MAX_LEN} characters", 400)
    
    return post


# -------------------- COMMENT VALIDATION --------------------
def validate_comment(comment_message="", lan="en"):
    """
    Validate comment message
    - tillader linjeskift
    - tjekker kun længde (1-200 tegn)
    """

    # Remove whitespace in both ends
    comment_message = comment_message.strip()

    # Validate length (min 1, max 200 characters)
    if not re.match(REGEX_COMMENT, comment_message): 
        raise Exception(f"Comment must be between {COMMENT_MIN_LEN} and {COMMENT_MAX_LEN} characters", 400)

    return comment_message


# -------------------- FILE UPLOAD VALIDATION --------------------
def validate_avatar_upload():
    """
    Validate avatar image upload
    """
    # Check if file exists in request
    if 'avatar' not in request.files:
        raise Exception("No file uploaded", 400)
    
    file = request.files['avatar']

    # Check if user selected a file
    if file.filename == '':
        raise Exception("No file selected", 400)
    
    # Check if file has extension
    if '.' not in file.filename:
        raise Exception("Invalid file - no extension", 400)
    
    # Get file extension (lowercase)
    file_extension = file.filename.rsplit('.', 1)[1].lower()

    # Check if file type is allowed
    if file_extension not in ALLOWED_IMAGE_UPLOAD:
        raise Exception(f"Invalid file type. Allowed: {', '.join(ALLOWED_IMAGE_UPLOAD)}", 400)
    
    # TODO: Add file size validation
    # file.seek(0, 2)
    # file_size = file.tell()
    # file.seek(0)
    # if file_size > MAX_IMAGE_UPLOAD_SIZE:
    #     raise Exception(f"File too large. Max: {MAX_IMAGE_UPLOAD_SIZE / (1024*1024)}MB", 400)
    
    return file, file_extension


def validate_post_media():
    """
    Validate post media upload (images and videos)
    - NO auto-resize (requires Pillow)
    - Only checks file type and size
    
    Returns:
        tuple: (file_object, file_extension) or (None, None) if no file
    Raises:
        Exception: If file is invalid (400)
    """
    # Check if file exists in request
    if 'post_media' not in request.files:
        return None, None
    
    file = request.files['post_media']
    
    # Check if user selected a file
    if file.filename == '':
        return None, None
    
    # Get file extension
    file_extension = file.filename.rsplit('.', 1)[1].lower() if '.' in file.filename else None
    
    # Validate extension
    if not file_extension or file_extension not in ALLOWED_POST_MEDIA:
        raise Exception(f"Invalid file type. Allowed: {', '.join(ALLOWED_POST_MEDIA)}", 400)
    
    # Check file size
    file.seek(0, 2)
    file_size = file.tell()
    file.seek(0)
    
    if file_size > MAX_POST_MEDIA_SIZE:
        raise Exception(f"File too large. Max: {MAX_POST_MEDIA_SIZE / (1024*1024):.0f}MB", 400)
    
    # Return file without any processing
    return file, file_extension


# -------------------- UUID VALIDATION --------------------
# Question: Hvorfor har vi både med og uden dashes?
def validate_uuid4(uuid4=""):
    """
    Validate UUID4 format (with dashes)
    
    Example: 550e8400-e29b-41d4-a716-446655440000
    """
    if not uuid4:
        uuid4 = request.values.get("uuid4", "").strip()
    if not re.match(REGEX_UUID4, uuid4): 
        raise Exception("Twitter exception - Invalid uuid4", 400)
    return uuid4


def validate_uuid4_without_dashes(uuid4=""):
    """
    Validate UUID4 format (without dashes)
    
    Example: 550e8400e29b41d4a716446655440000
    """
    error = "Invalid uuid4 without dashes"
    if not uuid4: 
        raise Exception(error, 400)
    uuid4 = uuid4.strip()
    if not re.match(REGEX_UUID4_WITHOUT_DASHES, uuid4): 
        raise Exception(error, 400)
    return uuid4


# -------------------- SEND EMAIL --------------------
def send_email(user_email, subject, template):
    """
    Send HTML email via Gmail SMTP
    
    Setup:
    1. Create Gmail account
    2. Enable 2-step verification
    3. Visit: https://myaccount.google.com/apppasswords
    4. Generate app password
    5. Update credentials below
    """
    try:
        # Gmail SMTP credentials
        sender_email = "webdevxclone@gmail.com"
        password = "hmpv qlnn rqzc ytrg"  # App password (not regular password)

        # Create email message
        message = MIMEMultipart()
        message["From"] = "X clone"
        message["To"] = user_email
        message["Subject"] = subject
        message.attach(MIMEText(template, "html"))

        # Send email via Gmail SMTP
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()  # Upgrade to secure connection
            server.login(sender_email, password)
            server.sendmail(sender_email, user_email, message.as_string())
        
        ic("Email sent successfully!")
        return "email sent"
    
    except Exception as ex:
        ic(ex)
        raise Exception("cannot send email", 500)