# Quick Start Guide

Get up and running with TES⩓IoT Platform in 5 minutes!

## Prerequisites

- Docker & Docker Compose installed
- 8GB RAM minimum
- Linux/macOS/Windows with WSL2

## 1. Clone the Repository

```bash
git clone https://github.com/tesaiot/tesa-iot-platform.git
cd tesa-iot-platform
```

## 2. Deploy the Platform

```bash
# Quick deployment with all services
./scripts/deploy-production.sh

# Or use make for common operations
make deploy
```

## 3. Access the Platform

Open your browser and navigate to:

- **Admin UI**: http://localhost:5566
- **Default Credentials**: 
  - Email: `admin@tesa.local`
  - Password: `admin123`

## 4. Add Your First Device

1. Navigate to **Device Management**
2. Click **Add Device**
3. Fill in device details:
   ```
   Device Name: My First Device
   Device Type: sensor
   Manufacturer: MyCompany
   Model: Temperature-001
   ```
4. Click **Generate Certificate** to create device credentials
5. Download the certificate bundle

## 5. Connect Your Device

### Using MQTT with Python

```python
import paho.mqtt.client as mqtt
import json
import time
import ssl

# Device configuration
DEVICE_ID = "your-device-id"
BROKER = "localhost"
PORT = 8883  # Secure MQTT port

# Certificate paths (from downloaded bundle)
CA_CERT = "ca.crt"
CLIENT_CERT = "device.crt"
CLIENT_KEY = "device.key"

# MQTT callbacks
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected successfully!")
        # Subscribe to commands
        client.subscribe(f"devices/{DEVICE_ID}/commands")
    else:
        print(f"Connection failed with code {rc}")

def on_message(client, userdata, msg):
    print(f"Received command: {msg.payload.decode()}")

# Setup MQTT client
client = mqtt.Client(client_id=DEVICE_ID)
client.on_connect = on_connect
client.on_message = on_message

# Configure TLS
client.tls_set(
    ca_certs=CA_CERT,
    certfile=CLIENT_CERT,
    keyfile=CLIENT_KEY,
    cert_reqs=ssl.CERT_REQUIRED,
    tls_version=ssl.PROTOCOL_TLSv1_2
)

# Connect to broker
client.connect(BROKER, PORT, 60)
client.loop_start()

# Send telemetry data
topic = f"devices/{DEVICE_ID}/telemetry"
while True:
    telemetry = {
        "temperature": 22.5 + (time.time() % 10) / 10,
        "humidity": 45 + (time.time() % 20) / 2,
        "timestamp": int(time.time() * 1000)
    }
    
    client.publish(topic, json.dumps(telemetry))
    print(f"Sent: {telemetry}")
    time.sleep(10)
```

### Using MQTT with Node.js

```javascript
const mqtt = require('mqtt');
const fs = require('fs');

// Device configuration
const DEVICE_ID = 'your-device-id';
const BROKER_URL = 'mqtts://localhost:8883';

// Certificate options
const options = {
    clientId: DEVICE_ID,
    ca: fs.readFileSync('ca.crt'),
    cert: fs.readFileSync('device.crt'),
    key: fs.readFileSync('device.key'),
    rejectUnauthorized: true
};

// Connect to broker
const client = mqtt.connect(BROKER_URL, options);

client.on('connect', () => {
    console.log('Connected successfully!');
    
    // Subscribe to commands
    client.subscribe(`devices/${DEVICE_ID}/commands`);
    
    // Send telemetry every 10 seconds
    setInterval(() => {
        const telemetry = {
            temperature: 22.5 + (Date.now() % 10000) / 1000,
            humidity: 45 + (Date.now() % 20000) / 1000,
            timestamp: Date.now()
        };
        
        client.publish(
            `devices/${DEVICE_ID}/telemetry`,
            JSON.stringify(telemetry)
        );
        
        console.log('Sent:', telemetry);
    }, 10000);
});

client.on('message', (topic, message) => {
    console.log('Received command:', message.toString());
});

client.on('error', (err) => {
    console.error('Connection error:', err);
});
```

## 6. View Device Data

1. Go back to the Admin UI
2. Navigate to **Device Management**
3. Click on your device
4. Go to the **Telemetry** tab
5. You should see real-time data flowing in!

## 7. Explore AI Features

1. Click the three-dot menu on your device
2. Select **"Open in Flowise AI"**
3. Ask questions about your device data:
   - "What's the average temperature?"
   - "Show me temperature trends"
   - "Alert me if humidity exceeds 70%"

## Common Issues

### Port 5566 Already in Use
```bash
# Check what's using the port
sudo lsof -i :5566

# Stop the platform
make stop

# Restart
make deploy
```

### Certificate Connection Failed
- Ensure you're using port 8883 (not 1883)
- Verify certificate paths are correct
- Check that device ID matches the certificate CN

### No Data Showing
- Check device is connected: `docker logs tesa-vernemq`
- Verify telemetry topic format: `devices/{device_id}/telemetry`
- Ensure JSON payload is valid

## Next Steps

- [Installation Guide](installation.md) - Production deployment
- [Architecture Overview](../architecture/overview.md) - Understand the system
- [API Reference](../api-reference/index.md) - Integrate with REST APIs
- [Tutorials](../tutorials/index.md) - Learn advanced features

## Need Help?

- 📖 [Full Documentation](https://docs.tesaiot.com)
- 💬 [Community Forum](https://forum.tesaiot.com)
- 🐛 [Report Issues](https://github.com/tesaiot/tesa-iot-platform/issues)