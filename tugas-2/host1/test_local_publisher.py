import json
import random
import time
import paho.mqtt.client as mqtt

# Pengujian lokal di Host 1 (dijalankan di Windows atau terminal WSL)
BROKER_HOST = "127.0.0.1"
BROKER_PORT = 1883
TOPIC = "jarkom/sensor/telemetry"

def generate_sample_data(i):
    return {
        "device_id": f"TEST-NODE-{random.randint(1, 3)}",
        "temperature": round(random.uniform(24.0, 34.0), 2),
        "humidity": round(random.uniform(50.0, 85.0), 2),
        "voltage": round(random.uniform(3.1, 3.4), 2),
        "packet_seq": i,
        "note": "Test Packet from Host 1 Verification Script"
    }

def main():
    print("============================================================")
    print("   JARKOMLAN: Verifikasi Lokal MQTT Publisher (Host 1)      ")
    print(f"   Target Broker: {BROKER_HOST}:{BROKER_PORT} | Topik: {TOPIC}")
    print("============================================================")

    try:
        client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="test-publisher-host1")
    except AttributeError:
        client = mqtt.Client(client_id="test-publisher-host1")

    try:
        client.connect(BROKER_HOST, BROKER_PORT, keepalive=60)
        print("[OK] Berhasil terhubung ke Mosquitto Broker.")
    except Exception as e:
        print(f"[!] Gagal terhubung ke Broker: {e}")
        print("    Pastikan Docker container 'jarkom-mqtt-broker' sudah berjalan!")
        return

    print("[*] Mengirim 5 paket telemetri simulasi...")
    for i in range(1, 6):
        payload = generate_sample_data(i)
        payload_str = json.dumps(payload)
        client.publish(TOPIC, payload_str)
        print(f"[{i}/5] Terkirim: {payload_str}")
        time.sleep(1.5)

    client.disconnect()
    print("")
    print("[OK] Pengiriman selesai! Silakan periksa:")
    print("    1. Log container subscriber: docker logs -f jarkom-mqtt-subscriber")
    print("    2. Dashboard Web Server di browser: http://localhost:8080 (atau IP VM)")
    print("============================================================")

if __name__ == "__main__":
    main()
