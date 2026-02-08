{
description = "Unified Flake Config"
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
    pkgs    = nixpkgs.legacyPackages.${system};
    unstable = nixpkgs-unstable.legacyPackages.${system};
    commonSettings = 
      {
        system = "x86_64-linux";
        dotfilesDir = "~/.dotfiles";
        allowUnfree = true;
        editor = "emacs";
        browser = "firefox"
      };
    
    #defining variables for each of my machines
    machines = 
    {
        wsl = commonSettings //  # // is used to merge and pull in shared values
              {
                host = "nixos";
                username = "nixos";
              }; 
        
        fern = commonSettings // 
               {
                 host = "fern";
                 username = "fern";
               };
        
        sakura = (commonSettings // # overriding system when required
                  {
                    system = "aarch64-linux";
                    host = "fern";
                    username = "fern";
                  };)
    }
      
  in
    {
      #config for each host is declared as: nixosConfiguration.<host_name>
      
      #WSL Configuration 
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem
        {
          modules = 
            [
              nixos-wsl.nixosModules.wsl
              home-manager.nixosModules.home-manager
              ./${machines.wsl.}configuration.nix
              extraSpecialArgs = 
                {
                  inherit unstable;
                  inherit machines.wsl;
                }
            ]
        };
      #T490 Setup
      nixosConfigurations.fern = nixpkgs.lib.nixosSystem
        {

        };
    };
}
