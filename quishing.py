import os
import qrcode
import logging
import sys
from flask import Flask, request, send_from_directory, abort

app = Flask(__name__)

# Set up logging
log_directory = os.path.join(os.getcwd(), 'log')
os.makedirs(log_directory, exist_ok=True)

logging.basicConfig(
    filename=os.path.join(log_directory, 'access.log'),
    level=logging.INFO,
    format='%(asctime)s %(message)s'
)

def serve_site(site, filename):
    try:
        visitor_ip = request.remote_addr
        user_agent = request.headers.get('User-Agent')
        logging.info(f"IP: {visitor_ip}, User-Agent: {user_agent}, Site: {site}, File: {filename}")
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
    print("1. Generate QR Code")
    print("2. Start Phishing Server")
    print("3. Exit")
    choice = input("Please select an option (1-3): ")

    if choice == '1':
        url = input("Enter the URL for the QR Code: ")
        output = input("Enter the output file name (default: phishing_qr.png): ") or "phishing_qr.png"
        generate_qr(url, output)
        show_menu()
    elif choice == '2':
        print("Starting the phishing server...")
        start_server()
    elif choice == '3':
        print("Exiting the tool. Goodbye!")
        sys.exit(0)
    else:
        print("[ERROR] Invalid choice. Please select a valid option.")
        show_menu()

@app.route('/<site>/<path:filename>', methods=['GET'])
def serve_site_route(site, filename):
    return serve_site(site, filename)

if __name__ == "__main__":
    show_menu()
