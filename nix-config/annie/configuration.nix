{config, lib, pkgs, stable, machine, ... }:
let
  userName = machine.username;
  allowUnfree = machine.allowUnfree;
in
{
  imports = 
    [ 
      <nixos-avf/avf>
    ];
  users.users.${userName} = 
    {
      isNormalUser = true;
      home = "/home/${userName}";
      description = "Annie User";
      extraGroups = [ "wheel" "networkmanager" ];
      # Add any other user configuration
    };
  nix.settings.trusted-users = [ "root" userName];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  services.getty.autologinUser = "${userName}";
  environment.systemPackages = with pkgs;
    [
      git
      git-lfs
      lazygit
      neovim
      wiper
      zoxide
      fzf
      vim 
      zsh
      oh-my-posh
      tealdeer
      btop
      #nnn  
      fd
      eza
      devenv
      nix-direnv
      yazi
      fastfetch
      home-manager
      ripgrep
      poetry
      pandoc
      syncthing
    ];
  
  fonts.packages = with pkgs.nerd-fonts; 
    [ 
      jetbrains-mono
      ubuntu
      fira-code
      fira-mono
      dejavu-sans-mono
      symbols-only
    ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  system.stateVersion = "26.05"; # Did you read the comment?
}
