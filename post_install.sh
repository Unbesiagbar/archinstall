#!/bin/bash

print_header() {
  echo
  echo "============================================================"
  echo "$1"
  echo "============================================================"
  echo
}

# Function to install Zsh and Oh My Zsh
install_zsh() {
  # Install Zsh
  pacman -S zsh

  # Set Zsh as the default shell for the user
  chsh -s /bin/zsh "$LOGNAME"

  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo "Zsh and Oh My Zsh installation completed successfully."
}

# Function to install graphics drivers
install_graphics_drivers() {
  # Install NVIDIA drivers and Optimus support
  pacman -S nvidia nvidia-utils lib32-nvidia-utils

  # Install Intel drivers for integrated graphics
  pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel

  # Install Wayland support
  pacman -S xorg-server-xwayland

  echo "Graphics drivers installation completed successfully."
}

# Function to install GNOME
install_gnome() {
  # Install minimal GNOME packages
  pacman -S gnome-shell gnome-control-center gnome-terminal nautilus

  # Install additional GNOME extensions for customization
  pacman -S gnome-shell-extensions gnome-tweaks

  echo "GNOME installation completed successfully."
}

# Function to install Sway
install_sway() {
  # Install and configure Sway
  pacman -S sway
  systemctl enable sway.service

  # Enable Sway autostart
  mkdir -p "/home/$LOGNAME/.config/sway"
  echo "exec sway" > "/home/$LOGNAME/.config/sway/config"

  echo "Sway installation completed successfully."
}

# Function to install additional software
install_additional_software() {
  # Install additional software for a modern UI look (modify as needed)
  pacman -S alacritty waybar rofi materia-gtk-theme papirus-icon-theme

  echo "Additional software installation completed successfully."
}

# Function to configure Flatpak installation and backup location
configure_flatpak_location() {
  # Determine the disk name where the system is installed
  disk=$(lsblk -no pkname $(df --output=source / | tail -n 1))

  # Prompt for the desired size of the Flatpak partition
  read -p "Enter the size of the Flatpak partition (e.g., 10G for 10GB): " size

  # Create a separate partition for Flatpak packages using Btrfs file system
  parted "/dev/$disk" mkpart primary btrfs 1MiB "$size"
  mkfs.btrfs "/dev/${disk}2"

  # Mount the partition to the desired location for installing Flatpak packages
  mount "/dev/${disk}2" /mnt/flatpak

  # Configure Flatpak to use the specified location in the .zshrc file
  echo "export FLATPAK_USER_DIR=/mnt/flatpak" >> "/home/$LOGNAME/.zshrc"
  echo "export XDG_DATA_HOME=\$HOME/.local/share:/mnt/flatpak" >> "/home/$LOGNAME/.zshrc"

  echo "Flatpak installation and backup location configured successfully."
}

print_header "Post-Installation Configuration"

print_header "Installing Zsh and Oh My Zsh"
install_zsh

print_header "Installing graphics drivers"
install_graphics_drivers

print_header "Installing GNOME"
install_gnome

print_header "Installing Sway"
install_sway

print_header "Installing additional software"
install_additional_software

print_header "Configuring Flatpak installation and backup location"
configure_flatpak_location

# Reboot the system
print_header "Installation completed. Rebooting..."
reboot
