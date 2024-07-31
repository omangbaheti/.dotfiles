{
    description = "Nix OS Config";

    inputs = 
    {
        #Defining nixpkgs sources
        nixpkgs.url = "nixpkgs/nixos-24.05";
        nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

        #Defining Home Manager
        home-manager.url = "github:nix-community/home-manager/release-24.05";
    };

    outputs = inputs@{self, nixpkgs, ...} :
    let 
        lib  = nixpkgs.lib;
        pkgs = import nixpkgs
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
          inherit pkgs;
          modules = 
          [(./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix")];
          extraSpecialArgs = 
          {
            inherit pkgs;
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
            modules = #[./configuration.nix];
              [(./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")];
            specialArgs = 
            {
              inherit pkgs;
              inherit systemSettings;
              inherit userSettings;
              inherit inputs;
            };
        };
      };
    };
}
