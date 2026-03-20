# NaiveProxy Docker

[![Build and Push Docker Image](https://github.com/rwecho/naiveproxy-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/rwecho/naiveproxy-docker/actions/workflows/docker-build.yml)

Docker image for [NaiveProxy](https://github.com/klzgrad/naiveproxy) with multi-architecture support (x86_64 and ARM64).

## Features

- 🏗️ Multi-architecture support (linux/amd64, linux/arm64)
- 📦 Based on Alpine Linux (minimal image size)
- 🔄 Daily automatic builds for new versions
- 🔒 Runs as non-root user for security
- ⚡ Multi-stage build for optimized image size

## Quick Start

### Pull Image

```bash
docker pull rwecho/naiveproxy:latest
```

### Run with Docker

```bash
# Create config file first
mkdir -p /path/to/config
cat > /path/to/config/config.json <<EOF
{
  "listen": "socks://0.0.0.0:1080",
  "proxy": "https://user:password@example.com:443",
  "log": ""
}
EOF

# Run container
docker run -d \
  --name naiveproxy \
  --restart unless-stopped \
  -v /path/to/config:/etc/naive \
  -p 1080:1080 \
  rwecho/naiveproxy:latest
```

### Run with Docker Compose

```yaml
version: '3.8'

services:
  naiveproxy:
    image: rwecho/naiveproxy:latest
    container_name: naiveproxy
    restart: unless-stopped
    volumes:
      - ./config:/etc/naive
    ports:
      - "1080:1080"
```

## Configuration

Create a `config.json` file with your NaiveProxy configuration:

```json
{
  "listen": "socks://0.0.0.0:1080",
  "proxy": "https://user:password@your-server:443",
  "log": ""
}
```

For more configuration options, see [NaiveProxy documentation](https://github.com/klzgrad/naiveproxy).

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CONFIG_PATH` | `/etc/naive/config.json` | Path to config file |

## Available Tags

- `latest` - Latest stable version
- `VERSION` - Specific version (e.g., `120.0.6099.43-1`)

## GitHub Actions

This project uses GitHub Actions for:

1. **Daily version check** - Automatically checks for new NaiveProxy releases
2. **Multi-arch build** - Builds for amd64 and arm64 platforms
3. **Auto push** - Pushes to Docker Hub when new versions are available

### Required Secrets

Set these secrets in your GitHub repository:

- `DOCKERHUB_USERNAME` - Your Docker Hub username
- `DOCKERHUB_TOKEN` - Your Docker Hub access token

### Manual Build

You can also trigger a manual build with a specific version:

1. Go to Actions → Build and Push NaiveProxy Docker Image
2. Click "Run workflow"
3. Enter the version (optional)
4. Click "Run workflow"

## Building Locally

```bash
# Build for current architecture
docker build --build-arg NAIVEPROXY_VERSION=120.0.6099.43-1 -t naiveproxy:local .

# Build for multiple architectures (requires buildx)
docker buildx build --platform linux/amd64,linux/arm64 \
  --build-arg NAIVEPROXY_VERSION=120.0.6099.43-1 \
  -t naiveproxy:local .
```

## License

This project is licensed under the MIT License. NaiveProxy is licensed under its own terms.

## Related

- [NaiveProxy](https://github.com/klzgrad/naiveproxy) - Original project
