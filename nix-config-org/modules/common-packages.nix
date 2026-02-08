{ config, pkgs, unstable, ... }:
{
  nix.settings.experimental-features = ["nix-command" "flakes"];
  environment.systemPackages = with pkgs;
    [
      #cli tools
      
      git
      git-lfs
      lazygit
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
      
      #LSPs / Compilers / Dev Envs
      glib
      gdb
      clang
      cmake
      gcc
      libvterm
      libgcc
      libtool
      
      pylint
      basedpyright
      unstable.pyrefly
      
      nodejs_24
      
      zulu8 #openjdk
      
      omnisharp-roslyn
      
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      proselint
      harper
      ltex-ls-plus
      texlab
      texliveFull
      
      nixfmt-rfc-style
      statix
      nil
      
      #misc    
      home-manager
      languagetool
      firefox
      coreutils
      syncthing
      hugo
      mupdf
    ];
}
