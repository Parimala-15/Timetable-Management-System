# reset_passwords.py
from werkzeug.security import generate_password_hash
from app import get_db_connection

def reset_all_passwords():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    TEMP_PASSWORD = "TempPass123!"  # Change if needed
    hashed_pw = generate_password_hash(TEMP_PASSWORD, method='pbkdf2:sha256')
    
    cursor.execute("UPDATE users SET password = %s", (hashed_pw,))
    conn.commit()
    conn.close()
    print(f"All passwords reset to: {TEMP_PASSWORD}")

if __name__ == "__main__":
    reset_all_passwords()