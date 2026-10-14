import json
import logging
import os
import random
import sys
import time
import paho.mqtt.client as mqtt

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [MQTT-PUBLISHER-HOST2] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)

# Konfigurasi Target Broker (Host 1)
BROKER_HOST = os.getenv("MQTT_BROKER_HOST", "192.168.1.10")
BROKER_PORT = int(os.getenv("MQTT_BROKER_PORT", "1883"))
TOPIC = os.getenv("MQTT_TOPIC", "jarkom/sensor/telemetry")
DEVICE_ID = os.getenv("DEVICE_ID", "HOST2-SENSOR-NODE")
INTERVAL_SECONDS = int(os.getenv("PUBLISH_INTERVAL", "3"))

def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        logging.info(f"Berhasil terhubung ke Broker di {BROKER_HOST}:{BROKER_PORT}")
    else:
        logging.error(f"Gagal terhubung ke Broker, return code: {rc}")

def main():
    logging.info("Memulai Service MQTT Publisher di Host 2...")
    logging.info(f"Target: {BROKER_HOST}:{BROKER_PORT} | Topik: {TOPIC} | Interval: {INTERVAL_SECONDS}s")

    try:
        client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=f"{DEVICE_ID}-client")
    except AttributeError:
        client = mqtt.Client(client_id=f"{DEVICE_ID}-client")

    client.on_connect = on_connect

    while True:
        try:
            client.connect(BROKER_HOST, BROKER_PORT, keepalive=60)
            break
        except Exception as e:
            logging.warning(f"Menghubungkan ke Broker di {BROKER_HOST} gagal: {e}. Mengulang dalam 5s...")
            time.sleep(5)

    client.loop_start()

    seq = 1
    try:
        while True:
            payload = {
                "device_id": DEVICE_ID,
                "seq": seq,
                "temperature": round(random.uniform(25.0, 35.0), 2),
                "humidity": round(random.uniform(55.0, 80.0), 2),
                "voltage": round(random.uniform(3.2, 3.4), 2),
                "source": "Host 2 Windows Docker Container"
            }
            payload_str = json.dumps(payload)
            client.publish(TOPIC, payload_str)
            logging.info(f"[{seq}] Data terkirim ke {TOPIC}: {payload_str}")
            seq += 1
            time.sleep(INTERVAL_SECONDS)
    except KeyboardInterrupt:
        logging.info("Publisher dihentikan oleh pengguna.")
    finally:
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
