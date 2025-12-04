from crypt import methods
from flask import Flask, render_template, request, session, redirect, url_for, jsonify, g, send_from_directory 
# Question: Hvorfor har vi send_from_directory og hvad er det?
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

import traceback
# traceback.print_exc()

from icecream import ic
ic.configureOutput(prefix=f'----- | ', includeContext=True)

app = Flask(__name__)

# Set the maximum file size to 1 MB
app.config['MAX_CONTENT_LENGTH'] = 30 * 1024 * 1024   # 1 MB


app.config['SESSION_TYPE'] = 'filesystem'
Session(app)


# -------------------- GLOBAL VARIABLES -------------------- #
############## GLOBAL PROCESSOR     ################
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



############################## FORKLAR DENNE
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
        # a user that has been deleted (soft-deleted) cannot log in
        cursor.execute("SELECT * FROM users WHERE user_pk = %s AND deleted_at IS NULL", (user_pk,))
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
##############################
##############################
def _____USER_____(): pass 
##############################
##############################
##############################

@app.get("/")
@app.get("/<lan>")
def view_index(lan="english"):
# Validate language parameter
    if lan not in x.allowed_languages: 
        lan = "english"
       
       # Set default language in x module
    x.default_language = lan
       
    return render_template("index.html", lan=lan)


# -------------------- SIGNUP -------------------- #
############## SIGNUP ################
@app.route("/signup", methods=["GET", "POST"])
@app.route("/signup/<lan>", methods=["GET", "POST"])
def signup(lan = "english"):
    # Question: skal der stadig være x.allowed_languages hvis vi ikke behøver skrive x??
    # Ulempen vil være at vi ikke ved hvor tingene kommer fra
    # Validate language parameter
    if lan not in x.allowed_languages: 
        lan = "english"

    if request.method == "GET":
        x.default_language = lan # Question: Skal vi have det her med = lan??
        return render_template("signup.html", lan=lan) # Question: SKAL VI HAVE LAN=LAN HER??

    if request.method == "POST":
        try:
            # Validate all user inputs
            user_email = x.validate_user_email(lan)
            user_password = x.validate_user_password(lan)
            user_username = x.validate_user_username(lan)
            user_first_name = x.validate_user_first_name(lan)

            # Generate unique user ID
            user_pk = uuid.uuid4().hex
            
            user_avatar_path = "https://avatar.iran.liara.run/public/40"
            user_verification_key = uuid.uuid4().hex
            user_total_follows = 0
            user_total_followers = 0
            user_admin = 0
            user_is_blocked = 0
            created_at = int(time.time())

            # Hash password before storing (NEVER store plain text passwords!)
            user_hashed_password = generate_password_hash(user_password)

            # Connect to the database
            q = "INSERT INTO users VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            db, cursor = x.db()
            # All the values that has NULL in the DB is now None here
            cursor.execute(q, (user_pk, user_email, user_hashed_password, user_username, user_first_name, None, None, user_avatar_path, 
            user_verification_key, None, None, user_total_follows, user_total_followers, user_admin, user_is_blocked, None, created_at, None, None))
            db.commit()

            # Send verification email
            email_verify_account = render_template("_email_verify_account.html", user_verification_key=user_verification_key)
            ic(email_verify_account)

            x.send_email(user_email=user_email, subject="Verify your account", template=email_verify_account)

            # Question: skal det her være udkommenteret??
            # Uncomment when email is configured:
            # x.send_email(user_email, "Verify your account", email_verify_account)


            # Redirect to login page
            return f"""<browser mix-redirect="{ url_for('login', lan=lan) }"></browser>""", 200 # Question: skal lan=lan være her??
            
        except Exception as ex:
            ic(ex)
            
            # User validation errors
            if len(ex.args) > 1 and ex.args[1] == 400:
                toast_error = render_template("___toast_error.html", message=ex.args[0])
                return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
            
            # Database duplicate entry errors
            if "Duplicate entry" in str(ex) and user_email in str(ex): 
                toast_error = render_template("___toast_error.html", message=x.lans("email_already_registered"))
                return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
            
            if "Duplicate entry" in str(ex) and user_username in str(ex): 
                toast_error = render_template("___toast_error.html", message=x.lans("username_already_registered"))
                return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400
            
            # System or developer error
            toast_error = render_template("___toast_error.html", message="System under maintenance")
            return f"""<mixhtml mix-bottom="#toast">{ toast_error }</mixhtml>""", 500

        finally:
            if "cursor" in locals(): cursor.close()
            if "db" in locals(): db.close()


# -------------------- LOGIN -------------------- #
############## LOGIN ################
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
        
        return render_template("login.html", lan=lan) # Question: skal vi stadig have lan=lan???

    if request.method == "POST":
        try:
            # Validate user input
            user_email = x.validate_user_email(lan)
            user_password = x.validate_user_password(lan)
            
            # Query database for user -> deleted user cannot log in
            q = "SELECT * FROM users WHERE user_email = %s"
            db, cursor = x.db() # Question: burde den her linje ikke være over q?
            cursor.execute(q, (user_email,))
            user = cursor.fetchone()
            
            # Check if user exists
            if not user: 
                raise Exception(x.lans("user_not_found"), 400) 
            
            if user["user_is_blocked"] == 1:
                raise Exception(x.lans("user_is_blocked"), 400)

            # Verify password hash
            if not check_password_hash(user["user_password"], user_password):
                raise Exception(x.lans("invalid_credentials"), 400) 

            # Check if user has verified email
            if user["user_verification_key"] != "":
                raise Exception(x.lans("user_not_verified"), 400) 

            # Store only user_pk in session (not entire user object)
            # This is more secure and efficient
            session["user_pk"] = user["user_pk"]
            session["lan"] = lan
            
            # Redirect to home page
            return f"""<browser mix-redirect="/home/{lan}"></browser>"""

        except Exception as ex:
            ic(ex)

            # User errors (validation, wrong password, etc.)
            if len(ex.args) > 1 and ex.args[1] == 400:
                toast_error = render_template("___toast_error.html", message=ex.args[0])
                return f"""<mixhtml mix-update="#toast">{ toast_error }</mixhtml>""", 400

            # System or developer error (database down, etc.)
            toast_error = render_template("___toast_error.html", message=x.lans("system_maintenance"))
            return f"""<browser mix-bottom="#toast">{ toast_error }</browser>""", 500
        
        finally:
            if "cursor" in locals(): cursor.close()
            if "db" in locals(): db.close()




# -------------------- FORGOT PASSWORD -------------------- #
############# FORGOT PASSWORD #################
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
            q = "UPDATE users SET user_password_reset_key = %s WHERE user_email = %s"
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


############# CREATE NEW PASSWORD #################
@app.route("/create-new-password", methods=["GET", "POST"])
def create_new_password():
    try:

        # getting the key from the url or the form
        key = request.args.get("key") or request.form.get("key")

        if not key:
            return "Invalid reset key", 400

        # We select the user that has the key from the url in user_password_reset
        db, cursor = x.db()
        q = "SELECT * FROM users WHERE user_password_reset_key = %s"
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
                user_password_reset_key = 0
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





# -------------------- HOME --------------------

############## HOME - GET ################
@app.route("/home", methods=["GET"])
@app.route("/home/<lan>", methods=["GET"]) 
@x.no_cache # prevents showing cached content after logout / "back" button
def home(lan = "english"):
    # Validate language parameter
    if lan not in x.allowed_languages: 
        lan = "english"

    try:
        # Check if user is logged in (g.user set by @app.before_request)
        if not g.user: 
            return redirect(url_for("login"))
        
        db, cursor = x.db()
        
        # Get random posts with user data (JOIN)
        # TODO = Only show the posts from users / posts that are not deleted
       
        is_admin = g.user["user_admin"]

        # Base query (same for everyone)
        base_query = """
        SELECT 
            users.*,
            posts.*,
            CASE 
                WHEN likes.like_user_fk IS NOT NULL THEN 1
                ELSE 0
            END AS liked_by_user
        FROM posts
        JOIN users ON users.user_pk = posts.post_user_fk
        LEFT JOIN likes 
        ON likes.like_post_fk = posts.post_pk
        AND likes.like_user_fk = %s
        """

        # Add condition ONLY if user is not admin
        if not is_admin:
            base_query += " WHERE posts.post_is_blocked = 0 AND users.user_is_blocked = 0"

        # Random order + limit
        base_query += " ORDER BY RAND() LIMIT 5"

        cursor.execute(base_query, (g.user["user_pk"],))
        tweets = cursor.fetchall()

        # Get random trends
        q = "SELECT * FROM trends ORDER BY RAND() LIMIT 3"
        cursor.execute(q)
        trends = cursor.fetchall()
        ic(trends)

        # Get user suggestions (exclude current user)
        q = """
            SELECT 
                users.*
            FROM users 
            WHERE users.user_pk != %s
            AND users.user_is_blocked = 0
            AND users.user_pk NOT IN (
                SELECT followed_user_fk
                FROM follows
                WHERE follow_user_fk = %s
            )
            ORDER BY RAND()
            LIMIT 3
            """
        cursor.execute(q, (g.user["user_pk"], g.user["user_pk"]))
        suggestions = cursor.fetchall()
        ic(suggestions)


        return render_template("home.html", tweets=tweets, trends=trends, suggestions=suggestions)
        
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############## HOME COMP ################
@app.get("/home-comp")
# TODO: add translation
def home_comp():
    try:
        if not g.user:
            return "error"

        db, cursor = x.db()

        # Get likes on a post
         
        is_admin = g.user["user_admin"]

        # Base query (same for everyone)
        base_query = """
        SELECT 
            users.*,
            posts.*,
            CASE 
                WHEN likes.like_user_fk IS NOT NULL THEN 1
                ELSE 0
            END AS liked_by_user
        FROM posts
        JOIN users ON users.user_pk = posts.post_user_fk
        LEFT JOIN likes 
        ON likes.like_post_fk = posts.post_pk
        AND likes.like_user_fk = %s
        """

        # Add condition ONLY if user is not admin
        if not is_admin:
            base_query += " WHERE posts.post_is_blocked = 0 AND users.user_is_blocked = 0"

        # Random order + limit
        base_query += " ORDER BY RAND() LIMIT 5"

        cursor.execute(base_query, (g.user["user_pk"],))
        tweets = cursor.fetchall()

        html = render_template("_home_comp.html", tweets=tweets)
        return f"""<browser mix-update="main">{ html }</browser>"""

    except Exception as ex:
        ic(ex)
        return "error"
        # TODO: better error messages
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()




# -------------------- LOGOUT -------------------- #

############## LOGOUT - GET ################
# TODO: add translation
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




# -------------------- PROFILE -------------------- #
############### PROFILE - GET ###############
# Question: mangler vi language og methods?
# TODO: add translation
@app.get("/profile")
def profile():
    try:
        # Check if user is logged in
        if not g.user: 
            return "error" # Question: mangler den end http code? f.eks. 400??
        
        # Fetch fresh user data from database
        q = "SELECT * FROM users WHERE user_pk = %s"
        db, cursor = x.db()
        cursor.execute(q, (g.user["user_pk"],))
        row = cursor.fetchone()
        q = """
        SELECT posts.*, users.user_username, users.user_first_name, users.user_last_name, users.user_avatar_path
        FROM posts
        JOIN users ON posts.post_user_fk = users.user_pk
        WHERE posts.post_user_fk = %s
        ORDER BY posts.created_at DESC
        """
        cursor.execute(q, (g.user["user_pk"],))
        posts = cursor.fetchall()
        # Render profile template
        profile_html = render_template("_profile.html", row=row, posts=posts)
        return f"""<browser mix-update="main">{ profile_html }</browser>"""
        
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############### EDIT PROFILE ###############
# TODO: add translation
@app.get("/edit_profile")
def edit_profile():
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
        edit_profile_html = render_template("_edit_profile.html", row=row)
        return f"""<browser mix-update="main">{ edit_profile_html }</browser>"""
        
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()



############## API UPDATE PROFILE ################
# TODO: add translation
@app.route("/api-update-profile", methods=["POST"])
def api_update_profile():
    try:
        # Check if user is logged in
        if not g.user: 
            return "invalid user"

        # Get user's language
        lan = g.user["user_language"]

        # Validate inputs
        user_email = x.validate_user_email()
        user_username = x.validate_user_username()
        user_first_name = x.validate_user_first_name()

        # timestamp for when the profile updates
        updated_at = int(time.time())

        # Update database
        q = "UPDATE users SET user_email = %s, user_username = %s, user_first_name = %s, updated_at = %s WHERE user_pk = %s"
        db, cursor = x.db()
        cursor.execute(q, (user_email, user_username, user_first_name, updated_at, g.user["user_pk"]))
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


# TODO: RYK HEN TIL PROFILE
############### IMAGES (AVATARS) ############### FORKLAR DENNE
## Serve images from static/images/avatars folder
# Required for avatar images to display
@app.route('/images/avatars/<path:filename>')
# TODO: add translation????
def serve_image(filename):
    """
    Serves avatar images from the static/images/avatars folder
    Example: /images/avatars/a1b2c3d4e5f6.jpg
    """
    return send_from_directory(os.path.join('static', 'images', 'avatars'), filename)


############################## 
@app.template_filter('avatar')
# TODO: add translation ???
def avatar_filter(avatar_path):
    """
    Ensures avatar path works in HTML
   - I alle templates kan vi bare skrive {{ user.user_avatar_path | avatar }}
   - Ingen kompliceret if/else logik i templates
    """
    # returnerer default billede hvis ingen avatar
    if not avatar_path:
        return "https://avatar.iran.liara.run/public/40"
    
    # håndterer eksterne URLs (fra tredjeparts services)
    if avatar_path.startswith("http"):
        return avatar_path
    
    # tilføjer '/' til lokale filer
    if not avatar_path.startswith("/"):
        return f"/{avatar_path}"
    
    return avatar_path

############## API UPLOAD AVATAR ################
@app.route("/api-upload-avatar", methods=["POST"])
# TODO: add translation???
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
        # timestamp = int(time.time())
        # filename = f"{g.user['user_pk']}_{timestamp}.{file_extension}"
    
        # Create unique filename with UUID
        unique_id = uuid.uuid4().hex
        filename = f"{unique_id}.{file_extension}"

        # Build filepath
        # Creating the avatar folder inside static / images  
        filepath = os.path.join('static','images','avatars', filename)
        
        # Ensure avatars folder exists
        avatar_folder = os.path.join('static', 'images', 'avatars')
        
        if not os.path.exists(avatar_folder):
            os.makedirs(avatar_folder)
        
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

        avatar_url = f"/static/images/avatars/{filename}"
        # finding the element with the id #current_avatar
        # replaces it with the new <img> tag that has the updated src (the new image)
        # mix-replace="#nav_avatar" > finds the element with the id nav_avatar
        # replaces it with the new <img> tag
        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-replace="#current_avatar"><img id="current_avatar" src="{avatar_url}" alt="Current avatar"></browser>
            <browser mix-replace="#nav_avatar"><img src="/{filepath}" alt="Profile" id="nav_avatar"></browser>
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
        toast_error = render_template("___toast_error.html", message=f"Could not upload avatar: {str(ex)}")
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500
        
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()




        
############### DELETE PROFILE ###############
@app.route("/delete-profile", methods=["GET"])
@app.route("/delete-profile/<lan>", methods=["GET"])
def delete_profile(lan = "english"):
    # Validate language parameter
    if lan not in x.allowed_languages: 
        lan = "english"
    
    try:
        # Check if user is logged in
        if not g.user: 
            return "error"
        
        # Fetch fresh user data from database
        q = "SELECT * FROM users WHERE user_pk = %s"
        db, cursor = x.db()
        cursor.execute(q, (g.user["user_pk"],))
        row = cursor.fetchone()

        # Render delete profile template
        delete_profile_html = render_template("___delete_profile.html", row=row)
        return f"""<browser mix-update="main">{ delete_profile_html }</browser>"""

    except Exception as ex:
        ic(ex)
        return "error"
    
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############## API DELETE PROFILE ################
@app.route("/api-delete-profile", methods=["GET", "DELETE"])
@app.route("/api-delete-profile/<lan>", methods=["GET", "DELETE"])
def api_delete_profile(lan = "english"):
    # Validate language parameter
    if lan not in x.allowed_languages: 
        lan = "english"

    try:
        # Check if user is logged in
        if not g.user: 
            return "invalid user"
        
        # Delete user from database
        q = "DELETE FROM users WHERE user_pk = %s"
        db, cursor = x.db()
        cursor.execute(q, (g.user["user_pk"],))
        db.commit()

        session.clear()

        # Redirect to index page
        return f"""<browser mix-redirect="/"></browser>"""
    
    except Exception as ex:
        ic(ex)
        if "db" in locals(): db.rollback()
        toast_error = render_template("___toast_error.html", message="System under maintenance")
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500
    
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()




# -------------------- POST/TWEET -------------------- #

############### API CREATE POST/TWEET ###############
# TODO: add translation
@app.route("/api-create-post", methods=["POST"])
def api_create_post():
    try:
        # Check if user is logged in
        if not g.user: 
            return "invalid user", 400
        
        user_pk = g.user["user_pk"]
        
        # Get post text (CAN BE EMPTY if there's media)
        post_message = request.form.get("post", "").strip()
        
        # Validate uploaded media (if any)
        file = None
        file_extension = None
        post_media_path = None
        
        if 'post_media' in request.files:
            uploaded_file = request.files['post_media']
            if uploaded_file.filename != '':
                file, file_extension = x.validate_post_media()
        
        # Must have either text or media
        if not post_message and not file:
            toast_error = render_template("___toast_error.html", message="Post must contain text or media")
            return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 400
        
        # Validate text ONLY if there is text
        # allow_empty=True because we already checked above that we have media if no text
        if post_message:
            post_message = x.validate_post(post_message, allow_empty=False)
        else:
            # No text, but we have media (already validated above)
            post_message = x.validate_post(post_message, allow_empty=True)
        
        # Generate post data
        post_pk = uuid.uuid4().hex
        post_total_comments = 0
        post_total_likes = 0
        post_total_bookmarks = 0
        post_is_blocked = 0
        created_at = int(time.time())
        
        # Handle file upload if present
        if file and file_extension:
            unique_id = uuid.uuid4().hex
            filename = f"{unique_id}.{file_extension}"
            
            media_folder = os.path.join('static', 'images', 'posts')
            filepath = os.path.join(media_folder, filename)
            
            if not os.path.exists(media_folder):
                os.makedirs(media_folder)
            
            file.save(filepath)
            post_media_path = f"images/posts/{filename}"
        
        # Insert post into DB
        db, cursor = x.db()
        q = """INSERT INTO posts VALUES(
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        )"""
        cursor.execute(q, (
            post_pk, user_pk, post_message, post_total_comments, 
            post_total_likes, post_total_bookmarks, post_media_path, 
            post_is_blocked, created_at, None, None
        ))
        db.commit()
        
        # Prepare response
        toast_ok = render_template("___toast_ok.html", message="The world is reading your post!")
        
        tweet = {
            "post_pk": post_pk,
            "user_first_name": g.user["user_first_name"],
            "user_last_name": g.user["user_last_name"],
            "user_username": g.user["user_username"],
            "user_avatar_path": g.user["user_avatar_path"],
            "post_message": post_message,
            "post_media_path": post_media_path,
            "post_is_blocked": 0,
            "post_total_likes": 0,
            "post_total_comments": 0
        }
        
        html_post_container = render_template("___post_container.html")
        html_post = render_template("_tweet.html", tweet=tweet, user=user_pk) # passing user so delete post will show us as soon as its posted
        
        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-top="#posts">{html_post}</browser>
            <browser mix-replace="#post_container">{html_post_container}</browser>
        """
        
    except Exception as ex:
        ic(ex)
        ic(traceback.format_exc())
        
        # Cleanup uploaded file on error
        if 'filepath' in locals() and os.path.exists(filepath):
            try:
                os.remove(filepath)
            except:
                pass
        
        if "db" in locals(): 
            db.rollback()

        # User validation error
        if len(ex.args) > 1 and ex.args[1] == 400:
            toast_error = render_template("___toast_error.html", message=ex.args[0])
            return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 400

        # System error
        toast_error = render_template("___toast_error.html", message=f"Error: {str(ex)}")
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############### EDIT POST - GET ###############
@app.get("/edit-post/<post_pk>")
def edit_post(post_pk):
    try:
        # check if user is logged in
        if not g.user:
            return "error", 400
        
        # get post from db
        db, cursor = x.db()
        q = "SELECT * FROM posts WHERE post_pk = %s AND post_user_fk = %s AND deleted_at IS NULL"
        cursor.execute(q, (post_pk, g.user["user_pk"]))
        post = cursor.fetchone()

        if not post:
            toast_error = render_template("___toast_error.html", message="Post not found or you don't have permission")
            return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 403
        
        edit_post_html = render_template("_edit_post.html", post=post)
        return f"""<browser mix-update="main">{edit_post_html}</browser>"""
    except Exception as ex:
        ic(ex) 
            
        toast_error = render_template("___toast_error.html", message="Could not load post")
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500
        

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()

############### API EDIT POST - POST ############### 
@app.route("/api-update-post/<post_pk>", methods=["POST"])
def api_update_post(post_pk):
    try:
        # Check if user is logged in
        if not g.user: 
            return "invalid user", 401
        
        # Get and validate new post message
        post_message = request.form.get("post_message", "").strip()
        
        # Validate: must have text (can't be empty for edit)
        if not post_message:
            toast_error = render_template("___toast_error.html", message="Post cannot be empty")
            return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 400
        
        # Validate post length
        post_message = x.validate_post(post_message, allow_empty=False)
        
        # Update timestamp
        updated_at = int(time.time())
        
        # Update database
        db, cursor = x.db()
        q = "UPDATE posts SET post_message = %s, updated_at = %s WHERE post_pk = %s AND post_user_fk = %s AND deleted_at IS NULL"
        
        cursor.execute(q, (post_message, updated_at, post_pk, g.user["user_pk"]))
        db.commit()
        
        # Check if update was successful
        if cursor.rowcount != 1:
            raise Exception("Could not update post", 400)
        
        # Fetch updated post with user data
        is_admin = g.user["user_admin"]

        # Base query
        q = """
            SELECT 
            users.*,
            posts.*,
            CASE 
                WHEN likes.like_user_fk IS NOT NULL THEN 1
                ELSE 0
            END AS liked_by_user
            FROM posts
            JOIN users ON users.user_pk = posts.post_user_fk
            LEFT JOIN likes 
            ON likes.like_post_fk = posts.post_pk
            AND likes.like_user_fk = %s
            """

        # Add filters ONLY for non-admins
        if not is_admin:
            q += " WHERE posts.post_is_blocked = 0 AND users.user_is_blocked = 0"

        # Add ordering + limit
        q += """
            ORDER BY 
            CASE 
                WHEN posts.updated_at = (
                SELECT MAX(updated_at) FROM posts WHERE updated_at IS NOT NULL
                ) THEN 0
                 ELSE 1
            END,
            RAND()
            LIMIT 5
            """

        cursor.execute(q, (post_pk,))
        tweets = cursor.fetchall()

        
        # Send success response
        toast_ok = render_template("___toast_ok.html", message="Post updated successfully!")
        # tweet_html = render_template("_tweet.html", tweet=tweets)
        home_html = render_template("_home_comp.html", tweets=tweets)
        # <browser mix-replace="#post_container_{post_pk}">{tweet_html}</browser>
        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-update="main">{home_html}</browser>
        """
        
    except Exception as ex:
        ic(ex)
        
        if "db" in locals(): 
            db.rollback()
        
        # User validation error
        if len(ex.args) > 1 and ex.args[1] == 400:
            toast_error = render_template("___toast_error.html", message=ex.args[0])
            return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 400
        
        # System error
        toast_error = render_template("___toast_error.html", message="Could not update post")
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()
   

    


############### API DELETE POST ###############
# @app.route("/api-delete-post", methods=["GET", "DELETE"])
# question: skal vi have language her??
@app.route("/api-delete-post/<post_pk>", methods=["DELETE"])
def api_delete_post(post_pk):
    try:
        # Check if user is logged in
        if not g.user:
            return "invalid user", 400 ## TODO: add a HTTP requests på de andre

        db, cursor = x.db()


        # Delete post from database IF its the users post
        q = "DELETE FROM posts WHERE post_pk = %s and post_user_fk = %s"
        cursor.execute(q, (post_pk, g.user["user_pk"],))
        db.commit()

        toast_ok = render_template("___toast_ok.html", message="Your post has been deleted") #TODO: Translate
        
        # Remove the post from the DOM + show toast
        # return "ok"
        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-remove="#post_container_{post_pk}"></browser>
        """, 200

    except Exception as ex:
        ic(ex)
        if "db" in locals(): db.rollback()
        toast_error = render_template("___toast_error.html", message="System under maintenance")
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500

    finally: 
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############## SINGLE POST/TWEET ################
# TODO: add translation
@app.get("/single-post/<post_pk>")
def view_single_post(post_pk):
    # Check if user is logged in
    try:
        if not g.user:
            return "invalid user", 400 ## TODO: add a HTTP requests på de andre

        db, cursor = x.db() # Question: hvorfor skal linjen være her?

        # Get likes on a post
        q = """
        SELECT 
            users.*,
            posts.*,
            CASE 
                WHEN likes.like_user_fk IS NOT NULL THEN 1
                ELSE 0
            END AS liked_by_user
        FROM posts
        JOIN users ON users.user_pk = posts.post_user_fk
        LEFT JOIN likes 
            ON likes.like_post_fk = posts.post_pk 
            AND likes.like_user_fk = %s
        WHERE posts.post_pk = %s
        """
        cursor.execute(q, (g.user["user_pk"], post_pk,))
        
        tweet = cursor.fetchone()

        if not tweet:
            return "Post not found", 404


        # Get comments on a post
        q = """
        SELECT
            comments.*,
            users.user_first_name,
            users.user_username,
            users.user_avatar_path
        FROM comments
        JOIN users ON users.user_pk = comments.comment_user_fk
        WHERE comments.comment_post_fk = %s
        ORDER BY comments.created_at DESC
        """

        # ORDER BY comments.created_at DESC (means: Show the newest comments first)
        
        cursor.execute(q, (post_pk,))  
        comments = cursor.fetchall()

        # Manglede at sende post_pk til templaten
        single_post_html = render_template("_single_post.html", tweet=tweet, comments=comments, post_pk=post_pk)
        return f"""<browser mix-update="main">{ single_post_html }</browser>"""

    except Exception as ex:
        
        # SYSTEM ERROR
        toast_error = render_template("___toast_error.html", message="Error") # TODO: lav en message der passer til error
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()



############## CREATE COMMENT ON POST/TWEET ################
# TODO: add translation
@app.route("/api-create-comment/<post_pk>", methods=["POST"])
def api_create_comment(post_pk):
    try:
        # Check if user is logged in
        if not g.user:
            return "invalid user", 400
        
        # Get and validate the comment from the comment form
        # ic("FORM", request.form.to_dict())
        # comment_raw = request.form.get("comment", "")
        # ic(comment_raw, len(comment_raw))
        # comment_message = x.validate_comment(comment_raw)
        comment_message = x.validate_comment(request.form.get("comment", ""))

        # Generate comment data
        comment_pk = uuid.uuid4().hex
        comment_user_fk = g.user["user_pk"]
        comment_post_fk = post_pk
        comment_is_blocked = 0
        created_at = int(time.time())

        # Insert comment into DB
        db, cursor = x.db()
        q = """INSERT INTO comments VALUES(%s, %s, %s, %s, %s, %s, %s, %s)"""
        cursor.execute(q, (comment_pk, comment_user_fk, comment_post_fk, comment_message, comment_is_blocked, created_at, None, None,),)
        db.commit()

        # Prepare response
        # toast_ok = render_template("___toast_ok.html", message="The world is reading your comment!")
        
        comment = {
            "comment_pk": comment_pk,
            "user_first_name": g.user["user_first_name"],
            "user_username": g.user["user_username"],
            "user_avatar_path": g.user["user_avatar_path"],
            "comment_message": comment_message,
            "comment_is_blocked": 0,
            "created_at": created_at
        }

        # Render templates
        toast_ok = render_template("___toast_ok.html", message="The world is reading your comment!")
        html_comment_container = render_template("___comment_container.html", post_pk=post_pk)
        html_comment = render_template("_comment.html", comment=comment)
        
        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-top="#comments">{html_comment}</browser>
            <browser mix-replace="#comment_container">{html_comment_container}</browser>
        """

        # Success
        return redirect(url_for("view_single_post", post_pk=post_pk))
        # Get all comments again, so the list will get updated
        q = """
        SELECT
            comments.*,
            users.user_first_name,
            users.user_username,
            users.user_avatar_path
        FROM comments
        JOIN users ON users.user_pk = comments.comment_user_fk
        WHERE comments.comment_post_fk = %s
        ORDER BY comments.created_at DESC
        """
        # ORDER BY comments.created_at DESC (means: Show the newest comments first)

        cursor.execute(q, (post_pk,))
        comments = cursor.fetchall()

        comments_html = render_template("___comments_list.html", comments=comments)
        toast_ok = render_template("___toast_ok.html", message="Comment posted")

        return f"""
            <browser mix-bottom="#toast">{toast_ok}</browser>
            <browser mix-replace="#post-comments">{comments_html}</browser>
            <browser mix-reset="#comment_frm"></browser> 
        """, 200

    except Exception as ex:
        ic(ex)
        ic(traceback.format_exc())

        if "db" in locals(): 
            db.rollback()

        # USER ERROR (Validating from x.validate_comment)
        if len(ex.args) > 1 and ex.args[1] == 400:
            toast_error = render_template("___toast_error.html", message=ex.args[0])
            return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 400

        # SYSTEM ERROR
        toast_error = render_template("___toast_error.html", message="Cannot post comment")
        return f"""<browser mix-bottom="#toast">{toast_error}</browser>""", 500

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()



############## LIKE POST/TWEET ################
@app.patch("/like-tweet/<post_pk>")
@x.no_cache
def api_like_tweet(post_pk):
    try:

        like_user_fk = session.get("user_pk")  # The user who is liking the tweet
        like_post_fk = post_pk                 # The tweet/post being liked
        created_at = int(time.time())         # Get the current timestamp

        db, cursor = x.db()

        # Insert the like record in the databse
        q = "INSERT INTO likes VALUES(%s, %s, %s, %s)"
        cursor.execute(q, (like_user_fk, like_post_fk, created_at, None))
        db.commit()  # Commit the change

        # Fetch the post data
        # Used to re-render the unlike button with updated state
        q = "SELECT * FROM posts WHERE post_pk = %s"
        cursor.execute(q, (post_pk,))
        tweet = cursor.fetchone()

        # Render the unlike button HTML
        button_unlike_tweet = render_template("___button_unlike_tweet.html", tweet=tweet)
        return f"""
            <mixhtml mix-replace="#button_like_container_{post_pk}">
                {button_unlike_tweet}
            </mixhtml>
        """

    except Exception as ex:
        ic(ex)
        return "error"

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()



############## UNLIKE TWEET ################
@app.delete("/unlike-tweet/<post_pk>")
@x.no_cache 
def api_unlike_tweet(post_pk):
    try:
  
        like_user_fk = g.user["user_pk"]  # The user who is unliking the tweet
        like_post_fk = post_pk                 # The tweet/post being unliked

        db, cursor = x.db()

        # Delete the like from database
        q = "DELETE FROM likes WHERE like_user_fk = %s AND like_post_fk = %s"
        cursor.execute(q, (like_user_fk, like_post_fk))
        db.commit()

        # Fetch the tweet data
        # This is used to re-render the like/unlike button with updated state
        q = "SELECT * FROM posts WHERE post_pk = %s"
        cursor.execute(q, (post_pk,))
        tweet = cursor.fetchone()

        # Render the like button HTML
        button_like_tweet = render_template("___button_like_tweet.html", tweet=tweet)
        return f"""
            <mixhtml mix-replace="#button_like_container_{post_pk}">
                {button_like_tweet}
            </mixhtml>
        """

    except Exception as ex:
        ic(ex)
        return "error"

    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()



# -------------------- FOLLOW -------------------- #
############## FOLLOW USER ################
@app.post("/follow-user/<user_pk>")
def follow_user(user_pk):
    try:
  
        follow_user_fk = g.user["user_pk"]  # The user who is performing the follow
        followed_user_fk = user_pk           # The user being followed 
        created_at = int(time.time())         # Get the current timestamp

        db, cursor = x.db()

        # Insert the new follow in the database
        q = "INSERT INTO follows VALUES(%s, %s, %s, %s)"
        cursor.execute(q, (follow_user_fk, followed_user_fk, created_at, None))
        db.commit()

        # Fetch the followed user's info
        # This is useful for re-rendering the follow/unfollow button dynamically
        q = "SELECT * FROM users WHERE user_pk = %s"
        cursor.execute(q, (user_pk,))
        suggestion = cursor.fetchone()

        # Render the unfollow button HTML
        button_unfollow_user_html = render_template("___button_unfollow_user.html", suggestion=suggestion)
        return f"""
        <browser mix-replace=#button_follow_user_{user_pk}>
        {button_unfollow_user_html}
        </browser>
        """

    except Exception as ex:
        ic(ex)
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############## UNFOLLOW USER ################
@app.post("/unfollow-user/<user_pk>")
def unfollow_user(user_pk):
    try:

        follow_user_fk = g.user["user_pk"]  # The user who is performing the unfollow
        followed_user_fk = user_pk           # The user being unfollowed

        db, cursor = x.db() 

        # Delete the follow from database
        q = "DELETE FROM follows WHERE follow_user_fk = %s AND followed_user_fk = %s"
        cursor.execute(q, (follow_user_fk, followed_user_fk))
        db.commit() 

        # Fetch updated user data
        # This is useful for re-rendering the follow/unfollow button dynamically
        q = "SELECT * FROM users WHERE user_pk = %s"
        cursor.execute(q, (user_pk,))
        suggestion = cursor.fetchone()

        # Render the follow/unfollow button HTML
        button_follow_user_html = render_template("___button_follow_user.html", suggestion=suggestion)
        return f"""
        <browser mix-replace=#button_follow_user_{user_pk}>
        {button_follow_user_html}
        </browser>
        """

    except Exception as ex:
        ic(ex)
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############## ALL USER FOLLOWERS ################
@app.get("/all-user-followers")
def view_all_user_followers():
    try:
        user_pk = g.user["user_pk"]
        db, cursor = x.db()

        # Query to get all followers of the current user
        # `f2` identifies users who follow the current user
        # LEFT JOIN `f1` checks if the current user also follows them back, so the correct button (follow/unfollow) shows
        # The CASE statement creates a "followed_by_user" flag:
        # 1 → current user follows them
        # 0 → current user does not follow them
        q = """
            SELECT
                users.*,
                CASE
                    WHEN f1.follow_user_fk IS NOT NULL THEN 1
                    ELSE 0
                END AS followed_by_user
            FROM users
            JOIN follows AS f2
                ON f2.follow_user_fk = users.user_pk
            LEFT JOIN follows AS f1
                ON f1.followed_user_fk = users.user_pk
                AND f1.follow_user_fk = %s 
            WHERE f2.followed_user_fk = %s
        """
        cursor.execute(q, (user_pk, user_pk))
        suggestions = cursor.fetchall()
        follower_list_html = render_template("_user_follower_list.html", suggestions=suggestions)
        return f"""<browser mix-update="main">{ follower_list_html }</browser>"""

    except Exception as ex:
        ic(ex)
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()



############## ALL USER FOLLOWS ################
@app.get("/all-user-follows")
def view_all_user_follows():
    try:
        # Get the current logged-in user's primary key
        user_pk = g.user["user_pk"]

        db, cursor = x.db()


        # Query to get all users that the current user follows
        # Join `users` and `follows` tables
        # `follows.followed_user_fk` points to the user being followed
        # `follows.follow_user_fk` is the current logged-in user
        q = """
            SELECT users.*
            FROM users
            JOIN follows ON follows.followed_user_fk = users.user_pk
            WHERE follows.follow_user_fk = %s
        """
        cursor.execute(q, (user_pk,))

        suggestions = cursor.fetchall()

        follows_list_html = render_template("_user_follows_list.html", suggestions=suggestions)
        return f"""<browser mix-update="main">{ follows_list_html }</browser>"""

    except Exception as ex:
        ic(ex)
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()



# -------------------- SEARCH -------------------- #
############## API SEARCH ################
@app.post("/api-search")
def api_search():
    try:
        # Get the search input from the request
        search_for = request.form.get("search_for", "")
        
        if not search_for:
            return "empty search field", 400

        part_of_query = f"%{search_for}%"

        db, cursor = x.db() 

        # Look for matches in `user_username` and `user_first_name` using LIKE
        # Look for matches in `user_bio` using FULLTEXT search in BOOLEAN MODE
        # BOOLEAN MODE allows prefix search with "*", fx. "dev*" to match "developer"
        q = """
            SELECT * FROM users
            WHERE (
             user_username LIKE %s
               OR user_first_name LIKE %s
               OR MATCH(user_bio) AGAINST(%s IN BOOLEAN MODE)
               )
               AND user_is_blocked = 0
        """
        cursor.execute(q, (part_of_query, part_of_query, search_for + "*"))

        users = cursor.fetchall()

        # - Use FULLTEXT search on the `post_message` column in BOOLEAN MODE
        q = """
            SELECT * FROM posts
            WHERE MATCH(post_message) AGAINST(%s IN BOOLEAN MODE)
        """
        cursor.execute(q, (search_for + "*",))

        posts = cursor.fetchall()

        # The JSON response will have two keys: "users" and "posts"
        results = {
            "users": users,
            "posts": posts
        }

        # Return the combined results as JSON
        return jsonify(results)

    except Exception as ex:
        return str(ex)
    
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()










# -------------------- ADMIN -------------------- #

############# ADMIN #################
@app.get("/admin")
def view_admin():
    try:
        
        db, cursor = x.db()
        # SQL query to select all users who are NOT blocked
        q = "SELECT * FROM users WHERE user_is_blocked != 1"  
        cursor.execute(q) 
        rows = cursor.fetchall()
        
        # SQL query to select all users who ARE blocked
        q = "SELECT * FROM users WHERE user_is_blocked = 1"  
        cursor.execute(q) 
        blocked_rows = cursor.fetchall()

        # Render the template with both Blocked and Unblocked users
        admin_html = render_template("_admin.html", rows=rows, blocked_rows=blocked_rows)
        
        # Go to the admin panel
        return f"""<browser mix-update="main">{ admin_html }</browser>"""
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############# ADMIN-BLOCK-USER #################
@app.post("/admin-block-user/<user_pk>")
def admin_block_user(user_pk):
    try:
        db, cursor = x.db()
        # SQL query to toggle the 'user_is_blocked' status for a specific user
        q = "UPDATE users SET user_is_blocked = NOT user_is_blocked WHERE user_pk = %s"
        cursor.execute(q, (user_pk,))
        db.commit()

        # SQL query to fetch all users who are NOT blocked
        q = "SELECT * FROM users WHERE user_is_blocked != 1"
        cursor.execute(q)
        rows = cursor.fetchall()

        # SQL query to fetch all users who are blocked
        q = "SELECT * FROM users WHERE user_is_blocked = 1"
        cursor.execute(q)
        blocked_rows = cursor.fetchall()

        # SQL query to fetch the updated data for the specific user 
        q = "SELECT * FROM users WHERE user_pk = %s"
        cursor.execute(q, (user_pk,))
        row = cursor.fetchone()
        ic(row)

        # GET the user's email from the fetched row
        user_email = row["user_email"]

        # render templates for emails
        email_user_is_blocked = render_template("_email_user_is_blocked.html")
        email_user_is_unblocked = render_template("_email_user_is_unblocked.html")
        
        # Send an email to the user depending on their new blocked status
        if row["user_is_blocked"]:
            x.send_email(user_email=user_email, subject="You have been blocked from X", template=email_user_is_blocked)
        else:
            x.send_email(user_email=user_email, subject="You have been unblocked from X", template=email_user_is_unblocked)     

        block_unblock_html = render_template("___block_unblock_user.html", row=row)
        admin_html = render_template("_admin.html", rows=rows, blocked_rows=blocked_rows)
        return f"""
        <browser mix-replace="#block_unblock_user_{user_pk}">{block_unblock_html}</browser>
        <browser mix-update="main">{ admin_html }</browser>
        """
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()


############# ADMIN-BLOCK-POST #################
@app.post("/admin-block-post/<post_pk>")
def admin_block_post(post_pk):
    try:
        db, cursor = x.db()
        q = "UPDATE posts SET post_is_blocked = NOT post_is_blocked WHERE post_pk = %s"
        cursor.execute(q, (post_pk,))
        db.commit()

        # SQL query to fetch a specific post along with data on the user who created the post.
        q = """SELECT 
        posts.*,
        users.user_first_name,
        users.user_last_name,
        users.user_username,
        users.user_avatar_path
        FROM posts
        JOIN users ON posts.post_user_fk = users.user_pk
        WHERE posts.post_pk = %s"""

        cursor.execute(q, (post_pk,))
        tweet = cursor.fetchone()

        # SQL query to select the user who created the post, in order to get their email
        q = "SELECT * FROM users WHERE user_pk = %s"
        cursor.execute(q, (tweet["post_user_fk"],))
        row = cursor.fetchone()

        # The users email
        user_email = row["user_email"]

        email_post_is_blocked = render_template("_email_post_is_blocked.html")
        email_post_is_unblocked = render_template("_email_post_is_unblocked.html")

        # Send an email to the user
        if tweet["post_is_blocked"]:
            x.send_email(user_email=user_email, subject="Your post has been blocked", template=email_post_is_blocked)
        else:
            x.send_email(user_email=user_email, subject="Your post has been unblocked", template=email_post_is_unblocked)


        block_unblock_html = render_template("___block_unblock_post.html", tweet=tweet)
        tweet_html = render_template("_tweet.html", tweet=tweet)
        return f"""
        <browser mix-replace="#block_unblock_post_{post_pk}">{block_unblock_html}</browser>
        <browser mix-replace="#post_container_{post_pk}">{tweet_html}</browser>
        """
    except Exception as ex:
        ic(ex)
        return "error"
    finally:
        if "cursor" in locals(): cursor.close()
        if "db" in locals(): db.close()  



# -------------------- VERIFY ACCOUNT -------------------- #
############## VERIFY ACCOUNT ################
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




# -------------------- DICTIONARY -------------------- #
############# GET DATA FROM SHEET #################
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

        toast_ok = render_template("___toast_ok.html", message="Dictionary updated")
        return f"""
                <browser mix-bottom="#toast">{toast_ok}</browser>
                """
        
    except Exception as ex:
        ic(ex)
        return str(ex)
    finally: 
        pass