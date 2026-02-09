{ config, pkgs, stable, ... }:
let
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
      python-with-packages
      
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
      nixfmt
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
