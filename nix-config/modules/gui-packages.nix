{ config, pkgs, stable, machine, inputs, ... }:
let
  # Only fern and nyx import this file, so these pins reach just those two.
  # The global lock is multiverse.lock, installed everywhere by the module.
  guiPins = inputs.multiverse.lib.readLock {
    inherit (machine) system;
    file = ../multiverse-gui.lock;
    config.allowUnfree = true;
  };
in
{
  # 26.05's rider build is flagged insecure until the branch catches up.
  # The real fix is `mvs lock add jetbrains.rider` — see "Updating Packages".
  nixpkgs.config.permittedInsecurePackages = [ "rider-2026.2.4" ];

  home.packages = (with pkgs; [
    #Dev-Tools
    kdePackages.okular
    kdePackages.kdeconnect-kde
    
    # prismlauncher
    # Virtual Machines and wine
    libvirt
    wine
    virt-manager
    qemu
    uefi-run
    lxc
    swtpm
    
    #niri
    vicinae
    # noctalia
    xwayland-satellite
    wlr-which-key
  ]) ++ builtins.attrValues guiPins;
}
