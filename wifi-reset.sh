#!/bin/bash
# Script de nettoyage - Restaure la configuration WiFi par défaut

echo "=== Nettoyage de la configuration WiFi ==="

# Supprime les configurations personnalisées
if [ -f /etc/modprobe.d/iwlwifi.conf ]; then
    echo "Suppression de /etc/modprobe.d/iwlwifi.conf..."
    sudo rm /etc/modprobe.d/iwlwifi.conf
fi

if [ -f /etc/NetworkManager/conf.d/wifi-reconnect.conf ]; then
    echo "Suppression de /etc/NetworkManager/conf.d/wifi-reconnect.conf..."
    sudo rm /etc/NetworkManager/conf.d/wifi-reconnect.conf
fi

if [ -f /etc/NetworkManager/conf.d/wifi-roaming.conf ]; then
    echo "Suppression de /etc/NetworkManager/conf.d/wifi-roaming.conf..."
    sudo rm /etc/NetworkManager/conf.d/wifi-roaming.conf
fi

if [ -f /etc/NetworkManager/conf.d/wifi-stable.conf ]; then
    echo "Suppression de /etc/NetworkManager/conf.d/wifi-stable.conf..."
    sudo rm /etc/NetworkManager/conf.d/wifi-stable.conf
fi

if [ -f /etc/NetworkManager/conf.d/no-roaming.conf ]; then
    echo "Suppression de /etc/NetworkManager/conf.d/no-roaming.conf..."
    sudo rm /etc/NetworkManager/conf.d/no-roaming.conf
fi

# Réactive le roaming en retirant le BSSID fixé
CONNECTION_NAME=$(nmcli -t -f NAME connection show --active | grep -v "lo\|docker\|br-")
if [ -n "$CONNECTION_NAME" ]; then
    echo "Réactivation du roaming pour: $CONNECTION_NAME"
    nmcli connection modify "$CONNECTION_NAME" 802-11-wireless.bssid ""
fi

# Recharge les modules WiFi avec les paramètres par défaut
echo "Rechargement des modules WiFi..."
sudo modprobe -r iwlmvm
sudo modprobe -r iwlwifi
sudo modprobe iwlwifi
sudo modprobe iwlmvm

# Redémarre NetworkManager
echo "Redémarrage de NetworkManager..."
sudo systemctl restart NetworkManager

echo ""
echo "✓ Configuration WiFi restaurée aux paramètres par défaut"
echo "  Reconnectez-vous à votre réseau WiFi si nécessaire"
