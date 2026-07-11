{ config, pkgs, lib, stable, machine, inputs, ... }:
let
  hostname = machine.host;
  username = machine.username;
  allowUnfree = machine.allowUnfree;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/common-packages.nix 
    ];

  # Bootloader.
  
  services.logrotate.checkConfig = false;
  nixpkgs.config.allowUnfree = true;
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "vultr";
  networking.domain = "guest";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGCznNafBn+pO8jaNT5u73dYTFliHk2vjOWMc3GhLOg omangbaheti@gmail.com'' ];
  programs.zsh.enable = true;
  users.users.root.shell = pkgs.zsh; 
  environment.systemPackages = with pkgs;
    [
      vim
      git
      lazygit
    ];

services.tailscale.enable = true;

# Open the UDP port for Tailscale
networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

# Optional: trust the tailscale interface (skips firewall for tailnet traffic)
networking.firewall.trustedInterfaces = [ "tailscale0" ];
  
  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    vpn = {
      enable = true;
      # WARNING: This file must _not_ be in the config git directory
      # You can usually get this wireguard file from your VPN provider
      wgConf = "/data/.secret/wg.conf";
    };

    jellyfin = {
      enable = true;
      # These options set up a nginx HTTPS reverse proxy, so you can access
      # Jellyfin on your domain with HTTPS
      # expose.https = {
      #   enable = true;
      #   domainName = "your.domain.com";
      #   acmeMail = "your@email.com"; # Required for ACME-bot
      # };
    };

    transmission = {
      enable = true;
      vpn.enable = true;
      peerPort = 50000; # Set this to the port forwarded by your VPN
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    # readarr.enable = true;
    sonarr.enable = true;
    seerr.enable = true;
  };  
  system.stateVersion = "26.05";
}
