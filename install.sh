#!/bin/bash
set -e

echo "🔧 TFT Miner Installer for Raspberry Pi 4B"
echo "=========================================="
echo ""

# Check if running as pi user
if [ "$USER" != "pi" ]; then
    echo "❌ This script must be run as the 'pi' user"
    echo "   Run: cd ~/tft-miner && bash install.sh"
    exit 1
fi

echo "📦 Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv git build-essential autoconf automake libtool pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev zlib1g-dev wireless-tools wpasupplicant

echo "📚 Installing Python packages..."
pip3 install flask --break-system-packages 2>/dev/null || pip3 install flask

echo "⛏️  Building cpuminer-opt..."
if [ ! -d "$HOME/cpuminer-opt" ]; then
    cd $HOME
    git clone https://github.com/JayDDee/cpuminer-opt.git
    cd cpuminer-opt
    ./build.sh
    echo "✅ cpuminer-opt built successfully"
else
    echo "✓ cpuminer-opt already exists"
fi

echo "📁 Setting up configuration directory..."
mkdir -p ~/.config/tft-miner

echo "📋 Installing systemd services..."
sudo cp tft-miner.service /etc/systemd/system/
sudo cp tft-miner-web.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable tft-miner.service
sudo systemctl enable tft-miner-web.service

echo "🔐 Configuring sudo permissions for miner control..."
sudoers_entry="pi ALL=(ALL) NOPASSWD: /bin/systemctl start tft-miner.service, /bin/systemctl stop tft-miner.service, /bin/systemctl restart tft-miner.service, /bin/systemctl status tft-miner.service, /bin/systemctl daemon-reload, /bin/cp /tmp/tft-miner.service /etc/systemd/system/, /bin/cp /etc/wpa_supplicant/wpa_supplicant.conf, /sbin/wpa_cli, /bin/systemctl restart networking, /bin/systemctl restart wpa_supplicant, /sbin/iwlist"
echo "$sudoers_entry" | sudo tee /etc/sudoers.d/tft-miner > /dev/null
sudo chmod 440 /etc/sudoers.d/tft-miner

echo ""
echo "📡 Scanning for WiFi networks..."
echo ""

# Scan for WiFi networks
networks=$(sudo iwlist wlan0 scan 2>/dev/null | grep 'ESSID:' | sed 's/.*ESSID:"\(.*\)".*/\1/' | sort -u | grep -v '^$')

if [ -z "$networks" ]; then
    echo "⚠️  No WiFi networks found"
    echo ""
    echo "Options:"
    echo "1. Configure WiFi later via web interface"
    echo "2. Make sure your WiFi router is on"
    echo "3. Try running install again"
    echo ""
    read -p "Skip WiFi setup for now? (y/n) " skip_wifi
    if [ "$skip_wifi" != "y" ] && [ "$skip_wifi" != "Y" ]; then
        echo "Please turn on your WiFi router and try again."
        exit 1
    fi
else
    echo "Available WiFi Networks:"
    echo ""
    
    # Create array of networks
    declare -a network_array
    count=1
    while IFS= read -r network; do
        echo "  $count) $network"
        network_array[$count]="$network"
        ((count++))
    done <<< "$networks"
    
    echo ""
    read -p "Select network number (or press Enter to skip): " network_choice
    
    if [ -n "$network_choice" ] && [ "$network_choice" -ge 1 ] && [ "$network_choice" -lt "$count" ]; then
        selected_ssid="${network_array[$network_choice]}"
        echo ""
        echo "Selected: $selected_ssid"
        echo ""
        
        read -sp "Enter WiFi password: " wifi_password
        echo ""
        
        # Configure wpa_supplicant
        sudo tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
    ssid="$selected_ssid"
    psk="$wifi_password"
    key_mgmt=WPA-PSK
}
EOF
        
        echo "✓ WiFi configured: $selected_ssid"
        
        # Restart WiFi
        echo "Connecting to WiFi..."
        sudo systemctl restart wpa_supplicant
        sleep 3
        
        # Check connection
        if sudo wpa_cli -i wlan0 status 2>/dev/null | grep -q "wpa_state=COMPLETED"; then
            echo "✅ WiFi connected successfully!"
        else
            echo "⚠️  WiFi connection pending... It may take a few moments"
        fi
    else
        echo "Skipping WiFi setup"
    fi
fi

echo ""
echo "🚀 Starting services..."
sudo systemctl start tft-miner-web.service

echo ""
echo "✅ Installation complete!"
echo ""
echo "═══════════════════════════════════════════════════"
echo "NEXT STEPS:"
echo "═══════════════════════════════════════════════════"
echo ""
echo "1️⃣  Find your Pi's IP address:"
echo ""
echo "   Command: hostname -I"
echo ""
echo "   Or check your router for the device named 'raspberrypi'"
echo ""
echo "2️⃣  Open in your browser on any device:"
echo ""
echo "   http://YOUR_PI_IP:5000"
echo ""
echo "3️⃣  Configure Mining Pool:"
echo "   Click '⚙️ SETTINGS' → Pool Config"
echo "   Enter your MaxedHash pool details:"
echo ""
echo "   • Pool Address: sha256d.maxedhash.com"
echo "   • Pool Port: 3032"
echo "   • Wallet: Your DigiByte wallet address"
echo "   • Worker: pi4b (or custom name)"
echo "   • Algorithm: sha256d"
echo ""
echo "   Click 'SAVE POOL CONFIG' to start mining"
echo ""
echo "═══════════════════════════════════════════════════"
echo "MANAGE WiFi:"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Go to Settings → Network tab to:"
echo "  • View connection status"
echo "  • Add or change WiFi network"
echo "  • Check IP addresses"
echo ""
echo "═══════════════════════════════════════════════════"
echo "MONITORING & LOGS:"
echo "═══════════════════════════════════════════════════"
echo ""
echo "View miner logs:"
echo "   sudo journalctl -u tft-miner.service -f"
echo ""
echo "View web interface logs:"
echo "   sudo journalctl -u tft-miner-web.service -f"
echo ""
echo "Check miner status:"
echo "   sudo systemctl status tft-miner.service"
echo ""
echo "Monitor CPU/temps:"
echo "   vcgencmd measure_temp"
echo ""
echo "═══════════════════════════════════════════════════"
echo "TFT DISPLAY (3.5\"):"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Run in kiosk mode on your TFT screen:"
echo "   chromium-browser --kiosk --disable-infobars http://127.0.0.1:5000/display"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""
echo "🎉 Happy mining! 🎉"
echo ""
