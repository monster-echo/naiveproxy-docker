# NaiveProxy Docker

[![Build and Push Docker Image](https://github.com/monster-echo/naiveproxy-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/monster-echo/naiveproxy-docker/actions/workflows/docker-build.yml)

Docker images for [NaiveProxy](https://github.com/klzgrad/naiveproxy) with multi-architecture support (x86_64 and ARM64).

## Images

| Image | Description |
|------|-------------|
| `rwecho/naiveproxy` | NaiveProxy 客户端 |
| `rwecho/caddy-forwardproxy` | Caddy + forward_proxy (服务端) |

## Features

- 🏗️ Multi-architecture support (linux/amd64, linux/arm64)
- 📦 Based on Debian slim (glibc native support)
- 🔄 Daily automatic builds for new versions
- 🔒 Runs as non-root user for security
- ⚡ Multi-stage build for optimized image size

## Quick Start

### Client Mode

```bash
docker pull rwecho/naiveproxy:latest
```

Create config file:

```bash
mkdir -p ~/naive-config
cat > ~/naive-config/config.json <<'EOF'
{
  "listen": "socks://0.0.0.0:1080",
  "proxy": "https://user:password@your-server.com:443"
}
EOF

Run client:

```bash
docker run -d \
  --name naiveproxy \
  --restart unless-stopped \
  -v ~/naive-config:/etc/naive \
  -p 1080:1080 \
  rwecho/naiveproxy:latest
```

### Server Mode (Caddy + forward_proxy)

```bash
docker pull rwecho/caddy-forwardproxy:latest
```

Create directories:

```bash
mkdir -p ~/naive-server/{caddy,html}
```

Create Caddyfile (`~/naive-server/caddy/Caddyfile`):

```text
your-domain.com {
  tls your-email@example.com

  route {
    forward_proxy {
      basic_auth your_user your_password
      hide_headers
    }
    file_server {
      root /var/www/html
    }
  }
}
```

Create a simple HTML page (`~/naive-server/html/index.html`):

```html
<!DOCTYPE html>
<html>
<head><title>Welcome</title></head>
<body><h1>Welcome!</h1></body>
</html>
```

Run server:

```bash
docker run -d \
  --name caddy \
  --restart unless-stopped \
  -v ~/naive-server/caddy:/etc/caddy \
  -v ~/naive-server/html:/var/www/html \
  -p 80:80 \
  -p 443:443 \
  rwecho/caddy-forwardproxy:latest
```

### Docker Compose

```yaml
version: '3.8'

services:
  caddy:
    image: rwecho/caddy-forwardproxy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./caddy:/etc/caddy
      - ./html:/var/www/html
```

## Configuration

### Client Config (config.json)

```json
{
  "listen": "socks://0.0.0.0:1080",
  "proxy": "https://user:password@your-server:443"
}
```

For more configuration options, see [NaiveProxy documentation](https://github.com/klzgrad/naiveproxy).

### Server Caddyfile

```text
your-domain.com {
  tls your-email@example.com

  route {
    forward_proxy {
      basic_auth your_user your_password
      hide_headers
    }
    file_server {
      root /var/www/html
    }
  }
}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CONFIG_PATH` | `/etc/naive/config.json` | Path to config file |

## Available Tags

- `latest` - Latest stable version
- `VERSION` - Specific version (e.g., `143.0.7499.109-2`)

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
4. Check "build_server" to also build the server image
5. Click "Run workflow"

## Building Locally

```bash
# Build client
docker build -t naiveproxy:local .

# Build server
docker build -f Dockerfile.server -t caddy-forwardproxy:local .
```

## License

This project is licensed under the MIT License. NaiveProxy is licensed under its own terms.

## Related

- [NaiveProxy](https://github.com/klzgrad/naiveproxy) - Original project
