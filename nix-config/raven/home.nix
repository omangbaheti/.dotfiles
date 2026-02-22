{ config, pkgs, stable, machine, ... }:
{
  home.stateVersion = "26.05";
  
  programs.home-manager.enable = true;
  programs.zoxide.enable = true;
  programs.git = 
    {
      enable = true;
      settings = {
        user.name = "Omang Baheti";
        user.email = "omangbaheti@gmail.com";
        init.defaultBranch = "main";
        push.default = "simple";
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
          #          e="emacsclient -c";
          emd = "emacs --daemon";
          rebuild-config = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix-config#${machine.systemType}";
          rebuild-home-config = "home-manager switch --flake  ~/.dotfiles/nix-config#${machine.username}@${machine.host}";
        };

      oh-my-zsh = 
        {
          enable = true;
        };
    };

  services.syncthing = 
    {
      enable = true;
    };

  home.packages = (with pkgs;
    [
      git
      git-lfs
      lazygit
      wiper
      zoxide
      fzf
      vim 
      zsh
      oh-my-posh
      tealdeer
      btop
      fd
      eza
      devenv
      nix-direnv
      yazi
      diff-so-fancy
      fastfetch
      openssh
      ripgrep
      poetry
      pandoc
      emacs-nox
      tirith
      android-tools
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ]);
  programs.zsh.initContent = 
    ''
 eval "$(zoxide init zsh)"
 eval "$(oh-my-posh init zsh)"
 eval "$(tirith init --shell zsh)"
 eval "$(direnv hook zsh)"
    '';
}
