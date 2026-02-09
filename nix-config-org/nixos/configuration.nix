# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{config, lib, pkgs, stable, machine ... }:
let
  userName = machine.username;
  allowUnfree = machine.allowUnfree;
in
{
  nix.settings.trusted-users = [ "root" userName];
  nixpkgs.config.allowUnfree = allowUnfree;
  
  wsl.enable = true;
  wsl.defaultUser = userName;
  
  imports = 
    [
      ../modules/common-packages.nix 
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

  environment.systemPackages = with pkgs;
    [
      gtk4
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
