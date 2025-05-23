try:
    from config import Config
    print("Success! Config imported correctly")
except ImportError as e:
    print(f"Import failed: {e}")
    print("Current Python path:", sys.path)