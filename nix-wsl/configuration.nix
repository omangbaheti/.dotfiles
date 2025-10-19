# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, unstable, ... }:
let
  R-with-my-packages = unstable.rWrapper.override {
    packages = with unstable.rPackages; [
      IRkernel
      ez
      dplyr
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
    ];
  };
in
{
  nix.settings.experimental-features = ["nix-command" "flakes"];
  
  wsl.enable = true;
  wsl.defaultUser = "nixos";
  programs.zsh.enable = true;
  
  users.defaultUserShell = pkgs.zsh;
  fonts.packages = with pkgs.nerd-fonts; 
    [ 
      jetbrains-mono
      ubuntu
      fira-code
      fira-mono
      dejavu-sans-mono
      symbols-only
    ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs;
    [
      home-manager
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      btop
      wiper
      git
      nixfmt-rfc-style
      eza
      languagetool
      git-lfs
      zoxide
      fzf
      gtk4
      firefox
      zsh
      oh-my-posh
      tealdeer
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      proselint
      coreutils
      nnn  
      nodejs_24
      (python3.withPackages (ps: with ps; [
        numpy
        pandas
        dill
        requests
        matplotlib
        scipy
        jupyter
        jupyterlab
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
      ]))
      R-with-my-packages
      zulu8
      fd
      glib
      gdb
      clang
      cmake
      gcc
      libvterm
      libgcc
      libtool
      yazi
      lazygit
      syncthing
      fastfetch
      diff-so-fancy
      nil
      texliveFull
      pandoc
      pylint
      statix
      omnisharp-roslyn
      unstable.pyrefly
      harper
      hugo
      ripgrep
      ltex-ls-plus
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
