{
description = "Unified Flake Config";
inputs = 
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
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
  };
outputs = { self, nixpkgs, nixpkgs-stable, nixos-wsl, home-manager, ... }@inputs: 
  let
    stableFor = system:
      nixpkgs-stable.legacyPackages.${system};
    commonSettings = 
      {
        dotfilesDir = ".dotfiles";
        allowUnfree = true;
        editor = "emacs";
        browser = "firefox";
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

        nyx = commonSettings // 
              {
                system = "x86_64-linux";
                host = "nyx";
                username = "nyx";
                systemType = "nyx";
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
                ({ ... }: {
                  home-manager.extraSpecialArgs = {
                    inherit machine;
                    stable = stableFor machine.system;
                    host = machine.host;
                    username = machine.username;
                    systemType = machine.systemType;
                    machines = machines;
                  };
    
                  home-manager.users.${machine.username} = import ./${machine.host}/home.nix;
                })
    
                ./${machine.host}/configuration.nix
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
        };
      homeConfigurations = 
        {
          "${machines.wsl.username}@${machines.wsl.host}" = mkHome machines.wsl;
          "${machines.fern.username}@${machines.fern.host}" = mkHome machines.fern;
          "${machines.nyx.username}@${machines.nyx.host}" = mkHome machines.nyx;
          "${machines.sakura.username}@${machines.sakura.host}" = mkHome machines.sakura;
        };
    };
}
