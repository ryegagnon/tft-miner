# TFT Miner

A complete SHA-256 mining setup for Raspberry Pi 4B with:
- 🖥️ Web-based configuration interface
- 📊 Live miner statistics display
- 💹 Real-time market data (CoinGecko API)
- 📱 3.5" TFT display support
- ⚙️ DigiByte, Bitcoin, Litecoin, Dogecoin support

## Quick Start

### 1. Clone the repository
```bash
cd ~
git clone https://github.com/ryegagnon/tft-miner.git
cd tft-miner
```

### 2. Run the installer
```bash
bash install.sh
```

The installer will:
- Install Python dependencies (Flask)
- Build cpuminer-opt from source
- Configure systemd services
- Set up sudo permissions for miner control
- Start the web interface on port 5000

### 3. Configure your pool

Open `http://YOUR_PI_IP:5000/settings` in a browser:

- **Pool Address**: `sha256d.maxedhash.com`
- **Pool Port**: `3032`
- **Wallet**: Your DigiByte wallet address
- **Worker**: `pi4b` (or custom name)
- **Algorithm**: `sha256d`

Click "SAVE POOL CONFIG" to start mining.

### 4. View live display

Open `http://YOUR_PI_IP:5000` to see:
- Hash rate
- Accepted/rejected shares
- Current coin price
- 24h price change
- Market cap

## For 3.5" TFT Display

Connect your TFT display, then run:

```bash
chromium-browser --kiosk --disable-infobars http://127.0.0.1:5000
```

Or add to `~/.config/autostart/` for auto-launch on boot.

## Monitoring

### Web Interface
- **Display**: `http://YOUR_PI_IP:5000`
- **Settings**: `http://YOUR_PI_IP:5000/settings`

### Check service status
```bash
sudo systemctl status tft-miner.service
sudo systemctl status tft-miner-web.service
```

### View logs
```bash
# Miner logs
sudo journalctl -u tft-miner.service -f

# Web interface logs
sudo journalctl -u tft-miner-web.service -f
```

### Control miner
```bash
# Start
sudo systemctl start tft-miner.service

# Stop
sudo systemctl stop tft-miner.service

# Restart
sudo systemctl restart tft-miner.service
```

## Supported Coins

- **DigiByte (DGB)** - SHA256d ✅ (recommended for MaxedHash)
- **Bitcoin (BTC)** - SHA256
- **Litecoin (LTC)** - Scrypt
- **Dogecoin (DOGE)** - Scrypt

Switch coins anytime in Settings → Coin Selection. The display will instantly update with current market data.

## System Requirements

- Raspberry Pi 4B (2GB+ RAM recommended)
- 16GB+ microSD card
- Active internet connection
- Cooling solution (heatsink or fan)

## Performance

- **Pi 4B 2GB**: ~3-5 MH/s SHA256d
- **Temperature**: Monitor with `vcgencmd measure_temp` (keep < 80°C)
- **Power**: ~5-7W mining power draw

## File Structure

```
~/.config/tft-miner/
  └── miner.json          # Pool configuration (auto-saved)

~/tft-miner/
  ├── app.py              # Flask backend
  ├── install.sh          # Installation script
  ├── tft-miner.service   # Miner systemd service
  ├── tft-miner-web.service # Web interface service
  └── templates/
      ├── index.html      # Display page
      └── settings.html   # Configuration page

~/cpuminer-opt/           # CPU miner (built during install)
```

## Troubleshooting

### Miner not starting?
```bash
sudo journalctl -u tft-miner.service -n 50
```

Check pool address, port, and wallet address in settings.

### Web interface not loading?
```bash
sudo journalctl -u tft-miner-web.service -n 50
```

Make sure Flask is installed: `pip3 install flask`

### Temperature too high?
Add a heatsink or fan, increase ventilation, or reduce clock speed.

### Want to disable miner on boot?
```bash
sudo systemctl disable tft-miner.service
```

Re-enable:
```bash
sudo systemctl enable tft-miner.service
```

## License

MIT License - Feel free to modify and distribute.

## Contributing

Fork, modify, and submit PRs. Contributions welcome!

## Pools Tested

- ✅ MaxedHash (sha256d.maxedhash.com)
- ✅ HMPOOL
- ✅ Mining Pool Hub

## Notes

- Earnings on a Pi 4B are minimal but contribute to your overall hash power
- Electricity cost may exceed earnings; mine for the love of crypto!
- Always keep your wallet address secure
- The web interface is for local network only (no remote security implemented)
