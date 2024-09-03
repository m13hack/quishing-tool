import qrcode
import argparse

def generate_qr(url, output_file, color='black', background='white'):
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

def main():
    parser = argparse.ArgumentParser(description="Quishing CLI Tool - Generate QR Codes for Phishing.")
    parser.add_argument('url', type=str, help='The phishing URL to embed in the QR code.')
    parser.add_argument('--output', type=str, default='phishing_qr.png', help='Output filename for the QR code image.')
    parser.add_argument('--color', type=str, default='black', help='Color of the QR code.')
    parser.add_argument('--background', type=str, default='white', help='Background color of the QR code.')

    args = parser.parse_args()
    generate_qr(args.url, args.output, args.color, args.background)

if __name__ == "__main__":
    main()
