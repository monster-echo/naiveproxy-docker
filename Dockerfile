# Multi-stage build for NaiveProxy
# Build stage: download and extract naiveproxy
FROM alpine:3.19 AS builder

ARG TARGETARCH
ARG NAIVEPROXY_VERSION

WORKDIR /build

# Install dependencies for downloading
RUN apk add --no-cache curl xz

# Download and extract NaiveProxy
RUN set -eux; \
    ARCH=$(echo ${TARGETARCH} | sed 's/amd64/x64/' | sed 's/arm64/arm64/'); \
    echo "Downloading naiveproxy for ${TARGETARCH} -> ${ARCH}"; \
    FILENAME="naiveproxy-v${NAIVEPROXY_VERSION}-linux-${ARCH}"; \
    curl -L -o naiveproxy.tar.xz "https://github.com/klzgrad/naiveproxy/releases/download/v${NAIVEPROXY_VERSION}/${FILENAME}.tar.xz"; \
    tar -xJf naiveproxy.tar.xz; \
    mv "${FILENAME}/naive" /build/naive; \
    chmod +x /build/naive

# Runtime stage - Use Debian slim for glibc support
FROM debian:bookworm-slim

LABEL maintainer="naiveproxy-docker"
LABEL org.opencontainers.image.source="https://github.com/klzgrad/naiveproxy"

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    tzdata && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -g 1000 naive && \
    useradd -u 1000 -g naive -s /bin/sh -m naive

WORKDIR /app

# Copy binary from builder
COPY --from=builder /build/naive /usr/local/bin/naive

# Make sure binary is executable
RUN chmod +x /usr/local/bin/naive

# Create config directory
RUN mkdir -p /etc/naive && \
    chown -R naive:naive /etc/naive

# Switch to non-root user
USER naive

# Expose default port (can be overridden)
EXPOSE 1080

# Default config path
ENV CONFIG_PATH=/etc/naive/config.json

# Entry point
ENTRYPOINT ["naive"]
CMD ["/etc/naive/config.json"]
