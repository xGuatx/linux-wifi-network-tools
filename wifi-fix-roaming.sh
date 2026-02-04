#!/bin/bash
# Script pour fixer la connexion WiFi sur une bande spécifique
# Empêche le roaming entre 2.4 GHz et 5 GHz

echo "=== Fixation de la bande WiFi ==="
echo ""
echo "Analyse des réseaux disponibles..."
echo ""

# Affiche les réseaux Livebox disponibles
nmcli -f SSID,BSSID,FREQ,SIGNAL,RATE,BARS dev wifi list | grep -E "SSID|Livebox-C3B1"

echo ""
echo "Recommandation basée sur l'analyse actuelle:"
echo "  2.4 GHz () - Signal: 59% - Débit: 130 Mbit/s  ← RECOMMANDÉ"
echo "  5 GHz   () - Signal: 49% - Débit: 405 Mbit/s"
echo ""
echo "Pour les jeux en ligne, un signal stable (2.4 GHz) est préférable"
echo "à un débit élevé mais instable (5 GHz)"
echo ""

# Demande à l'utilisateur
echo "Quelle bande voulez-vous utiliser ?"
echo "1) 2.4 GHz () - Recommandé pour la stabilité"
echo "2) 5 GHz () - Plus rapide mais signal plus faible"
echo ""
read -p "Votre choix (1 ou 2): " choice

case $choice in
    1)
        BSSID=""
        BAND="2.4 GHz"
        ;;
    2)
        BSSID=""
        BAND="5 GHz"
        ;;
    *)
        echo "Choix invalide. Annulé."
        exit 1
        ;;
esac

echo ""
echo "Configuration pour forcer la connexion sur $BAND ($BSSID)..."
echo ""

# Récupère le nom de la connexion actuelle
CONNECTION_NAME=$(nmcli -t -f NAME connection show --active | grep -v "lo\|docker\|br-")

if [ -z "$CONNECTION_NAME" ]; then
    echo "Erreur: Impossible de trouver la connexion active"
    exit 1
fi

echo "Connexion trouvée: $CONNECTION_NAME"

# Configure la connexion pour utiliser uniquement ce BSSID
echo "Fixation du BSSID à $BSSID..."
nmcli connection modify "$CONNECTION_NAME" 802-11-wireless.bssid "$BSSID"

# Désactive le roaming dans NetworkManager
echo "Désactivation du roaming automatique..."
sudo tee /etc/NetworkManager/conf.d/no-roaming.conf > /dev/null <<EOF
[device-no-roaming]
match-device=interface-name:wlan0
wifi.scan-interval=0

[connection]
connection.auth-retries=3
ipv4.may-fail=no
EOF

# Optimise le driver WiFi pour la stabilité
echo "Optimisation du driver WiFi..."
sudo tee /etc/modprobe.d/iwlwifi.conf > /dev/null <<EOF
# Désactive l'économie d'énergie pour éviter les pertes de signal
options iwlwifi power_save=0

# Active le redémarrage automatique du firmware
options iwlwifi fw_restart=1
EOF

# Recharge la connexion
echo "Reconnexion au réseau..."
nmcli connection down "$CONNECTION_NAME"
sleep 2
nmcli connection up "$CONNECTION_NAME"

echo ""
echo "✓ Configuration terminée!"
echo ""
echo "Votre connexion est maintenant fixée sur:"
echo "  Bande: $BAND"
echo "  BSSID: $BSSID"
echo ""
echo "Le système ne basculera PLUS automatiquement entre les bandes."
echo ""
echo "Pour vérifier la connexion:"
echo "  nmcli device show wlan0"
echo ""
echo "Pour revenir en arrière (réactiver le roaming):"
echo "  ./wifi-reset.sh"
echo ""
echo "Testez maintenant votre jeu en ligne!"
