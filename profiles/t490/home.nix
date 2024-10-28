{ config, pkgs, userSettings, ... }:

{
    home.username = userSettings.name;
    home.homeDirectory = "/home/" + userSettings.name;

    programs.home-manager.enable = true;

    imports = 
    [

    ];

    home.stateVersion = "24.05";

    home.packages = (with pkgs;
    [
        #Dev-Tools
        jetbrains.rider
        unityhub
        ventoy
        bitwarden-desktop
        blender
        
        #Tools
        libreoffice-fresh
        gimp
        aseprite
        zotero
        obsidian
        android-studio
        #Media
        vlc
        obs-studio
        ffmpeg
        spotify
        parsec-bin
        
        #Communication
        discord
        whatsapp-for-linux
        telegram-desktop
        slack 
        zoom-us
        teams
        #Games
        steam
        lutris-unwrapped
        
        # Virtual Machines and wine
        libvirt
        wine
        virt-manager
        qemu
        uefi-run
        lxc
        swtpm
        bottles
        fprintd
    ]);

    home.sessionVariables = 
    {
        EDITOR = userSettings.editor;
        SPAWNEDITOR = userSettings.spawnEditor;
        TERM = userSettings.term;
        BROWSER = userSettings.browser;
    };
}