#!/bin/bash

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Update package list and install required dependencies
echo "Installing required dependencies..."
apt update
apt install -y software-properties-common

# Add deadsnakes PPA for Python 3.13
echo "Adding deadsnakes PPA for Python 3.13..."
add-apt-repository -y ppa:deadsnakes/ppa
apt update

# Install Python 3.13 and its development files
echo "Installing Python 3.13..."
apt install -y python3.13 python3.13-venv python3.13-dev

# Create symlinks (optional, uncomment if you want to use python3.13 as default python3)
# update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1
# update-alternatives --set python3 /usr/bin/python3.13

# Install and configure PostgreSQL
echo "Installing PostgreSQL..."
apt install -y postgresql postgresql-contrib postgresql-server-dev-all

# Configure PostgreSQL to start on boot
systemctl enable postgresql
systemctl start postgresql

# Install Nginx
echo "Installing Nginx..."
apt install -y nginx

# Configure Nginx to start on boot
systemctl enable nginx
systemctl start nginx

# Install additional development tools
echo "Installing additional development tools..."
apt install -y build-essential libssl-dev libffi-dev python3-dev python3-pip

# Create a virtual environment (optional)
# echo "Creating a virtual environment..."
# python3.13 -m venv ~/venv
# source ~/venv/bin/activate

# Print installation summary
echo ""
echo "========================================"
echo "Python development environment setup complete!"
echo "Python 3.13 is now available as python3.13"
echo "PostgreSQL is running and configured to start on boot"
echo "Nginx is running and configured to start on boot"
echo ""
echo "To create a new virtual environment:"
echo "  python3.13 -m venv myenv"
echo "  source myenv/bin/activate"
echo ""
echo "To verify PostgreSQL is running:"
echo "  sudo -u postgres psql -c '\l'"
echo ""
echo "Nginx default page should be available at http://your-server-ip/"
echo "========================================"
