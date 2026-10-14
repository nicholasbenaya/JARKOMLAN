-- Skrip Inisialisasi Database MySQL untuk JARKOMLAN IoT Pipeline
CREATE DATABASE IF NOT EXISTS jarkom_iot CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE jarkom_iot;

-- Tabel log telemetri sensor yang dikirim oleh Publisher via MQTT
CREATE TABLE IF NOT EXISTS sensor_telemetry (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_id VARCHAR(64) NOT NULL,
    topic VARCHAR(128) NOT NULL,
    temperature DECIMAL(5, 2) DEFAULT NULL,
    humidity DECIMAL(5, 2) DEFAULT NULL,
    voltage DECIMAL(4, 2) DEFAULT NULL,
    raw_payload TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_device (device_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed data awal untuk verifikasi konektivitas Web Server sebelum pengujian Publisher
INSERT INTO sensor_telemetry (device_id, topic, temperature, humidity, voltage, raw_payload)
VALUES 
    ('SYS-INIT-01', 'jarkom/sensor/status', 27.50, 60.00, 3.30, '{"system": "ready", "note": "Database initialized successfully"}');
