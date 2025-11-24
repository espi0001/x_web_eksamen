from flask import Flask, render_template, request, session, redirect, url_for, jsonify, g, send_from_directory
from flask_session import Session
from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash
import x 
import time
import uuid
import os
import requests
import io
import csv
import json
import dictionary

from icecream import ic
ic.configureOutput(prefix=f'----- | ', includeContext=True)

app = Flask(__name__)

# Set the maximum file size to 1 MB
app.config['MAX_CONTENT_LENGTH'] = 1 * 1024 * 1024   # 1 MB

app.config['SESSION_TYPE'] = 'filesystem'
Session(app)

##############################
# Load logged-in user before each request
# Runs automatically before every route
@app.before_request
def load_logged_in_user():
    # Initialize g.user as None
    g.user = None
    
    # Get user_pk from session (stored during login)
    user_pk = session.get("user_pk")
    
    # If no user_pk in session, user is not logged in
    if not user_pk:
        return
    
    # Fetch user from database
    try:
        db, cursor = x.db()
        cursor.execute("SELECT * FROM users WHERE user_pk = %s", (user_pk,))
        user = cursor.fetchone()
        
        if user:
            # Remove password for security (never expose in g.user)
            user.pop("user_password", None)
            
            # Add language preference from session
            user["user_language"] = session.get("lan", "english")
            
            # Store user in Flask global g object
            # Now available in all routes and templates as g.user
            g.user = user
    finally:
        # Always close database connections
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
# Context processor - makes variables available in ALL templates
# You don't need to pass these variables manually to each render_template()
@app.context_processor
def global_variables():
    # Get language from user or default to english
    lan = g.user.get("user_language", "english") if g.user else "english"
    
    # Return dictionary of global template variables
    return dict(
        lan=lan,        # Language for current user
        user=g.user,    # Current logged-in user (or None)
        x=x,             # x.py module (for constants, validation regex, etc.)
        lans=x.lans,
        dictionary=dictionary
    )

##############################
##############################
##############################
def _____USER_____(): pass 
##############################
##############################
##############################

@app.get("/")
def view_index():
    return render_template("index.html")

##############################
# Serve images from images folder
# Required for avatar images to display
@app.route('/images/<path:filename>')
def serve_image(filename):
    """
    Serves images from the images folder
    Example: /images/abc123_1732447200.jpg
    """
    return send_from_directory('images', filename)

##############################
@app.route("/login", methods=["GET", "POST"])
@app.route("/login/<lan>", methods=["GET", "POST"])
@x.no_cache
def login(lan = "english"):
    # Validate language parameter
    if lan not in x.allowed_languages: 
        lan = "english"
    
    # Set default language in x module
    x.default_language = lan

    if request.method == "GET":
        # If user already logged in, redirect to home
        if g.user: 
            return redirect(url_for("home"))
        
        return render_template("login.html", lan=lan)

    if request.method == "POST":
        try:
            # Validate user input
            user_email = x.validate_user_email(lan)
            user_password = x.validate_user_password(lan)
            
            # Query database for user
            q = "SELECT * FROM users WHERE user_email = %s"
            db, cursor = x.db()
            cursor.execute(q, (user_email,))
            user = cursor.fetchone()
            
            # Check if user exists
            if not user: 
                raise Exception(x.lans("user_not_found", lan), 400)

            # Verify password hash
            if not check_password_hash(user["user_password"], user_password):
                raise Exception(x.lans("invalid_credentials", lan), 400)

            # Check if user has verified email
            if user["user_verification_key"] != "":
                raise Exception(x.lans("user_not_verified", lan), 400)

            # Store only user_pk in session (not entire user object)
            # This is more secure and efficient
            session["user_pk"] = user["user_pk"]
            session["lan"] = lan
            
            # Redirect to home page
            return f"""<browser mix-redirect="/home"></browser>"""

        except Exception as ex:
            ic(ex)

            # User errors (validation, wrong password, etc.)
            if len(ex.args) > 1 and ex.args[1] == 400:
                toast_error = render_template("___toast_error.html", message=ex.args[0])
                return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400

            # System or developer error (database down, etc.)
            toast_error = render_template("___toast_error.html", message=x.lans("system_maintenance", lan))
            return f"""<browser mix-bottom="#toast">{ toast_error }</browser>""", 500
        
        finally:
            if "cursor" in locals(): cursor.close()
            if "db" in locals(): db.close()

##############################
@app.route("/signup", methods=["GET", "POST"])
@app.route("/signup/<lan>", methods=["GET", "POST"])
def signup(lan = "english"):
    # Validate language parameter
    if lan not in x.allowed_languages: 
        lan = "english"

    if request.method == "GET":
        x.default_language = lan
        return render_template("signup.html", lan=lan)

    if request.method == "POST":
        try:
            # Validate all user inputs
            user_email = x.validate_user_email(lan)
            user_password = x.validate_user_password(lan)
            user_username = x.validate_user_username(lan)
            user_first_name = x.validate_user_first_name(lan)

            # Generate unique user ID
            user_pk = uuid.uuid4().hex
            
            # Set default values for new user
            user_last_name = ""
            user_avatar_path = "https://avatar.iran.liara.run/public/40"
            user_verification_key = uuid.uuid4().hex
            user_birthday = 0
            user_verified_at = 0
            user_bio = ""
            user_total_follows = 0
            user_total_followers = 0
            user_admin = 0
            user_is_blocked = 0
            user_password_reset = 0
            created_at = int(time.time())
            updated_at = 0
            deleted_at = 0

            # Hash password before storing (NEVER store plain text passwords!)
            user_hashed_password = generate_password_hash(user_password)

            # Connect to the database
            q = "INSERT INTO users VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            db, cursor = x.db()
            cursor.execute(q, (user_pk, user_email, user_hashed_password, user_username, 
            user_first_name, user_last_name, user_birthday, user_avatar_path, user_verification_key, user_verified_at, user_bio, user_total_follows, user_total_followers, user_admin, user_is_blocked, user_password_reset, created_at, updated_at, deleted_at))
            db.commit()

            # Send verification email
            email_verify_account = render_template("_email_verify_account.html", 
                                                   user_verification_key=user_verification_key)
            ic(email_verify_account)

            x.send_email(user_email=user_email, subject="Verify your account", template=email_verify_account)

            # Uncomment when email is configured:
            # x.send_email(user_email, "Verify your account", email_verify_account)


            # Redirect to login page
            return f"""<mixhtml mix-redirect="{ url_for('login', lan=lan) }"></mixhtml>""", 200
            
        except Exception as ex:
            ic(ex)
            
            # User validation errors
            if len(ex.args) > 1 and ex.args[1] == 400:
                toast_error = render_template("___toast_error.html", message=ex.args[0])
                return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
            
            # Database duplicate entry errors
            if "Duplicate entry" in str(ex) and user_email in str(ex): 
                toast_error = render_template("___toast_error.html", 
                                            message=x.lans("email_already_registered", lan))
                return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
            
            if "Duplicate entry" in str(ex) and user_username in str(ex): 
                toast_error = render_template("___toast_error.html", 
                                            message=x.lans("username_already_registered", lan))
                return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
            
            # System or developer error
            toast_error = render_template("___toast_error.html", message="System under maintenance")
            return f"""<mixhtml mix-bottom="#toast">{ toast_error }</mixhtml>""", 500

        finally:
            if "cursor" in locals(): cursor.close()
            if "db" in locals(): db.close()

##############################
@app.get("/home")
@x.no_cache
def home():
    try:
        # Check if user is logged in (g.user set by @app.before_request)
        if not g.user: 
            return redirect(url_for("login"))
        
        db, cursor = x.db()
        
        # Get random posts with user data (JOIN)
        q = "SELECT * FROM users JOIN posts ON user_pk = post_user_fk ORDER BY RAND() LIMIT 5"
        cursor.execute(q)
        tweets = cursor.fetchall()
        ic(tweets)

        # Get random trends
        q = "SELECT * FROM trends ORDER BY RAND() LIMIT 3"
        cursor.execute(q)
        trends = cursor.fetchall()
        ic(trends)

        # Get user suggestions (exclude current user)
        q = "SELECT * FROM users WHERE user_pk != %s ORDER BY RAND() LIMIT 3"
        cursor.execute(q, (g.user["user_pk"],))
        suggestions = cursor.fetchall()
        ic(suggestions)


        return render_template("home.html", tweets=tweets, trends=trends, suggestions=suggestions)
        
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.route("/verify-account", methods=["GET"])
def verify_account():
    try:
        # Get verification key from URL parameter
        user_verification_key = x.validate_uuid4_without_dashes(request.args.get("key", ""))
        user_verified_at = int(time.time())
        
        # Update user verification status
        db, cursor = x.db()
        q = "UPDATE users SET user_verification_key = '', user_verified_at = %s WHERE user_verification_key = %s"
        cursor.execute(q, (user_verified_at, user_verification_key))
        db.commit()
        
        # Check if exactly one row was updated
        if cursor.rowcount != 1: 
            raise Exception("Invalid key", 400)
        
        return redirect(url_for('login'))
        
    except Exception as ex:
        ic(ex)
        if "db" in locals(): db.rollback()
        
        # User error (invalid key)
        if len(ex.args) > 1 and ex.args[1] == 400: 
            return ex.args[0], 400    

        # System error
        return "Cannot verify user"

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.get("/logout")
def logout():
    try:
        # Clear all session data
        session.clear()
        return redirect(url_for("login"))
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        pass

##############################
@app.get("/home-comp")
def home_comp():
    try:
        # Check if user is logged in
        if not g.user: 
            return "error"
        
        db, cursor = x.db()
        q = "SELECT * FROM users JOIN posts ON user_pk = post_user_fk ORDER BY RAND() LIMIT 5"
        cursor.execute(q)
        tweets = cursor.fetchall()
        ic(tweets)

        # Render partial template
        html = render_template("_home_comp.html", tweets=tweets)
        return f"""<mixhtml mix-update="main">{ html }</mixhtml>"""
        
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.get("/profile")
def profile():
    try:
        # Check if user is logged in
        if not g.user: 
            return "error"
        
        # Fetch fresh user data from database
        q = "SELECT * FROM users WHERE user_pk = %s"
        db, cursor = x.db()
        cursor.execute(q, (g.user["user_pk"],))
        row = cursor.fetchone()
        
        # Render profile template
        profile_html = render_template("_profile.html", row=row)
        return f"""<browser mix-update="main">{ profile_html }</browser>"""
        
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.patch("/like-tweet")
@x.no_cache
def api_like_tweet():
    try:
        # Render unlike button template
        button_unlike_tweet = render_template("___button_unlike_tweet.html")
        return f"""
            <mixhtml mix-replace="#button_1">
                {button_unlike_tweet}
            </mixhtml>
        """
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.route("/api-create-post", methods=["POST"])
def api_create_post():
    try:
        # Check if user is logged in
        if not g.user: 
            return "invalid user"
        
        # Get user ID and validate post
        user_pk = g.user["user_pk"]        
        post_message = x.validate_post(request.form.get("post", ""))
        
        # Generate post data
        post_pk = uuid.uuid4().hex
        post_media_path = ""
        post_total_likes = 0
        post_total_bookmarks = 0
        post_is_blocked = 0
        created_at = int(time.time())
        updated_at = 0
        deleted_at = 0

        # Insert post into database
        db, cursor = x.db()
        q = """INSERT INTO posts VALUES(
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        )"""
        cursor.execute(q, (
            post_pk, user_pk, post_message, post_total_likes, 
            post_total_bookmarks, post_media_path, post_is_blocked, 
            created_at, updated_at, deleted_at
        ))
        db.commit()
        
        # Prepare response data
        toast_ok = render_template("___toast_ok.html", message="The world is reading your post!")
        
        # Create tweet object for template
        tweet = {
            "user_first_name": g.user["user_first_name"],
            "user_last_name": g.user["user_last_name"],
            "user_username": g.user["user_username"],
            "user_avatar_path": g.user["user_avatar_path"],
            "post_message": post_message,
        }
        
        # Render templates
        html_post_container = render_template("___post_container.html")
        html_post = render_template("_tweet.html", tweet=tweet)
        
        # Return multiple updates to browser
        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-top="#posts">{html_post}</browser>
            <browser mix-replace="#post_container">{html_post_container}</browser>
        """
        
    except Exception as ex:
        ic(ex)
        if "db" in locals(): db.rollback()

        # User validation error
        if "x-error post" in str(ex):
            toast_error = render_template("___toast_error.html", 
                                        message=f"Post - {x.POST_MIN_LEN} to {x.POST_MAX_LEN} characters")
            return f"""<browser mix-bottom="#toast">{toast_error}</browser>"""

        # System error
        toast_error = render_template("___toast_error.html", message="System under maintenance")
        return f"""<browser mix-bottom="#toast">{ toast_error }</browser>""", 500

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.route("/api-update-profile", methods=["POST"])
def api_update_profile():
    try:
        # Check if user is logged in
        if not g.user: 
            return "invalid user"

        # Get user's language
        lan = g.user["user_language"]

        # Validate inputs
        user_email = x.validate_user_email(lan)
        user_username = x.validate_user_username(lan)
        user_first_name = x.validate_user_first_name(lan)

        # Update database
        q = "UPDATE users SET user_email = %s, user_username = %s, user_first_name = %s WHERE user_pk = %s"
        db, cursor = x.db()
        cursor.execute(q, (user_email, user_username, user_first_name, g.user["user_pk"]))
        db.commit()

        # Send success response
        toast_ok = render_template("___toast_ok.html", message="Profile updated successfully")
        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-update="#profile_tag .name">{user_first_name}</browser>
            <browser mix-update="#profile_tag .handle">@{user_username}</browser>
        """, 200
        
    except Exception as ex:
        ic(ex)
        
        # User validation errors
        if len(ex.args) > 1 and ex.args[1] == 400:
            toast_error = render_template("___toast_error.html", message=ex.args[0])
            return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
        
        # Database duplicate errors
        if "Duplicate entry" in str(ex) and user_email in str(ex): 
            toast_error = render_template("___toast_error.html", message="Email already registered")
            return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
            
        if "Duplicate entry" in str(ex) and user_username in str(ex): 
            toast_error = render_template("___toast_error.html", message="Username already registered")
            return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
        
        # System error
        toast_error = render_template("___toast_error.html", message="System under maintenance")
        return f"""<mixhtml mix-bottom="#toast">{ toast_error }</mixhtml>""", 500

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.route("/api-upload-avatar", methods=["POST"])
def api_upload_avatar():
    """
    Handles avatar/profile picture upload
    """
    try:
        # Check if user is logged in
        if not g.user: 
            raise Exception("You must be logged in", 400)
        
        # Validate uploaded file
        file, file_extension = x.validate_avatar_upload()
        
        # Create unique filename > we could make it a uuid instead
        timestamp = int(time.time())
        filename = f"{g.user['user_pk']}_{timestamp}.{file_extension}"
        
        # Build filepath
        filepath = os.path.join('images', filename)
        
        # Ensure images folder exists
        if not os.path.exists('images'):
            os.makedirs('images')
        
        # Delete old avatar if it exists (not external URL)
        if g.user["user_avatar_path"] and not g.user["user_avatar_path"].startswith("http"):
            old_avatar = g.user["user_avatar_path"]
            if os.path.exists(old_avatar):
                try:
                    os.remove(old_avatar)
                    ic(f"Deleted old avatar: {old_avatar}")
                except Exception as e:
                    ic(f"Could not delete old avatar: {e}")
        
        # Save new file to disk
        file.save(filepath)
        
        # Update database
        db, cursor = x.db()
        q = "UPDATE users SET user_avatar_path = %s WHERE user_pk = %s"
        cursor.execute(q, (filepath, g.user["user_pk"]))
        db.commit()
        
        # Update g.user in memory
        g.user["user_avatar_path"] = filepath
        
        # Send success response and redirect
        toast_ok = render_template("___toast_ok.html", message="Avatar updated successfully!")
        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-redirect="/home"></browser>
        """, 200
        
    except Exception as ex:
        ic(f"Exception: {ex}")
        
        # Cleanup: delete uploaded file if error occurred
        if 'filepath' in locals() and os.path.exists(filepath):
            os.remove(filepath)
        
        # Rollback database changes
        if "db" in locals(): 
            db.rollback()
        
        # User validation error
        if len(ex.args) > 1 and ex.args[1] == 400:
            toast_error = render_template("___toast_error.html", message=ex.args[0])
            return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 400
        
        # System error
        toast_error = render_template("___toast_error.html", 
                                     message=f"Could not upload avatar: {str(ex)}")
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500
        
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.post("/api-search")
def api_search():
    try:
        # TODO: Validate search input
        search_for = request.form.get("search_for", "")
        if not search_for: 
            return """empty search field""", 400
        
        # Create SQL LIKE pattern
        part_of_query = f"%{search_for}%"
        ic(search_for)
        
        # Search database
        db, cursor = x.db()
        q = "SELECT * FROM users WHERE user_username LIKE %s"
        cursor.execute(q, (part_of_query,))
        users = cursor.fetchall()
        
        # Return JSON response
        return jsonify(users)
        
    except Exception as ex:
        ic(ex)
        return str(ex)
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

##############################
@app.get("/get-data-from-sheet")
def get_data_from_sheet():
    try:
        # TODO: Check if admin is running this endpoint
        
        # Fetch Google Sheet data as CSV
        url = f"https://docs.google.com/spreadsheets/d/{x.google_spread_sheet_key}/export?format=csv&id={x.google_spread_sheet_key}"
        res = requests.get(url=url)
        csv_text = res.content.decode('utf-8')
        csv_file = io.StringIO(csv_text)
        
        # Parse CSV data
        data = {}
        reader = csv.DictReader(csv_file)
        ic(reader)
        
        for row in reader:
            item = {
                'english': row['english'],
                'danish': row['danish'],
                'spanish': row['spanish']
            }
            data[row['key']] = item

        # Save to JSON file
        json_data = json.dumps(data, ensure_ascii=False, indent=4)
        with open("dictionary.json", 'w', encoding='utf-8') as f:
            f.write(json_data)
 
        return "ok"
        
    except Exception as ex:
        ic(ex)
        return str(ex)
    finally: 
        pass


@app.route("/forgot-password", methods=["GET", "POST"])
def forgot_password():
    try:
        # GET to view the template
        if request.method == "GET":
             return render_template("forgot_password.html")
        
        # POST to begin process of creating new password
        if request.method == "POST":
             user_email = x.validate_user_email()

             # uuid to insert on the user_password_reset
             user_password_reset_key = uuid.uuid4().hex

            # updating the user_password_reset key on the user that matches the email
             db, cursor = x.db()
             q = "UPDATE users SET user_password_reset = %s WHERE user_email = %s"
             cursor.execute(q, (user_password_reset_key, user_email))
             db.commit()

             # rendering the template that the email is gonna contain
             email_forgot_password = render_template("_email_forgot_password.html", user_password_reset_key=user_password_reset_key)
             
             # passing the email, subject and template to the send_email function.
             x.send_email(user_email=user_email, subject="Update your password", template=email_forgot_password)
             
             toast_ok = render_template("___toast_ok.html", message="Check your email")
             return f"""<browser mix-bottom=#toast>{ toast_ok }</browser>"""


    except Exception as ex:
        ic(ex)
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

@app.route("/create-new-password", methods=["GET", "POST"])
def create_new_password():
    try:
        # getting the key from the url or the form
        key = request.args.get("key") or request.form.get("key")

        if not key:
            return "Invalid reset key", 400

        # We select the user that has the key from the url in user_password_reset
        db, cursor = x.db()
        q = "SELECT * FROM users WHERE user_password_reset = %s"
        cursor.execute(q, (key,))
        row = cursor.fetchone()

        if not row:
            return "Invalid reset link", 400

        # on GET, create_new_password.html is shown and we pass the key from the url
        if request.method == "GET":
            return render_template("create_new_password.html", key=key)
        
        # on POST we update the password
        if request.method == "POST":
            user_password = x.validate_user_password()

            user_hashed_password = generate_password_hash(user_password)

            # We update the user_password and set the user_password_reset key back to 0
            q = """
            UPDATE users 
            SET user_password = %s,
                user_password_reset = 0
            WHERE user_email = %s
            """
            cursor.execute(q, (user_hashed_password, row["user_email"]))
            db.commit()

            return """<browser mix-redirect="/login"></browser>"""

    except Exception as ex:
        ic(ex)
        return "Server error", 500   # ← RETURN SOMETHING HERE
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()




