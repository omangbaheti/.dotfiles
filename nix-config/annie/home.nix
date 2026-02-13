{ config, lib, pkgs, machine, ... }:

{
  # Read the changelog before changing this value
  home.stateVersion = "24.05";
  
  programs.zsh = 
    {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions  = true;
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
          rebuild-config = "nix-on-droid switch --flake ~/.dotfiles/nix-config#${machine.systemType}";
          rebuild-home-config = "home-manager switch --flake  ~/.dotfiles/nix-config#${machine.username}@${machine.host}";
        };

      oh-my-zsh = 
        {
          enable = true;
          plugins = [ "git" "sudo" ];
          theme = "robbyrussell";
        };
    };
  
  programs.zsh.initExtra = 
    ''
eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh)"
eval "$(tirith init --shell zsh)"
eval "$(direnv hook zsh)"
    '';
  # insert home-manager config
}
