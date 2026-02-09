{ config, pkgs, stable, machine, ... }:
{
  # home.username = userSettings.name;
  # home.homeDirectory = "/home/" + userSettings.name;
  # home.stateVersion = "25.05";
 <<common-home-config>>
  programs.zsh.initContent = 
    ''
<<zshConfigFern>>
    '';
  
  home.packages = (with pkgs;
    [
      #Dev-Tools
      jetbrains.rider
      unityhub
      #ventoy
      bitwarden-desktop
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

  <<emacs-config-wayland>>

  #   programs.zsh = {
  #     enable = true;
  #     enableCompletion = true;
  #     autosuggestion.enable = true;
  #     syntaxHighlighting.enable = true;

  #     shellAliases = {
  #       ll = "eza -l";
  #       la = "eza -la";
  #       ls = "eza";
  #       grep = "rg";
  #       find = "fd";
  #       e="emacsclient -c";
  #       update-config = "sudo nixos-rebuild switch --flake .#nixos";
  #       exp="/mnt/c/WINDOWS/explorer.exe .";
  #     };

  #     oh-my-zsh = {
  #       enable = true;
  #       plugins = [ "git" "sudo" ];
  #       theme = "robbyrussell";
  #     };
  
  #     initContent = ''
  # alias edituserconfig="code ~/.dotfiles/nix-devices-config/t490/home.nix"
  # alias editsystemconfig="code ~/.dotfiles/profiles/t490/configuration.nix"
  # alias updatesystemconfig="sudo nixos-rebuild switch --flake ~/.dotfiles/nix-devices-config"
  # alias updateuserconfig="home-manager switch --flake ~/.dotfiles/nix-devices-config#user" 
  # '';

  #   };


  home.sessionVariables = 
    {
      EMACSLOADINIT = "~/.dotfiles/emacs/init.el";
      # EDITOR = userSettings.editor;
      # SPAWNEDITOR = userSettings.spawnEditor;
      # BROWSER = userSettings.browser;
    };
  home.file.".emacs.d/init.el".source = /${config.home.homeDirectory}/${machine.dotfilesDir}/emacs/init.el;
}
