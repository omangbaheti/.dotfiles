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
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  users.users.nixos.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGCznNafBn+pO8jaNT5u73dYTFliHk2vjOWMc3GhLOg omangbaheti@gmail.com'' ];
  
  # Set your time zone.
  time.timeZone = "America/Toronto";
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  users.users.root.shell = pkgs.zsh; 
  environment.systemPackages = with pkgs;
    [
      vim
      git
      lazygit
      lazydocker
      btop
    ];


programs.zsh.enable = true;
  
services.tailscale.enable = true;
services.logrotate.checkConfig = false;
services.openssh.enable = true;
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
