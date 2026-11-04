#!/bin/sh
# ==============================================================================
# Script Runner Server Node untuk VM Linux (Alpine / Ubuntu / Debian)
# Penggunaan:
#   sh server_vm.sh 5002 "Node 2 - Linux VM 1" "#22c55e"
#   sh server_vm.sh 5003 "Node 3 - Linux VM 2" "#eab308"
# ==============================================================================

PORT=${1:-5002}
NODE_NAME=${2:-"Node 2 - Linux VM 1"}
COLOR=${3:-"#22c55e"}
PLATFORM="VirtualBox Linux VM"

echo "=================================================="
echo " Mempersiapkan Server Node: $NODE_NAME"
echo " Port: $PORT | Color: $COLOR"
echo "=================================================="

# Pastikan DNS dan repositori aktif
echo "nameserver 8.8.8.8" > /etc/resolv.conf
if [ -f /etc/alpine-release ]; then
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.20/main" > /etc/apk/repositories
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.20/community" >> /etc/apk/repositories
fi

# Pastikan Python 3 terpasang
if ! command -v python3 >/dev/null 2>&1; then
    echo "[i] Memasang python3..."
    if command -v apk >/dev/null 2>&1; then
        apk add --no-cache python3
    elif command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y python3
    fi
fi

# Jika file server_node.py sudah ada, jalankan langsung
if [ -f "server_node.py" ]; then
    echo "[i] Menjalankan server_node.py..."
    python3 server_node.py --port "$PORT" --name "$NODE_NAME" --platform "$PLATFORM" --color "$COLOR"
    exit 0
fi

# Jika belum ada file server_node.py, buat inline server mandiri
cat << 'EOF' > /tmp/vm_server.py
import sys
import socket
import argparse
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

hit_count = 0

class VMHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] [{self.server.node_name}] {self.address_string()} - {format % args}")

    def do_GET(self):
        global hit_count
        hit_count += 1
        client_ip = self.headers.get('X-Forwarded-For', self.client_address[0])
        proxy_ip = self.client_address[0]
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        if self.path.startswith('/api') or 'application/json' in self.headers.get('Accept', ''):
            data = {
                "status": "success",
                "node_name": self.server.node_name,
                "node_platform": self.server.node_platform,
                "port": self.server.server_port,
                "hit_count": hit_count,
                "client_ip": client_ip,
                "proxy_ip": proxy_ip,
                "timestamp": timestamp,
                "hostname": socket.gethostname()
            }
            payload = json.dumps(data, indent=2).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', str(len(payload)))
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.end_headers()
            self.wfile.write(payload)
            return

        html = f"""<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{self.server.node_name}</title>
    <style>
        body {{ font-family: sans-serif; background: #0f172a; color: #f8fafc; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; padding: 16px; }}
        .card {{ background: #1e293b; border: 2px solid {self.server.badge_color}; border-radius: 16px; padding: 24px; max-width: 480px; width: 100%; text-align: center; }}
        .badge {{ display: inline-block; background: {self.server.badge_color}; color: #0f172a; font-weight: bold; padding: 6px 14px; border-radius: 9999px; text-transform: uppercase; margin-bottom: 16px; }}
        h1 {{ margin: 0 0 8px 0; }}
        .hit {{ font-size: 2rem; color: #38bdf8; font-weight: bold; margin: 16px 0; }}
    </style>
</head>
<body>
    <div class="card">
        <div class="badge">{self.server.node_platform}</div>
        <h1>{self.server.node_name}</h1>
        <p>Port: :{self.server.server_port} | Hostname: {socket.gethostname()}</p>
        <div class="hit">Hit Counter: #{hit_count}</div>
        <p style="font-size: 0.85rem; color: #94a3b8;">Client IP: {client_ip} | Waktu: {timestamp}</p>
    </div>
</body>
</html>"""
        payload = html.encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Content-Length', str(len(payload)))
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.end_headers()
        self.wfile.write(payload)

parser = argparse.ArgumentParser()
parser.add_argument("--port", type=int, default=5002)
parser.add_argument("--name", type=str, default="Node 2 - Linux VM")
parser.add_argument("--platform", type=str, default="VirtualBox VM")
parser.add_argument("--color", type=str, default="#22c55e")
args = parser.parse_args()

httpd = HTTPServer(('0.0.0.0', args.port), VMHandler)
httpd.node_name = args.name
httpd.node_platform = args.platform
httpd.badge_color = args.color
print(f"[*] Node Server Aktif di 0.0.0.0:{args.port}")
httpd.serve_forever()
EOF

python3 /tmp/vm_server.py --port "$PORT" --name "$NODE_NAME" --platform "$PLATFORM" --color "$COLOR"
