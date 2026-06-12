{ config, pkgs, stable, machine, inputs, ... }:
{
  # home.username = userSettings.name;
  # home.homeDirectory = "/home/" + userSettings.name;
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  nix.settings.auto-optimise-store = true;
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
  
  programs.zsh.initContent = 
    ''
eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh)"
eval "$(tirith init --shell zsh)"
eval "$(direnv hook zsh)"
    '';
  nixpkgs.config.allowUnfree = true;
  home.packages = (with pkgs;
    [
      #Dev-Tools
      jetbrains.rider
      unityhub
      
      #ventoy
      #bitwarden-desktop
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

      
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default     
      # Virtual Machines and wine
      libvirt
      wine
      virt-manager
      qemu
      uefi-run
      lxc
      swtpm
    ]);

  # services.emacs = {
  #   enable = true;
  # };
  
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
  home.sessionVariables = 
    {
      EMACSLOADINIT = "~/.dotfiles/emacs/init.el";
      EDITOR = machine.editor;
      BROWSER = machine.browser;
      LOMBOK_JAR = "${pkgs.lombok}/share/java/lombok.jar";
      # SPAWNEDITOR = userSettings.spawnEditor;
    };
  home.file.".emacs.d/early-init.el".source = ../../emacs/early-init.el;
  home.file.".emacs.d/init.el".source = ../../emacs/init.el;
  home.file.".config/niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/home/nyx/.dotfiles/niri/config.kdl";
  home.file.".config/noctalia" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/noctalia";
    recursive = true;  # symlinks each file individually
  };
  home.file.".local/share/vicinae/scripts".source =  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/scripts/vicinae";
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";
  
  gtk = 
    {
      enable = true;
      theme = 
        {
          package = pkgs.orchis-theme;
          name = "Orchis-Dark"; # or "Orchis-Dark", "Orchis-Purple", etc.
        };
    };

}
