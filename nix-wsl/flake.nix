{
  description = "WSL Flake config";

  inputs = 
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixos-wsl = 
        {
          url = "github:nix-community/NixOS-WSL";
          inputs.nixpkgs.follows = "nixpkgs";
        };

      home-manager = 
        {
          url = "github:nix-community/home-manager/release-25.05";
          inputs.nixpkgs.follows = "nixpkgs";
        };
    };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-wsl, home-manager, ... }@inputs: 
    let
        system = "x86_64-linux";
        pkgs    = nixpkgs.legacyPackages.${system};
        unstable = nixpkgs-unstable.legacyPackages.${system};
    in
      {
        nixosConfigurations = 
          {
            nixos = nixpkgs.lib.nixosSystem 
              {
                inherit system;
                specialArgs = { inherit unstable; };
                modules = 
                  [
                    nixos-wsl.nixosModules.wsl
                    home-manager.nixosModules.home-manager
                    ./configuration.nix
                    {
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;
                      home-manager.extraSpecialArgs = { inherit unstable; };
                      home-manager.users.nixos = import ./home.nix;
                      system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
                    }
                  ];
              };
          };
      };
}

