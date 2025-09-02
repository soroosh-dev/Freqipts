#!/bin/bash

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if username and password are provided as arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# Update and upgrade system
echo "Updating and upgrading system packages..."
apt update && apt upgrade -y

# Install required packages
echo "Installing required packages..."
apt install -y xfce4 xrdp ufw fail2ban git curl wget htop nano

# Create new user and set password
echo "Creating new user: $USERNAME..."
adduser --gecos "" --disabled-password "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

# Add user to sudo group
usermod -aG sudo "$USERNAME"

# Configure XRDP
echo "Configuring XRDP..."
systemctl enable xrdp
systemctl start xrdp

# Configure firewall
echo "Configuring firewall..."
ufw allow 22/tcp
ufw allow 3389/tcp
echo "y" | ufw enable

# Configure fail2ban
echo "Configuring fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

# Configure XRDP to use XFCE
echo "Configuring XRDP to use XFCE..."
echo 'startxfce4' > /home/$USERNAME/.xsession
chown $USERNAME:$USERNAME /home/$USERNAME/.xsession

# Install additional recommended packages
echo "Installing additional recommended packages..."
apt install -y xfce4-goodies xfce4-terminal firefox

# Clean up
echo "Cleaning up..."
apt autoremove -y
apt clean

echo ""
echo "========================================"
echo "Server setup completed successfully!"
echo "New user created: $USERNAME"
echo "You can now connect using RDP on port 3389"
echo "========================================"
