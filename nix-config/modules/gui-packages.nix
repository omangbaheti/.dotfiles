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

    #Media
    vlc
    obs-studio
    spotify
    parsec-bin

    #Communication
    discord
    telegram-desktop
    slack
    zoom-us
    steam

    # Virtual Machines and wine
    libvirt
    wine
    virt-manager
    qemu
    uefi-run
    lxc
    swtpm
  ]);
}
