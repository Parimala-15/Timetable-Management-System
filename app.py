from flask import Flask, render_template, request, jsonify, session, redirect, url_for, flash
import mysql.connector
from mysql.connector import Error
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
import logging
import os
import subprocess
from datetime import timedelta

# Initialize Flask app
app = Flask(__name__)
app.secret_key = os.urandom(24).hex()
app.permanent_session_lifetime = timedelta(minutes=30)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('timetable.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Database Configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'umamagg2022..,,',
    'database': 'timetable_db',
    'auth_plugin': 'mysql_native_password',
    'connect_timeout': 10
}

# MySQL Path Configuration
MYSQL_PATH = r'"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"'

# ================== PASSWORD HANDLING IMPROVEMENTS ==================
def validate_password_hash(hashed_pw):
    """Strict validation for password hashes"""
    return (isinstance(hashed_pw, str) and 
           hashed_pw.startswith('pbkdf2:sha256:') and 
           len(hashed_pw) > 60
    )

def secure_password_hash(password):
    """Generate password hash with explicit parameters"""
    return generate_password_hash(
        password,
        method='pbkdf2:sha256',
        salt_length=16
    )

def reset_user_password(username, new_password):
    """Safe password reset function"""
    conn = get_db_connection()
    if not conn:
        return False
        
    try:
        cursor = conn.cursor()
        hashed_pw = secure_password_hash(new_password)
        cursor.execute(
            "UPDATE users SET password = %s WHERE username = %s",
            (hashed_pw, username)
        )
        conn.commit()
        return True
    except Error as e:
        logger.error(f"Password reset failed: {e}")
        return False
    finally:
        if conn.is_connected():
            conn.close()
# ====================================================================

def run_mysql_command(command, database=None):
    """Execute a MySQL command with proper authentication"""
    cmd = f"{MYSQL_PATH} -u {DB_CONFIG['user']} -p{DB_CONFIG['password']}"
    if database:
        cmd += f" {database}"
    cmd += f' -e "{command}"'
    
    try:
        subprocess.run(cmd, shell=True, check=True)
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed: {cmd}")
        logger.error(f"Error: {e}")
        return False

def initialize_database():
    """Initialize the database using the schema.sql file"""
    try:
        schema_path = os.path.abspath(os.path.join('database', 'schema.sql'))
        
        if not run_mysql_command("DROP DATABASE IF EXISTS timetable_db; CREATE DATABASE timetable_db;"):
            return False

        if not run_mysql_command("SET FOREIGN_KEY_CHECKS=0;", "timetable_db"):
            return False

        import_cmd = f'{MYSQL_PATH} -u {DB_CONFIG["user"]} -p{DB_CONFIG["password"]} timetable_db < "{schema_path}"'
        try:
            subprocess.run(import_cmd, shell=True, check=True)
        except subprocess.CalledProcessError as e:
            logger.error(f"Import failed: {import_cmd}")
            logger.error("Try running manually:")
            logger.error(f'"{MYSQL_PATH}" -u root -p timetable_db < "{schema_path}"')
            return False

        run_mysql_command("SET FOREIGN_KEY_CHECKS=1;", "timetable_db")
        logger.info("✅ Database initialized successfully")
        return True
        
    except Exception as e:
        logger.error(f"❌ Unexpected error during initialization: {e}")
        return False

def get_db_connection():
    """Establish and return database connection"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        logger.error(f"Database connection failed: {e}")
        return None

# Decorators
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please login first', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# ================== IMPROVED AUTH ROUTES ==================
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()
        email = request.form.get('email', '').strip()
        
        if not all([username, password, email]):
            flash('All fields are required', 'danger')
            return render_template('register.html')
        
        try:
            hashed_pw = secure_password_hash(password)
            
            conn = get_db_connection()
            if not conn:
                flash('Database connection error', 'danger')
                return render_template('register.html')
            
            with conn.cursor() as cursor:
                cursor.execute(
                    "INSERT INTO users (username, password, email) VALUES (%s, %s, %s)",
                    (username, hashed_pw, email)
                )
                conn.commit()
                flash('Registration successful! Please login', 'success')
                return redirect(url_for('login'))
                
        except mysql.connector.IntegrityError:
            flash('Username already exists', 'danger')
        except Exception as e:
            logger.error(f"Registration error: {e}")
            flash('Registration failed', 'danger')
        finally:
            if conn and conn.is_connected():
                conn.close()
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()
        
    
        if not username or not password:
            flash('Both fields are required', 'danger')
            return render_template('login.html')
        
        conn = get_db_connection()
        if not conn:
            flash('Database connection error', 'danger')
            return render_template('login.html')
        
        try:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    "SELECT user_id, username, password, role FROM users WHERE username = %s", 
                    (username,)
                )
                user = cursor.fetchone()
                
                if not user:
                    flash('Invalid credentials', 'danger')
                elif not validate_password_hash(user['password']):
                    logger.error(f"Invalid hash format for user {username}")
                    if reset_user_password(username, "TempReset123!"):
                        flash('Your password was automatically reset. Please try again with "TempReset123!"', 'warning')
                    else:
                        flash('System error: password reset required', 'danger')
                elif check_password_hash(user['password'], password):
                    session.permanent = True
                    session['user_id'] = user['user_id']
                    session['username'] = user['username']
                    session['role'] = user.get('role', 'user')
                    flash('Login successful!', 'success')
                    return redirect(url_for('select_group'))
                else:
                    flash('Invalid credentials', 'danger')
        except Error as e:
            logger.error(f"Login error: {e}")
            flash('Server error during login', 'danger')
        finally:
            if conn and conn.is_connected():
                conn.close()
    
    return render_template('login.html')
@app.route('/select_group', methods=['GET', 'POST'])
@login_required
def select_group():
    if request.method == 'POST':
        session['year'] = request.form['year']
        session['section'] = request.form['section']
        return redirect(url_for('index'))  # Go to index after selecting group
    return render_template('partials/select_group.html')





@app.route('/admin/reset-passwords', methods=['POST'])
@login_required
def admin_reset_passwords():
    if session.get('role') != 'admin':
        flash('Admin access required', 'danger')
        return redirect(url_for('index'))
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        temp_pw = "TempReset123!"
        hashed_pw = secure_password_hash(temp_pw)
        
        cursor.execute("UPDATE users SET password = %s", (hashed_pw,))
        conn.commit()
        flash(f'All passwords reset to "{temp_pw}"', 'success')
    except Exception as e:
        logger.error(f"Password reset failed: {e}")
        flash('Password reset failed', 'danger')
    finally:
        if conn and conn.is_connected():
            conn.close()
    
    return redirect(url_for('index'))
# =============================================================

@app.route('/')
@login_required
def index():
    return render_template('index.html')
@app.route('/timetable', methods=['POST'])
@login_required
def timetable():
    # Get selected year and section from form
    session['year'] = request.form.get('year')
    session['section'] = request.form.get('section')
    
    # Redirect back to the timetable view
    return redirect(url_for('index'))  # Make sure 'index' renders index.html


@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out', 'info')
    return redirect(url_for('login'))

@app.route('/api/timetable')
@login_required
def get_timetable():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        with conn.cursor(dictionary=True) as cursor:
            cursor.execute("""
                SELECT ts.day, ts.period, ts.start_time, ts.end_time, ts.is_lunch,
                       s.subject_code, s.subject_name, 
                       f.name as faculty_name, f.designation,
                       r.room_id, r.building,
                       te.notes
                FROM timetable_slots ts
                LEFT JOIN timetable_entries te ON ts.slot_id = te.slot_id
                LEFT JOIN subjects s ON te.subject_code = s.subject_code
                LEFT JOIN faculty f ON te.faculty_id = f.faculty_id
                LEFT JOIN rooms r ON te.room_id = r.room_id
                WHERE te.group_id = 1
                ORDER BY FIELD(ts.day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), ts.period
            """)
            
            timetable = {day: {} for day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']}
            
            for row in cursor:
                day = row['day']
                period = row['period']
                
                if row['is_lunch']:
                    timetable[day][period] = {'is_lunch': True}
                elif row['subject_code']:
                    timetable[day][period] = {
                        'subject_code': row['subject_code'],
                        'subject_name': row['subject_name'],
                        'faculty': f"{row['faculty_name']} ({row['designation']})",
                        'room': f"{row['room_id']} ({row['building']})",
                        'time': f"{row['start_time']}-{row['end_time']}",
                        'notes': row['notes'] or ''
                    }
            
            return jsonify(timetable)
    except Error as e:
        logger.error(f"Timetable API error: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if conn and conn.is_connected():
            conn.close()
@app.cli.command('reset-admin')
def reset_admin_command():
    """Reset admin password via command line"""
    from werkzeug.security import generate_password_hash
    conn = get_db_connection()
    cursor = conn.cursor()
    
    admin_pw = "Admin123!"  # Change if needed
    hashed_pw = generate_password_hash(admin_pw, method='pbkdf2:sha256')
    
    cursor.execute(
        """
        INSERT INTO users (username, password, email, role) 
        VALUES ('admin', %s, 'admin@example.com', 'admin')
        ON DUPLICATE KEY UPDATE password = %s
        """,
        (hashed_pw, hashed_pw)
    )
    conn.commit()
    conn.close()
    print(f"Admin password reset to: {admin_pw}")

if __name__ == '__main__':
    if initialize_database():
        app.run(host='0.0.0.0', port=5000, debug=True)
    else:
        logger.critical("Failed to initialize database - check logs")