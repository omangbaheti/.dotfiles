# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:
{


  nix.settings.experimental-features = ["nix-command" "flakes"];

  wsl.enable = true;
  wsl.defaultUser = "nixos";
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  fonts.packages = with pkgs; [ nerdfonts ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs;


  [
  home-manager
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  btop
  git
  nixfmt-rfc-style
  eza
  languagetool
  git-lfs
  zoxide
  fzf
  gtk4
  emacs30
  zsh
  ispell
  proselint
  ripgrep
  coreutils
  
  nodejs_23
  (python3.withPackages (ps: with ps; [
      numpy
      pandas
      requests
      matplotlib
      scipy
      jupyter
      jupyterlab
      seaborn
      epc
      sexpdata
      six
      inflect
      pyqt6
      pyqt6-sip
    ]))
  fd
  glib
  clang
  yazi
  lazygit
  libgcc
  syncthing
  fastfetch
  diff-so-fancy
  nil
  texliveFull
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
