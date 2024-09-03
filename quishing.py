import os
import qrcode
import argparse
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

@app.route('/<site>/<path:filename>', methods=['GET'])
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

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Quishing Tool")
    parser.add_argument("--action", choices=['generate', 'start'], required=True, help="Action to perform")
    parser.add_argument("--url", help="URL for QR code generation")
    parser.add_argument("--output", default="phishing_qr.png", help="Output filename for QR code")
    args = parser.parse_args()

    if args.action == 'generate':
        if not args.url:
            print("[ERROR] URL is required for QR code generation.")
            sys.exit(1)
        generate_qr(args.url, args.output)
    elif args.action == 'start':
        app.run(host='0.0.0.0', port=5000)
