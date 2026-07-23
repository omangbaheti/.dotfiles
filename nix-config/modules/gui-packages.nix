{ config, pkgs, stable, machine, inputs, ... }:
{
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
    zotero
    obsidian
    stable.android-studio
    audacity
    kdePackages.okular
    
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
    noctalia-shell
    xwayland-satellite
    wlr-which-key
  ]);
}
