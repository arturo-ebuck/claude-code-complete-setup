# Error Handling and Debugging Strategies

## Error Handling Philosophy

### 1. Core Principles
- **Fail Fast**: Detect and report errors immediately
- **Fail Gracefully**: Provide meaningful feedback and recovery options
- **Be Specific**: Clear error messages with actionable solutions
- **Log Everything**: Maintain audit trail for debugging
- **Clean Up**: Always release resources on failure

### 2. Error Categories
- **User Errors**: Invalid input, missing files, wrong permissions
- **System Errors**: Resource exhaustion, network failures, OS issues
- **Logic Errors**: Bugs, edge cases, unexpected states
- **External Errors**: API failures, dependency issues, third-party problems

## Language-Specific Error Handling

### 1. Python Error Handling
```python
import logging
import traceback
from typing import Optional, Union

class ApplicationError(Exception):
    """Base application exception with context."""
    def __init__(self, message: str, code: Optional[str] = None, details: Optional[dict] = None):
        super().__init__(message)
        self.code = code
        self.details = details or {}

def robust_file_operation(filepath: str) -> str:
    """Example of comprehensive error handling."""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        
        if not content:
            raise ValueError("File is empty")
        
        return content
        
    except FileNotFoundError:
        logging.error(f"File not found: {filepath}")
        raise ApplicationError(
            f"The file '{filepath}' does not exist",
            code="FILE_NOT_FOUND",
            details={"filepath": filepath, "suggestion": "Check the file path"}
        )
    
    except PermissionError:
        logging.error(f"Permission denied: {filepath}")
        raise ApplicationError(
            f"No permission to read '{filepath}'",
            code="PERMISSION_DENIED",
            details={"filepath": filepath, "suggestion": "Check file permissions"}
        )
    
    except IOError as e:
        logging.error(f"IO error reading {filepath}: {e}")
        raise ApplicationError(
            f"Failed to read file: {e}",
            code="IO_ERROR",
            details={"filepath": filepath, "error": str(e)}
        )
    
    except Exception as e:
        logging.exception(f"Unexpected error reading {filepath}")
        raise ApplicationError(
            "An unexpected error occurred",
            code="UNKNOWN_ERROR",
            details={"filepath": filepath, "error": str(e), "traceback": traceback.format_exc()}
        )
```

### 2. Shell Script Error Handling
```bash
#!/usr/bin/env bash
set -euo pipefail

# Global error handler
error_handler() {
    local exit_code=$?
    local line_number=$1
    
    echo "Error occurred in script at line $line_number"
    echo "Exit code: $exit_code"
    echo "Call stack:"
    
    local i=0
    while caller $i; do
        ((i++))
    done
    
    # Cleanup
    cleanup_on_error
    
    exit "$exit_code"
}

trap 'error_handler ${LINENO}' ERR

# Function with error checking
safe_command() {
    local cmd="$1"
    local error_msg="${2:-Command failed}"
    
    if ! output=$($cmd 2>&1); then
        echo "Error: $error_msg"
        echo "Command: $cmd"
        echo "Output: $output"
        return 1
    fi
    
    echo "$output"
}

# Cleanup function
cleanup_on_error() {
    echo "Performing cleanup..."
    # Remove temporary files
    rm -f /tmp/tempfile.*
    # Kill background processes
    jobs -p | xargs -r kill 2>/dev/null || true
}
```

### 3. JavaScript/TypeScript Error Handling
```typescript
// Custom error classes
class ApplicationError extends Error {
    constructor(
        message: string,
        public code: string,
        public statusCode: number = 500,
        public details?: any
    ) {
        super(message);
        this.name = 'ApplicationError';
    }
}

class ValidationError extends ApplicationError {
    constructor(message: string, field: string, value?: any) {
        super(message, 'VALIDATION_ERROR', 400, { field, value });
        this.name = 'ValidationError';
    }
}

// Async error wrapper
const asyncHandler = (fn: Function) => {
    return async (req: Request, res: Response, next: NextFunction) => {
        try {
            await fn(req, res, next);
        } catch (error) {
            next(error);
        }
    };
};

// Global error handler
const errorHandler = (err: Error, req: Request, res: Response, next: NextFunction) => {
    logger.error({
        error: err.message,
        stack: err.stack,
        request: {
            method: req.method,
            url: req.url,
            body: req.body,
            user: req.user?.id
        }
    });

    if (err instanceof ApplicationError) {
        return res.status(err.statusCode).json({
            error: err.message,
            code: err.code,
            details: err.details
        });
    }

    // Default error response
    res.status(500).json({
        error: 'Internal server error',
        code: 'INTERNAL_ERROR'
    });
};
```

## Debugging Strategies

### 1. Systematic Debugging Process
```
1. Reproduce the Issue
   - Identify exact steps
   - Isolate variables
   - Create minimal test case

2. Gather Information
   - Check logs
   - Examine error messages
   - Review recent changes

3. Form Hypothesis
   - What could cause this?
   - What changed recently?
   - Similar past issues?

4. Test Hypothesis
   - Add logging/breakpoints
   - Test in isolation
   - Verify assumptions

5. Fix and Verify
   - Implement solution
   - Test thoroughly
   - Prevent regression
```

### 2. Debugging Tools and Techniques

#### Python Debugging
```python
import pdb
import logging
import functools

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Debug decorator
def debug_trace(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        logging.debug(f"Calling {func.__name__} with args={args}, kwargs={kwargs}")
        try:
            result = func(*args, **kwargs)
            logging.debug(f"{func.__name__} returned {result}")
            return result
        except Exception as e:
            logging.exception(f"Error in {func.__name__}: {e}")
            raise
    return wrapper

# Interactive debugging
def problematic_function(data):
    # Set breakpoint
    pdb.set_trace()
    
    # Or conditional breakpoint
    if len(data) > 100:
        breakpoint()  # Python 3.7+
    
    return process_data(data)

# Print debugging with context
def debug_print(label, value):
    frame = inspect.currentframe().f_back
    filename = frame.f_code.co_filename
    line_no = frame.f_lineno
    func_name = frame.f_code.co_name
    
    print(f"[DEBUG {filename}:{line_no} in {func_name}] {label}: {value}")
```

#### Shell Script Debugging
```bash
# Debug mode
set -x  # Print commands
set -v  # Print script lines

# Conditional debugging
debug() {
    [[ "${DEBUG:-0}" == "1" ]] && echo "[DEBUG] $*" >&2
}

# Trace function
trace() {
    echo "[TRACE] ${BASH_SOURCE[1]}:${BASH_LINENO[0]} in ${FUNCNAME[1]}()" >&2
}

# Assert function
assert() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    if ! eval "$condition"; then
        echo "ASSERT: $message (condition: $condition)" >&2
        echo "Location: ${BASH_SOURCE[1]}:${BASH_LINENO[0]}" >&2
        exit 1
    fi
}

# Usage
assert "[[ -f $config_file ]]" "Config file must exist"
```

### 3. Logging Best Practices

#### Structured Logging
```python
import json
import logging
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_obj = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'pathname': record.pathname,
            'line': record.lineno,
            'function': record.funcName,
            'process': record.process,
            'thread': record.thread
        }
        
        # Add extra fields
        if hasattr(record, 'user_id'):
            log_obj['user_id'] = record.user_id
        if hasattr(record, 'request_id'):
            log_obj['request_id'] = record.request_id
            
        # Add exception info
        if record.exc_info:
            log_obj['exception'] = self.formatException(record.exc_info)
            
        return json.dumps(log_obj)

# Context-aware logging
import contextvars

request_id = contextvars.ContextVar('request_id', default=None)

class ContextFilter(logging.Filter):
    def filter(self, record):
        record.request_id = request_id.get()
        return True

# Setup
logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
handler.addFilter(ContextFilter())
logger.addHandler(handler)
```

## Common Debugging Patterns

### 1. Binary Search Debugging
```python
def binary_search_debug(data_list, target_condition):
    """Find where in a list a condition starts failing."""
    left, right = 0, len(data_list) - 1
    
    while left < right:
        mid = (left + right) // 2
        
        print(f"Testing index {mid}")
        if target_condition(data_list[mid]):
            print(f"Condition passed at {mid}")
            left = mid + 1
        else:
            print(f"Condition failed at {mid}")
            right = mid
    
    return left
```

### 2. State Snapshot Debugging
```python
import copy
import pickle

class StateDebugger:
    def __init__(self):
        self.snapshots = {}
    
    def capture(self, label, obj):
        """Capture object state at a point."""
        self.snapshots[label] = {
            'timestamp': datetime.now(),
            'state': copy.deepcopy(obj.__dict__) if hasattr(obj, '__dict__') else str(obj)
        }
    
    def compare(self, label1, label2):
        """Compare two snapshots."""
        if label1 not in self.snapshots or label2 not in self.snapshots:
            return "Missing snapshot"
        
        state1 = self.snapshots[label1]['state']
        state2 = self.snapshots[label2]['state']
        
        differences = []
        for key in set(state1.keys()) | set(state2.keys()):
            val1 = state1.get(key, '<missing>')
            val2 = state2.get(key, '<missing>')
            if val1 != val2:
                differences.append(f"{key}: {val1} -> {val2}")
        
        return differences
    
    def save(self, filename):
        """Save snapshots to file."""
        with open(filename, 'wb') as f:
            pickle.dump(self.snapshots, f)
```

### 3. Performance Debugging
```python
import time
import functools
from contextlib import contextmanager

# Performance decorator
def time_it(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        try:
            result = func(*args, **kwargs)
            return result
        finally:
            end = time.perf_counter()
            print(f"{func.__name__} took {end - start:.4f} seconds")
    return wrapper

# Context manager for timing
@contextmanager
def timer(name):
    start = time.perf_counter()
    yield
    end = time.perf_counter()
    print(f"{name} took {end - start:.4f} seconds")

# Memory profiling
import tracemalloc

@contextmanager
def memory_trace(name):
    tracemalloc.start()
    yield
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    print(f"{name} - Current: {current / 1024 / 1024:.2f} MB, Peak: {peak / 1024 / 1024:.2f} MB")
```

## Error Recovery Strategies

### 1. Retry Mechanisms
```python
import time
import random
from typing import TypeVar, Callable

T = TypeVar('T')

def exponential_backoff_retry(
    func: Callable[..., T],
    max_retries: int = 3,
    base_delay: float = 1.0,
    max_delay: float = 60.0,
    exponential_base: float = 2.0,
    jitter: bool = True
) -> T:
    """Retry with exponential backoff."""
    
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            
            # Calculate delay
            delay = min(base_delay * (exponential_base ** attempt), max_delay)
            
            # Add jitter
            if jitter:
                delay *= (0.5 + random.random())
            
            logging.warning(
                f"Attempt {attempt + 1} failed: {e}. "
                f"Retrying in {delay:.2f} seconds..."
            )
            time.sleep(delay)
```

### 2. Circuit Breaker Pattern
```python
from enum import Enum
from datetime import datetime, timedelta

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(
        self,
        failure_threshold: int = 5,
        recovery_timeout: int = 60,
        expected_exception: type = Exception
    ):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.expected_exception = expected_exception
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
    
    def call(self, func, *args, **kwargs):
        if self.state == CircuitState.OPEN:
            if self._should_attempt_reset():
                self.state = CircuitState.HALF_OPEN
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except self.expected_exception as e:
            self._on_failure()
            raise
    
    def _should_attempt_reset(self):
        return (
            self.last_failure_time and
            datetime.now() - self.last_failure_time > timedelta(seconds=self.recovery_timeout)
        )
    
    def _on_success(self):
        self.failure_count = 0
        self.state = CircuitState.CLOSED
    
    def _on_failure(self):
        self.failure_count += 1
        self.last_failure_time = datetime.now()
        
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN
```

## Debugging in Production

### 1. Safe Production Debugging
```python
# Feature flags for debug features
DEBUG_FEATURES = {
    'verbose_logging': os.getenv('ENABLE_VERBOSE_LOGGING', 'false').lower() == 'true',
    'debug_endpoints': os.getenv('ENABLE_DEBUG_ENDPOINTS', 'false').lower() == 'true',
    'trace_requests': os.getenv('ENABLE_REQUEST_TRACING', 'false').lower() == 'true'
}

# Conditional debug endpoints
if DEBUG_FEATURES['debug_endpoints']:
    @app.route('/debug/heap')
    def heap_snapshot():
        import tracemalloc
        snapshot = tracemalloc.take_snapshot()
        top_stats = snapshot.statistics('lineno')[:10]
        return jsonify([{
            'file': stat.filename,
            'line': stat.lineno,
            'size': stat.size,
            'count': stat.count
        } for stat in top_stats])

# Safe production logging
def log_safely(level, message, **kwargs):
    """Log with PII sanitization."""
    # Sanitize sensitive fields
    sanitized_kwargs = {}
    sensitive_fields = ['password', 'token', 'api_key', 'secret']
    
    for key, value in kwargs.items():
        if any(field in key.lower() for field in sensitive_fields):
            sanitized_kwargs[key] = '[REDACTED]'
        else:
            sanitized_kwargs[key] = value
    
    logger.log(level, message, extra=sanitized_kwargs)
```

### 2. Remote Debugging Setup
```python
# Remote debugger configuration
def setup_remote_debugger():
    """Setup remote debugging (development only)."""
    if os.getenv('ENABLE_REMOTE_DEBUG') == 'true':
        import debugpy
        debugpy.listen(("0.0.0.0", 5678))
        print("Waiting for debugger attach...")
        debugpy.wait_for_client()
        print("Debugger attached!")

# Health check with debug info
@app.route('/health')
def health_check():
    health_data = {
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    }
    
    if DEBUG_FEATURES['verbose_logging']:
        health_data.update({
            'version': app.config.get('VERSION'),
            'uptime': get_uptime(),
            'memory_usage': get_memory_usage(),
            'active_connections': get_connection_count()
        })
    
    return jsonify(health_data)
```

## Error Reporting and Monitoring

### 1. Error Aggregation
```python
class ErrorAggregator:
    def __init__(self, window_size: int = 300):  # 5 minutes
        self.window_size = window_size
        self.errors = defaultdict(list)
    
    def add_error(self, error_type: str, error: Exception, context: dict = None):
        now = time.time()
        self.errors[error_type].append({
            'timestamp': now,
            'error': str(error),
            'type': type(error).__name__,
            'context': context or {}
        })
        
        # Clean old errors
        cutoff = now - self.window_size
        self.errors[error_type] = [
            e for e in self.errors[error_type]
            if e['timestamp'] > cutoff
        ]
    
    def get_summary(self):
        summary = {}
        for error_type, error_list in self.errors.items():
            summary[error_type] = {
                'count': len(error_list),
                'recent': error_list[-5:] if error_list else []
            }
        return summary
```

### 2. Alerting Rules
```python
class AlertManager:
    def __init__(self):
        self.alert_rules = []
    
    def add_rule(self, name: str, condition: Callable, action: Callable):
        self.alert_rules.append({
            'name': name,
            'condition': condition,
            'action': action,
            'last_triggered': None
        })
    
    def check_alerts(self, metrics: dict):
        for rule in self.alert_rules:
            if rule['condition'](metrics):
                # Debounce alerts (1 hour)
                if rule['last_triggered'] is None or \
                   time.time() - rule['last_triggered'] > 3600:
                    rule['action'](rule['name'], metrics)
                    rule['last_triggered'] = time.time()

# Example usage
alert_manager = AlertManager()

alert_manager.add_rule(
    'high_error_rate',
    lambda m: m.get('error_rate', 0) > 0.05,  # 5% error rate
    lambda name, m: send_alert(f"High error rate: {m['error_rate']:.2%}")
)

alert_manager.add_rule(
    'memory_usage',
    lambda m: m.get('memory_percent', 0) > 90,
    lambda name, m: send_alert(f"High memory usage: {m['memory_percent']}%")
)
```

## Best Practices Summary

### Error Handling
1. **Be Specific**: Catch specific exceptions, not broad Exception
2. **Add Context**: Include relevant information in error messages
3. **Log Appropriately**: Different log levels for different severities
4. **Clean Up**: Always release resources in finally blocks
5. **Fail Fast**: Detect errors early in the process

### Debugging
1. **Reproduce First**: Always reproduce before fixing
2. **Isolate Issues**: Create minimal test cases
3. **Use Tools**: Leverage debuggers and profilers
4. **Log Strategically**: Add logging at key decision points
5. **Version Control**: Use git bisect for regression bugs

### Production
1. **Monitor Continuously**: Set up comprehensive monitoring
2. **Aggregate Errors**: Group similar errors together
3. **Alert Wisely**: Avoid alert fatigue with smart rules
4. **Debug Safely**: Never expose sensitive data
5. **Document Issues**: Keep runbooks for common problems

## Last Updated
2025-07-29

## Status
ACTIVE - ERROR HANDLING GUIDE