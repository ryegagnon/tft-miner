# TFT Miner Setup Guide

Complete step-by-step guide for setting up SHA-256 mining on Raspberry Pi 4B with web-based configuration and 3.5" TFT display support.

---

## Table of Contents

1. [Hardware Requirements](#hardware-requirements)
2. [Prepare the Hardware](#prepare-the-hardware)
3. [Flash Raspberry Pi OS](#flash-raspberry-pi-os)
4. [Connect via SSH from Windows](#connect-via-ssh-from-windows)
5. [Run the Installer](#run-the-installer)
6. [Configure Mining Pool](#configure-mining-pool)
7. [Monitor Your Miner](#monitor-your-miner)
8. [Setup TFT Display](#setup-tft-display)
9. [Troubleshooting](#troubleshooting)

---

## Hardware Requirements

### Essential
- **Raspberry Pi 4B** (2GB RAM minimum recommended)
- **microSD card** (16GB or larger)
- **Power supply** (5V 3A USB-C)
- **Ethernet cable** (recommended for initial setup)
- **Windows PC** with SSH client (built-in to Windows 10/11)

### Recommended
- **Heatsink + Fan** (Pi will run hot during mining — keep it under 80°C)
- **3.5" TFT Display** (optional, for live stats display)
- **HDMI Cable + Monitor** (for initial verification, optional)

### Optional
- WiFi adapter (if not using Ethernet)
- PoE Power Injector (if using PoE hat)

---

## Prepare the Hardware

### Step 1: Assemble the Pi

1. Apply heatsinks to:
   - Main CPU chip
   - RAM chip
   - USB controller chip

2. Install cooling fan (if using one)

3. Insert microSD card into the SD card slot

### Step 2: Connect Cables

- Connect Ethernet cable to Pi's Gigabit Ethernet port
- Connect USB-C power supply (do NOT power on yet)
- Optional: Connect HDMI cable to monitor/TV

### Step 3: Power On

- Plug in the power supply
- Wait 1-2 minutes for the Pi to boot
- Green LED should blink (indicates activity)

---

## Flash Raspberry Pi OS

Follow these steps **before** connecting to the Pi.

### On Your Windows PC

1. **Download Raspberry Pi Imager**
   - Go to: https://www.raspberrypi.com/software/
   - Download for Windows
   - Install it

2. **Insert microSD into PC card reader**

3. **Open Raspberry Pi Imager**

4. **Select Device**
   - Click "CHOOSE DEVICE"
   - Select: **Raspberry Pi 4**

5. **Select Operating System**
   - Click "CHOOSE OS"
   - Select: **Raspberry Pi OS (other)**
   - Select: **Raspberry Pi OS Lite (32-bit)**
   
   *(We use Lite because we don't need the GUI)*

6. **Select Storage**
   - Click "CHOOSE STORAGE"
   - Select your microSD card
   - ⚠️ **WARNING:** Make sure you select the RIGHT card — this will erase it

7. **Write**
   - Click "NEXT"
   - Click "EDIT SETTINGS" (optional, to set hostname)
   - Click "SAVE"
   - Click "YES" to begin writing
   - Wait 3-5 minutes for completion
   - Click "CONTINUE" when done

8. **Eject microSD**
   - Right-click the SD card in Windows
   - Click "Eject"
   - Remove the card from the reader

---

## Connect via SSH from Windows

### Insert microSD and Power On

1. Insert the flashed microSD card into your Pi
2. Plug in the power supply
3. Wait 1-2 minutes for boot

### Find the Pi's IP Address

**Option A: Using Windows PowerShell (Easiest)**

Open PowerShell and run:

```powershell
ping raspberrypi.local
```

You should see output like:
```
Reply from 192.168.1.50: bytes=32 time=5ms TTL=64
```

The IP address is `192.168.1.50` in this example.

**Option B: Check Your Router**

1. Open your router's admin page (usually `192.168.1.1` or `192.168.0.1`)
2. Login with your router password
3. Look for connected devices
4. Find device named `raspberrypi`
5. Note its IP address

### Connect via SSH

Open Windows PowerShell and run:

```powershell
ssh pi@raspberrypi.local
```

Or use the IP address:

```powershell
ssh pi@192.168.1.50
```

When prompted for password, type:
```
raspberry
```

You should see a prompt like:
```
pi@raspberrypi:~ $
```

✅ **You are now connected to the Pi!**

---

## Run the Installer

Once connected via SSH, follow these steps:

### Step 1: Update the System

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

This takes 2-5 minutes.

### Step 2: Change Your Password (Recommended)

```bash
passwd
```

Enter a new password twice. This is more secure than the default.

### Step 3: Clone the Repository

```bash
cd ~
git clone https://github.com/ryegagnon/tft-miner.git
cd tft-miner
```

### Step 4: Run the Installer

```bash
bash install.sh
```

The installer will:
- Install Python, Flask, and build tools
- Clone and build cpuminer-opt (takes 10-20 minutes)
- Setup systemd services
- Configure sudo permissions

### Step 5: WiFi Setup (during install)

The installer will scan for WiFi networks and show:

```
📡 Scanning for WiFi networks...

Available WiFi Networks:

  1) MyHomeNetwork
  2) WorkWiFi
  3) CoffeeShop
  4) GuestNetwork

Select network number (or press Enter to skip):
```

**Option A: Setup WiFi Now**
- Type the number of your network (e.g., `1`)
- Press Enter
- Type your WiFi password
- Press Enter
- Wait for connection confirmation

**Option B: Skip WiFi**
- Just press Enter without typing anything
- You can configure WiFi later via the web interface

### Step 6: Installation Complete

You should see:

```
✅ Installation complete!

═══════════════════════════════════════════════════
NEXT STEPS:
═══════════════════════════════════════════════════

1️⃣  Find your Pi's IP address:
   Command: hostname -I

2️⃣  Open in your browser:
   http://YOUR_PI_IP:5000
```

---

## Configure Mining Pool

### Step 1: Find Your Pi's IP

In the SSH terminal, type:

```bash
hostname -I
```

You'll see output like:
```
192.168.1.50
```

Note this IP address.

### Step 2: Open the Web Interface

On your Windows PC, open a browser and go to:

```
http://192.168.1.50:5000
```

Replace `192.168.1.50` with your Pi's actual IP.

You should see the **Pi Miner Dashboard** with:
- Hash Rate (currently 0)
- Accepted/Rejected shares
- Current coin price
- Market cap

### Step 3: Open Settings

Click the link or go to:

```
http://192.168.1.50:5000/settings
```

You'll see two tabs:
- **Pool Config**
- **Network**

### Step 4: Configure Pool Settings

Click the **Pool Config** tab and fill in:

**Coin Selection:**
- Select: `DigiByte (DGB) - SHA256d`

**Pool Address:**
- Enter: `sha256d.maxedhash.com`

**Pool Port:**
- Enter: `3032`

**Wallet Address:**
- Enter: Your DigiByte wallet address
- Example: `DGv7nL5Fy2VFw4p7kL2nM9qR5sT7vX9zW`

**Worker Name:**
- Enter: `pi4b`
- (This helps identify your Pi in MaxedHash dashboard)

**Algorithm:**
- Enter: `sha256d`

### Step 5: Save Configuration

Click the blue button: **💾 SAVE POOL CONFIG**

You should see a green confirmation message:
```
✓ Pool config saved and miner restarted
```

✅ **Your miner is now running!**

---

## Monitor Your Miner

### View Live Dashboard

Open your browser to:

```
http://192.168.1.50:5000
```

You should see:
- ⛏️ **Hash Rate** (should show a number like 3.45 MH/s)
- ✓ **Accepted shares** (increases as miner works)
- ✗ **Rejected shares** (should stay low)
- 💰 **Current coin price**
- 📊 **Market cap**

### Check Logs

To view what the miner is doing:

```bash
sudo journalctl -u tft-miner.service -f
```

You should see mining activity like:
```
[pool] Stratum connected
[CPU0] Submitting work...
[pool] Accepted: 1 share
```

Press `Ctrl+C` to exit logs.

### Monitor Temperature

Pi should stay under 80°C. Check with:

```bash
vcgencmd measure_temp
```

If too hot:
- Improve ventilation
- Add a bigger heatsink
- Reduce CPU clock speed

### Control the Miner

**Stop mining:**
```bash
sudo systemctl stop tft-miner.service
```

**Start mining:**
```bash
sudo systemctl start tft-miner.service
```

**Restart mining:**
```bash
sudo systemctl restart tft-miner.service
```

**Check status:**
```bash
sudo systemctl status tft-miner.service
```

---

## Setup TFT Display

### Prerequisites
- 3.5" TFT display connected to Pi
- Chromium browser installed (usually pre-installed)

### Option A: Manual Launch

SSH into your Pi and run:

```bash
DISPLAY=:0 chromium-browser --kiosk --disable-infobars http://127.0.0.1:5000/display &
```

The display will boot into kiosk mode showing live mining stats.

### Option B: Auto-Launch on Boot

1. Create an autostart directory:

```bash
mkdir -p ~/.config/autostart
```

2. Create the desktop file:

```bash
nano ~/.config/autostart/miner.desktop
```

3. Paste this content:

```ini
[Desktop Entry]
Type=Application
Name=Miner Display
Exec=chromium-browser --kiosk --disable-infobars http://127.0.0.1:5000/display
NoDisplay=false
```

4. Save and exit:
- Press `Ctrl+X`
- Press `Y`
- Press `Enter`

5. Make it executable:

```bash
chmod +x ~/.config/autostart/miner.desktop
```

6. Reboot:

```bash
sudo reboot
```

The display will automatically show mining stats on startup.

### Display Shows

The 3.5" TFT will display:
- 🔹 Coin logo
- Hash rate (live, updates every 5 seconds)
- Accepted/rejected shares
- Current coin price
- 24-hour % change
- Market cap
- Last updated timestamp

---

## Troubleshooting

### Can't Connect via SSH

**Problem:** `ssh: Could not resolve hostname raspberrypi.local`

**Solution:**
1. Check Pi is powered on (green LED blinking)
2. Check Ethernet cable is connected
3. Try using IP address instead:
   ```powershell
   ssh pi@192.168.1.50
   ```
4. If that fails, check your router for the Pi's IP address

### Miner Not Running

**Problem:** Hashrate shows 0 kH/s

**Solution:**
1. Check miner status:
   ```bash
   sudo systemctl status tft-miner.service
   ```
2. Check logs for errors:
   ```bash
   sudo journalctl -u tft-miner.service -n 50
   ```
3. Verify pool settings are correct in Settings page
4. Restart miner:
   ```bash
   sudo systemctl restart tft-miner.service
   ```

### WiFi Not Connecting

**Problem:** WiFi shows disconnected in Settings

**Solution:**
1. Go to Settings → Network tab
2. Re-enter WiFi SSID and password
3. Click "SAVE WiFi CONFIG"
4. Wait 10 seconds for connection

### Temperature Too High

**Problem:** `vcgencmd measure_temp` shows > 80°C

**Solution:**
1. Ensure heatsinks are properly attached
2. Add/improve cooling fan
3. Improve air circulation around Pi
4. Reduce mining intensity (edit miner service)

### Web Interface Not Loading

**Problem:** Browser shows "ERR_CONNECTION_REFUSED"

**Solution:**
1. Check web service is running:
   ```bash
   sudo systemctl status tft-miner-web.service
   ```
2. Restart it:
   ```bash
   sudo systemctl restart tft-miner-web.service
   ```
3. Check logs:
   ```bash
   sudo journalctl -u tft-miner-web.service -n 50
   ```

### Change Pool Settings Later

1. Open browser to: `http://YOUR_PI_IP:5000/settings`
2. Go to **Pool Config** tab
3. Update any field
4. Click **SAVE POOL CONFIG**
5. Miner will restart with new settings

---

## Performance Expectations

### Hash Rate
- **Pi 4B 2GB:** 3-5 MH/s on SHA256d
- **Pi 4B 4GB:** 3-5 MH/s on SHA256d

(Hash rate depends on CPU load and cooling)

### Earnings (Example)
- Pool: MaxedHash
- Coin: DigiByte
- Hash Rate: 4 MH/s
- **Expected:** $0.05 - $0.15 per day (varies with difficulty)

### Power Consumption
- Idle: ~2-3W
- Mining: ~5-7W
- Max temp target: < 80°C

---

## Common Commands

### System
```bash
# Reboot Pi
sudo reboot

# Check IP address
hostname -I

# Check temperature
vcgencmd measure_temp

# View current config
cat ~/.config/tft-miner/miner.json
```

### Miner Control
```bash
# Start miner
sudo systemctl start tft-miner.service

# Stop miner
sudo systemctl stop tft-miner.service

# Restart miner
sudo systemctl restart tft-miner.service

# Check status
sudo systemctl status tft-miner.service
```

### View Logs
```bash
# Miner logs (real-time)
sudo journalctl -u tft-miner.service -f

# Web interface logs (real-time)
sudo journalctl -u tft-miner-web.service -f

# Last 50 lines of miner logs
sudo journalctl -u tft-miner.service -n 50
```

### Network
```bash
# Configure WiFi via web
# Go to: http://YOUR_PI_IP:5000/settings → Network tab

# Check network status
ip addr show eth0
ip addr show wlan0
```

---

## Support & Resources

- **Repository:** https://github.com/ryegagnon/tft-miner
- **Raspberry Pi Docs:** https://www.raspberrypi.com/documentation/
- **MaxedHash Pool:** https://maxedhash.com
- **DigiByte Wallet:** https://digibyte.org/wallets

---

## Quick Reference: First-Time Setup

1. Flash Raspberry Pi OS Lite to microSD
2. Insert microSD into Pi
3. Connect Ethernet + Power
4. Wait 1-2 minutes
5. SSH in: `ssh pi@raspberrypi.local`
6. Run: `bash install.sh`
7. Select WiFi network (or skip)
8. Wait for installation to complete
9. Run: `hostname -I` (note the IP)
10. Open browser: `http://YOUR_PI_IP:5000/settings`
11. Enter pool details
12. Click SAVE
13. Monitor at: `http://YOUR_PI_IP:5000`
14. Optional: Launch TFT display

**Total time:** ~30-45 minutes (including cpuminer build time)

---

**Happy mining! 🎉**
