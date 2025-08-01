{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nixos"; # Replace with your username
  home.homeDirectory = "/home/nixos"; # Replace with your username

  home.packages = with pkgs; [
    cmake
  ];
  
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
PATH=/nix/store/5qng39wihv3lfgr03cf7mqbg4lpf4m45-cmake-3.30.5/bin:$PATH
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
     if ! emacsclient -e "(server-running-p)" | grep -q t; then
        emacs --daemon
     fi

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
  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  home.sessionVariables = {
    EMACSLOADINIT = "${config.home.homeDirectory}/.dotfiles/emacs/init.el";
  };

  home.file.".emacs.d/init.el".source = "${config.home.homeDirectory}/.dotfiles/emacs/init.el";


  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "24.11"; # Don't change this
}
