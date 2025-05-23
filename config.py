import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'your-secret-key-here'
    DB_HOST = 'localhost'
    DB_USER = 'root'
    DB_PASSWORD = 'umamagg2022..,,'
    DB_NAME = 'timetable_db'
    DB_POOL_SIZE = 5