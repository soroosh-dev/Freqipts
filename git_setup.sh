#!/bin/bash

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "This script should not be run as root. Please run as a regular user."
    exit 1
fi

# Get user information
read -p "Enter your Git name (e.g., John Doe): " GIT_NAME
read -p "Enter your Git email: " GIT_EMAIL
read -s -p "Enter passphrase for SSH key (leave empty for no passphrase): " SSH_PASSPHRASE
echo ""

# Configure Git
echo "Configuring Git..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Set default branch name to main
git config --global init.defaultBranch main

# Configure line endings
git config --global core.autocrlf input

# Set default push behavior
git config --global push.default current

# Configure pull to rebase by default
git config --global pull.rebase true

# Configure credential helper to store credentials
git config --global credential.helper store

# Generate SSH key
echo "Generating SSH key..."
SSH_KEY_PATH="$HOME/.ssh/id_ed25519_github"

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate the SSH key with the provided passphrase
if [ -z "$SSH_PASSPHRASE" ]; then
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N ""
else
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N "$SSH_PASSPHRASE"
fi

# Set correct permissions
chmod 600 "$SSH_KEY_PATH"
chmod 644 "${SSH_KEY_PATH}.pub"

# Configure SSH config for GitHub
echo "Configuring SSH..."
cat >> ~/.ssh/config <<EOL

# GitHub account
Host github.com
  HostName github.com
  User git
  IdentityFile $SSH_KEY_PATH
  IdentitiesOnly yes
  AddKeysToAgent yes
EOL

# Set correct permissions for SSH config
chmod 600 ~/.ssh/config

# Add SSH key to SSH agent
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain "$SSH_KEY_PATH"

# Configure Git to use SSH for GitHub
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Configure Git to sign commits with SSH key
git config --global gpg.format ssh
git config --global user.signingkey "${SSH_KEY_PATH}.pub"
git config --global commit.gpgsign true

# Display the public key
echo ""
echo "========================================"
echo "Git configuration complete!"
echo ""
echo "Your public SSH key (add this to GitHub):"
echo ""
cat "${SSH_KEY_PATH}.pub"
echo ""
echo "========================================"
echo "To add this key to your GitHub account:"
echo "1. Go to https://github.com/settings/keys"
echo "2. Click 'New SSH key'"
echo "3. Give it a title (e.g., $(hostname))"
echo "4. Paste the key above"
echo "5. Click 'Add SSH key'"
echo ""
echo "To test your SSH connection, run:"
echo "ssh -T git@github.com"
echo "========================================"
