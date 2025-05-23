import subprocess
import os

# Configuration
MYSQL_PATH = r'"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"'
DB_PASSWORD = "Parimala@15"
SCHEMA_PATH = os.path.abspath("schema.sql")

def run_command(cmd):
    try:
        subprocess.run(cmd, shell=True, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed: {cmd}\nError: {e}")
        return False

print("1. Dropping and recreating database...")
if not run_command(f"{MYSQL_PATH} -u root -p{DB_PASSWORD} -e \"DROP DATABASE IF EXISTS timetable_db; CREATE DATABASE timetable_db;\""):
    exit(1)

print("2. Disabling foreign key checks...")
if not run_command(f"{MYSQL_PATH} -u root -p{DB_PASSWORD} timetable_db -e \"SET FOREIGN_KEY_CHECKS=0;\""):
    exit(1)

print(f"3. Importing {SCHEMA_PATH}...")
if not run_command(f"type {SCHEMA_PATH} | {MYSQL_PATH} -u root -p{DB_PASSWORD} timetable_db"):
    print("\nTroubleshooting:")
    print(f"- Verify file exists: dir {SCHEMA_PATH}")
    print("- Try manual import:")
    print(f"  {MYSQL_PATH} -u root -p timetable_db < {SCHEMA_PATH}")
    exit(1)

print("4. Enabling foreign key checks...")
run_command(f"{MYSQL_PATH} -u root -p{DB_PASSWORD} timetable_db -e \"SET FOREIGN_KEY_CHECKS=1;\"")

print("✅ Database initialized successfully!")