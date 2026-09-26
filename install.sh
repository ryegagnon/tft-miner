#!/bin/bash
set -e

echo "🔨 TFT Miner Installer for Raspberry Pi 4B"
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
sudo apt-get install -y python3 python3-pip python3-venv git build-essential autoconf automake libtool pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev zlib1g-dev

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

echo "🔧 Setting up configuration directory..."
mkdir -p ~/.config/tft-miner

echo "📋 Installing systemd services..."
sudo cp tft-miner.service /etc/systemd/system/
sudo cp tft-miner-web.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable tft-miner.service
sudo systemctl enable tft-miner-web.service

echo "🔐 Configuring sudo permissions for miner control..."
sudoers_entry="pi ALL=(ALL) NOPASSWD: /bin/systemctl start tft-miner.service, /bin/systemctl stop tft-miner.service, /bin/systemctl restart tft-miner.service, /bin/systemctl status tft-miner.service, /bin/systemctl daemon-reload, /bin/cp /tmp/tft-miner.service /etc/systemd/system/"
echo "$sudoers_entry" | sudo tee /etc/sudoers.d/tft-miner > /dev/null
sudo chmod 440 /etc/sudoers.d/tft-miner

echo "🚀 Starting services..."
sudo systemctl start tft-miner-web.service

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Find your Pi's IP address:"
echo "   hostname -I"
echo ""
echo "2. Open in your browser:"
echo "   http://YOUR_PI_IP:5000/settings"
echo ""
echo "3. Configure your MaxedHash pool details:"
echo "   - Pool Address: sha256d.maxedhash.com"
echo "   - Pool Port: 3032"
echo "   - Wallet: Your DigiByte wallet address"
echo "   - Worker: pi4b (or custom name)"
echo "   - Algorithm: sha256d"
echo ""
echo "4. Click 'SAVE POOL CONFIG' to start mining"
echo ""
echo "View live display:"
echo "   http://YOUR_PI_IP:5000"
echo ""
echo "View logs:"
echo "   sudo journalctl -u tft-miner-web.service -f"
echo "   sudo journalctl -u tft-miner.service -f"
echo ""
echo "On your 3.5\" TFT display, run:"
echo "   chromium-browser --kiosk --disable-infobars http://127.0.0.1:5000"
echo ""
