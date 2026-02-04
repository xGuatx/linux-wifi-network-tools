# Linux WiFi & Network Tools

Collection of shell scripts for WiFi troubleshooting, network diagnostics, and connectivity management on Linux.

## Description

Utilities for managing wireless connections, diagnosing network issues, scanning WiFi networks, and automating network configuration.

## Prerequisites

- Linux system with WiFi capability
- sudo access
- Required packages: `wireless-tools`, `net-tools`, `iw`

## Installation

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt-get install wireless-tools iw net-tools network-manager

# Make scripts executable
chmod +x *.sh
```

## Scripts

### wifi_status.sh
Display current WiFi connection status and diagnostics.

```bash
./wifi_status.sh
```

Output:
- Interface name
- Connection status
- SSID
- Signal strength
- IP address
- Gateway
- DNS servers

### wifi_scan.sh
Scan for available WiFi networks.

```bash
./wifi_scan.sh

# Scan with detailed info
./wifi_scan.sh --detailed

# Scan specific interface
./wifi_scan.sh wlan1
```

### wifi_connect.sh
Connect to WiFi network.

```bash
# Interactive mode
./wifi_connect.sh

# Direct connection
./wifi_connect.sh SSID_NAME PASSWORD

# Connect with hidden SSID
./wifi_connect.sh --hidden SSID_NAME PASSWORD
```

### wifi_disconnect.sh
Disconnect from current WiFi network.

```bash
./wifi_disconnect.sh

# Disable WiFi
./wifi_disconnect.sh --disable
```

### fix_wifi.sh
Automatic WiFi troubleshooting and fixes.

```bash
./fix_wifi.sh

# Force reset
./fix_wifi.sh --reset
```

### network_test.sh
Test network connectivity and speed.

```bash
./network_test.sh

# Quick test
./network_test.sh --quick

# Full diagnostics
./network_test.sh --full
```

## Features

### WiFi Management

#### List Available Networks
```bash
# Using iwlist
sudo iwlist wlan0 scan | grep -E "ESSID|Quality"

# Using nmcli
nmcli device wifi list
```

#### Check Signal Strength
```bash
# Current connection
iwconfig wlan0 | grep -i "signal level"

# Continuous monitoring
watch -n 1 'iwconfig wlan0 | grep -i "signal level"'
```

#### Change WiFi Channel
```bash
# Set specific channel
sudo iwconfig wlan0 channel 6
```

### Network Diagnostics

#### Ping Test
```bash
# Test connectivity
ping -c 4 8.8.8.8

# Test DNS resolution
ping -c 4 google.com
```

#### Traceroute
```bash
# Trace path to host
traceroute google.com

# Use ICMP instead of UDP
sudo traceroute -I google.com
```

#### Speed Test
```bash
# Using speedtest-cli
pip3 install speedtest-cli
speedtest-cli

# Simple bandwidth test
iperf3 -c speedtest.example.com
```

### Network Configuration

#### View IP Configuration
```bash
# Show all interfaces
ip addr show

# Show specific interface
ip addr show wlan0
```

#### Renew DHCP Lease
```bash
sudo dhclient -r wlan0  # Release
sudo dhclient wlan0      # Renew
```

#### Set Static IP
```bash
sudo ip addr add 192.168.1.100/24 dev wlan0
sudo ip route add default via 192.168.1.1
```

## Usage Examples

### Basic Connection

```bash
# Scan networks
./wifi_scan.sh

# Connect to network
./wifi_connect.sh "My WiFi" "password123"

# Verify connection
./wifi_status.sh
```

### Troubleshooting

```bash
# WiFi not working
./fix_wifi.sh

# Manual reset
sudo systemctl restart NetworkManager
```

### Monitoring

```bash
# Watch signal strength
watch -n 1 './wifi_status.sh | grep Signal'

# Log connection quality
while true; do
    ./wifi_status.sh >> wifi_quality.log
    sleep 60
done
```

## Configuration Files

### NetworkManager

```bash
# Connection configs
/etc/NetworkManager/system-connections/

# Main config
/etc/NetworkManager/NetworkManager.conf
```

### WPA Supplicant

```bash
# WiFi credentials
/etc/wpa_supplicant/wpa_supplicant.conf

# Example entry:
network={
    ssid="MyNetwork"
    psk="password123"
}
```

## Advanced Features

### Auto-Connect Script

```bash
#!/bin/bash
# auto_wifi.sh - Automatically connect to known networks

KNOWN_NETWORKS=("HomeWiFi:password1" "WorkWiFi:password2")

for network in "${KNOWN_NETWORKS[@]}"; do
    SSID="${network%%:*}"
    PASS="${network##*:}"

    if ./wifi_scan.sh | grep -q "$SSID"; then
        ./wifi_connect.sh "$SSID" "$PASS"
        break
    fi
done
```

### Signal Strength Monitor

```bash
#!/bin/bash
# Monitor and alert on weak signal

THRESHOLD=40  # dBm

while true; do
    SIGNAL=$(iwconfig wlan0 | grep -oP 'Signal level=\K-\d+')
    if [ ${SIGNAL#-} -gt $THRESHOLD ]; then
        notify-send "Weak WiFi Signal" "Signal: $SIGNAL dBm"
    fi
    sleep 10
done
```

### MAC Address Randomization

```bash
# Generate random MAC
sudo macchanger -r wlan0

# Use specific MAC
sudo macchanger -m 00:11:22:33:44:55 wlan0
```

## Troubleshooting

### WiFi Interface Not Found

```bash
# List all network interfaces
ip link show

# Check if WiFi drivers loaded
lsmod | grep wireless
lsmod | grep wifi

# Reload WiFi module
sudo modprobe -r iwlwifi
sudo modprobe iwlwifi
```

### Cannot Connect to Network

```bash
# Check if NetworkManager is running
sudo systemctl status NetworkManager

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Try manual connection with wpa_supplicant
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

### Weak Signal

```bash
# Check for interference
./wifi_scan.sh --channel-usage

# Try different channel (router config)
# Avoid channels 1, 6, 11 overlap

# Check antenna connection (laptop/desktop)
```

### Slow Speed

```bash
# Test actual speed
./network_test.sh --speed

# Check link quality
iwconfig wlan0 | grep -i "link quality"

# Disable power management
sudo iwconfig wlan0 power off
```

## Best Practices

- Keep WiFi drivers updated
- Use WPA3 when available
- Disable WiFi when not needed (battery)
- Use ethernet for bandwidth-intensive tasks
- Monitor for rogue access points
- Change default router passwords

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| WiFi disconnects randomly | Disable power management |
| Slow speeds | Change channel, check interference |
| Can't find network | Check if hidden, scan again |
| Authentication failed | Verify password, check security type |
| No IP address | Restart DHCP client |

## Automation

### Systemd Service (Auto WiFi)

```ini
# /etc/systemd/system/auto-wifi.service
[Unit]
Description=Auto WiFi Connection
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/auto_wifi.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo systemctl enable auto-wifi.service
sudo systemctl start auto-wifi.service
```

## Security

### Secure WiFi Best Practices

```bash
# Never store passwords in plain text
# Use NetworkManager keyring

# Check for WPA3 support
iw list | grep WPA3

# Disable WPS (router setting)
```

### Monitor Network

```bash
# Watch for new devices
arp-scan --localnet

# Monitor connections
sudo netstat -tuln

# Check DNS queries
sudo tcpdump -i wlan0 port 53
```

## Resources

- [iwconfig Manual](https://linux.die.net/man/8/iwconfig)
- [NetworkManager Guide](https://networkmanager.dev/)
- [WPA Supplicant](https://w1.fi/wpa_supplicant/)
- [Wireless Tools](https://hewlettpackard.github.io/wireless-tools/Tools.html)

## License

Personal project - Private use

---

**Note**: Some operations require root/sudo access. Handle WiFi passwords securely.
