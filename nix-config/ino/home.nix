{ config, pkgs, stable, machine, inputs, ... }:
{
  home.stateVersion = "26.05";
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  programs.home-manager.enable = true;
  programs.zoxide.enable = true;
  programs.git = {
    enable = true;
    settings = {
      user.name = "Omang Baheti";
      user.email = "omangbaheti@gmail.com";
      init.defaultBranch = "main";
      push.default = "simple";
      extraConfig =
        {
          credential.helper = "cache --timeout=28800";
        };
    };
  };
  
  programs.zsh = 
    {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
  
      shellAliases = 
        {
          ll = "eza -l";
          la = "eza -lah --tree --ignore-glob='.git|.venv|node_modules'";
          ls = "eza -h --git --icons --color=auto --group-directories-first -s extension";
          tree = "eza --tree --icons --ignore-glob='.git|.venv|node_modules'";
          grep = "rg";
          find = "fd";
          e="emacsclient -c";
          emd = "emacs --daemon";
          rebuild-config = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix-config#${machine.systemType}";
          rebuild-home-config = "home-manager switch --flake  ~/.dotfiles/nix-config#${machine.username}@${machine.host}";
          exp="/mnt/c/WINDOWS/explorer.exe .";
        };
  
      oh-my-zsh = 
        {
          enable = true;
          plugins = [ "git" "sudo" ];
          theme = "robbyrussell";
        };
    };
  
  
    # Direnv for automatic environment loading
    programs.direnv = 
      {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        
        config = {
          global = {
            log_format = "-";
            log_filter = "^$";
            hide_env_diff = true;
          };
        };
      };
  
  
      services.syncthing = 
      {
          enable = true;
      };
  
  programs.gpg.enable = true;
  
  services.gpg-agent = 
    {
      enable = true;
      pinentry.package = pkgs.pinentry-curses; 
      extraConfig = ''
      default-cache-ttl = 31536000;  # 1 year in seconds
      max-cache-ttl = 31536000;
        allow-loopback-pinentry
      '';
    };
  
  home.file.".pi/agent/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/pi/agent/settings.json";
  home.file.".pi/agent/skills".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/pi/skills";
  home.file.".pi/agent/extensions".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/pi/agent/extensions";
  
  programs.zsh.initContent = 
    ''
eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh)"
eval "$(tirith init --shell zsh)"
eval "$(direnv hook zsh)"
export COLORTERM=truecolor

# Multiverse pins. Functions rather than aliases because they must run from the
# flake directory — mvs writes ./multiverse.lock in the cwd.
function mvs {
  (cd ~/.dotfiles/nix-config && nix run 'github:fzakaria/nixpkgs-multiverse#mvs' -- "$@")
}
function nix-install     { mvs lock add "$@" }
function nix-gui-install { mvs --file multiverse-gui.lock lock add "$@" }
function nix-uninstall   { mvs lock rm "$@" }
function nix-status      { mvs lock status }
# lock update only knows revisions already in the index: nix flake update multiverse first.
function nix-update      { mvs lock update "$@" }
# gui-only lock: mvs never looks past the file it is given, so say which one.
function nix-gui-update  { mvs --file multiverse-gui.lock lock update "$@" }
function nix-gui-uninstall { mvs --file multiverse-gui.lock lock rm "$@" }
function nix-gui-status  { mvs --file multiverse-gui.lock lock status }
    '';
  nixpkgs.config.allowUnfree = true;
  
  home.packages = (with pkgs;
    [
    ]);

  services.emacs = {
    enable = true;
  };
  
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    # extraConfig = builtins.readFile /home/nixos/.dotfiles/emacs/init.el;
    extraPackages = (
      epkgs: with pkgs.emacsPackages;   
        [ 
          vterm 
          zmq 
          treesit-auto
          treesit-grammars.with-all-grammars
          pdf-tools
        ]
          
    );
  };
  
  home.sessionVariables = 
    {
      EMACSLOADINIT = "~/.dotfiles/emacs/init.el";
      EDITOR = machine.editor;
      BROWSER = machine.browser;
      LOMBOK_JAR = "${pkgs.lombok}/share/java/lombok.jar";
    };
  
  home.file.".emacs.d/early-init.el".source = ../../emacs/early-init.el;
  home.file.".emacs.d/init.el".source = ../../emacs/init.el;
}
