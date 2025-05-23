from werkzeug.security import generate_password_hash
from app import get_db_connection

def setup_admin():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Create fresh admin user
    admin_hash = generate_password_hash("Admin123!", method='pbkdf2:sha256')
    
    cursor.execute(
        "INSERT INTO users (username, password, email, role) VALUES (%s, %s, %s, %s)",
        ("admin", admin_hash, "admin@example.com", "admin")
    )
    
    conn.commit()
    conn.close()
    print("✅ Admin account created: username='admin', password='Admin123!'")

if __name__ == "__main__":
    setup_admin()