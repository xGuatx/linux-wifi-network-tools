  sudo cp /tmp/iwlwifi.conf /etc/modprobe.d/iwlwifi.conf && \
  sudo mkdir -p /etc/NetworkManager/conf.d && \
  sudo cp /tmp/wifi-reconnect.conf /etc/NetworkManager/conf.d/wifi-reconnect.conf && \
  sudo rmmod iwlmvm && sudo rmmod iwlwifi && sudo modprobe iwlwifi && \
  sudo systemctl restart NetworkManager
