(setq evil-want-keybinding nil)
(setq package-quickstart t)
(setq use-package-always-defer t)
(org-babel-load-file
 (expand-file-name
  "~/.dotfiles/emacs/config.org"
  user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(setq gc-cons-threshold #x40000000)
(setq read-process-output-max (* 1024 1024 4))
