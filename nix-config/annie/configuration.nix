{ config, lib, pkgs, machine, ... }:

{
  
  # imports =
  #   [ # Include the results of the hardware scan.
  #     # ../modules/common-packages.nix 
  #   ];
  
  environment.packages = with pkgs; [
      git
      git-lfs
      lazygit
      pinentry-curses
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
      diff-so-fancy
      fastfetch
      ripgrep
      poetry
      pandoc
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";
}
