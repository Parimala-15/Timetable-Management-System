from werkzeug.security import generate_password_hash, check_password_hash

def hash_password(password):
    """Generate a secure password hash"""
    if not password or not isinstance(password, str):
        raise ValueError("Password must be a non-empty string")
    return generate_password_hash(password)

def verify_password(stored_hash, input_password):
    """Verify password against stored hash with validation"""
    if not all([stored_hash, input_password]):
        return False
    if not isinstance(stored_hash, str) or not stored_hash.startswith('pbkdf2:'):
        raise ValueError("Invalid password hash format")
    return check_password_hash(stored_hash, input_password)