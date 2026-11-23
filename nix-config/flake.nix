{
description = "Unified Flake Config";
inputs = 
  {
    # Calm base: a release branch only takes backports, so a weekly
    # `nix flake update nixpkgs` moves a handful of packages, not the world.
    # Anything you want fresher than this goes in multiverse.lock — see
    # "Updating Packages" below.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Per-package pins across every nixpkgs revision ever. No inputs of its
    # own, so it adds no nixpkgs to the lock graph.
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    nixos-wsl = 
      {
        url = "github:nix-community/NixOS-WSL";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    
    home-manager = 
      {
        # Matched to the nixpkgs channel; master is 26.11 and warns about the
        # mismatch.
        url = "github:nix-community/home-manager/release-26.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    
    nix-colors.url = "github:misterio77/nix-colors";
    
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixarr.url = "github:nix-media-server/nixarr";    
    
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    freesmlauncher = {
      url = "github:FreesmTeam/FreesmLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module"; 

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    herdr = {
      url = "github:herdrdev/herdr/v0.9.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };
outputs = { self, nixpkgs, nixos-wsl, home-manager, lanzaboote, freesmlauncher, nixarr, ... }@inputs: 
  let
    # `stable` and the base are the same channel now; this keeps the `stable`
    # argument working (with unfree allowed) at every existing call site.
    stableFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    commonSettings = 
      {
        dotfilesDir = ".dotfiles";
        allowUnfree = true;
        editor = "emacs -c -a";
        browser = "zen";
      };
    
    #defining variables for each of my machines
    machines = 
      {
        wsl = commonSettings //  # // is used to merge and pull in shared values
              {
                system = "x86_64-linux";
                host = "nixos";
                username = "nixos";
                systemType = "nix-wsl"; #TODO: change host-name to nix-wsl and remove redundant use of systemType
              }; 

        fern = commonSettings // 
               {
                 system = "x86_64-linux";
                 host = "fern";
                 username = "fern";
                 systemType = "fern";
               };
        
        vultr = commonSettings // 
                {
                  system = "x86_64-linux";
                  host = "vultr";
                  username = "root";
                  systemType = "vultr";
                };

        ino = commonSettings // 
                {
                  system = "x86_64-linux";
                  host = "ino";
                  username = "ino";
                  systemType = "ino";
                };
        
        nyx = commonSettings // 
              {
                system = "x86_64-linux";
                host = "nyx";
                username = "nyx";
                systemType = "nyx";
              };
        
        
        annie = commonSettings //
                {
                  system = "aarch64-linux";
                  host = "annie";
                  username = "annie";
                  systemType = "annie";
                };
        
        raven =  commonSettings //
                 {
                   system = "aarch64-linux";
                   host = "raven";
                   username = "raven";
                   systemType = "other-distro";
                 };
        
        sakura = (commonSettings // # overriding system when required
                  {
                    system = "aarch64-linux";
                    host = "sakura";
                    username = "sakura";
                    systemType = "pi";
                  });
        
      };
    mkSystem = machine:
      let
        pkgs = nixpkgs.legacyPackages.${machine.system};
        isWSL = machine.systemType == "nix-wsl";
      in
        nixpkgs.lib.nixosSystem 
          {
            system = machine.system;
            modules = 
              [
                (if isWSL then nixos-wsl.nixosModules.wsl else {})
                home-manager.nixosModules.home-manager
                # Forward args into HM modules here:
                ({ ... }:
                  {
                    home-manager.extraSpecialArgs = {
                      inherit machine;
                      inherit inputs;
                      stable = stableFor machine.system;
                      host = machine.host;
                      username = machine.username;
                      systemType = machine.systemType;
                      machines = machines;
                    };
                    # Per-package pins live here. Empty lock = no-op until you add
                    # something with `mvs lock add`; see "Updating Packages".
                    home-manager.sharedModules = [
                      inputs.multiverse.homeManagerModules.default
                      {
                        multiverse = {
                          enable = true;
                          config.allowUnfree = true;
                          lock = ./multiverse.lock;
                        };
                      }
                    ];
                    home-manager.users.${machine.username} = import ./${machine.host}/home.nix;
                  })
                lanzaboote.nixosModules.lanzaboote  
                # Same lock file, system side: `multiverse.locked.<attr>` is
                # available to configuration.nix and installs into
                # environment.systemPackages automatically.
                inputs.multiverse.nixosModules.default
                { multiverse = { enable = true; config.allowUnfree = machine.allowUnfree; lock = ./multiverse.lock; }; }
                ./${machine.host}/configuration.nix
                nixarr.nixosModules.default 
              ];
    
            specialArgs = {
              inherit inputs; 
              inherit self;
              machine = machine;
              stable = stableFor machine.system;
              host = machine.host;
              username =  machine.username;
              systemType = machine.systemType;
            };
          }; 
    mkHome = machine:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${machine.system};
        extraSpecialArgs = 
          {
            inherit inputs;
            machine = machine;
            stable = stableFor machine.system;
            host = machine.host;
            username = machine.username;
            systemType = machine.systemType;
          };
    
        modules = [
          ({ ... }: {
            home.username = machine.username;
            home.homeDirectory = "/home/${machine.username}";
            # home.homeDirectory = if machine.username == "root" then "/root" else "/home/${machine.username}"; 
            # home-manager.useGlobalPkgs = true;
            # home-manager.useUserPackages = true;
          })
    
          inputs.multiverse.homeManagerModules.default
          {
            multiverse = {
              enable = true;
              config.allowUnfree = true;
              lock = ./multiverse.lock;
            };
          }
    
          # Put your actual HM module(s) here
          ./${machine.host}/home.nix
        ];
      };
  in
    {
      nixosConfigurations = 
        {
          nix-wsl= mkSystem machines.wsl;
          fern   = mkSystem machines.fern;
          nyx    = mkSystem machines.nyx;
          sakura = mkSystem machines.sakura;
          vultr = mkSystem machines.vultr;
          ino = mkSystem machines.ino;
          annie = mkSystem machines.annie;
        };
      
      homeConfigurations = 
        {
          "${machines.wsl.username}@${machines.wsl.host}" = mkHome machines.wsl;
          "${machines.fern.username}@${machines.fern.host}" = mkHome machines.fern;
          "${machines.nyx.username}@${machines.nyx.host}" = mkHome machines.nyx;
          "${machines.ino.username}@${machines.ino.host}" = mkHome machines.ino;
          "${machines.raven.username}@${machines.raven.host}" = mkHome machines.raven;
        };
    };
}
