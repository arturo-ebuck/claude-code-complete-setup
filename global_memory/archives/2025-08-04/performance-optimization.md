# Performance Optimization Guide

## Performance Optimization Principles

### 1. Measurement First
- **Profile Before Optimizing**: Never guess, always measure
- **Identify Bottlenecks**: Focus on the 20% causing 80% of issues
- **Set Performance Goals**: Define acceptable thresholds
- **Monitor Continuously**: Track performance over time

### 2. Optimization Hierarchy
1. **Algorithm Optimization**: O(n²) to O(n log n)
2. **Data Structure Selection**: Right tool for the job
3. **I/O Optimization**: Reduce disk/network operations
4. **Memory Management**: Efficient allocation and usage
5. **Micro-optimizations**: Last resort, minimal impact

## Code Performance Patterns

### 1. Algorithmic Optimizations
```python
# Inefficient: O(n²)
def find_duplicates_slow(items):
    duplicates = []
    for i in range(len(items)):
        for j in range(i + 1, len(items)):
            if items[i] == items[j] and items[i] not in duplicates:
                duplicates.append(items[i])
    return duplicates

# Efficient: O(n)
def find_duplicates_fast(items):
    seen = set()
    duplicates = set()
    for item in items:
        if item in seen:
            duplicates.add(item)
        seen.add(item)
    return list(duplicates)

# Using Counter for frequency analysis
from collections import Counter
def find_duplicates_counter(items):
    counts = Counter(items)
    return [item for item, count in counts.items() if count > 1]
```

### 2. Data Structure Optimization
```python
# Dictionary vs List lookup
# Slow: O(n) lookup
users_list = [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]
def find_user_list(user_id):
    for user in users_list:
        if user['id'] == user_id:
            return user

# Fast: O(1) lookup
users_dict = {1: {'name': 'Alice'}, 2: {'name': 'Bob'}}
def find_user_dict(user_id):
    return users_dict.get(user_id)

# Set operations for membership testing
# Slow: O(n)
valid_ids_list = [1, 2, 3, 4, 5]
if user_id in valid_ids_list:
    process_user()

# Fast: O(1)
valid_ids_set = {1, 2, 3, 4, 5}
if user_id in valid_ids_set:
    process_user()
```

### 3. Memory Optimization
```python
# Generator for memory efficiency
def read_large_file(filename):
    """Memory-efficient file reading."""
    with open(filename, 'r') as f:
        for line in f:
            yield line.strip()

# Slots for class memory optimization
class Point:
    __slots__ = ['x', 'y']  # Reduces memory overhead
    
    def __init__(self, x, y):
        self.x = x
        self.y = y

# String interning for repeated strings
import sys
common_strings = ['status', 'error', 'success', 'pending']
interned_strings = {s: sys.intern(s) for s in common_strings}
```

## I/O Performance

### 1. File Operations
```python
# Batch file operations
def process_files_batch(file_paths):
    """Process multiple files efficiently."""
    results = []
    
    # Read all files in parallel
    import concurrent.futures
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        future_to_file = {executor.submit(read_file, path): path 
                          for path in file_paths}
        
        for future in concurrent.futures.as_completed(future_to_file):
            path = future_to_file[future]
            try:
                data = future.result()
                results.append(process_data(data))
            except Exception as exc:
                print(f'{path} generated an exception: {exc}')
    
    return results

# Buffered I/O
def copy_file_buffered(src, dst, buffer_size=1024*1024):
    """Copy file with custom buffer size."""
    with open(src, 'rb') as fsrc:
        with open(dst, 'wb') as fdst:
            while True:
                buffer = fsrc.read(buffer_size)
                if not buffer:
                    break
                fdst.write(buffer)
```

### 2. Database Optimization
```python
# Connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:pass@localhost/db',
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_timeout=30,
    pool_recycle=3600
)

# Batch database operations
def bulk_insert(records):
    """Efficient bulk insert."""
    # Instead of individual inserts
    # for record in records:
    #     db.execute("INSERT INTO table VALUES (%s, %s)", record)
    
    # Use bulk insert
    db.execute_many(
        "INSERT INTO table VALUES (%s, %s)",
        records
    )
    
    # Or use COPY for PostgreSQL
    cursor.copy_from(
        file=StringIO('\n'.join([f"{r[0]}\t{r[1]}" for r in records])),
        table='table',
        columns=('col1', 'col2')
    )
```

## Caching Strategies

### 1. In-Memory Caching
```python
from functools import lru_cache
import time
from typing import Dict, Any, Optional

# LRU Cache for function results
@lru_cache(maxsize=128)
def expensive_computation(n: int) -> int:
    time.sleep(1)  # Simulate expensive operation
    return n * n

# Time-based cache
class TTLCache:
    def __init__(self, ttl: int = 300):
        self._cache: Dict[str, tuple[Any, float]] = {}
        self._ttl = ttl
    
    def get(self, key: str) -> Optional[Any]:
        if key in self._cache:
            value, timestamp = self._cache[key]
            if time.time() - timestamp < self._ttl:
                return value
            else:
                del self._cache[key]
        return None
    
    def set(self, key: str, value: Any) -> None:
        self._cache[key] = (value, time.time())
    
    def clear_expired(self) -> None:
        current_time = time.time()
        expired_keys = [
            k for k, (_, timestamp) in self._cache.items()
            if current_time - timestamp >= self._ttl
        ]
        for key in expired_keys:
            del self._cache[key]
```

### 2. Distributed Caching
```python
import redis
import pickle
import json

class RedisCache:
    def __init__(self, host='localhost', port=6379, db=0):
        self.redis = redis.Redis(host=host, port=port, db=db)
    
    def get(self, key: str) -> Optional[Any]:
        data = self.redis.get(key)
        if data:
            return pickle.loads(data)
        return None
    
    def set(self, key: str, value: Any, ttl: int = 300) -> None:
        self.redis.setex(key, ttl, pickle.dumps(value))
    
    def get_json(self, key: str) -> Optional[dict]:
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
    
    def set_json(self, key: str, value: dict, ttl: int = 300) -> None:
        self.redis.setex(key, ttl, json.dumps(value))
```

## Async and Parallel Processing

### 1. Asyncio Optimization
```python
import asyncio
import aiohttp
from typing import List

async def fetch_url(session: aiohttp.ClientSession, url: str) -> str:
    async with session.get(url) as response:
        return await response.text()

async def fetch_multiple_urls(urls: List[str]) -> List[str]:
    """Fetch multiple URLs concurrently."""
    connector = aiohttp.TCPConnector(limit=100)  # Connection pool
    timeout = aiohttp.ClientTimeout(total=30)
    
    async with aiohttp.ClientSession(
        connector=connector,
        timeout=timeout
    ) as session:
        # Create tasks for all URLs
        tasks = [fetch_url(session, url) for url in urls]
        
        # Use gather with return_exceptions to handle failures
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Process results
        successful_results = []
        for url, result in zip(urls, results):
            if isinstance(result, Exception):
                print(f"Failed to fetch {url}: {result}")
            else:
                successful_results.append(result)
        
        return successful_results

# Semaphore for rate limiting
async def rate_limited_fetch(urls: List[str], max_concurrent: int = 10):
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def fetch_with_semaphore(url):
        async with semaphore:
            return await fetch_url(session, url)
    
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_with_semaphore(url) for url in urls]
        return await asyncio.gather(*tasks)
```

### 2. Multiprocessing Optimization
```python
import multiprocessing
from concurrent.futures import ProcessPoolExecutor, as_completed
import numpy as np

def cpu_intensive_task(data_chunk):
    """CPU-intensive processing."""
    # Simulate heavy computation
    return np.sum(np.array(data_chunk) ** 2)

def parallel_processing(data: List[List[float]], num_workers: int = None):
    """Process data in parallel using multiple CPU cores."""
    if num_workers is None:
        num_workers = multiprocessing.cpu_count()
    
    # Chunk data for distribution
    chunk_size = len(data) // num_workers
    chunks = [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]
    
    results = []
    with ProcessPoolExecutor(max_workers=num_workers) as executor:
        # Submit all tasks
        future_to_chunk = {
            executor.submit(cpu_intensive_task, chunk): i 
            for i, chunk in enumerate(chunks)
        }
        
        # Collect results in order
        for future in as_completed(future_to_chunk):
            chunk_idx = future_to_chunk[future]
            try:
                result = future.result()
                results.append((chunk_idx, result))
            except Exception as exc:
                print(f'Chunk {chunk_idx} generated an exception: {exc}')
    
    # Sort results by chunk index
    results.sort(key=lambda x: x[0])
    return [r[1] for r in results]
```

## Memory Management

### 1. Memory Profiling
```python
import tracemalloc
import gc
from memory_profiler import profile

# Trace memory allocations
def trace_memory_usage():
    tracemalloc.start()
    
    # Your code here
    data = [i ** 2 for i in range(1000000)]
    
    current, peak = tracemalloc.get_traced_memory()
    print(f"Current memory usage: {current / 1024 / 1024:.2f} MB")
    print(f"Peak memory usage: {peak / 1024 / 1024:.2f} MB")
    
    tracemalloc.stop()

# Profile function memory usage
@profile
def memory_intensive_function():
    # Create large list
    large_list = [i for i in range(1000000)]
    
    # Process data
    result = sum(large_list)
    
    # Clear memory
    del large_list
    gc.collect()
    
    return result
```

### 2. Memory-Efficient Patterns
```python
# Use generators instead of lists
def process_large_dataset(filename):
    """Process large file without loading into memory."""
    total = 0
    count = 0
    
    with open(filename, 'r') as f:
        for line in f:
            value = float(line.strip())
            total += value
            count += 1
    
    return total / count if count > 0 else 0

# Weak references for caches
import weakref

class CacheWithWeakRefs:
    def __init__(self):
        self._cache = weakref.WeakValueDictionary()
    
    def get(self, key):
        return self._cache.get(key)
    
    def set(self, key, value):
        self._cache[key] = value

# Context manager for temporary large objects
from contextlib import contextmanager

@contextmanager
def temporary_large_object():
    # Create large object
    large_obj = [i for i in range(10000000)]
    try:
        yield large_obj
    finally:
        # Ensure cleanup
        del large_obj
        gc.collect()
```

## Database Query Optimization

### 1. Query Optimization Techniques
```sql
-- Use indexes effectively
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

-- Composite indexes for multiple columns
CREATE INDEX idx_composite ON table(col1, col2, col3);

-- Partial indexes for specific conditions
CREATE INDEX idx_active_users ON users(email) WHERE active = true;

-- Use EXPLAIN to analyze queries
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123;
```

### 2. ORM Optimization
```python
# SQLAlchemy optimization
from sqlalchemy.orm import selectinload, joinedload

# Eager loading to prevent N+1 queries
# Bad: N+1 queries
users = session.query(User).all()
for user in users:
    print(user.orders)  # Each access triggers a query

# Good: Single query with join
users = session.query(User).options(
    joinedload(User.orders)
).all()

# Bulk operations
from sqlalchemy import update

# Bad: Individual updates
for user in users:
    user.last_login = datetime.now()
    session.commit()

# Good: Bulk update
session.execute(
    update(User).where(User.id.in_([u.id for u in users])).values(
        last_login=datetime.now()
    )
)
session.commit()
```

## Network Optimization

### 1. HTTP Request Optimization
```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Connection pooling and retry strategy
def create_session():
    session = requests.Session()
    
    # Retry strategy
    retry_strategy = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
    )
    
    # Mount adapter with connection pool
    adapter = HTTPAdapter(
        pool_connections=100,
        pool_maxsize=100,
        max_retries=retry_strategy
    )
    
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    
    return session

# Batch API requests
def batch_api_requests(endpoints: List[str], session: requests.Session):
    """Make multiple API requests efficiently."""
    import concurrent.futures
    
    def fetch(url):
        response = session.get(url)
        response.raise_for_status()
        return response.json()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(fetch, url) for url in endpoints]
        results = []
        
        for future in concurrent.futures.as_completed(futures):
            try:
                data = future.result()
                results.append(data)
            except Exception as e:
                print(f"Request failed: {e}")
    
    return results
```

### 2. Data Compression
```python
import gzip
import zlib
import brotli

def compress_data(data: bytes, method: str = 'gzip') -> bytes:
    """Compress data using specified method."""
    if method == 'gzip':
        return gzip.compress(data, compresslevel=6)
    elif method == 'zlib':
        return zlib.compress(data, level=6)
    elif method == 'brotli':
        return brotli.compress(data, quality=4)
    else:
        raise ValueError(f"Unknown compression method: {method}")

def compress_response(data: dict) -> bytes:
    """Compress JSON response."""
    json_str = json.dumps(data)
    json_bytes = json_str.encode('utf-8')
    
    # Choose compression based on size
    if len(json_bytes) < 1024:  # < 1KB
        return json_bytes  # No compression
    elif len(json_bytes) < 10240:  # < 10KB
        return gzip.compress(json_bytes, compresslevel=1)  # Fast compression
    else:
        return gzip.compress(json_bytes, compresslevel=6)  # Better compression
```

## Profiling and Monitoring

### 1. Performance Profiling
```python
import cProfile
import pstats
from line_profiler import LineProfiler

# Function profiling
def profile_function(func):
    """Profile function execution."""
    profiler = cProfile.Profile()
    profiler.enable()
    
    result = func()
    
    profiler.disable()
    stats = pstats.Stats(profiler)
    stats.sort_stats('cumulative')
    stats.print_stats(10)  # Top 10 functions
    
    return result

# Line-by-line profiling
def line_profile_example():
    lp = LineProfiler()
    lp.add_function(expensive_function)
    
    # Run function
    lp.enable()
    expensive_function()
    lp.disable()
    
    # Print results
    lp.print_stats()

# Custom timer context manager
import time
from contextlib import contextmanager

@contextmanager
def timer(name: str):
    start = time.perf_counter()
    yield
    elapsed = time.perf_counter() - start
    print(f"{name} took {elapsed:.4f} seconds")

# Usage
with timer("Database query"):
    results = db.query("SELECT * FROM large_table")
```

### 2. Performance Metrics
```python
class PerformanceMonitor:
    def __init__(self):
        self.metrics = defaultdict(list)
    
    def record(self, metric_name: str, value: float):
        self.metrics[metric_name].append({
            'value': value,
            'timestamp': time.time()
        })
    
    def get_stats(self, metric_name: str):
        values = [m['value'] for m in self.metrics[metric_name]]
        if not values:
            return None
        
        return {
            'count': len(values),
            'mean': statistics.mean(values),
            'median': statistics.median(values),
            'min': min(values),
            'max': max(values),
            'p95': np.percentile(values, 95),
            'p99': np.percentile(values, 99)
        }
    
    @contextmanager
    def measure(self, metric_name: str):
        start = time.perf_counter()
        yield
        elapsed = time.perf_counter() - start
        self.record(metric_name, elapsed)
```

## Optimization Checklist

### Before Optimizing
- [ ] Profile to identify bottlenecks
- [ ] Set performance goals
- [ ] Measure baseline performance
- [ ] Identify critical paths

### During Optimization
- [ ] Focus on algorithmic improvements first
- [ ] Use appropriate data structures
- [ ] Implement caching where beneficial
- [ ] Consider parallel processing
- [ ] Optimize I/O operations

### After Optimization
- [ ] Measure improvement
- [ ] Document changes
- [ ] Monitor in production
- [ ] Set up alerts for regressions

## Best Practices Summary

1. **Measure First**: Always profile before optimizing
2. **Focus on Bottlenecks**: Optimize the critical 20%
3. **Choose Right Algorithms**: O(n) beats O(n²)
4. **Cache Wisely**: Cache expensive computations
5. **Batch Operations**: Group similar operations
6. **Use Async**: For I/O-bound tasks
7. **Parallelize**: For CPU-bound tasks
8. **Monitor Continuously**: Track performance metrics
9. **Optimize Queries**: Use indexes and avoid N+1
10. **Manage Memory**: Use generators and clean up

## Last Updated
2025-07-29

## Status
ACTIVE - PERFORMANCE GUIDE