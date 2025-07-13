#!/bin/bash

# Enhanced user_data.sh script for NGINX installation
# Author: Generated script
# Description: Installs and configures NGINX with improved error handling and logging

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# Configuration
LOGFILE="/var/log/user_data.log"
NGINX_USER="nginx"
BACKUP_DIR="/etc/nginx/backup"

# Function to log messages with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

# Function to handle errors
error_handler() {
    local exit_code=$?
    log "ERROR: Script failed at line $1 with exit code $exit_code"
    log "ERROR: Command that failed: $BASH_COMMAND"
    exit $exit_code
}

# Set up error trapping
trap 'error_handler $LINENO' ERR

# Create log file and set permissions
touch "$LOGFILE"
chmod 644 "$LOGFILE"

log "=== Starting NGINX installation script ==="
log "Operating System: $(cat /etc/system-release 2>/dev/null || echo 'Unknown')"
log "User: $(whoami)"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log "ERROR: This script must be run as root"
    exit 1
fi

# Update system packages
log "Updating system packages..."
if yum update -y >> "$LOGFILE" 2>&1; then
    log "System update completed successfully"
else
    log "WARNING: System update encountered issues but continuing..."
fi

# Install NGINX
log "Installing NGINX..."
if yum install -y nginx >> "$LOGFILE" 2>&1; then
    log "NGINX installation completed successfully"
else
    log "ERROR: Failed to install NGINX"
    exit 1
fi

# Verify NGINX installation
if ! command -v nginx &> /dev/null; then
    log "ERROR: NGINX command not found after installation"
    exit 1
fi

# Check NGINX version
NGINX_VERSION=$(nginx -v 2>&1 | grep -o '[0-9.]*')
log "NGINX version installed: $NGINX_VERSION"

# Create backup directory
log "Creating backup directory..."
mkdir -p "$BACKUP_DIR"

# Backup default configuration
if [[ -f /etc/nginx/nginx.conf ]]; then
    log "Backing up default NGINX configuration..."
    cp /etc/nginx/nginx.conf "$BACKUP_DIR/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Configure firewall (if firewalld is available)
if systemctl is-active --quiet firewalld; then
    log "Configuring firewall for HTTP and HTTPS..."
    firewall-cmd --permanent --add-service=http >> "$LOGFILE" 2>&1 || true
    firewall-cmd --permanent --add-service=https >> "$LOGFILE" 2>&1 || true
    firewall-cmd --reload >> "$LOGFILE" 2>&1 || true
    log "Firewall configuration completed"
fi

# Start and enable NGINX
log "Starting NGINX service..."
if systemctl start nginx; then
    log "NGINX started successfully"
else
    log "ERROR: Failed to start NGINX"
    exit 1
fi

log "Enabling NGINX to start on boot..."
if systemctl enable nginx; then
    log "NGINX enabled for automatic startup"
else
    log "WARNING: Failed to enable NGINX for automatic startup"
fi

# Verify NGINX is running
if systemctl is-active --quiet nginx; then
    log "NGINX service is running"
else
    log "ERROR: NGINX service is not running"
    exit 1
fi

# Test NGINX configuration
log "Testing NGINX configuration..."
if nginx -t >> "$LOGFILE" 2>&1; then
    log "NGINX configuration test passed"
else
    log "ERROR: NGINX configuration test failed"
    exit 1
fi

# Display service status
log "NGINX service status:"
systemctl status nginx --no-pager -l >> "$LOGFILE" 2>&1

# Create a simple index page
log "Creating custom index page..."
cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to NGINX!</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        h1 { color: #333; }
        .info { background: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>NGINX is running successfully!</h1>
    <div class="info">
        <p><strong>Server:</strong> NGINX</p>
        <p><strong>Installation Date:</strong> $(date)</p>
        <p><strong>Status:</strong> Active</p>
    </div>
</body>
</html>
EOF

# Get server IP for testing
SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")

log "=== NGINX installation completed successfully ==="
log "Server IP: $SERVER_IP"
log "Test URL: http://$SERVER_IP"
log "Configuration file: /etc/nginx/nginx.conf"
log "Document root: /usr/share/nginx/html"
log "Log file: $LOGFILE"
log "Backup directory: $BACKUP_DIR"

# Final verification
log "Performing final verification..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    log "SUCCESS: NGINX is responding to HTTP requests"
else
    log "WARNING: NGINX may not be responding properly to HTTP requests"
fi

log "=== Script execution completed ==="

# Display summary
cat << EOF

=== INSTALLATION SUMMARY ===
✓ System updated
✓ NGINX installed (version: $NGINX_VERSION)
✓ NGINX service started and enabled
✓ Firewall configured (if available)
✓ Configuration tested
✓ Custom index page created

Next steps:
1. Visit http://$SERVER_IP to test your server
2. Check logs at $LOGFILE
3. Customize /etc/nginx/nginx.conf as needed
4. Add your website files to /usr/share/nginx/html

EOF