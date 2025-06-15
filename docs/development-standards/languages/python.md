# Python Development Standards

This guide outlines the Python development standards for the TES⩓IoT Platform.

## Python Version

- **Required**: Python 3.9+
- **Recommended**: Python 3.11 (current stable)
- **Framework**: FastAPI for APIs, Celery for async tasks

## Code Style

### PEP 8 Compliance

Follow PEP 8 with these specific guidelines:

```python
# Good: Clear imports grouped by type
import os
import sys
from datetime import datetime
from typing import Optional, List, Dict

import pydantic
from fastapi import FastAPI, HTTPException
from sqlalchemy import create_engine

from app.core.config import settings
from app.models.device import Device
```

### Naming Conventions

```python
# Classes: PascalCase
class DeviceManager:
    pass

# Functions/Variables: snake_case
def get_device_by_id(device_id: str) -> Device:
    device_name = "sensor_001"
    return device

# Constants: UPPER_SNAKE_CASE
MAX_RETRY_ATTEMPTS = 3
DEFAULT_TIMEOUT = 30

# Private: Leading underscore
def _internal_helper():
    pass
```

## Type Hints

Always use type hints for better code clarity:

```python
from typing import Optional, List, Dict, Union, Tuple
from datetime import datetime

def process_telemetry(
    device_id: str,
    data: Dict[str, float],
    timestamp: Optional[datetime] = None
) -> Tuple[bool, Optional[str]]:
    """
    Process telemetry data from a device.
    
    Args:
        device_id: Unique device identifier
        data: Telemetry data as key-value pairs
        timestamp: Optional timestamp, defaults to now
        
    Returns:
        Tuple of (success, error_message)
    """
    if not timestamp:
        timestamp = datetime.utcnow()
    
    try:
        # Process data
        return True, None
    except Exception as e:
        return False, str(e)
```

## Project Structure

```
src/
├── api/
│   ├── __init__.py
│   ├── main.py              # FastAPI app
│   ├── dependencies.py      # Dependency injection
│   ├── middleware.py        # Custom middleware
│   │
│   ├── controllers/         # API endpoints
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── devices.py
│   │   └── telemetry.py
│   │
│   ├── models/             # Pydantic models
│   │   ├── __init__.py
│   │   ├── device.py
│   │   └── user.py
│   │
│   ├── services/           # Business logic
│   │   ├── __init__.py
│   │   ├── device_service.py
│   │   └── auth_service.py
│   │
│   └── core/              # Core functionality
│       ├── __init__.py
│       ├── config.py      # Settings
│       ├── security.py    # Auth/Security
│       └── database.py    # DB connection
│
├── tasks/                 # Celery tasks
│   ├── __init__.py
│   └── telemetry.py
│
├── tests/                 # Test files
│   ├── unit/
│   ├── integration/
│   └── conftest.py
│
├── alembic/              # Database migrations
├── scripts/              # Utility scripts
└── requirements/         # Dependencies
    ├── base.txt
    ├── dev.txt
    └── prod.txt
```

## FastAPI Best Practices

### API Structure

```python
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List

from app.models.device import Device, DeviceCreate, DeviceUpdate
from app.services.device_service import DeviceService
from app.core.deps import get_current_user, get_db

app = FastAPI(
    title="TES⩓IoT API",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

security = HTTPBearer()

@app.get("/api/v1/devices", response_model=List[Device])
async def list_devices(
    skip: int = 0,
    limit: int = 100,
    organization_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    List all devices accessible to the current user.
    
    - **skip**: Number of records to skip
    - **limit**: Maximum number of records to return
    - **organization_id**: Filter by organization
    """
    service = DeviceService(db)
    return service.list_devices(
        user=current_user,
        skip=skip,
        limit=limit,
        organization_id=organization_id
    )

@app.post("/api/v1/devices", response_model=Device, status_code=status.HTTP_201_CREATED)
async def create_device(
    device: DeviceCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new device."""
    service = DeviceService(db)
    return service.create_device(device, current_user)
```

### Dependency Injection

```python
# app/core/deps.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.core.security import verify_token
from app.models.user import User

security = HTTPBearer()

def get_db():
    """Database session dependency."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """Get current authenticated user."""
    token = credentials.credentials
    
    user_id = verify_token(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return user
```

## Error Handling

### Custom Exceptions

```python
# app/core/exceptions.py
class TesaIoTException(Exception):
    """Base exception for TES⩓IoT Platform."""
    pass

class DeviceNotFoundException(TesaIoTException):
    """Device not found in database."""
    pass

class InsufficientPermissionsException(TesaIoTException):
    """User lacks required permissions."""
    pass

class ValidationException(TesaIoTException):
    """Input validation failed."""
    def __init__(self, field: str, reason: str):
        self.field = field
        self.reason = reason
        super().__init__(f"Validation failed for {field}: {reason}")
```

### Exception Handlers

```python
# app/main.py
from fastapi import Request
from fastapi.responses import JSONResponse

@app.exception_handler(DeviceNotFoundException)
async def device_not_found_handler(request: Request, exc: DeviceNotFoundException):
    return JSONResponse(
        status_code=404,
        content={
            "success": False,
            "error": {
                "code": "DEVICE_NOT_FOUND",
                "message": str(exc)
            }
        }
    )

@app.exception_handler(ValidationException)
async def validation_exception_handler(request: Request, exc: ValidationException):
    return JSONResponse(
        status_code=400,
        content={
            "success": False,
            "error": {
                "code": "VALIDATION_ERROR",
                "message": str(exc),
                "details": {
                    "field": exc.field,
                    "reason": exc.reason
                }
            }
        }
    )
```

## Database Access

### SQLAlchemy Models

```python
# app/models/db/device.py
from sqlalchemy import Column, String, DateTime, Boolean, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base

class DeviceDB(Base):
    __tablename__ = "devices"
    
    id = Column(UUID(as_uuid=True), primary_key=True)
    name = Column(String(255), nullable=False)
    type = Column(String(50), nullable=False)
    status = Column(String(20), default="active")
    organization_id = Column(UUID(as_uuid=True), nullable=False)
    metadata = Column(JSON, default={})
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    telemetry = relationship("TelemetryDB", back_populates="device")
```

### Repository Pattern

```python
# app/repositories/device_repository.py
from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_

from app.models.db.device import DeviceDB

class DeviceRepository:
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, device_id: str) -> Optional[DeviceDB]:
        """Get device by ID."""
        return self.db.query(DeviceDB).filter(
            DeviceDB.id == device_id
        ).first()
    
    def list_by_organization(
        self, 
        organization_id: str,
        skip: int = 0,
        limit: int = 100
    ) -> List[DeviceDB]:
        """List devices for an organization."""
        return self.db.query(DeviceDB).filter(
            DeviceDB.organization_id == organization_id
        ).offset(skip).limit(limit).all()
    
    def create(self, device_data: dict) -> DeviceDB:
        """Create new device."""
        device = DeviceDB(**device_data)
        self.db.add(device)
        self.db.commit()
        self.db.refresh(device)
        return device
```

## Testing

### Unit Tests

```python
# tests/unit/test_device_service.py
import pytest
from unittest.mock import Mock, patch
from datetime import datetime

from app.services.device_service import DeviceService
from app.models.device import DeviceCreate

@pytest.fixture
def mock_db():
    """Mock database session."""
    return Mock()

@pytest.fixture
def device_service(mock_db):
    """Device service instance."""
    return DeviceService(mock_db)

def test_create_device_success(device_service, mock_db):
    """Test successful device creation."""
    # Arrange
    device_data = DeviceCreate(
        name="Test Device",
        type="sensor",
        organization_id="org_123"
    )
    
    expected_device = Mock(
        id="dev_123",
        name="Test Device",
        type="sensor"
    )
    
    mock_db.add.return_value = None
    mock_db.commit.return_value = None
    mock_db.refresh.return_value = None
    
    # Act
    with patch('app.services.device_service.DeviceDB', return_value=expected_device):
        result = device_service.create_device(device_data, Mock())
    
    # Assert
    assert result.id == "dev_123"
    assert result.name == "Test Device"
    mock_db.add.assert_called_once()
    mock_db.commit.assert_called_once()
```

### Integration Tests

```python
# tests/integration/test_api_devices.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.core.database import Base, get_db

# Test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)

def test_list_devices_authenticated():
    """Test listing devices with authentication."""
    # Create test token
    token = create_test_token(user_id="user_123")
    
    response = client.get(
        "/api/v1/devices",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    assert response.status_code == 200
    assert response.json()["success"] is True
```

## Security Best Practices

### Input Validation

```python
# app/models/device.py
from pydantic import BaseModel, Field, validator
import re

class DeviceCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    type: str = Field(..., regex="^(sensor|gateway|actuator)$")
    organization_id: str
    metadata: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    @validator('name')
    def validate_name(cls, v):
        """Validate device name format."""
        if not re.match(r'^[a-zA-Z0-9_\-\s]+$', v):
            raise ValueError('Name contains invalid characters')
        return v
    
    @validator('metadata')
    def validate_metadata(cls, v):
        """Validate metadata size."""
        if len(str(v)) > 10000:  # 10KB limit
            raise ValueError('Metadata too large')
        return v
```

### Secure Coding

```python
# app/core/security.py
import secrets
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hash password using bcrypt."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password against hash."""
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(
    subject: str, 
    expires_delta: Optional[timedelta] = None
) -> str:
    """Create JWT access token."""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    
    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "type": "access"
    }
    
    encoded_jwt = jwt.encode(
        to_encode, 
        settings.SECRET_KEY, 
        algorithm=settings.ALGORITHM
    )
    return encoded_jwt

def generate_secure_token(length: int = 32) -> str:
    """Generate cryptographically secure random token."""
    return secrets.token_urlsafe(length)
```

## Performance Optimization

### Async Best Practices

```python
# app/services/telemetry_service.py
import asyncio
from typing import List
import aioredis
from motor.motor_asyncio import AsyncIOMotorClient

class TelemetryService:
    def __init__(self):
        self.redis = None
        self.mongodb = None
    
    async def connect(self):
        """Initialize async connections."""
        self.redis = await aioredis.create_redis_pool('redis://localhost')
        self.mongodb = AsyncIOMotorClient('mongodb://localhost:27017')
    
    async def process_telemetry_batch(
        self, 
        messages: List[Dict[str, Any]]
    ) -> None:
        """Process telemetry messages in parallel."""
        tasks = []
        
        for message in messages:
            task = self._process_single_message(message)
            tasks.append(task)
        
        # Process all messages concurrently
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Handle any exceptions
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                logger.error(f"Failed to process message {i}: {result}")
    
    async def _process_single_message(
        self, 
        message: Dict[str, Any]
    ) -> None:
        """Process single telemetry message."""
        # Validate message
        device_id = message.get('device_id')
        data = message.get('data')
        
        # Store in Redis for real-time access
        await self.redis.setex(
            f"telemetry:{device_id}:latest",
            60,  # 60 seconds TTL
            json.dumps(data)
        )
        
        # Store in MongoDB for historical data
        await self.mongodb.telemetry.insert_one({
            'device_id': device_id,
            'data': data,
            'timestamp': datetime.utcnow()
        })
```

### Caching

```python
# app/core/cache.py
from functools import wraps
import hashlib
import json
from typing import Optional, Callable
import redis

redis_client = redis.Redis(host='localhost', port=6379, decode_responses=True)

def cache_result(expire: int = 300):
    """Cache function results in Redis."""
    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Create cache key from function name and arguments
            cache_key = f"{func.__name__}:{hashlib.md5(str(args).encode()).hexdigest()}"
            
            # Try to get from cache
            cached = redis_client.get(cache_key)
            if cached:
                return json.loads(cached)
            
            # Call function and cache result
            result = await func(*args, **kwargs)
            redis_client.setex(cache_key, expire, json.dumps(result))
            
            return result
        return wrapper
    return decorator

# Usage example
@cache_result(expire=600)  # Cache for 10 minutes
async def get_device_statistics(device_id: str) -> Dict[str, Any]:
    """Get device statistics (expensive operation)."""
    # Complex calculation here
    return statistics
```

## Logging and Monitoring

### Structured Logging

```python
# app/core/logging.py
import logging
import json
from pythonjsonlogger import jsonlogger

# Configure JSON logging
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)

logger = logging.getLogger()
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

# Usage
logger.info(
    "Device connected",
    extra={
        "device_id": device_id,
        "organization_id": org_id,
        "ip_address": ip_address,
        "event_type": "device.connected"
    }
)
```

## Documentation

### Docstring Standards

```python
def calculate_device_health_score(
    device_id: str,
    telemetry_data: List[Dict[str, float]],
    time_window: timedelta = timedelta(hours=24)
) -> float:
    """
    Calculate health score for a device based on telemetry data.
    
    The health score is calculated using a weighted average of various
    metrics including uptime, error rate, and sensor readings.
    
    Args:
        device_id: Unique identifier of the device
        telemetry_data: List of telemetry readings with timestamps
        time_window: Time period to consider for calculation
        
    Returns:
        float: Health score between 0.0 (unhealthy) and 1.0 (healthy)
        
    Raises:
        ValueError: If device_id is invalid or telemetry_data is empty
        DeviceNotFoundException: If device doesn't exist
        
    Example:
        >>> score = calculate_device_health_score(
        ...     "dev_123",
        ...     telemetry_data,
        ...     timedelta(hours=12)
        ... )
        >>> print(f"Health score: {score:.2%}")
        Health score: 95.50%
    """
    pass
```

## Code Review Checklist

- [ ] Code follows PEP 8 style guide
- [ ] All functions have type hints
- [ ] Complex logic has comments
- [ ] No hardcoded secrets or credentials
- [ ] Input validation is comprehensive
- [ ] Error handling covers edge cases
- [ ] Tests cover happy path and error cases
- [ ] Performance implications considered
- [ ] Security best practices followed
- [ ] Documentation is clear and complete