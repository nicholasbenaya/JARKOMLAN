import sys
import itertools
import urllib.request
import urllib.error
from http.server import HTTPServer, BaseHTTPRequestHandler
import argparse
from datetime import datetime

# ==============================================================================
# Pure Python Reverse Proxy & Load Balancer (No Dependencies Required)
# ==============================================================================

class ReverseProxyHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass # Ditangani custom di do_GET/do_POST

    def forward_request(self, method):
        target_backend = next(self.server.backend_cycle)
        target_url = f"{target_backend.rstrip('/')}{self.path}"

        headers = {k: v for k, v in self.headers.items() if k.lower() not in ['host', 'content-length']}
        headers['Host'] = target_backend.replace('http://', '').replace('https://', '')
        headers['X-Forwarded-For'] = self.client_address[0]
        headers['X-Forwarded-Proto'] = 'http'

        body = None
        if 'Content-Length' in self.headers:
            body = self.rfile.read(int(self.headers['Content-Length']))

        req = urllib.request.Request(target_url, data=body, headers=headers, method=method)

        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] [PROXY] {self.client_address[0]} -> {target_backend} ({self.path})")

        try:
            with urllib.request.urlopen(req, timeout=5) as resp:
                resp_body = resp.read()
                self.send_response(resp.status)
                for header, val in resp.headers.items():
                    if header.lower() not in ['transfer-encoding', 'content-length', 'connection']:
                        self.send_header(header, val)
                self.send_header('Content-Length', str(len(resp_body)))
                self.send_header('X-Served-By-Proxy', 'JARKOMLAN-ReverseProxy-Native')
                self.end_headers()
                self.wfile.write(resp_body)
        except urllib.error.HTTPError as e:
            err_body = e.read()
            self.send_response(e.code)
            self.send_header('Content-Type', 'text/html')
            self.send_header('Content-Length', str(len(err_body)))
            self.end_headers()
            self.wfile.write(err_body)
        except Exception as e:
            msg = f"<h1>502 Bad Gateway</h1><p>Gagal menghubungi backend {target_backend}: {e}</p>".encode('utf-8')
            self.send_response(502)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', str(len(msg)))
            self.end_headers()
            self.wfile.write(msg)

    def do_GET(self):
        self.forward_request('GET')

    def do_POST(self):
        self.forward_request('POST')

    def do_HEAD(self):
        self.forward_request('HEAD')

def run():
    parser = argparse.ArgumentParser(description="Python Native Reverse Proxy Load Balancer")
    parser.add_argument("--port", type=int, default=80, help="Port proxy mendengarkan (default 80)")
    parser.add_argument("--host1-ip", type=str, default="127.0.0.1", help="Alamat IP LAN Host 1")
    args = parser.parse_args()

    backend_nodes = [
        f"http://{args.host1_ip}:5001",
        f"http://{args.host1_ip}:5002",
        f"http://{args.host1_ip}:5003",
        f"http://{args.host1_ip}:5004",
    ]

    server_address = ('0.0.0.0', args.port)
    try:
        httpd = HTTPServer(server_address, ReverseProxyHandler)
    except PermissionError:
        print(f"[!] Akses ditolak pada port {args.port}. Coba gunakan port 8080 atau jalankan sebagai Administrator.")
        server_address = ('0.0.0.0', 8080)
        httpd = HTTPServer(server_address, ReverseProxyHandler)
        args.port = 8080

    httpd.backend_cycle = itertools.cycle(backend_nodes)

    print("==================================================")
    print(" REVERSE PROXY & LOAD BALANCER NATIVE AKTIF       ")
    print(f" Listening: http://0.0.0.0:{args.port}          ")
    print(f" Upstream Cluster Host 1 ({args.host1_ip}):     ")
    for node in backend_nodes:
        print(f"  - {node}")
    print("==================================================")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[!] Reverse Proxy dihentikan.")
        httpd.server_close()

if __name__ == '__main__':
    run()
