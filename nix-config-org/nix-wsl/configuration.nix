# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{config, lib, pkgs, unstable, ... }:
let
  R-with-my-packages = unstable.rWrapper.override {
    packages = with unstable.rPackages; [
      IRkernel
      ez
      dplyr
      effsize
      tidyr
      purrr
      car
      nlme
      reshape2
      rstatix
      prettyR
      afex
      estimability
      emmeans
      ARTool
      multcomp
      digest
    ];
  };
  python-with-packages = pkgs.python3.withPackages (ps: with ps; [
    numpy
    pandas
    dill
    requests
    matplotlib
    scipy
    # Remove jupyter and jupyterlab - managed by services.jupyter
    seaborn
    xlib
    epc
    sexpdata
    six
    inflect
    pyqt6
    pyqt6-sip
    pyqt6-webengine
    qrcode
    python-lsp-server
    watchdog
    ipykernel  # Keep this for the kernel
  ]);
in
{

  nix.settings.trusted-users = [ "root" "nixos" ];
  wsl.enable = true;
  wsl.defaultUser = "nixos";
  fonts.packages = with pkgs.nerd-fonts; 
    [ 
      jetbrains-mono
      ubuntu
      fira-code
      fira-mono
      dejavu-sans-mono
      symbols-only
    ];
  imports = [ ../modules/common-packages.nix ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  nixpkgs.config.allowUnfree = true;

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
