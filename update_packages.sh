#!/bin/bash
# Script to update all system packages, including GPU drivers and firmware,
# then cleanup after.

# This comes from post_install.sh
CALLED_FROM_POST_INSTALL_YN="$1";

echo "updating apt package cache... ";
  sudo apt update;
  echo "";
  
echo "checking for broken installs... ";
  sudo dpkg --configure -a;
  sudo apt install -f;
  echo "";
  
echo "updating to the current point release (dist-upgrade)... ";
  sudo apt dist-upgrade -y;
  echo "";
  
if [ "${CALLED_FROM_POST_INSTALL_YN:-}" != "y" ]; then
  NVIDIA_YN="$(lspci | grep -i "vga\|nvidia" | grep -iq "nvidia"; echo $?)";
  
  if [ "${NVIDIA_YN:-}" = "0" ]; then
    echo "checking for nvidia-driver-assistant... ";
      ASSISTANT_INSTALLED_YN="$(which nvidia-driver-assistant)";
      
      if [ -z "${ASSISTANT_INSTALLED_YN:-}" ]; then
        sudo apt install nvidia-driver-assistant;
      fi;
      
    echo "checking for gpu compatibility... ";
      GPU_COMPATIBLE_YN="$(nvidia-driver-assistant | grep -q "cuda-drivers"; echo "$?")";
      
    echo "updating/repairing nvidia drivers and cuda... ";
      if [ "${GPU_COMPATIBLE_YN:-}" = "0" ]; then
        sudo apt install cuda-drivers cuda-12-8 -y;
      else
        sudo apt install cuda -y;
      fi;
      
      echo "";
  fi;
fi;

echo "cleaning up downloaded apt packages... ";
  sudo apt clean;
  echo "";
  
echo "removing old packages... ";
  sudo apt autoremove -y;
  echo "";
  
echo "checking if running on a physical system... ";
  GET_SYSTEM_MANUFACTURER="$(sudo dmidecode -s system-manufacturer)";
  if [ "$(echo "${GET_SYSTEM_MANUFACTURER:-}" | grep -i "vmware"; echo $?)" != "0" ]; then
    echo "updating firmware database... ";
      sudo fwupdmgr get-updates -y;
      echo "";
      
    echo "updating firmware... ";
      sudo fwupdmgr update --no-reboot-check -y;
      echo "";
  fi;
  
echo "script done";
exit 0
# EOS
