# Python Patterns and Standards

## Code Style Guidelines

### 1. PEP 8 Compliance
- **Line Length**: Maximum 88 characters (Black default)
- **Indentation**: 4 spaces (never tabs)
- **Blank Lines**: 2 lines between top-level definitions
- **Imports**: Grouped and ordered (standard, third-party, local)

### 2. Naming Conventions
```python
# Classes: PascalCase
class DataProcessor:
    pass

# Functions/Variables: snake_case
def process_data(input_data):
    processed_result = transform(input_data)
    return processed_result

# Constants: UPPER_SNAKE_CASE
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30

# Private: Leading underscore
def _internal_helper():
    pass
```

### 3. Type Hints
```python
from typing import List, Dict, Optional, Union, Tuple, Any
from dataclasses import dataclass

def process_items(
    items: List[str],
    config: Dict[str, Any],
    timeout: Optional[int] = None
) -> Tuple[List[str], bool]:
    """Process items with configuration."""
    results: List[str] = []
    success: bool = True
    return results, success

@dataclass
class Configuration:
    host: str
    port: int
    debug: bool = False
```

## Design Patterns

### 1. Singleton Pattern
```python
class Singleton:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not hasattr(self, 'initialized'):
            self.initialized = True
            # Initialize once
```

### 2. Factory Pattern
```python
from abc import ABC, abstractmethod

class Parser(ABC):
    @abstractmethod
    def parse(self, data: str) -> dict:
        pass

class JSONParser(Parser):
    def parse(self, data: str) -> dict:
        import json
        return json.loads(data)

class XMLParser(Parser):
    def parse(self, data: str) -> dict:
        # XML parsing logic
        pass

class ParserFactory:
    @staticmethod
    def create_parser(format: str) -> Parser:
        if format == 'json':
            return JSONParser()
        elif format == 'xml':
            return XMLParser()
        raise ValueError(f"Unknown format: {format}")
```

### 3. Context Manager Pattern
```python
from contextlib import contextmanager
import tempfile
import os

@contextmanager
def temporary_file(content: str):
    """Create a temporary file with content."""
    fd, path = tempfile.mkstemp()
    try:
        with os.fdopen(fd, 'w') as f:
            f.write(content)
        yield path
    finally:
        os.unlink(path)

# Usage
with temporary_file("test data") as tmp_path:
    # Use tmp_path
    pass
```

### 4. Decorator Pattern
```python
import functools
import time
import logging

def retry(max_attempts: int = 3, delay: float = 1.0):
    """Retry decorator with exponential backoff."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    wait_time = delay * (2 ** attempt)
                    logging.warning(f"Attempt {attempt + 1} failed: {e}. Retrying in {wait_time}s...")
                    time.sleep(wait_time)
        return wrapper
    return decorator

@retry(max_attempts=3)
def unstable_api_call():
    # API call that might fail
    pass
```

## Error Handling

### 1. Custom Exceptions
```python
class ApplicationError(Exception):
    """Base application exception."""
    pass

class ValidationError(ApplicationError):
    """Raised when validation fails."""
    def __init__(self, field: str, message: str):
        self.field = field
        super().__init__(f"{field}: {message}")

class ConfigurationError(ApplicationError):
    """Raised when configuration is invalid."""
    pass

# Usage
def validate_email(email: str):
    if '@' not in email:
        raise ValidationError('email', 'Invalid email format')
```

### 2. Exception Handling Best Practices
```python
import logging

def safe_operation():
    try:
        # Risky operation
        result = perform_operation()
    except FileNotFoundError as e:
        logging.error(f"File not found: {e}")
        return None
    except PermissionError as e:
        logging.error(f"Permission denied: {e}")
        raise  # Re-raise critical errors
    except Exception as e:
        logging.exception("Unexpected error occurred")
        # Handle or re-raise
    else:
        # Executed if no exception
        logging.info("Operation successful")
        return result
    finally:
        # Always executed
        cleanup_resources()
```

## Async Patterns

### 1. Basic Async/Await
```python
import asyncio
import aiohttp
from typing import List

async def fetch_url(session: aiohttp.ClientSession, url: str) -> str:
    """Fetch content from URL asynchronously."""
    async with session.get(url) as response:
        return await response.text()

async def fetch_multiple_urls(urls: List[str]) -> List[str]:
    """Fetch multiple URLs concurrently."""
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results

# Run async function
# asyncio.run(fetch_multiple_urls(['url1', 'url2']))
```

### 2. Async Context Managers
```python
class AsyncResource:
    async def __aenter__(self):
        await self.connect()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.disconnect()
    
    async def connect(self):
        # Async connection logic
        pass
    
    async def disconnect(self):
        # Async cleanup
        pass

# Usage
async def use_resource():
    async with AsyncResource() as resource:
        # Use resource
        pass
```

## Data Handling

### 1. Dataclasses
```python
from dataclasses import dataclass, field
from typing import List, Optional
from datetime import datetime

@dataclass
class User:
    id: int
    name: str
    email: str
    created_at: datetime = field(default_factory=datetime.now)
    tags: List[str] = field(default_factory=list)
    metadata: Optional[dict] = None
    
    def __post_init__(self):
        # Validation after initialization
        if '@' not in self.email:
            raise ValueError("Invalid email")
```

### 2. Property Decorators
```python
class Temperature:
    def __init__(self, celsius: float = 0.0):
        self._celsius = celsius
    
    @property
    def celsius(self) -> float:
        return self._celsius
    
    @celsius.setter
    def celsius(self, value: float):
        if value < -273.15:
            raise ValueError("Temperature below absolute zero")
        self._celsius = value
    
    @property
    def fahrenheit(self) -> float:
        return self._celsius * 9/5 + 32
    
    @fahrenheit.setter
    def fahrenheit(self, value: float):
        self.celsius = (value - 32) * 5/9
```

## Performance Patterns

### 1. Caching
```python
from functools import lru_cache
import time

@lru_cache(maxsize=128)
def expensive_computation(n: int) -> int:
    """Cache results of expensive computation."""
    time.sleep(1)  # Simulate expensive operation
    return n ** 2

# Manual caching with TTL
from datetime import datetime, timedelta

class CacheWithTTL:
    def __init__(self, ttl_seconds: int = 300):
        self._cache = {}
        self._ttl = timedelta(seconds=ttl_seconds)
    
    def get(self, key: str) -> Optional[Any]:
        if key in self._cache:
            value, timestamp = self._cache[key]
            if datetime.now() - timestamp < self._ttl:
                return value
            del self._cache[key]
        return None
    
    def set(self, key: str, value: Any):
        self._cache[key] = (value, datetime.now())
```

### 2. Generator Patterns
```python
def read_large_file(file_path: str, chunk_size: int = 1024):
    """Read large file in chunks."""
    with open(file_path, 'r') as file:
        while True:
            chunk = file.read(chunk_size)
            if not chunk:
                break
            yield chunk

# Generator expression for memory efficiency
squares = (x**2 for x in range(1000000))
```

## Testing Patterns

### 1. Unit Testing
```python
import unittest
from unittest.mock import Mock, patch, MagicMock

class TestDataProcessor(unittest.TestCase):
    def setUp(self):
        self.processor = DataProcessor()
    
    def tearDown(self):
        # Cleanup
        pass
    
    def test_process_valid_data(self):
        result = self.processor.process([1, 2, 3])
        self.assertEqual(result, [2, 4, 6])
    
    @patch('module.external_api_call')
    def test_with_mock(self, mock_api):
        mock_api.return_value = {'status': 'success'}
        result = self.processor.call_api()
        self.assertEqual(result['status'], 'success')
        mock_api.assert_called_once()
```

### 2. Pytest Patterns
```python
import pytest
from typing import List

@pytest.fixture
def sample_data() -> List[int]:
    return [1, 2, 3, 4, 5]

@pytest.fixture
def mock_database(mocker):
    return mocker.Mock(spec=Database)

def test_calculate_average(sample_data):
    assert calculate_average(sample_data) == 3.0

@pytest.mark.parametrize("input,expected", [
    ([1, 2, 3], 6),
    ([0, 0, 0], 0),
    ([-1, -2, -3], -6),
])
def test_sum_values(input, expected):
    assert sum(input) == expected
```

## Configuration Management

### 1. Configuration Classes
```python
import os
from typing import Optional

class Config:
    """Application configuration."""
    def __init__(self):
        self.debug = self._get_bool('DEBUG', False)
        self.host = os.getenv('HOST', 'localhost')
        self.port = self._get_int('PORT', 8000)
        self.database_url = os.getenv('DATABASE_URL', 'sqlite:///app.db')
    
    @staticmethod
    def _get_bool(key: str, default: bool) -> bool:
        value = os.getenv(key, str(default)).lower()
        return value in ('true', '1', 'yes', 'on')
    
    @staticmethod
    def _get_int(key: str, default: int) -> int:
        try:
            return int(os.getenv(key, str(default)))
        except ValueError:
            return default
```

### 2. Settings Validation
```python
from pydantic import BaseSettings, validator

class Settings(BaseSettings):
    app_name: str = "MyApp"
    debug: bool = False
    database_url: str
    redis_url: Optional[str] = None
    max_connections: int = 100
    
    @validator('database_url')
    def validate_database_url(cls, v):
        if not v.startswith(('postgresql://', 'mysql://', 'sqlite://')):
            raise ValueError('Invalid database URL')
        return v
    
    class Config:
        env_file = '.env'
        env_file_encoding = 'utf-8'
```

## Logging Best Practices

### 1. Structured Logging
```python
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_object = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        if hasattr(record, 'extra'):
            log_object.update(record.extra)
        return json.dumps(log_object)

# Configure logging
logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)
logger.setLevel(logging.INFO)
```

### 2. Context-aware Logging
```python
import contextvars
import logging

request_id = contextvars.ContextVar('request_id', default=None)

class ContextFilter(logging.Filter):
    def filter(self, record):
        record.request_id = request_id.get()
        return True

# Usage
def handle_request(req_id: str):
    request_id.set(req_id)
    logger.info("Processing request", extra={'user_id': 123})
```

## Code Organization

### 1. Project Structure
```
project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── __main__.py
│       ├── core/
│       │   ├── __init__.py
│       │   └── models.py
│       ├── api/
│       │   ├── __init__.py
│       │   └── endpoints.py
│       └── utils/
│           ├── __init__.py
│           └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── test_core/
│   └── test_api/
├── requirements.txt
├── setup.py
└── README.md
```

### 2. Module Organization
```python
"""
module_name.py
~~~~~~~~~~~~~

Brief module description.

Example usage:
    >>> from module_name import main_function
    >>> result = main_function(data)
"""

# Standard library imports
import os
import sys
from typing import List, Dict

# Third-party imports
import requests
import pandas as pd

# Local imports
from .core import process_data
from .utils import validate_input

# Module-level constants
DEFAULT_TIMEOUT = 30
MAX_RETRIES = 3

# Public API
__all__ = ['main_function', 'helper_function']

def main_function(data: List[Dict]) -> Dict:
    """Main entry point for module."""
    pass
```

## Best Practices Summary

1. **Type Hints**: Always use type hints for clarity
2. **Docstrings**: Document all public functions/classes
3. **Error Handling**: Be specific with exceptions
4. **Testing**: Aim for high test coverage
5. **Async When Appropriate**: Use for I/O-bound operations
6. **Configuration**: Externalize configuration
7. **Logging**: Structured logging for production
8. **Code Organization**: Clear module structure
9. **Performance**: Profile before optimizing
10. **Security**: Validate inputs, sanitize outputs

## Last Updated
2025-07-29

## Status
ACTIVE - PYTHON STANDARDS