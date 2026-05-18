#!/usr/bin/env bash
# ==============================================================================
# AIC Wi-Fi driver Master Setup Script
# Automatically compiles, installs, loads, and configures the AIC8800DC USB Wi-Fi card.
# ==============================================================================

# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[31m[ERROR] Please run this script with sudo or as root!\e[0m"
    exit 1
fi

set -e # Exit immediately on error

echo "##################################################"
echo "AIC Wi-Fi Driver Auto-Compiler & Installer"
echo "##################################################"

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 1. Compile the driver
echo -e "\n\e[33m[1/6] Compiling wireless driver for kernel $(uname -r)...\e[0m"
make -C "${SCRIPT_DIR}/drivers/aic8800" clean
make -C "${SCRIPT_DIR}/drivers/aic8800"

# 2. Install kernel modules
echo -e "\n\e[33m[2/6] Installing kernel modules into the system...\e[0m"
make -C "${SCRIPT_DIR}/drivers/aic8800" install

# 3. Deploy firmware files
echo -e "\n\e[33m[3/6] Deploying firmware files to /lib/firmware/...\e[0m"
mkdir -p /lib/firmware/
cp -rf "${SCRIPT_DIR}/fw/aic8800DC" /lib/firmware/

# 4. Deploy udev rules
echo -e "\n\e[33m[4/6] Deploying udev mode-switching rules...\e[0m"
cp -f "${SCRIPT_DIR}/tools/aic.rules" /lib/udev/rules.d/
cp -f "${SCRIPT_DIR}/tools/aic.rules" /etc/udev/rules.d/

# 5. Reload udev and trigger mode switch
echo -e "\n\e[33m[5/6] Reloading udev and triggering USB mode switch...\e[0m"
udevadm control --reload-rules
udevadm trigger

# Eject virtual CD-ROM to force Wi-Fi mode
if [ -L /dev/aicudisk ]; then
    echo "[INFO] Ejecting old storage interface /dev/aicudisk..."
    eject /dev/aicudisk || true
fi
if [ -L /dev/aicudiskv2 ]; then
    echo "[INFO] Ejecting new storage interface /dev/aicudiskv2..."
    eject /dev/aicudiskv2 || true
fi

# 6. Reload kernel modules
echo -e "\n\e[33m[6/6] Reloading kernel driver modules...\e[0m"
modprobe -r aic8800_fdrv || true
modprobe -r aic_load_fw || true
modprobe aic_load_fw
modprobe aic8800_fdrv

echo -e "\n##################################################"
echo -e "\e[32mThe Setup Script is completed successfully!\e[0m"
echo "##################################################"

# Find the new network interface name
INTERFACE=$(ip link show | grep -E 'wl[x0-9a-fA-F]+' | awk -F': ' '{print $2}' | tail -n 1)

if [ -n "$INTERFACE" ]; then
    echo -e "\e[36m[SUCCESS] Found active wireless interface: $INTERFACE\e[0m"
    echo -e "\e[36m[SUCCESS] Bringing interface $INTERFACE up...\e[0m"
    ip link set "$INTERFACE" up || true
    
    echo -e "\n\e[35m[TIPS] How to connect to your Wi-Fi:\e[0m"
    echo -e "  * Interactive UI (Terminal):  \e[33msudo nmtui\e[0m"
    echo -e "  * CLI Connect Command:       \e[33msudo nmcli dev wifi connect \"SSID\" password \"PASSWORD\"\e[0m"
    echo -e "  * Desktop UI:                Click the network icon in the top right corner."
else
    echo -e "\e[33m[NOTICE] No active wireless interface was detected automatically yet.\e[0m"
    echo -e "\e[33m         Please replug your USB Wi-Fi adapter to trigger automatic mode-switching.\e[0m"
fi
