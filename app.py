#!/usr/bin/env python3
import os
import json
import subprocess
from flask import Flask, render_template, request, jsonify
from pathlib import Path

app = Flask(__name__)

CONFIG_DIR = Path("/home/pi/.config/tft-miner")
CONFIG_FILE = CONFIG_DIR / "miner.json"
MINER_SERVICE = "tft-miner"

DEFAULT_CONFIG = {
    "pool_address": "sha256d.maxedhash.com",
    "pool_port": "3032",
    "wallet": "",
    "worker_name": "pi4b",
    "algorithm": "sha256d"
}

def ensure_config_dir():
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)

def load_config():
    ensure_config_dir()
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    return DEFAULT_CONFIG.copy()

def save_config(config):
    ensure_config_dir()
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=2)

def update_miner_service(config):
    """Update the miner systemd service with new pool config"""
    service_content = f"""[Unit]
Description=TFT Miner - SHA256 CPU Mining
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/cpuminer-opt
ExecStart=/home/pi/cpuminer-opt/cpuminer-sse2 -a {config['algorithm']} -o stratum+tcp://{config['pool_address']}:{config['pool_port']} -u {config['wallet']}.{config['worker_name']} -p x
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
"""
    
    tmp_file = "/tmp/tft-miner.service"
    with open(tmp_file, "w") as f:
        f.write(service_content)
    
    try:
        subprocess.run(["sudo", "cp", tmp_file, "/etc/systemd/system/tft-miner.service"], check=True)
        subprocess.run(["sudo", "systemctl", "daemon-reload"], check=True)
        subprocess.run(["sudo", "systemctl", "restart", MINER_SERVICE], check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error updating service: {e}")
        return False

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/settings")
def settings():
    return render_template("settings.html")

@app.route("/api/config", methods=["GET"])
def get_config():
    return jsonify(load_config())

@app.route("/api/config", methods=["POST"])
def update_config():
    data = request.json
    save_config(data)
    
    if update_miner_service(data):
        return jsonify({"status": "success", "message": "Config saved and miner restarted"})
    else:
        return jsonify({"status": "error", "message": "Config saved but failed to restart miner"}), 500

@app.route("/api/miner/status", methods=["GET"])
def miner_status():
    """Return current miner stats - placeholder for future integration"""
    return jsonify({
        "hashrate": "0.00",
        "unit": "kH/s",
        "accepted": 0,
        "rejected": 0
    })

@app.route("/api/miner/start", methods=["POST"])
def start_miner():
    try:
        subprocess.run(["sudo", "systemctl", "start", MINER_SERVICE], check=True)
        return jsonify({"status": "success", "message": "Miner started"})
    except subprocess.CalledProcessError as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/api/miner/stop", methods=["POST"])
def stop_miner():
    try:
        subprocess.run(["sudo", "systemctl", "stop", MINER_SERVICE], check=True)
        return jsonify({"status": "success", "message": "Miner stopped"})
    except subprocess.CalledProcessError as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
