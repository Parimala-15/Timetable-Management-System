import mysql.connector
from mysql.connector import Error
from config import Config

def execute_query(query, params=None, fetch=True):
    """Generic database query executor"""
    conn = None
    try:
        conn = mysql.connector.connect(
            host=Config.DB_HOST,
            user=Config.DB_USER,
            password=Config.DB_PASSWORD,
            database=Config.DB_NAME
        )
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        
        if fetch:
            if 'SELECT' in query.upper():
                return cursor.fetchall()
            else:
                conn.commit()
                return cursor.rowcount
        return None
        
    except Error as e:
        print(f"Database error: {e}")
        return None
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()