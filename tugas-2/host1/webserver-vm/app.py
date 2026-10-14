import os
import time
from datetime import datetime
from flask import Flask, render_template, jsonify, request
import pymysql
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Konfigurasi Database (Menghubungkan ke Host 1 Docker MySQL)
DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_USER = os.getenv("DB_USER", "jarkom")
DB_PASSWORD = os.getenv("DB_PASSWORD", "jarkom123")
DB_NAME = os.getenv("DB_NAME", "jarkom_iot")

def get_db_connection():
    """Membuka koneksi ke MySQL di Host 1."""
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=5
    )

@app.route("/")
def index():
    """Halaman Dashboard Utama."""
    server_info = {
        "db_host": DB_HOST,
        "db_port": DB_PORT,
        "db_name": DB_NAME,
        "server_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    return render_template("index.html", server_info=server_info)

@app.route("/api/health")
def health():
    """Endpoint pengecekan koneksi database."""
    try:
        start_time = time.time()
        conn = get_db_connection()
        conn.close()
        latency_ms = round((time.time() - start_time) * 1000, 2)
        return jsonify({
            "status": "healthy",
            "db_connected": True,
            "latency_ms": latency_ms,
            "db_target": f"{DB_HOST}:{DB_PORT}"
        }), 200
    except Exception as e:
        return jsonify({
            "status": "unhealthy",
            "db_connected": False,
            "error": str(e),
            "db_target": f"{DB_HOST}:{DB_PORT}"
        }), 503

@app.route("/api/telemetry")
def get_telemetry():
    """Mengambil 20 data telemetri sensor terbaru."""
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            sql = """
                SELECT id, device_id, topic, temperature, humidity, voltage, raw_payload,
                       DATE_FORMAT(created_at, '%%Y-%%m-%%d %%H:%%i:%%s') as created_at
                FROM sensor_telemetry
                ORDER BY id DESC
                LIMIT 20
            """
            cursor.execute(sql)
            rows = cursor.fetchall()
            
            # Hitung statistik ringkas
            cursor.execute("SELECT COUNT(*) as total_count FROM sensor_telemetry")
            total_count = cursor.fetchone()["total_count"]
        conn.close()

        return jsonify({
            "status": "success",
            "count": len(rows),
            "total_records": total_count,
            "data": rows
        }), 200
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e),
            "data": []
        }), 500

if __name__ == "__main__":
    bind_port = int(os.getenv("PORT", "8080"))
    print(f"[*] Menjalankan Web Server di http://0.0.0.0:{bind_port}")
    print(f"[*] Target DB Host: {DB_HOST}:{DB_PORT}")
    app.run(host="0.0.0.0", port=bind_port, debug=False)
