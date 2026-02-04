#!/bin/bash
# Script d'optimisation WiFi pour Intel AX200
# Version conservatrice pour éviter les latences

echo "=== Optimisation WiFi Intel AX200 ==="
echo ""
echo "Ce script va appliquer des optimisations CONSERVATRICES pour réduire les pertes de signal"
echo "Si vous rencontrez des problèmes, exécutez ./wifi-reset.sh"
echo ""
read -p "Continuer? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "Annulé."
    exit 1
fi

# Configuration modprobe (paramètres conservateurs)
echo "Configuration du module iwlwifi..."
sudo tee /etc/modprobe.d/iwlwifi.conf > /dev/null <<'EOF'
# Configuration conservatrice pour Intel AX200

# Désactive uniquement l'économie d'énergie agressive
options iwlwifi power_save=0

# Active le redémarrage automatique du firmware en cas d'erreur
options iwlwifi fw_restart=1
EOF

# Configuration NetworkManager pour gérer le roaming
echo "Configuration de NetworkManager..."
sudo tee /etc/NetworkManager/conf.d/wifi-reconnect.conf > /dev/null <<'EOF'
[device]
# Désactive la randomisation d'adresse MAC qui peut causer des problèmes
wifi.scan-rand-mac-address=no

[connection]
# Améliore la gestion des reconnexions
connection.auth-retries=3
ipv4.may-fail=no

[connectivity]
# Vérifie la connectivité toutes les 30 secondes
interval=30
EOF

# Recharge les modules
echo ""
echo "Rechargement des modules WiFi..."
sudo modprobe -r iwlmvm
sudo modprobe -r iwlwifi
sudo modprobe iwlwifi
sudo modprobe iwlmvm

# Redémarre NetworkManager
echo "Redémarrage de NetworkManager..."
sudo systemctl restart NetworkManager

echo ""
echo "✓ Optimisations appliquées avec succès!"
echo ""
echo "Changements appliqués:"
echo "  - Désactivation de l'économie d'énergie WiFi"
echo "  - Redémarrage auto du firmware en cas d'erreur"
echo "  - Amélioration de la gestion des reconnexions"
echo ""
echo "Testez votre connexion. Si vous avez des problèmes de latence:"
echo "  ./wifi-reset.sh"
