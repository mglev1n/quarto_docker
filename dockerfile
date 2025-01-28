FROM ubuntu:latest

ARG QUARTO_VERSION="latest"

RUN set -eux && \
    # Handle 'default' version by setting to 'latest' \
    if [ "$QUARTO_VERSION" = "default" ]; then \
        QUARTO_VERSION="latest"; \
    fi && \
    # Get system architecture \
    ARCH=$(dpkg --print-architecture) && \
    # Install system dependencies \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        pandoc \
    && \
    # Determine download URL \
    if [ "$QUARTO_VERSION" = "latest" ] || [ "$QUARTO_VERSION" = "release" ]; then \
        QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json | grep -oP "(?<=\"download_url\":\s\")https.*${ARCH}\.deb"); \
    elif [ "$QUARTO_VERSION" = "prerelease" ]; then \
        QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_prerelease.json | grep -oP "(?<=\"download_url\":\s\")https.*${ARCH}\.deb"); \
    else \
        QUARTO_DL_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${ARCH}.deb"; \
    fi && \
    # Download and install Quarto \
    wget "$QUARTO_DL_URL" -O /tmp/quarto.deb && \
    dpkg -i /tmp/quarto.deb && \
    rm /tmp/quarto.deb && \
    # Verify installation and check dependencies \
    quarto check install && \
    # Cleanup \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["quarto", "--version"]