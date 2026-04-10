(setq user-emacs-directory "~/.emacs.d/")  ;; writable path for config
(setq package-user-dir "~/.emacs.d/elpa/") ;; writable path for installed packages
;; (setq package-enable-at-startup nil)
(setq evil-want-keybinding nil)
(setq gc-cons-threshold #x40000000)
(setq read-process-output-max (* 1024 1024 4))
(org-babel-load-file
 (expand-file-name
  "~/.dotfiles/emacs/config.org"
  user-emacs-directory))
