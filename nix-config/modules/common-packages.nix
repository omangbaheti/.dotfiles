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
    orjson
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
      gpg-tui     
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
      jdt-language-server
      lombok
      openjdk25
      # zulu8 
      
      # C#
      omnisharp-roslyn
      csharp-ls
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

      #flutter
      flutter
      
      #misc    
      home-manager
      languagetool
      
      claude-code
      opencode
      pi-coding-agent
      
      #misc     
      firefox
      coreutils
      syncthing
      hugo
      mupdf
      sioyek
      tirith
      scrcpy
      android-tools
      pinentry-curses
      sops
      age
      ssh-to-age
      ffmpeg
      proton-pass-cli
      
      #for controlling external monitor
      ddcutil
      luminance
      #secure boot
      sbctl
      nvtopPackages.nvidia
    ];
}
