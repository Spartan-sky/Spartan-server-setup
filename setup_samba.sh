!#/bin/bash

# Variables
SHARE_NAME="Public"
SHARE_DIR="home/skylar/shared"
SAMBA_CONF="/etc/samba/smb.conf"
USER="$(whoami)"

# Ensure Samba is installed
if ! command -v smbd >/dev/null 2>&1; then
  echo "Installing Samba..."
  sudo apt update
  sudo apt install -y samba
fi

# Create the share directory
echo "Creating directory: $SHARE_DIR"
sudo mkdir -p "$SHARE_DIR"
sudo chmod 755 "$SHARE_DIR"
sudo chown "$USER:$USER" "$SHARE_DIR"

# Add the [Public] share to smb.conf
CONFIG_BLOCK="[$SHARE_NAME]
   path = $SHARE_DIR
   browseable = yes
   read only = no
   guest ok = yes
   force user = $USER"

# Add to smb.conf
if ! grep -q "^\[$SHARE_NAME\]" "$SAMBA_CONFIG"; then
  echo "Adding [$SHARE_NAME] share to $SAMBA_CONFIG..."
  echo -e "\n$CONFIG_BLOCK" | sudo tee -a "$SAMBA_CONFIG" >/dev/null
else
  echo "[$SHARE_NAME] already exists in $SAMBA_CONFIG"
fi

# Restart Samba service
echo "Restarting Samba..."
sudo systemctl restart smbd

echo "✅ Samba setup complete for [$SHARE_NAME]."
echo "You can now access it via //hostname/$SHARE_NAME or //IP/$SHARE_NAME"
