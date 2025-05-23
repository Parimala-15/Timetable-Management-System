from app import app, get_db_connection
from werkzeug.security import generate_password_hash

def migrate():
    with app.app_context():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute("SELECT user_id, password FROM users")
        users = cursor.fetchall()
        
        for user in users:
            if not user['password'].startswith('pbkdf2:'):
                new_hash = generate_password_hash(
                    user['password'],
                    method='pbkdf2:sha256',
                    salt_length=16
                )
                cursor.execute(
                    "UPDATE users SET password = %s WHERE user_id = %s",
                    (new_hash, user['user_id'])
                )
                print(f"Updated user {user['user_id']}")
        
        conn.commit()
        conn.close()

if __name__ == '__main__':
    migrate()