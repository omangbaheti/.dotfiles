{ config, pkgs, stable, machine, ... }:
{
  # home.username = userSettings.name;
  # home.homeDirectory = "/home/" + userSettings.name;
  home.stateVersion = "25.05";
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
      
      protonvpn-gui
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
      ffmpeg
      spotify
      parsec-bin
      
      #Communication
      discord
      wasistlos
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

  home.sessionVariables = 
    {
      EMACSLOADINIT = "~/.dotfiles/emacs/init.el";
      EDITOR = machine.editor;
      BROWSER = machine.browser;
      # SPAWNEDITOR = userSettings.spawnEditor;
    };
  home.file.".emacs.d/init.el".source = /${config.home.homeDirectory}/${machine.dotfilesDir}/emacs/init.el;
}
