{
description = "Unified Flake Config";
inputs = 
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    
    nixos-wsl = 
      {
        url = "github:nix-community/NixOS-WSL";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    
    home-manager = 
      {
        url = "github:nix-community/home-manager/master";
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
  };
outputs = { self, nixpkgs, nixpkgs-stable, nixos-wsl, home-manager, lanzaboote, freesmlauncher, nixarr, ... }@inputs: 
  let
    # stableFor = system:
    #   nixpkgs-stable.legacyPackages.${system};
    stableFor = system:
      import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    commonSettings = 
      {
        dotfilesDir = ".dotfiles";
        allowUnfree = true;
        editor = "emacsclient -c -a";
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
                    home-manager.users.${machine.username} = import ./${machine.host}/home.nix;
                  })
                lanzaboote.nixosModules.lanzaboote  
                ./${machine.host}/configuration.nix
                nixarr.nixosModules.default 
              ];
    
            specialArgs = {
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
            # home.homeDirectory = "/home/${machine.username}";
            home.homeDirectory = if machine.username == "root" then "/root" else "/home/${machine.username}"; 
            # home-manager.useGlobalPkgs = true;
            # home-manager.useUserPackages = true;
          })
    
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
          "${machines.annie.username}@${machines.annie.host}" = mkHome machines.annie;
          "${machines.vultr.username}@${machines.vultr.host}" = mkHome machines.vultr;
          "${machines.ino.username}@${machines.ino.host}" = mkHome machines.ino;
          "${machines.sakura.username}@${machines.sakura.host}" = mkHome machines.sakura;
          "${machines.raven.username}@${machines.raven.host}" = mkHome machines.raven;
        };
    };
}
