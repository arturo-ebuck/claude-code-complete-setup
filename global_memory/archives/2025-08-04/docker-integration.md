# Docker Integration Guide

## Docker Fundamentals

### 1. Core Concepts
- **Images**: Immutable templates for containers
- **Containers**: Running instances of images
- **Volumes**: Persistent data storage
- **Networks**: Container communication
- **Registry**: Image storage and distribution

### 2. Docker Architecture
```
Client → Docker Daemon → Container Runtime
   ↓           ↓              ↓
  CLI      Image Store    Containers
           Registry       Networks
                         Volumes
```

## Dockerfile Best Practices

### 1. Efficient Dockerfile Structure
```dockerfile
# Multi-stage build for smaller images
# Stage 1: Build
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first (layer caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build application
RUN npm run build

# Stage 2: Runtime
FROM node:18-alpine

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy built application from builder
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Use dumb-init to handle signals
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "dist/index.js"]
```

### 2. Python Dockerfile Example
```dockerfile
# Python multi-stage build
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1001 appuser

# Set working directory
WORKDIR /app

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# Copy application code
COPY --chown=appuser:appuser . .

# Update PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Switch to non-root user
USER appuser

# Run application
CMD ["python", "-m", "app.main"]
```

### 3. Optimization Techniques
```dockerfile
# Layer caching optimization
# Bad: Invalidates cache on any file change
COPY . /app
RUN pip install -r requirements.txt

# Good: Dependencies cached separately
COPY requirements.txt /app/
RUN pip install -r requirements.txt
COPY . /app

# Reduce layer size
# Bad: Multiple RUN commands
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2

# Good: Single RUN with cleanup
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# Use specific versions
# Bad: Latest tag
FROM python:latest

# Good: Specific version
FROM python:3.11.4-slim

# Minimize final image
# Use .dockerignore
cat > .dockerignore << EOF
.git
.gitignore
README.md
.env
.venv
__pycache__
*.pyc
.pytest_cache
.coverage
node_modules
npm-debug.log
EOF
```

## Docker Compose Patterns

### 1. Development Environment
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules  # Prevent overwriting
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://user:pass@db:5432/myapp
    ports:
      - "3000:3000"
      - "9229:9229"  # Debug port
    depends_on:
      - db
      - redis
    command: npm run dev

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"

  adminer:
    image: adminer
    ports:
      - "8080:8080"
    depends_on:
      - db

volumes:
  postgres_data:
  redis_data:
```

### 2. Production Configuration
```yaml
version: '3.8'

services:
  app:
    image: myapp:latest
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
    secrets:
      - api_key
      - db_password
    networks:
      - frontend
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - app
    networks:
      - frontend

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay
    internal: true

secrets:
  api_key:
    external: true
  db_password:
    external: true
```

## Container Security

### 1. Security Best Practices
```dockerfile
# Use minimal base images
FROM alpine:3.18

# Don't run as root
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set secure permissions
COPY --chown=appuser:appgroup . /app
RUN chmod -R 550 /app

# Drop capabilities
RUN apk add --no-cache libcap && \
    setcap 'cap_net_bind_service=+ep' /app/server

# Use secrets at build time
# syntax=docker/dockerfile:1
FROM alpine
RUN --mount=type=secret,id=mysecret \
    cat /run/secrets/mysecret

# Scan for vulnerabilities
# Use tools like Trivy, Snyk, or Docker Scout
```

### 2. Runtime Security
```yaml
# docker-compose security options
services:
  app:
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
```

## Docker Networking

### 1. Network Types
```bash
# Bridge network (default)
docker network create --driver bridge myapp-network

# Host network (performance)
docker run --network host myapp

# Overlay network (Swarm/multi-host)
docker network create --driver overlay --attachable myapp-overlay

# Custom bridge with subnet
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  myapp-custom
```

### 2. Service Discovery
```yaml
# Docker Compose automatic DNS
services:
  app:
    image: myapp
    networks:
      - backend
    environment:
      # Services can reach each other by name
      - REDIS_URL=redis://redis:6379
      - DB_HOST=postgres

  redis:
    image: redis:alpine
    networks:
      - backend

  postgres:
    image: postgres:15
    networks:
      - backend

networks:
  backend:
    driver: bridge
```

## Volume Management

### 1. Volume Types
```yaml
services:
  app:
    volumes:
      # Named volume (managed by Docker)
      - app_data:/data
      
      # Bind mount (development)
      - ./src:/app/src
      
      # Anonymous volume
      - /app/node_modules
      
      # Read-only mount
      - ./config:/app/config:ro
      
      # Tmpfs mount (memory)
    tmpfs:
      - /tmp

volumes:
  app_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /mnt/data/app
```

### 2. Backup and Restore
```bash
#!/bin/bash
# Backup volume
docker run --rm \
  -v myapp_data:/source \
  -v $(pwd):/backup \
  alpine tar -czf /backup/backup.tar.gz -C /source .

# Restore volume
docker run --rm \
  -v myapp_data:/target \
  -v $(pwd):/backup \
  alpine tar -xzf /backup/backup.tar.gz -C /target

# Database-specific backup
docker exec postgres pg_dump -U user dbname > backup.sql
docker exec -i postgres psql -U user dbname < backup.sql
```

## Container Orchestration

### 1. Docker Swarm
```bash
# Initialize swarm
docker swarm init --advertise-addr 192.168.1.100

# Deploy stack
docker stack deploy -c docker-compose.yml myapp

# Scale service
docker service scale myapp_web=5

# Rolling update
docker service update \
  --image myapp:v2 \
  --update-parallelism 2 \
  --update-delay 10s \
  myapp_web
```

### 2. Health Checks
```dockerfile
# Dockerfile health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Or custom script
COPY healthcheck.sh /usr/local/bin/
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
```

```yaml
# Compose health check
services:
  app:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

## Development Workflow

### 1. Hot Reload Setup
```dockerfile
# Development Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install nodemon for hot reload
RUN npm install -g nodemon

# Copy package files
COPY package*.json ./
RUN npm install

# Volume will be mounted here
VOLUME ["/app"]

# Use nodemon for development
CMD ["nodemon", "--legacy-watch", "src/index.js"]
```

### 2. Debugging Configuration
```yaml
# VS Code debugging with Docker
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
      - "9229:9229"  # Node.js debug port
    environment:
      - NODE_OPTIONS=--inspect=0.0.0.0:9229
    volumes:
      - .:/app
      - /app/node_modules
    command: npm run debug
```

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "attach",
      "name": "Docker: Attach to Node",
      "port": 9229,
      "address": "localhost",
      "localRoot": "${workspaceFolder}",
      "remoteRoot": "/app",
      "protocol": "inspector"
    }
  ]
}
```

## CI/CD Integration

### 1. GitHub Actions
```yaml
name: Docker CI/CD

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            user/app:latest
            user/app:${{ github.sha }}
          cache-from: type=registry,ref=user/app:buildcache
          cache-to: type=registry,ref=user/app:buildcache,mode=max
```

### 2. Multi-arch Builds
```dockerfile
# Build for multiple architectures
# Use buildx
docker buildx create --use
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag myapp:latest \
  --push .
```

## Monitoring and Logging

### 1. Logging Configuration
```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=app"
        env: "ENV,VERSION"

  # Centralized logging with ELK
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false

  logstash:
    image: logstash:8.8.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf

  kibana:
    image: kibana:8.8.0
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
```

### 2. Metrics Collection
```yaml
# Prometheus monitoring
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

  # Container metrics
  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    ports:
      - "8080:8080"
```

## Troubleshooting

### 1. Common Issues
```bash
# Debug container issues
docker logs container_name --follow --tail 50

# Exec into running container
docker exec -it container_name /bin/sh

# Inspect container
docker inspect container_name

# Check resource usage
docker stats

# Clean up resources
docker system prune -a --volumes

# Debug build issues
docker build --no-cache --progress=plain .

# Check layer sizes
docker history image_name
```

### 2. Performance Optimization
```bash
# Limit container resources
docker run -m 512m --cpus="1.5" myapp

# Use tmpfs for temporary files
docker run --tmpfs /tmp:rw,noexec,nosuid,size=100m myapp

# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1
docker build .
```

## Best Practices Summary

1. **Use minimal base images**: Alpine, distroless
2. **Multi-stage builds**: Reduce final image size
3. **Layer caching**: Order Dockerfile commands properly
4. **Security**: Non-root users, minimal permissions
5. **Health checks**: Ensure container readiness
6. **Resource limits**: Prevent resource exhaustion
7. **Logging**: Centralized logging strategy
8. **Secrets management**: Never hardcode secrets
9. **Version pinning**: Specific versions for reproducibility
10. **Regular updates**: Keep images and dependencies current

## Last Updated
2025-07-29

## Status
ACTIVE - DOCKER GUIDE