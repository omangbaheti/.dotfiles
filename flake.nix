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
        pkgs = nixpkgs;
        home-manager = inputs.home-manager;
        systemSettings = 
        {
          system = "x86_64-linux";
          timezone = "America/Vancouver";
          bootMode = "uefi";
          profile = "t490";
          bootMountPath = "/boot";
          defaultLocale = "en_CA.UTF-8";
          gpuType = "intel";
          allowUnfree = true;
        };

        #ToDo: What is rec keyword 
        userSettings = rec 
        {
          username = "Fern";
          name = "Omang";
          email = "omangbaheti@gmail.com";
          dotfilesDir = "~/.dotfiles";
          browser = "firefox";
        };
        
    in 
    {
      homeConfigurations = 
      {
        user = home-manager.lib.homeManagerConfiguration
        {
          inherit pkgs;
          modules = 
          [("~/.dotfiles/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")];
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
            modules = 
            [("~/.dotfiles/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")];
        };
      };
    };
}