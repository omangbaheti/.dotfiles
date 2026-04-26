(setq user-emacs-directory "~/.emacs.d/")  ;; writable path for config
(setq package-user-dir "~/.emacs.d/elpa/") ;; writable path for installed packages
;; (setq evil-want-keybinding nil)
(setq gc-cons-threshold #x40000000)
(setq read-process-output-max (* 1024 1024 4))
;; (org-babel-load-file
;;  (expand-file-name
;;   "~/.dotfiles/emacs/config.org"
;;   user-emacs-directory))
(let* ((config-org (expand-file-name "~/.dotfiles/emacs/config.org"))
       (config-el  (expand-file-name "~/.dotfiles/emacs/config.el")))
  (if (or (not (file-exists-p config-el))
          (file-newer-than-file-p config-org config-el))
      (org-babel-load-file config-org)
    (load-file config-el)))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

