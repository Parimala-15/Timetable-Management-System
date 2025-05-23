from app import get_db_connection

def create_tables():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        user_id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        email VARCHAR(100),
        role VARCHAR(20) DEFAULT 'user'
    )""")
    
    # Add admin user
    from werkzeug.security import generate_password_hash
    cursor.execute(
        "INSERT INTO users (username, password, role) VALUES (%s, %s, 'admin')",
        ("admin", generate_password_hash("Admin123!"))
    )
    
    conn.commit()
    print("✅ Tables created + admin user added")

if __name__ == "__main__":
    create_tables()