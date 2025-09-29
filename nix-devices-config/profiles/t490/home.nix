{ config, pkgs, pkgs-unstable, userSettings, ... }:

{
    home.username = userSettings.name;
    home.homeDirectory = "/home/" + userSettings.name;

    programs.home-manager.enable = true;
    programs.zoxide.enable = true;


    home.stateVersion = "25.05";

    home.packages = (with pkgs;
    [
        #Dev-Tools
        jetbrains.rider
        pkgs-unstable.unityhub
        #ventoy
        bitwarden-desktop
        blender
        rclone
        
        #Tools
        libreoffice
        gimp
        aseprite
        zotero
        obsidian
        pkgs-unstable.android-studio
        audacity

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

    


      programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = (
      epkgs: with pkgs-unstable.emacsPackages;   
        [ 
          vterm 
          zmq 
          treesit-auto
          treesit-grammars.with-all-grammars
          lsp-bridge
          pdf-tools
        ]
    );
  };

  home.sessionVariables = 
    {
        EDITOR = userSettings.editor;
        SPAWNEDITOR = userSettings.spawnEditor;
        TERM = userSettings.term;
        BROWSER = userSettings.browser;
    };
#xdg.configFile."emacs/init.el".source = ../../emacs/init.el;  
#xdg.configFile."emacs/init.el".source = "${config.home.homeDirectory}/.dotfiles/emacs/init.el";
xdg.configFile."emacs/init.el".source = 
  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/emacs/init.el";

}