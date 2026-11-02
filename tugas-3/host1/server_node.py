import sys
import os
import socket
import argparse
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

hit_count = 0

class ClusterNodeHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Format log ringkas dan informatif
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] [{self.server.node_name}] {self.address_string()} - {format % args}")

    def do_GET(self):
        global hit_count
        hit_count += 1

        client_ip = self.headers.get('X-Forwarded-For', self.client_address[0])
        proxy_ip = self.client_address[0]
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Jika request meminta JSON
        if self.path.startswith('/api') or 'application/json' in self.headers.get('Accept', ''):
            response_data = {
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
            payload = json.dumps(response_data, indent=2).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', str(len(payload)))
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.end_headers()
            self.wfile.write(payload)
            return

        # Response HTML visual untuk browser HP / Laptop
        badge_color = self.server.badge_color
        html_content = f"""<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{self.server.node_name} - JARKOMLAN Cluster</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background: #0f172a;
            color: #f8fafc;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 16px;
        }}
        .card {{
            background: #1e293b;
            border: 2px solid {badge_color};
            border-radius: 16px;
            padding: 24px;
            max-width: 480px;
            width: 100%;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.5);
            text-align: center;
        }}
        .badge {{
            display: inline-block;
            background: {badge_color};
            color: #0f172a;
            font-weight: 700;
            font-size: 0.85rem;
            padding: 6px 14px;
            border-radius: 9999px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 16px;
        }}
        h1 {{
            font-size: 1.6rem;
            margin-bottom: 8px;
            color: #ffffff;
        }}
        p.subtitle {{
            color: #94a3b8;
            font-size: 0.95rem;
            margin-bottom: 24px;
        }}
        .stats-grid {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            text-align: left;
            margin-bottom: 24px;
        }}
        .stat-item {{
            background: #0f172a;
            padding: 12px;
            border-radius: 8px;
            border: 1px solid #334155;
        }}
        .stat-label {{
            font-size: 0.75rem;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 4px;
        }}
        .stat-value {{
            font-size: 1rem;
            font-weight: 600;
            color: #38bdf8;
            word-break: break-all;
        }}
        .hit-box {{
            background: rgba(56, 189, 248, 0.1);
            border: 1px dashed #38bdf8;
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 16px;
        }}
        .hit-box span {{
            font-size: 1.8rem;
            font-weight: 800;
            color: #38bdf8;
        }}
        .footer {{
            font-size: 0.8rem;
            color: #64748b;
        }}
    </style>
</head>
<body>
    <div class="card">
        <div class="badge">{self.server.node_platform}</div>
        <h1>{self.server.node_name}</h1>
        <p class="subtitle">Dilayani oleh Reverse Proxy & Load Balancer</p>

        <div class="hit-box">
            <div class="stat-label">Total Permintaan Diterima Node Ini</div>
            <span>#{hit_count}</span>
        </div>

        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-label">Port Node</div>
                <div class="stat-value">:{self.server.server_port}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Client IP (HP)</div>
                <div class="stat-value">{client_ip}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Proxy IP</div>
                <div class="stat-value">{proxy_ip}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Waktu Request</div>
                <div class="stat-value">{timestamp}</div>
            </div>
        </div>

        <div class="footer">
            Tugas 3 JARKOMLAN - Sistem Terdistribusi Load Balancing
        </div>
    </div>
</body>
</html>
"""
        payload = html_content.encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Content-Length', str(len(payload)))
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.end_headers()
        self.wfile.write(payload)

def run():
    parser = argparse.ArgumentParser(description="Cluster Node HTTP Server")
    parser.add_argument("--port", type=int, default=5001, help="Port server mendengarkan")
    parser.add_argument("--name", type=str, default="Node 1 - Windows", help="Nama unik node")
    parser.add_argument("--platform", type=str, default="Windows Native", help="Platform eksekusi")
    parser.add_argument("--color", type=str, default="#38bdf8", help="Warna tema HEX badge")
    args = parser.parse_args()

    server_address = ('0.0.0.0', args.port)
    httpd = HTTPServer(server_address, ClusterNodeHandler)
    httpd.node_name = args.name
    httpd.node_platform = args.platform
    httpd.badge_color = args.color

    print(f"==================================================")
    print(f" Server Aktif: {args.name}")
    print(f" Platform    : {args.platform}")
    print(f" Listening   : 0.0.0.0:{args.port}")
    print(f"==================================================")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[!] Server dimatikan.")
        httpd.server_close()

if __name__ == '__main__':
    run()
