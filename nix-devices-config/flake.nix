{
    description = "Nix OS Config";

    inputs = 
    {
        #Defining nixpkgs sources
        nixpkgs.url = "nixpkgs/nixos-25.05";
        nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

        #Defining Home Manager
        home-manager.url = "github:nix-community/home-manager/release-25.05";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs@{self, nixpkgs, nixpkgs-unstable, ...} :
    let 
        lib = nixpkgs.lib;
        
        # Remove the manual pkgs instantiation - let NixOS handle this
        pkgs-unstable = import nixpkgs-unstable
        {
          system = systemSettings.system;
          config = 
          {
            allowUnfree = true;
          };
        };

        home-manager = inputs.home-manager;
        systemSettings = 
        {
          system = "x86_64-linux";
          timezone = "America/Vancouver";
          hostname = "nixos";
          bootMode = "uefi";
          profile = "t490";
          bootMountPath = "/boot";
          defaultLocale = "en_CA.UTF-8";
          gpuType = "intel";
          allowUnfree = true;
          desktopEnvironment = "";
        };

        #ToDo: What is rec keyword 
        userSettings = rec 
        {
          username = "fern";
          name = "fern";
          email = "omangbaheti@gmail.com";
          dotfilesDir = "~/.dotfiles";
          term = "bash";
          browser = "firefox";
          editor = "code";
          spawnEditor = "code";
        };
        
    in 
    {
      homeConfigurations = 
      {
        user = home-manager.lib.homeManagerConfiguration
        {
          pkgs = import nixpkgs {
            system = systemSettings.system;
            config.allowUnfree = systemSettings.allowUnfree;
          };
          modules = 
          [(./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix")];
          extraSpecialArgs = 
          {
            inherit pkgs-unstable;
            inherit systemSettings;
            inherit userSettings;
            inherit inputs;
          };
        };
      };

      nixosConfigurations = 
      {
        nixos = lib.nixosSystem
        {
            system = systemSettings.system;
            modules = 
            [
              # Your main configuration
              (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")
              
              # Nixpkgs configuration module
              {
                nixpkgs = {
                  config = {
                    allowUnfree = systemSettings.allowUnfree;
                  };
                };
              }
            ];
            specialArgs = 
            {
              # Removed 'inherit pkgs;' - this was causing the warning
              inherit pkgs-unstable;
              inherit systemSettings;
              inherit userSettings;
              inherit inputs;
            };
        };
      };
    };
}
