{ config, pkgs, stable, machine, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  # home.username = machine.username; 
  # home.homeDirectory = /home/${machine.username}; # Replace with your username
  
  home.packages = with pkgs; 
    [
      cmake
      glib
      dconf
    ];
  programs.home-manager.enable = true;
  
  programs.zoxide.enable = true;
  programs.git = {
    enable = true;
    settings = {
      user.name = "Omang Baheti";
      user.email = "omangbaheti@gmail.com";
      init.defaultBranch = "main";
      push.default = "simple";
    };
  };
  
  programs.zsh = 
    {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
  
      shellAliases = 
        {
          ll = "eza -l";
          la = "eza -lah --tree --ignore-glob='.git|.venv|node_modules'";
          ls = "eza -h --git --icons --color=auto --group-directories-first -s extension";
          tree = "eza --tree --icons --ignore-glob='.git|.venv|node_modules'";
          grep = "rg";
          find = "fd";
          e="emacsclient -c";
          emd = "emacs --daemon";
          rebuild-config = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix-config#${machine.systemType}";
          rebuild-home-config = "home-manager switch --flake  ~/.dotfiles/nix-config#${machine.username}@${machine.host}";
          exp="/mnt/c/WINDOWS/explorer.exe .";
        };
  
      oh-my-zsh = 
        {
          enable = true;
          plugins = [ "git" "sudo" ];
          theme = "robbyrussell";
        };
    };
  
  services.syncthing = 
    {
      enable = true;
    };
  
  programs.gpg.enable = true;
  
  services.gpg-agent = 
    {
      enable = true;
      pinentry.package = pkgs.pinentry-curses; 
      extraConfig = ''
      default-cache-ttl = 31536000;  # 1 year in seconds
      max-cache-ttl = 31536000;
        allow-loopback-pinentry
      '';
    };  
  programs.zsh.initContent = 
    ''
 PATH=/nix/store/5qng39wihv3lfgr03cf7mqbg4lpf4m45-cmake-3.30.5/bin:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:$PATH
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
 
 eval "$(zoxide init zsh)"
 eval "$(oh-my-posh init zsh)"
 eval "$(tirith init --shell zsh)"
 eval "$(direnv hook zsh)"
'';

  services.ssh-agent.enable = true;
  
  programs.ssh = {
    enable = true;

    matchBlocks."github.com" = {
      identityFile = "~/.ssh/id_ed25519";
      addKeysToAgent = "yes";
      forwardAgent = true;
    };
  };

  programs.keychain = 
    {
      enable = true;
      keys = [ "id_ed25519" ];  # Replace with your SSH key filename
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
        epkgs: with pkgs.emacsPackages;   
          [ 
            vterm 
            zmq 
            treesit-auto
            treesit-grammars.with-all-grammars
            pdf-tools
          ]
      );
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
      EMACSLOADINIT = "${config.home.homeDirectory}/${machine.dotfilesDir}/emacs/init.el";
      GTK_THEME = "Orchis-Dark";
    };
  
  home.file.".emacs.d/init.el".source = /${config.home.homeDirectory}/${machine.dotfilesDir}/emacs/init.el;
  # home.file.".emacs.d/init.el".source = ../emacs/init.el;
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "24.11"; # Don't change this
}
