# edit this configuration file to define what should be installed on
# your system. help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the nixos manual (`nixos-help`).

# nixos-wsl specific options are documented on the nixos-wsl repository:
# https://github.com/nix-community/nixos-wsl

{config, lib, pkgs, stable, machine, inputs, ... }:
let
  username = machine.username;
  allowUnfree = machine.allowUnfree;
  secretsdir = "/home/${username}/.dotfiles/.secrets";
  hostfile   = "${secretsdir}/${username}/secrets.yaml";
in
{
  nix.settings.trusted-users = [ "root" username];
  nixpkgs.config.allowUnfree = allowUnfree;
  
  wsl.enable = true;
  wsl.defaultUser = username;
  
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
    ]++ (with pkgs;[
      noto-fonts-monochrome-emoji
    ]);
  fonts.fontconfig.defaultFonts.emoji = [ "Noto Emoji" ];
  hardware.graphics.enable = true;
  # hardware.graphics.extrapackages = [ pkgs.mesa.drivers ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs;
    [
      gtk4
      exercism
    ];

  # this value determines the nixos release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. it's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # did you read the comment?
}
