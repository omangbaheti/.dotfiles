{ config, pkgs, stable, machine, inputs, ... }:
let
  # Only fern and nyx import this file, so these pins reach just those two.
  # The global lock is multiverse.lock, installed everywhere by the module.
  guiPins = inputs.multiverse.lib.readLock {
    inherit (machine) system;
    file = ../multiverse-gui.lock;
    config.allowUnfree = true;
  };
in
{
  # 26.05's rider build is flagged insecure until the branch catches up.
  # The real fix is `mvs lock add jetbrains.rider` — see "Updating Packages".
  nixpkgs.config.permittedInsecurePackages = [ "rider-2026.2.4" ];

  home.packages = (with pkgs; [
    #Dev-Tools
    jetbrains.rider
    unityhub

    blender
    rclone

    proton-vpn
    localsend

    #Tools
    libreoffice
    gimp
    aseprite
    # zotero
    # obsidian comes from multiverse.lock (installed on every host)
    stable.android-studio
    audacity
    kdePackages.okular
    kdePackages.kdeconnect-kde
    
    #whatspp
    karere
    
    #Media
    vlc
    obs-studio
    spotify
    parsec-bin

    #Communication
    discord
    vesktop #better discord
    telegram-desktop
    slack
    zoom-us
    
    #games
    steam
    # prismlauncher
    
    # Virtual Machines and wine
    libvirt
    wine
    virt-manager
    qemu
    uefi-run
    lxc
    swtpm
    
    #niri
    vicinae
    noctalia
    xwayland-satellite
    wlr-which-key
  ]) ++ builtins.attrValues guiPins;
}
