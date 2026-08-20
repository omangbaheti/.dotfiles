{ config, pkgs, lib, stable, machine, inputs, ... }:
let
  hostname = machine.host;
  username = machine.username;
  allowUnfree = machine.allowUnfree;
  home = "/home/${username}";
  immichDirs = [ "thumbs" "upload" "backups" "library" "profile" "encoded-video" ];
  mediaRoot = "/mnt/d/images/immich";
  mkDir = path: { d = { user = "immich"; group = "immich"; mode = "0750"; }; };
  mkFile = path: { f = { user = "immich"; group = "immich"; mode = "0640"; }; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/common-packages.nix 
      inputs.nix-minecraft.nixosModules.minecraft-servers      
      inputs.sops-nix.nixosModules.sops   
      inputs.playit-nixos-module.nixosModules.default 
    ];

  # Bootloader.
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];
};
  ## minecraft
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ]; 
  
  fileSystems."/mnt/d" = {
    device = "/dev/disk/by-uuid/38536e44-4640-43d2-951c-edb483b464c1";
    fsType = "ext4";
    options = [ "nofail" ];
  }; 
  
  users.users = {
    "${username}" = {
      isNormalUser = true;
      description = "ino";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGCznNafBn+pO8jaNT5u73dYTFliHk2vjOWMc3GhLOg omangbaheti@gmail.com''
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHjuH720PJ/+WJybGHkyvJn+jl1KWQytl3K1z4rYjYDd omangbaheti@gmail.com'' 
      ];
    };
  };
  users.groups.arrs = {};

  users.users.sonarr.extraGroups = [ "arrs" ];
  users.users.radarr.extraGroups = [ "arrs" ];
  users.users.bazarr.extraGroups = [ "arrs" ];
  users.users.jellyfin.extraGroups = [ "video" "render" ];
  systemd.tmpfiles.rules = [
    "d /mnt/d 0775 root users -"
    "d /mnt/d/media 0775 root users -"
    "d /mnt/d/media/movies/ 0775 radarr arrs -"
    "d /mnt/d/media/shows/ 0775 sonarr arrs -"
    "d ${home}/Notes 0755 ${username} users -"
    "d ${home}/Notes/Agenda 0755 ${username} users -"
  ];

  sops = {
    validateSopsFiles = false;
    age.sshKeyPaths = ["${home}/.ssh/id_ed25519"];
    defaultSopsFile = "${home}/.dotfiles/.secrets/secrets.yaml";
    secrets."nextcloud_admin_pass" = { owner = "nextcloud"; }; 
    secrets."nextcloud_db_pass" = { owner = "nextcloud"; }; 
    secrets."cloudflare_tunnel_key" = { owner = "ino"; }; 
    secrets."playit_key" = { owner = "ino"; }; 
  };
  
  # Set your time zone.
  time.timeZone = "America/Toronto";
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  
  networking.hostName = hostname; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  
  # Open the UDP port for Tailscale
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port 443];

  # Optional: trust the tailscale interface (skips firewall for tailnet traffic)
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  
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
      glance
    ];

  programs.zsh.enable = true;

  #docker containers 
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker"; 
  virtualisation.oci-containers.containers.voxeldash-one =
    {
      image = "ghcr.io/gnmyt/voxeldash-one:dev-56309bb";
      ports = [ "0.0.0.0:7867:7867"    "0.0.0.0:35223:35223" ]; 
      volumes = [ "/var/lib/voxeldash:/data" ];
    };
  
  virtualisation.oci-containers.containers.byparr =
    {
      image = "ghcr.io/thephaseless/byparr:latest";
      autoStart = true;
      ports = [ "127.0.0.1:8191:8191" ];
      environment = {
        LOG_LEVEL = "INFO";
        PORT = "8191";
        HOST = "0.0.0.0";
      };
      pull = "always"; 
    };

  #systemd services 
  services.tailscale.enable = true;
  services.logrotate.checkConfig = false;
  services.openssh.enable = true;

  services.cloudflared =
    {
      enable = true;
      tunnels."eec2b94a-fd09-4e71-bc7a-757617a0a882" =
        {
          credentialsFile = "/home/ino/.cloudflared/eec2b94a-fd09-4e71-bc7a-757617a0a882.json";
          default = "http_status:404";
          ingress = {
            "immich.amber-forge.party" = "http://127.0.0.1:2283";
            "nextcloud.amber-forge.party" = "http://127.0.0.1:80";
            "jellyfin.amber-forge.party" = "http://127.0.0.1:8096";
            "home.amber-forge.party" = "http://127.0.0.1:8080";
          };
        };
    };  
  
  services.minecraft-servers = {
    enable = true;
    eula = true;
  };

  services.glance = {
    enable = true;
    # openfirewall = true;
    settings = {
      server.port = 8080;
    };
  };
  
  systemd.services.glance.serviceConfig.User = lib.mkForce "${username}";
  
  systemd.services.glance = {
    serviceConfig = {
      ExecStart = lib.mkForce "${lib.getExe pkgs.glance} --config ${home}/.dotfiles/glance/glance.yml";
      # if sandboxed and needs to read your home dir:
      ProtectHome = lib.mkForce false;
    };
  };
  services.syncthing = 
    {
      enable = true;
      openDefaultPorts = true; 
      guiAddress = "0.0.0.0:8384";
      user = "ino";
      group = "users";
      dataDir = "/home/ino";
    };
  
  services.immich = {
    package = pkgs.immich;
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    mediaLocation = "/mnt/d/images/immich";
    # openFirewall = true;
  };

  #bug upstream where any folder other than /var/lib/immich doesnt work, so need to make them manually
  systemd.tmpfiles.settings.immich =
    { "${mediaRoot}" = mkDir mediaRoot; }
    // lib.genAttrs (map (d: "${mediaRoot}/${d}") immichDirs) mkDir
      // lib.genAttrs (map (d: "${mediaRoot}/${d}/.immich") immichDirs) mkFile;
  
  services.playit = {
    enable = true;
    secretPath = config.sops.secrets.playit_key.path; #"/home/ino/.secrets/playit.toml";
  }; 

  
  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/mnt/d/jellyfin";
    stateDir = "/mnt/d/jellyfin/.state/nixarr";

    # vpn = {
    #   enable = false;
    #   # WARNING: This file must _not_ be in the config git directory
    #   # You can usually get this wireguard file from your VPN provider
    #   # wgConf = "/data/.secret/wg.conf";
    # };
    
    vpn = {
      enable = true;
      wgConf = "${home}/.dotfiles/.secrets/wg.conf";
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

    qbittorrent = {
      enable = true;
      extraAllowedIps = [ "100.*.*.*" ];
      qui.enable = true;
    };

    
    transmission = {
      enable = true;
      vpn.enable = true;
      # rpc-whitelist-enabled = false;
      extraAllowedIps = [ "100.*.*.*" ];
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
  
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.amber-forge.party"; # MagicDNS name, or just the tailscale IP
    # hostName = "ino.caracal-silverside.ts.net"; # MagicDNS name, or just the tailscale IP
    package = pkgs.nextcloud34;

    database.createLocally = true;
    configureRedis = true;

    https = true; # Tailscale already encrypts the tunnel
    maxUploadSize = "16G";
    autoUpdateApps.enable = true;

    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts mail notes tasks;
    };

    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = config.sops.secrets.nextcloud_admin_pass.path;
    };

    settings = {
      defaultPhoneRegion = "CA";
      overwriteProtocol = "https";
    };
  };


  system.stateVersion = "26.05";
}
