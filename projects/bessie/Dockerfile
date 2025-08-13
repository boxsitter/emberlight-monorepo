# Multi-stage build for Flutter web development
FROM ubuntu:22.04 as base

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_VERSION=3.24.5
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    && tar -xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -C /opt \
    && rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Pre-download Flutter web dependencies
RUN flutter precache --web

# Set up working directory - copy from two levels up (monorepo root)
WORKDIR /app
COPY ../../ .

# Set working directory to the bessie project
WORKDIR /app/projects/bessie

# Get dependencies for all packages in the monorepo
RUN cd /app && flutter pub get
RUN cd /app/packages/ember_core && flutter pub get
RUN cd /app/packages/ember_fire && flutter pub get  
RUN cd /app/packages/bess_ui && flutter pub get
RUN cd /app/packages/ember_cli_utils && flutter pub get

# Get dependencies for the bessie project
RUN flutter pub get

# Enable web support
RUN flutter config --enable-web

# Expose the port Flutter web server will use
EXPOSE 8080

# Set environment variables for debug mode
ENV FLUTTER_WEB_PORT=8080
ENV FLUTTER_WEB_HOSTNAME=0.0.0.0

# Command to run the app in debug mode with hot reload
CMD ["flutter", "run", "--web-port=8080", "--web-hostname=0.0.0.0", "--debug", "--hot"]