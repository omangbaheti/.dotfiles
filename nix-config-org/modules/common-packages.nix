{ config, pkgs, stable, ... }:
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
      #C/C++
      glib
      gdb
      clang
      cmake
      gcc
      libvterm
      libgcc
      libtool
     
      #python 
      pylint
      basedpyright
      pyrefly
     
      #node 
      nodejs_24
      
      #openjdk
      zulu8 
      
      # C#
      omnisharp-roslyn
      
      #Latex LSP and grammar checking
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      proselint
      harper
      ltex-ls-plus
      texlab
      texliveFull
     
      #Nix 
      nixfmt-rfc-style
      statix
      nil
      
      #misc    
      home-manager
      languagetool
      
      #misc     
      firefox
      coreutils
      syncthing
      hugo
      mupdf
    ];
}
