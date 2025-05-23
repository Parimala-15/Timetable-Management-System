from werkzeug.security import generate_password_hash
from app import get_db_connection

ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "Admin123!"  # Case-sensitive!
ADMIN_EMAIL = "admin@example.com"

def reset_admin():
    conn = get_db_connection()
    cursor = conn.cursor()
    hashed_pw = generate_password_hash(ADMIN_PASSWORD, method='pbkdf2:sha256')
    
    cursor.execute(
        """
        INSERT INTO users (username, password, email, role) 
        VALUES (%s, %s, %s, 'admin')
        ON DUPLICATE KEY UPDATE password = %s
        """,
        (ADMIN_USERNAME, hashed_pw, ADMIN_EMAIL, hashed_pw)
    )
    conn.commit()
    conn.close()
    print(f"✅ Admin reset: Username='{ADMIN_USERNAME}', Password='{ADMIN_PASSWORD}'")

if __name__ == "__main__":
    reset_admin()