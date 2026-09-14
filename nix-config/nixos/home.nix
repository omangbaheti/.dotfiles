{ config, pkgs, stable, machine, inputs, ... }:
{
  # home manager needs a bit of information about you and the
  # paths it should manage.
  # home.username = machine.username; 
  # home.homedirectory = /home/${machine.username}; # replace with your username
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
    
  sops = {
    validateSopsFiles = false;
    age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
    defaultSopsFile = "/${config.home.homeDirectory}/.dotfiles/.secrets/shared/secrets.yaml";
    secrets."opencode_go" = { }; 
  };
  
  home.packages = with pkgs; 
    [
      cmake
      glib
      dconf
      (pkgs.symlinkJoin {
        name = "pi-coding-agent";
        buildinputs = [ pkgs.makeWrapper ];
        paths = [ pkgs.pi-coding-agent ];
        postbuild = ''
        wrapprogram $out/bin/pi \
          --set npm_config_prefix ${config.home.homeDirectory}/.pi/npm/ \
          --prefix path : ${
            pkgs.lib.makeBinPath [
              pkgs.nodejs_latest
            ]
          }
      '';
      })
    ];

  programs.home-manager.enable = true;
  # nix.settings.auto-optimise-store = true;
  programs.zoxide.enable = true;
  programs.git = {
    enable = true;
    settings = {
      user.name = "Omang Baheti";
      user.email = "omangbaheti@gmail.com";
      init.defaultBranch = "main";
      push.default = "simple";
      extraConfig =
        {
          credential.helper = "cache --timeout=28800";
        };
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
  
  home.file.".pi/agent/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/pi/settings.json";
  home.file.".pi/agent/skills".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/pi/skills";
  home.file.".pi/agent/extensions".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/pi/extensions";  

  programs.zsh = {
    initExtraFirst = ''
    # must run before oh-my-zsh/p10k/starship init
    [[ "$term" == "dumb" ]] && unsetopt zle && ps1='$ ' && return
  '';
    initExtra = ''
  export OPENCODE_API_KEY="$(cat ${config.sops.secrets.opencode_go.path})"
'';

    initContent = 
      ''
 # PATH=/nix/store/5qng39wihv3lfgr03cf7mqbg4lpf4m45-cmake-3.30.5/bin:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:$PATH
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
 export COLORTERM=truecolor
  #export display=$(ip route list default | awk '{print $3}'):0.0
'';

  };

  # programs.zsh.
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
      keys = [ "id_ed25519" ];  # replace with your ssh key filename
      enableZshIntegration = true;
    };
  

  services.emacs = {
    enable = true;
  };
  
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    # extraConfig = builtins.readFile /home/nixos/.dotfiles/emacs/init.el;
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
          name = "orchis-dark"; # or "orchis-dark", "orchis-purple", etc.
        };
    };

  home.sessionVariables = 
    {
      emacsloadinit = "${config.home.homeDirectory}/${machine.dotfilesDir}/emacs/init.el";
      pi_npm_bin = "${config.home.homeDirectory}/.pi/npm/bin";
      gtk_theme = "orchis-dark";
      lombok_jar = "${pkgs.lombok}/share/java/lombok.jar";
      libgl_always_indirect = "1";
    };
  
  home.file.".emacs.d/init.el".source = ../../emacs/init.el;
  home.file.".emacs.d/early-init.el".source = ../../emacs/early-init.el;
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";
  

  # this value determines the home manager release that your
  # configuration is compatible with.
  home.stateVersion = "24.11"; # don't change this
}
