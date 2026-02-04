#!/bin/bash
# Script pour réactiver la carte Ethernet

echo "=== Réactivation de la carte Ethernet ==="
echo ""

# Supprime le blacklist
if [ -f /etc/modprobe.d/blacklist-alx.conf ]; then
    echo "Suppression du blacklist alx..."
    sudo rm /etc/modprobe.d/blacklist-alx.conf
else
    echo "Aucun blacklist trouvé (déjà supprimé)"
fi

# Recharge le module
echo "Rechargement du module alx..."
sudo modprobe alx

# Régénère l'initramfs
echo "Mise à jour de l'initramfs..."
sudo mkinitcpio -P

echo ""
echo "✓ Carte Ethernet réactivée!"
echo ""
echo "La carte Ethernet Killer E2500 est de nouveau active."
echo "Vérifiez avec: lspci -k | grep -A3 Ethernet"
echo ""
echo "Note: Si les erreurs PCIe reviennent, relancez ./fix-ethernet-pcie.sh"
