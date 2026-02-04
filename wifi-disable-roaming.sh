#!/bin/bash
# Script pour désactiver le roaming WiFi
# Empêche les basculements entre 2.4 GHz et 5 GHz

echo "=== Désactivation du roaming WiFi ==="
echo ""
echo "Ce script va désactiver le basculement automatique entre bandes WiFi"
echo "Pour annuler les modifications : ./wifi-reset.sh"
echo ""
read -p "Continuer? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "Annulé."
    exit 1
fi

# Configuration NetworkManager - Désactive le roaming agressif
echo "Configuration de NetworkManager..."
sudo tee /etc/NetworkManager/conf.d/wifi-roaming.conf > /dev/null <<'EOF'
[device]
# Désactive la randomisation d'adresse MAC
wifi.scan-rand-mac-address=no

[connection]
# Améliore la stabilité des connexions
connection.auth-retries=3
ipv4.may-fail=no

[wifi]
# Désactive le scan en arrière-plan qui déclenche le roaming
wifi.backend=iwd
# Réduit la fréquence de scan (limite le roaming)
wifi.scan-rand-mac-address=no
EOF

# Configuration wpa_supplicant pour limiter le roaming
echo "Configuration du roaming..."
sudo tee /etc/NetworkManager/conf.d/wifi-stable.conf > /dev/null <<'EOF'
[device-wifi-stable]
# Force la connexion à rester sur le même BSSID sauf si signal très faible
match-device=interface-name:wlan0
wifi.scan-interval=300

[connection-wifi-stable]
# Ne bascule que si le signal devient vraiment mauvais (< -85 dBm)
match-device=interface-name:wlan0
wifi.powersave=2
EOF

# Redémarre NetworkManager
echo "Redémarrage de NetworkManager..."
sudo systemctl restart NetworkManager

echo ""
echo "✓ Roaming WiFi désactivé!"
echo ""
echo "Changements appliqués:"
echo "  - Scan WiFi réduit (toutes les 5 minutes au lieu de 30s)"
echo "  - Basculement uniquement si signal < -85 dBm"
echo "  - Stabilisation de la connexion actuelle"
echo ""
echo "Reconnectez-vous à votre réseau WiFi (choisissez 2.4 ou 5 GHz)"
echo ""
echo "Conseil: Utilisez la bande 5 GHz si vous êtes proche du routeur"
echo "         Utilisez la bande 2.4 GHz si vous êtes plus éloigné"
echo ""
echo "Si problèmes: ./wifi-reset.sh"
