import os
import sys
import time
import urllib.request
import json

WEB_SERVER_HOST = os.getenv("WEB_SERVER_HOST", "192.168.1.15")
WEB_SERVER_PORT = os.getenv("WEB_SERVER_PORT", "8080")

def main():
    target_url = f"http://{WEB_SERVER_HOST}:{WEB_SERVER_PORT}/api/telemetry"
    print("============================================================")
    print("   JARKOMLAN: Web Client Verifikasi (Host 2)                ")
    print(f"   Target URL: {target_url}")
    print("============================================================")

    try:
        req = urllib.request.Request(target_url, headers={"User-Agent": "Host2-WebClient/1.0"})
        with urllib.request.urlopen(req, timeout=5) as response:
            status_code = response.getcode()
            raw_body = response.read().decode("utf-8")
            data = json.loads(raw_body)

        print(f"[✓] Respon HTTP {status_code} OK!")
        print(f"[*] Total Records di DB: {data.get('total_records')}")
        print(f"[*] Jumlah Data Ditampilkan: {data.get('count')}")
        print("------------------------------------------------------------")
        print(f"{'ID':<6} | {'Device ID':<16} | {'Suhu':<8} | {'Kelembapan':<10} | {'Waktu Diterima'}")
        print("------------------------------------------------------------")
        for item in data.get("data", [])[:10]:
            print(f"{item.get('id'):<6} | {item.get('device_id'):<16} | {str(item.get('temperature')) + ' C':<8} | {str(item.get('humidity')) + ' %':<10} | {item.get('created_at')}")
        print("------------------------------------------------------------")
        print("[✓] Verifikasi Web Client selesai!")
    except Exception as e:
        print(f"[!] Gagal menghubungi Web Server di {target_url}: {e}")
        print("    Tips:")
        print("    1. Pastikan VM Linux di Host 1 sudah menjalankan app.py.")
        print("    2. Pastikan IP target sudah sesuai dengan IP VM Linux.")

if __name__ == "__main__":
    main()
