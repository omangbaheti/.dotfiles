{ config, pkgs, stable, inputs, ... }:
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
      zoxide
      fzf
      vim 
      zsh
      oh-my-posh
      tealdeer
      btop
      fd
      eza
      devenv
      nix-direnv
      yazi
      diff-so-fancy
      fastfetch
      ripgrep
      gpg-tui     
      #LSPs / Compilers / Dev Envs
      #C/C++
      # libvterm
      # libtool
      
      #python 
      python-with-packages
      
      #misc    
      home-manager
      
      #misc     
      coreutils
      sioyek
      tirith
      android-tools
      sops
      age
      ssh-to-age
      ffmpeg
      proton-pass-cli
      cloudflared     
      openssl
      #for controlling external monitor
      ddcutil
      luminance
      #secure boot
      sbctl
      nvtopPackages.nvidia
      libva-utils
      inputs.herdr.packages.${pkgs.system}.default
    ];
}
