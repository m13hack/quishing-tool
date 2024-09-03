from flask import Flask, request
import logging

app = Flask(__name__)

logging.basicConfig(filename='log/access.log', level=logging.INFO)

@app.route('/')
def index():
    user_ip = request.remote_addr
    logging.info(f'IP: {user_ip}')
    return "Phishing Page"

if __name__ == "__main__":
    app.run(debug=True)
