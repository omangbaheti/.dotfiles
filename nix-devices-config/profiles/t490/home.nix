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
      bottles-unwrapped
      fprintd
    ]);

  # services.power-profiles-daemon.enable = true;

  services.emacs = {
    enable = true;
  };

  services.syncthing = {
    enable = true;
  };
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
  

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -l";
      la = "eza -la";
      ls = "eza";
      grep = "rg";
      find = "fd";
      e="emacsclient -c";
      update-config = "sudo nixos-rebuild switch --flake .#nixos";
      exp="explorer.exe .";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "robbyrussell";
    };

    initContent = ''
   DISPLAY=$(ip route | grep default | awk '{print $3}'):0.0
   LIBGL_ALWAYS_INDIRECT=1  
   PATH=/nix/store/5qng39wihv3lfgr03cf7mqbg4lpf4m45-cmake-3.30.5/bin:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:$PATH
     eval "$(zoxide init zsh)"
     #env "YAZI_CONFIG_HOME=~/.dotfiles/yazi" yazi
     eval "$(oh-my-posh init zsh)"
     function isWinDir 
     {
        case "$PWD/" in
        /mnt/*) return 0 ;;
        *) return 1 ;;
        esac
     }

     function lazygit 
     {
        if isWinDir; then
     #  Use Windows `lazygit.exe` in Windows-mounted dirs
            command lazygit.exe "$@"
        else
     #  Use native Linux `lazygit` in native dirs
            command lazygit "$@"
        fi 
     }
    '';
  };

  programs.git = {
    enable = true;
    userName = "Omang Baheti";
    userEmail = "omangbaheti@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.default = "simple";
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";       # Automatically adds keys to the agent
    forwardAgent = true;         # Optional: disables forwarding
    extraConfig = ''
    Host github.com
      IdentityFile ~/.ssh/id_ed25519
  '';
  };
  
  programs.keychain = {
    enable = true;
    keys = [ "id_ed25519" ];  # Replace with your SSH key filename
    agents = [ "ssh" ];
    enableZshIntegration = true;
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
