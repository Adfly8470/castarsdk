FROM docker.io/ubuntu:latest AS grass-desktop-package-builder

# Install tools to download and handle the wipter.deb package
RUN apt-get -y update && apt-get -y --no-install-recommends --no-install-suggests install \
    binutils wget ca-certificates

# Download the wipter.deb package
RUN wget -q -O /tmp/wipter.deb https://provider-assets.wipter.com/latest/linux/x64/wipter-app-amd64.deb

FROM docker.io/ubuntu:latest

# Install essential packages, including dependencies for GNOME Keyring and D-Bus
RUN apt-get -y update && apt-get -y --no-install-recommends --no-install-suggests install \
    wget tini xdotool gpg openbox ca-certificates \
    python3-pip python3-venv \
    git \
    # Add dependencies for GNOME Keyring and D-Bus
    gnome-keyring libsecret-1-0 libsecret-1-dev dbus-x11 \
    && apt-get clean

# Create a virtual environment and install Python dependencies, including keyring (optional)
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir websockify keyring

# Update CA certificates
RUN update-ca-certificates

# Copy noVNC files
RUN git clone https://github.com/novnc/noVNC.git /noVNC

# Expose the necessary ports
EXPOSE 5900 6080

# Install TurboVNC
RUN wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey | gpg --dearmor > /etc/apt/trusted.gpg.d/TurboVNC.gpg
RUN wget -q -O /etc/apt/sources.list.d/turbovnc.list https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list
RUN apt-get -y update && apt-get -y install turbovnc
RUN apt-get install -y libwebkit2gtk-4.1-0 && rm -rf /var/lib/apt/lists/*

# Copy the wipter.deb package from the builder stage
COPY --from=grass-desktop-package-builder /tmp/wipter.deb /tmp/wipter.deb

# Set the working directory
WORKDIR /app

# Install system dependencies for wipter
RUN apt-get -y update && \
    apt-get -y install curl iputils-ping net-tools apt-transport-https libnspr4 libnss3 libxss1 && \
    apt-get clean

# Install the wipter.deb package and fix any broken dependencies
RUN dpkg -i /tmp/wipter.deb; apt-get -y --fix-broken --no-install-recommends --no-install-suggests install
RUN rm /tmp/wipter.deb

# Create a non-root user for security (recommended)
RUN useradd -m -s /bin/bash wipter
USER wipter

# Set up the keyring directory for the user
RUN mkdir -p /home/wipter/.local/share/keyrings

# Copy the start script
COPY start.sh /home/wipter/start.sh

# Ensure the start script is executable
#RUN chmod +x /home/wipter/start.sh

# Use tini as the entrypoint to manage processes
ENTRYPOINT ["tini", "-s", "/home/wipter/start.sh"]
