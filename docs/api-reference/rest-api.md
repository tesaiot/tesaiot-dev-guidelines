# REST API Reference

The TES⩓IoT Platform provides a comprehensive REST API for managing devices, organizations, users, and telemetry data.

## Base URL

```
https://api.tesaiot.com/v1
```

For local development:
```
http://localhost:5566/api/v1
```

## Authentication

All API requests require authentication using Bearer tokens:

```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     https://api.tesaiot.com/v1/devices
```

### Obtaining a Token

```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "your-password"
}
```

Response:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

## Common Headers

| Header | Description | Required |
|--------|-------------|----------|
| `Authorization` | Bearer token | Yes |
| `Content-Type` | `application/json` | For POST/PUT |
| `X-Request-ID` | Unique request identifier | No |
| `X-Organization-ID` | Organization context | Sometimes |

## Response Format

All responses follow a consistent format:

### Success Response
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2025-06-15T10:30:00Z",
    "version": "1.0"
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input provided",
    "details": {
      "field": "email",
      "reason": "Invalid email format"
    }
  },
  "meta": {
    "timestamp": "2025-06-15T10:30:00Z",
    "request_id": "req_123456"
  }
}
```

## Endpoints

### Authentication

#### Login
```http
POST /api/v1/auth/login
```

Request:
```json
{
  "email": "user@example.com",
  "password": "secure-password"
}
```

Response:
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": "usr_123",
    "email": "user@example.com",
    "name": "John Doe",
    "roles": ["admin"]
  }
}
```

#### Refresh Token
```http
POST /api/v1/auth/refresh
```

Request:
```json
{
  "refresh_token": "eyJ..."
}
```

#### Logout
```http
POST /api/v1/auth/logout
```

### Organizations

#### List Organizations
```http
GET /api/v1/organizations
```

Query Parameters:
- `page` (integer): Page number
- `limit` (integer): Items per page
- `search` (string): Search term
- `parent_id` (string): Filter by parent

Response:
```json
{
  "data": [
    {
      "id": "org_123",
      "name": "Acme Corporation",
      "type": "enterprise",
      "parent_id": null,
      "settings": {
        "max_devices": 1000,
        "features": ["ai", "analytics"]
      },
      "created_at": "2025-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3
  }
}
```

#### Get Organization Tree
```http
GET /api/v1/organizations/tree
```

Response:
```json
{
  "data": {
    "id": "org_123",
    "name": "Parent Org",
    "children": [
      {
        "id": "org_456",
        "name": "Child Org",
        "children": []
      }
    ]
  }
}
```

#### Create Organization
```http
POST /api/v1/organizations
```

Request:
```json
{
  "name": "New Organization",
  "type": "department",
  "parent_id": "org_123",
  "settings": {
    "timezone": "UTC",
    "language": "en"
  }
}
```

### Devices

#### List Devices
```http
GET /api/v1/devices
```

Query Parameters:
- `organization_id` (string): Filter by organization
- `status` (string): active, inactive, maintenance
- `type` (string): sensor, gateway, actuator
- `tags` (array): Filter by tags

Response:
```json
{
  "data": [
    {
      "id": "dev_789",
      "name": "Temperature Sensor 01",
      "type": "sensor",
      "status": "active",
      "organization_id": "org_123",
      "metadata": {
        "manufacturer": "Acme",
        "model": "TS-100",
        "firmware": "1.2.3"
      },
      "last_seen": "2025-06-15T10:00:00Z",
      "created_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

#### Get Device Details
```http
GET /api/v1/devices/{device_id}
```

Response includes full device information plus:
```json
{
  "data": {
    "id": "dev_789",
    "name": "Temperature Sensor 01",
    "certificates": {
      "fingerprint": "SHA256:abcd1234...",
      "expires_at": "2025-07-15T00:00:00Z"
    },
    "telemetry_summary": {
      "last_value": {
        "temperature": 22.5,
        "humidity": 45.2
      },
      "message_count": 15420
    }
  }
}
```

#### Create Device
```http
POST /api/v1/devices
```

Request:
```json
{
  "name": "New Sensor",
  "type": "sensor",
  "organization_id": "org_123",
  "metadata": {
    "location": "Building A, Floor 2",
    "manufacturer": "Acme",
    "model": "TS-200"
  },
  "tags": ["temperature", "indoor"]
}
```

#### Generate Device Certificate
```http
POST /api/v1/devices/{device_id}/certificates
```

Request:
```json
{
  "key_algorithm": "EC",
  "key_size": 256,
  "validity_days": 30
}
```

Response:
```json
{
  "certificate": "-----BEGIN CERTIFICATE-----\n...",
  "private_key": "-----BEGIN EC PRIVATE KEY-----\n...",
  "ca_certificate": "-----BEGIN CERTIFICATE-----\n...",
  "expires_at": "2025-07-15T00:00:00Z"
}
```

### Telemetry

#### Get Device Telemetry
```http
GET /api/v1/devices/{device_id}/telemetry
```

Query Parameters:
- `start_time` (ISO 8601): Start of time range
- `end_time` (ISO 8601): End of time range
- `limit` (integer): Maximum records
- `aggregation` (string): none, minute, hour, day

Response:
```json
{
  "data": [
    {
      "timestamp": "2025-06-15T10:00:00Z",
      "data": {
        "temperature": 22.5,
        "humidity": 45.2,
        "pressure": 1013.25
      }
    }
  ],
  "meta": {
    "device_id": "dev_789",
    "count": 100,
    "aggregation": "none"
  }
}
```

#### Send Telemetry (MQTT Bridge)
```http
POST /api/v1/devices/{device_id}/telemetry/ingest
```

Request:
```json
{
  "timestamp": "2025-06-15T10:00:00Z",
  "data": {
    "temperature": 22.5,
    "humidity": 45.2
  }
}
```

### Commands

#### Send Command to Device
```http
POST /api/v1/devices/{device_id}/commands
```

Request:
```json
{
  "command": "restart",
  "parameters": {
    "delay": 5000
  },
  "timeout": 30000
}
```

Response:
```json
{
  "command_id": "cmd_123",
  "status": "pending",
  "created_at": "2025-06-15T10:00:00Z"
}
```

#### Get Command Status
```http
GET /api/v1/commands/{command_id}
```

### Analytics

#### Device Statistics
```http
GET /api/v1/devices/{device_id}/stats
```

Query Parameters:
- `period` (string): hour, day, week, month
- `metrics` (array): Specific metrics to include

Response:
```json
{
  "data": {
    "period": "day",
    "metrics": {
      "message_count": 1440,
      "average_values": {
        "temperature": 22.3,
        "humidity": 46.8
      },
      "uptime_percentage": 99.9
    }
  }
}
```

## Rate Limiting

API rate limits are enforced per endpoint:

| Endpoint | Rate Limit |
|----------|------------|
| Authentication | 5 requests/minute |
| Device List | 100 requests/minute |
| Telemetry Ingestion | 1000 requests/minute |
| Others | 60 requests/minute |

Rate limit headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1623456789
```

## Error Codes

| Code | Description |
|------|-------------|
| `UNAUTHORIZED` | Invalid or missing authentication |
| `FORBIDDEN` | Insufficient permissions |
| `NOT_FOUND` | Resource not found |
| `VALIDATION_ERROR` | Invalid input data |
| `RATE_LIMITED` | Too many requests |
| `INTERNAL_ERROR` | Server error |

## Pagination

List endpoints support pagination:

```
GET /api/v1/devices?page=2&limit=50
```

Response includes pagination metadata:
```json
{
  "pagination": {
    "page": 2,
    "limit": 50,
    "total": 245,
    "pages": 5,
    "has_next": true,
    "has_prev": true
  }
}
```

## Filtering and Sorting

Most list endpoints support filtering and sorting:

```
GET /api/v1/devices?status=active&sort=-created_at&tags=temperature,outdoor
```

- Use `-` prefix for descending sort
- Multiple values separated by commas
- Nested fields use dot notation: `metadata.location`

## Webhooks

Configure webhooks for real-time events:

```http
POST /api/v1/webhooks
```

Request:
```json
{
  "url": "https://your-app.com/webhook",
  "events": ["device.connected", "device.disconnected"],
  "secret": "webhook-secret"
}
```

## SDK Examples

### Python
```python
from tesaiot import Client

client = Client(
    base_url="https://api.tesaiot.com",
    api_key="your-api-key"
)

# List devices
devices = client.devices.list(organization_id="org_123")

# Get telemetry
telemetry = client.devices.get_telemetry(
    device_id="dev_789",
    start_time="2025-06-15T00:00:00Z"
)
```

### JavaScript/TypeScript
```typescript
import { TesaIoTClient } from '@tesaiot/sdk';

const client = new TesaIoTClient({
  baseUrl: 'https://api.tesaiot.com',
  apiKey: 'your-api-key'
});

// List devices
const devices = await client.devices.list({
  organizationId: 'org_123'
});

// Send command
const result = await client.devices.sendCommand('dev_789', {
  command: 'restart',
  parameters: { delay: 5000 }
});
```

## API Versioning

The API uses URL versioning:
- Current version: `v1`
- Version in URL: `/api/v1/...`
- Deprecation notice: 6 months
- Sunset period: 12 months

## Support

- API Status: https://status.tesaiot.com
- Documentation: https://docs.tesaiot.com
- Support: support@tesaiot.com