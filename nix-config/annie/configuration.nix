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

  nix.settings.experimental-features = ["nix-command" "flakes"];
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
      ripgrep
      poetry
      pandoc
      syncthing
    ];
  system.stateVersion = "26.05"; # Did you read the comment?
}
