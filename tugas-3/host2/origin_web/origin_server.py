import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from datetime import datetime

class OriginHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        # Tambahkan header caching HTTP agar Squid tahu file ini boleh di-cache
        self.send_header('Cache-Control', 'public, max-age=3600')
        self.send_header('X-Origin-Server', 'Host 2 Origin Server')
        super().end_headers()

    def log_message(self, format, *args):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] [ORIGIN HIT] {self.address_string()} - {format % args}")

def run():
    port = 8080
    server_address = ('0.0.0.0', port)
    httpd = HTTPServer(server_address, OriginHandler)
    print("==================================================")
    print(" ORIGIN WEB SERVER (HOST 2) AKTIF                ")
    print(f" Listening: http://0.0.0.0:{port}                ")
    print(" Caching Header: max-age=3600 (1 Jam)            ")
    print("==================================================")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[!] Origin Web Server dimatikan.")
        httpd.server_close()

if __name__ == '__main__':
    run()
