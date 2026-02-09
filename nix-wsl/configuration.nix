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
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = [ "root" "nixos" ];
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

  services.jupyter = {
    enable = true;
    password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$+d1QjDGEk7oxAlImDwwDuQ$xwz6lp0qiMj0bSfeKAiWk7PAHqvjmDmRAYOq93lwNJk";
    kernels = {
      python3 = {
        displayName = "Python 3";
        argv = [
          "${python-with-packages.interpreter}"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
        language = "python";
      };
      
      R = {
        displayName = "R";
        argv = [
          "${R-with-my-packages}/bin/R"
          "--slave"
          "-e"
          "IRkernel::main()"
          "--args"
          "{connection_file}"
        ];
        language = "R";
      };
    };
  };

  environment.systemPackages = with pkgs;
    [
      home-manager
      vim 
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
      python-with-packages
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
      texlab
      poetry
      devenv
      nix-direnv
      basedpyright
      mupdf
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
