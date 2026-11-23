{ config, pkgs, stable, machine, inputs, ... }:
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
    zotero
    obsidian
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
  ]);
}
