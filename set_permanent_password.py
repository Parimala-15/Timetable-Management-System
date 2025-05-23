from werkzeug.security import generate_password_hash
from app import get_db_connection

# Generate permanent hash
permanent_password = "TempReset123!"
hashed_pw = generate_password_hash(permanent_password, method='pbkdf2:sha256')

# Update database
conn = get_db_connection()
cursor = conn.cursor()
cursor.execute(
    "UPDATE users SET password = %s WHERE username = 'admin'",
    (hashed_pw,)
)
conn.commit()
print(f"✅ Permanent password set to: {permanent_password}")