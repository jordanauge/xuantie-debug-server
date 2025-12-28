# Use the smallest stable Debian base
FROM debian:stable-slim

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
# Added 'sudo' because the installer script explicitly calls it
RUN apt-get update && apt-get install -y --no-install-recommends \
    libusb-1.0-0 \
    usbutils \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Copy the installer
COPY XuanTie-DebugServer-linux-x86_64-V5.18.5-20250612.sh .

# 1. Make executable
# 2. Use printf to send: 
#    'yes' (agreement)
#    ''    (empty enter for default path /usr/bin/XUANTIE_DebugServer)
#    'yes' (confirmation)
RUN chmod +x XuanTie-DebugServer-linux-x86_64-V5.18.5-20250612.sh && \
    printf 'yes\n\nyes\n' | ./XuanTie-DebugServer-linux-x86_64-V5.18.5-20250612.sh -i && \
    rm XuanTie-DebugServer-linux-x86_64-V5.18.5-20250612.sh

# Update PATH so you can call DebugServerConsole from anywhere
# The default path used by the script is /usr/bin/XUANTIE_DebugServer
ENV PATH="/usr/bin/XUANTIE_DebugServer/bin:${PATH}"

WORKDIR /work

# Expose ports: 1025 (Server), 1234 (GDB)
EXPOSE 1025 1234

CMD ["DebugServerConsole"]
