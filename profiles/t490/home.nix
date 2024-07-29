{ config, pkgs, userSettings, ... }:

{
    home.username = userSettings.name;
    home.homeDirectory = "/home" + userSettings.name;

    programs.home-manager.enable = true;

    imports = 
    [

    ];

    home.stateVersion = "24.05";

    home.packages = (with pkgs;
    [
        #Dev-Tools
        github-desktop
        jetbrains.rider
        unityhub
        ventoy
        bitwarden-desktop

        #Tools
        libreoffice-fresh
        gimp
        aseprite
        zotero

        #Media
        vlc
        obs-studio
        ffmpeg
        spotify

        #Communication
        discord
        whatsapp-for-linux
        telegram-desktop

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
    ]);

    home.sessionVariables = 
    {
        EDITOR = userSettings.editor;
        SPAWNEDITOR = userSettings.spawnEditor;
        TERM = userSettings.term;
        BROWSER = userSettings.browser;
    };
}