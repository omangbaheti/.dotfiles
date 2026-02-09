{ config, pkgs, stable, machine ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = machine.username; 
  home.homeDirectory = /home/${machine.username}; # Replace with your username
  
  home.packages = with pkgs; 
    [
      cmake
      glib
      dconf
    ];
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Omang Baheti";
    userEmail = "omangbaheti@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.default = "simple";
    };
  };

  # Zsh configuration
  programs.zsh = 
    {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = 
        {
          ll = "eza -l";
          la = "eza -la";
          ls = "eza";
          grep = "rg";
          find = "fd";
          e="emacsclient -c";
          update-config = "sudo nixos-rebuild switch --flake .#nixos";
          exp="/mnt/c/WINDOWS/explorer.exe .";
        };

      oh-my-zsh = 
        {
          enable = true;
          plugins = [ "git" "sudo" ];
          theme = "robbyrussell";
        };

      initContent = ''
   #DISPLAY=$(ip route | grep default | awk '{print $3}'):0.0
   #LIBGL_ALWAYS_INDIRECT=1  
   eval "$(direnv hook zsh)"
   export R_LIBS_SITE=$(ls -d /nix/store/*-r-*/library | tr '\n' ':')

   PATH=/nix/store/5qng39wihv3lfgr03cf7mqbg4lpf4m45-cmake-3.30.5/bin:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:$PATH
     eval "$(zoxide init zsh)"
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

  services.ssh-agent.enable = true;
  
  programs.ssh = 
    {
      enable = true;
      addKeysToAgent = "yes";       # Automatically adds keys to the agent
      forwardAgent = true;         # Optional: disables forwarding
      extraConfig = ''
    Host github.com
      IdentityFile ~/.ssh/id_ed25519
  '';
    };
  
  programs.keychain = 
    {
      enable = true;
      keys = [ "id_ed25519" ];  # Replace with your SSH key filename
      agents = [ "ssh" ];
      enableZshIntegration = true;
    };
  
  # Direnv for automatic environment loading
  programs.direnv = 
    {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      
      config = {
        global = {
          log_format = "-";
          log_filter = "^$";
          hide_env_diff = true;
        };
      };
    };


    services.emacs = {
      enable = true;
    };
  
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages = (
        epkgs: with unstable.emacsPackages;   
          [ 
            vterm 
            zmq 
            treesit-auto
            treesit-grammars.with-all-grammars
            pdf-tools
            (melpaBuild {
              ename = "reader";
              pname = "emacs-reader";
              version = "20250630";
              src = pkgs.fetchFromGitea {
                domain = "codeberg.org";
                owner = "divyaranjan";
                repo = "emacs-reader";
                rev = "0.3.2"; # replace with 'tag' for stable
                hash = "sha256-BpuWWGt46BVgQZPHzeLEbzT+ooR4v29R+1Lv0K55kK8=";
              };
              files = ''(:defaults "render-core.so")'';
              nativeBuildInputs = [ pkgs.pkg-config ];
              buildInputs = [ pkgs.gcc unstable.mupdf pkgs.gnumake pkgs.pkg-config ];
              preBuild = "make clean all";
            })
  
          ]
      );
    };

  services.syncthing = 
    {
      enable = true;
    };

  gtk = 
    {
      enable = true;
      theme = 
        {
          package = pkgs.orchis-theme;
          name = "Orchis-Dark"; # or "Orchis-Dark", "Orchis-Purple", etc.
        };
    };

  home.sessionVariables = 
    {
      EMACSLOADINIT = "${homeDirectory}/${machine.dotfilesDir}/emacs/init.el";
      GTK_THEME = "Orchis-Dark";
    };
  
  #home.file.".emacs.d/init.el".source = "${config.home.homeDirectory}/.dotfiles/emacs/init.el";
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "24.11"; # Don't change this
}
