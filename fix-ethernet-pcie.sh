#!/bin/bash
# Désactive la carte Ethernet défectueuse qui cause des erreurs PCIe
# Ces erreurs peuvent perturber le WiFi et causer des déconnexions

echo "=== Désactivation de la carte Ethernet défectueuse ==="
echo ""
echo "Problème détecté:"
echo "  Carte:  Ethernet (alx)"
echo "  Erreurs: BadTLP, BadDLLP, Timeouts PCIe"
echo "  Impact: Peut perturber le WiFi sur le même bus PCI"
echo ""
echo "Solution: Blacklister le driver 'alx' pour désactiver la carte"
echo ""
read -p "Continuer? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "Annulé."
    exit 1
fi

# Blackliste le driver alx
echo "Blacklistage du driver alx..."
sudo tee /etc/modprobe.d/blacklist-alx.conf > /dev/null <<EOF
# Blacklist du driver alx (Ethernet)
# Cause des erreurs PCIe qui perturbent le WiFi
blacklist alx
EOF

# Décharge le module immédiatement
echo "Déchargement du module alx..."
sudo modprobe -r alx 2>/dev/null || echo "Module déjà déchargé"

# Régénère l'initramfs pour que le blacklist soit permanent
echo "Mise à jour de l'initramfs..."
sudo mkinitcpio -P

echo ""
echo "✓ Carte Ethernet désactivée!"
echo ""
echo "La carte Ethernet ne sera plus chargée au démarrage."
echo "Cela devrait résoudre:"
echo "  - Les erreurs PCIe BadTLP/BadDLLP"
echo "  - Les perturbations potentielles du WiFi"
echo "  - Les déconnexions de jeux en ligne"
echo ""
echo "Note: Vous utilisez déjà le WiFi, donc pas d'impact sur votre connexion"
echo ""
echo "Pour réactiver la carte Ethernet:"
echo "  sudo rm /etc/modprobe.d/blacklist-alx.conf"
echo "  sudo mkinitcpio -P"
echo "  reboot"
