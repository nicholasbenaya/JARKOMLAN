import json
import logging
import os
import sys
import time
import paho.mqtt.client as mqtt
import pymysql

# Konfigurasi Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [MQTT-SUBSCRIBER] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)

# Pengambilan Konfigurasi dari Environment Variable
MQTT_BROKER = os.getenv("MQTT_BROKER_HOST", "mqtt-broker")
MQTT_PORT = int(os.getenv("MQTT_BROKER_PORT", "1883"))
MQTT_TOPIC = os.getenv("MQTT_TOPIC", "jarkom/sensor/#")

DB_HOST = os.getenv("DB_HOST", "db-server")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_USER = os.getenv("DB_USER", "jarkom")
DB_PASSWORD = os.getenv("DB_PASSWORD", "jarkom123")
DB_NAME = os.getenv("DB_NAME", "jarkom_iot")

def get_db_connection():
    """Membuka koneksi ke database MySQL dengan toleransi waktu startup."""
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )

def wait_for_db(max_retries=15, delay=3):
    """Menunggu hingga container database siap menerima koneksi."""
    logging.info(f"Menghubungkan ke MySQL di {DB_HOST}:{DB_PORT} (Database: {DB_NAME})...")
    for attempt in range(1, max_retries + 1):
        try:
            conn = get_db_connection()
            conn.close()
            logging.info("Koneksi ke MySQL berhasil!")
            return True
        except Exception as e:
            logging.warning(f"Percobaan ke-{attempt}/{max_retries} gagal: {e}. Mencoba lagi dalam {delay} detik...")
            time.sleep(delay)
    logging.error("Gagal terhubung ke MySQL setelah beberapa percobaan.")
    return False

def save_telemetry(device_id, topic, temp, hum, volt, raw_payload):
    """Menyimpan record telemetri ke tabel sensor_telemetry."""
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO sensor_telemetry (device_id, topic, temperature, humidity, voltage, raw_payload)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (device_id, topic, temp, hum, volt, raw_payload))
        conn.close()
        logging.info(f"Berhasil menyimpan data dari [{device_id}] pada topik [{topic}] ke MySQL.")
    except Exception as e:
        logging.error(f"Gagal menyimpan data ke database: {e}")

def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        logging.info(f"Terhubung ke Broker MQTT ({MQTT_BROKER}:{MQTT_PORT})")
        client.subscribe(MQTT_TOPIC)
        logging.info(f"Berlangganan (Subscribed) ke topik: '{MQTT_TOPIC}'")
    else:
        logging.error(f"Gagal terhubung ke MQTT Broker dengan return code: {rc}")

def on_message(client, userdata, msg):
    payload_str = msg.payload.decode("utf-8", errors="replace")
    topic = msg.topic
    logging.info(f"Menerima pesan pada topik [{topic}]: {payload_str}")

    device_id = "UNKNOWN-NODE"
    temperature = None
    humidity = None
    voltage = None

    try:
        data = json.loads(payload_str)
        if isinstance(data, dict):
            device_id = str(data.get("device_id", data.get("id", "HOST2-NODE")))
            temperature = data.get("temperature", data.get("temp"))
            humidity = data.get("humidity", data.get("hum"))
            voltage = data.get("voltage", data.get("volt"))
    except json.JSONDecodeError:
        # Jika bukan JSON, anggap sebagai plain string
        device_id = "RAW-DEVICE"

    save_telemetry(device_id, topic, temperature, humidity, voltage, payload_str)

def main():
    logging.info("Memulai layanan MQTT Subscriber...")
    
    # Pastikan DB siap sebelum connect ke MQTT
    if not wait_for_db():
        sys.exit(1)

    # Inisialisasi MQTT Client (kompatibel paho-mqtt v1 dan v2)
    try:
        client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="jarkom-subscriber-service")
    except AttributeError:
        client = mqtt.Client(client_id="jarkom-subscriber-service")

    client.on_connect = on_connect
    client.on_message = on_message

    while True:
        try:
            logging.info(f"Menghubungkan ke Broker MQTT di {MQTT_BROKER}:{MQTT_PORT}...")
            client.connect(MQTT_BROKER, MQTT_PORT, keepalive=60)
            break
        except Exception as e:
            logging.warning(f"Gagal terhubung ke Broker: {e}. Mengulang dalam 5 detik...")
            time.sleep(5)

    try:
        client.loop_forever()
    except KeyboardInterrupt:
        logging.info("Menghentikan subscriber...")
        client.disconnect()

if __name__ == "__main__":
    main()
