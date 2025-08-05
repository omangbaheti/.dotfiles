;;(setq debug-on-error t)
(setq warning-minimum-level :error)
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))


;; Install use-package support

(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

(setq evil-want-keybinding nil)
;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
  :init
  (setq evil-want-keybinging nil)
  (setq evil-want-integration t)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-search-module 'evil-search)
  (evil-mode))

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))
(use-package evil-tutor)

(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))
  
  ;;setting RETURN key in org-mode to follow links
  (setq org-return-follows-link t)

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause evaluate the declaration immediately. It is not deferred.
;;Useful for configuring built-in emacs features.
(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))

(use-package general
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer leader-key
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode
  (setq evil-want-keybinding nil)
  (leader-key
    "SPC" '(consult-mode-command :wk "Consult M-X")
    "." '(find-file :wk "Find file")
    "f c" '((lambda () (interactive) (find-file "~/.dotfiles/emacs/config.org")) :wk "Edit emacs config")
    "f r" '(consult-recent-file :wk "Find Recent Files")
    "f /" '(consult-line :wk "Find Line")
    "TAB TAB" '(comment-line :wk "Comment lines"))

  (leader-key
    "b" '(:ignore t :wk "buffer")
    "b b" '(consult-buffer :wk "Switch buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-this-buffer :wk "Kill this buffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer"))
  
  (leader-key
    "e" '(:ignore t :wk "Evaluate")
    "e b" '(eval-buffer :wk "Evaluate the elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate elisp expression")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expressions before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    ;;"e h" '(counsel-esh-history :which-key "Eshell History")
    "e s" '(eshell :which-key "Eshell"))
  
  (leader-key
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (leader-key
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (leader-key
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))
  
  (leader-key
    "p" '(projectile-command-map :wk "Projectile"))
  
  (leader-key
    "t n" '(neotree-toggle :wk "Toggle neotree file viewer")) 
  
  (leader-key
    "h" '(:ignore t :wk "Help")
    "h p" '(describe-package :wk "Describe Package")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe Variable")
    "h r r" '((lambda() (interactive) (load-file "~/.dotfiles/emacs/init.el") (ignore (elpaca-process-queues))) :wk "Reload emacs config"))
    ;;"h r r" '((lambda() (interactive) (load-file "~/.dotfiles/emacs/init.el")) :wk "reload emacs config"))
  (leader-key
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(visual-line-mode :wk "Toggle truncated lines"))

  (leader-key
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window Left")
    "w j" '(evil-window-down :wk "Window Down")
    "w k" '(evil-window-up :wk "Window Up")
    "w l" '(evil-window-right :wk "Window Right")
    "w w" '(evil-window-next :wk "Goto Next Window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer Move Left")
    "w J" '(buf-move-down :wk "Buffer Move Down")
    "w K" '(buf-move-up :wk "Buffer Move Up")
    "w L" '(buf-move-right :wk "Buffer Move Right")))

(defun keyboard-quit-dwim ()
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(define-key global-map (kbd "C-g") #'keyboard-quit-dwim)

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
  ;;  "Switches between the current buffer, and the buffer above the
  ;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
  "Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
  "Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
  "Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;; Setting the default font
(set-face-attribute 'default nil
		    :font "JetBrainsMono Nerd Font"
		    :height 110
		    :weight 'medium)
;; Setting font for variable pitch
(set-face-attribute 'variable-pitch nil
                    :family (or (car (seq-filter
                                      (lambda (f) (member f (font-family-list)))
                                      '("Ubuntu" "DejaVu Sans" "Arial")))
                                "Sans")
                    :height 140)
;;Setting font for fixed pitch
(set-face-attribute 'fixed-pitch nil
		    :font "JetBrainsMono Nerd Font"
		    :height 110
		    :weight 'medium)

;; Makes commented text and keywords  italics
(set-face-attribute 'font-lock-comment-face nil
		    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
		    :slant 'italic)

(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font-11"))
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(scroll-bar-mode -1)               ; disable scrollbar
(tool-bar-mode -1)                 ; disable toolbar
(tooltip-mode -1)                  ; disable tooltips
(set-fringe-mode 10)               ; give some breathing room
(menu-bar-mode -1)                 ; disable menubar
(blink-cursor-mode 0)              ; disable blinking cursor

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(setq backup-directory-alist '((".*" . "~/.local/share/Trash/files")))

(global-set-key [escape] 'keyboard-escape-quit)

(delete-selection-mode 1)
(electric-indent-mode -1)
(electric-pair-mode 1)
(setq org-edit-src-content-indentation 0)

;;(use-package beacon
  ;;:ensure t (:files (:defaults) :build nil)  ;; disables native compilation
  ;;:init
  ;;(setq beacon-blink-duration 0.05      ;; Optional: Customize blink duration
        ;;beacon-color "#ff9da4")        ;; Optional: Customize the blink color
  ;;:config
  ;;(beacon-mode 1))                     ;; Enable beacon globallybeacon-mode 1)

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(require 'org-tempo)

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  ;; Customize as needed
  (modify-all-frames-parameters
   '((right-divider-width . 0)
     (internal-border-width . 0)))
  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'fringe (face-attribute 'default :background))
  (setq org-modern-star '("◉" "○" "✸" "✿")
        org-modern-table t 
        org-modern-checkbox '((?X . "") (?- . "❍") (\s . "☐"))
        org-modern-block-fringe t))



(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)  ;; Acknowledge v2 upgrade prompt
  :custom
  (org-roam-directory (file-truename "~/org-roam"))  ;; Set your notes directory
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture))
  :config
  (org-roam-db-autosync-enable))

(use-package org-roam-ui
    :after org-roam
    :hook (after-init . org-roam-ui-mode)
    :custom
    (org-roam-ui-sync-theme t)
    (org-roam-ui-follow t)
    (org-roam-ui-update-on-save t)
    (org-roam-ui-open-on-start nil))

(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit nil 
        which-key-separator " → " ))

(use-package sudo-edit
  :config 
  (leader-key
    "fu" '(sudo-edit-find-file :wk "Sudo find file")
    "fU" '(sudo-edit :wk "Sudo Edit File")))

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package vertico
  :ensure t
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  (setq vertico-count 10)

  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t
        ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
        vertico-cycle t))

(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :ensure t
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the package.
  (marginalia-mode))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides nil))

(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :bind (:map corfu-map ("<tab>" . corfu-complete))
  :config
  (setq tab-always-indent 'complete)
  (setq corfu-preview-current nil)
  (setq corfu-min-width 20)

  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1) ; shows documentation after `corfu-popupinfo-delay'

  ;; Sort by input history (no need to modify `corfu-sort-function').
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

(use-package consult

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (setq consult-buffer-sources '(consult--source-buffer))
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"
  
  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
)

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

;;eshell-syntax-highlighting -- adds zsh-like syntax highlighting
;;eshell-rc-script -- your profile for eshell similar to .zshrc
;;eshell-aliases-file -- sets aliases file for the eshell

(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
:ensure t
:config
(setq vterm-shell (or (executable-find "zsh") "/bin/zsh"))
(setq vterm-max-scrollback 5000)
:hook ((vterm-mode . (lambda () (display-line-numbers-mode 0)))))

(use-package doom-themes
  :ensure t
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; for treemacs users
  (doom-themes-treemacs-theme "doom-nord") ; use "doom-colors" for less minimal icon theme
  :config
  (load-theme 'doom-nord-aurora t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (nerd-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))
;; If non-nil, cause imenu to see `doom-modeline' declarations.
;; This is done by adjusting `lisp-imenu-generic-expression' to
;; include support for finding `doom-modeline-def-*' forms.
;; Must be set before loading doom-modeline.
(setq doom-modeline-support-imenu t)

;; How tall the mode-line should be. It's only respected in GUI.
;; If the actual char height is larger, it respects the actual height.
(setq doom-modeline-height 25)

;; How wide the mode-line bar should be. It's only respected in GUI.
(setq doom-modeline-bar-width 4)

;; Whether to use hud instead of default bar. It's only respected in GUI.
(setq doom-modeline-hud nil)

;; The limit of the window width.
;; If `window-width' is smaller than the limit, some information won't be
;; displayed. It can be an integer or a float number. `nil' means no limit."
(setq doom-modeline-window-width-limit 85)

;; Override attributes of the face used for padding.
;; If the space character is very thin in the modeline, for example if a
;; variable pitch font is used there, then segments may appear unusually close.
;; To use the space character from the `fixed-pitch' font family instead, set
;; this variable to `(list :family (face-attribute 'fixed-pitch :family))'.
(setq doom-modeline-spc-face-overrides nil)

;; How to detect the project root.
;; nil means to use `default-directory'.
;; The project management packages have some issues on detecting project root.
;; e.g. `projectile' doesn't handle symlink folders well, while `project' is unable
;; to hanle sub-projects.
;; You can specify one if you encounter the issue.
(setq doom-modeline-project-detection 'auto)

;; Determines the style used by `doom-modeline-buffer-file-name'.
;;
;; Given ~/Projects/FOSS/emacs/lisp/comint.el
;;   auto => emacs/l/comint.el (in a project) or comint.el
;;   truncate-upto-project => ~/P/F/emacs/lisp/comint.el
;;   truncate-from-project => ~/Projects/FOSS/emacs/l/comint.el
;;   truncate-with-project => emacs/l/comint.el
;;   truncate-except-project => ~/P/F/emacs/l/comint.el
;;   truncate-upto-root => ~/P/F/e/lisp/comint.el
;;   truncate-all => ~/P/F/e/l/comint.el
;;   truncate-nil => ~/Projects/FOSS/emacs/lisp/comint.el
;;   relative-from-project => emacs/lisp/comint.el
;;   relative-to-project => lisp/comint.el
;;   file-name => comint.el
;;   file-name-with-project => FOSS|comint.el
;;   buffer-name => comint.el<2> (uniquify buffer name)
;;
;; If you are experiencing the laggy issue, especially while editing remote files
;; with tramp, please try `file-name' style.
;; Please refer to https://github.com/bbatsov/projectile/issues/657.
(setq doom-modeline-buffer-file-name-style 'auto)

;; Whether display icons in the mode-line.
;; While using the server mode in GUI, should set the value explicitly.
(setq doom-modeline-icon t)

;; Whether display the icon for `major-mode'. It respects option `doom-modeline-icon'.
(setq doom-modeline-major-mode-icon t)

;; Whether display the colorful icon for `major-mode'.
;; It respects `nerd-icons-color-icons'.
(setq doom-modeline-major-mode-color-icon t)

;; Whether display the icon for the buffer state. It respects option `doom-modeline-icon'.
(setq doom-modeline-buffer-state-icon t)

;; Whether display the modification icon for the buffer.
;; It respects option `doom-modeline-icon' and option `doom-modeline-buffer-state-icon'.
(setq doom-modeline-buffer-modification-icon t)

;; Whether display the lsp icon. It respects option `doom-modeline-icon'.
(setq doom-modeline-lsp-icon t)

;; Whether display the time icon. It respects option `doom-modeline-icon'.
(setq doom-modeline-time-icon t)

;; Whether display the live icons of time.
;; It respects option `doom-modeline-icon' and option `doom-modeline-time-icon'.
(setq doom-modeline-time-live-icon t)

;; Whether to use an analogue clock svg as the live time icon.
;; It respects options `doom-modeline-icon', `doom-modeline-time-icon', and `doom-modeline-time-live-icon'.
(setq doom-modeline-time-analogue-clock t)

;; The scaling factor used when drawing the analogue clock.
(setq doom-modeline-time-clock-size 0.7)

;; Whether to use unicode as a fallback (instead of ASCII) when not using icons.
(setq doom-modeline-unicode-fallback nil)

;; Whether display the buffer name.
(setq doom-modeline-buffer-name t)

;; Whether highlight the modified buffer name.
(setq doom-modeline-highlight-modified-buffer-name t)

;; When non-nil, mode line displays column numbers zero-based.
;; See `column-number-indicator-zero-based'.
(setq doom-modeline-column-zero-based t)

;; Specification of \"percentage offset\" of window through buffer.
;; See `mode-line-percent-position'.
(setq doom-modeline-percent-position '(-3 "%p"))

;; Format used to display line numbers in the mode line.
;; See `mode-line-position-line-format'.
(setq doom-modeline-position-line-format '("%l"))

;; Format used to display column numbers in the mode line.
;; See `mode-line-position-column-format'.
(setq doom-modeline-position-column-format '("C%c"))

;; Format used to display combined line/column numbers in the mode line. See `mode-line-position-column-line-format'.
(setq doom-modeline-position-column-line-format '("%l:%c"))

;; Whether display the minor modes in the mode-line.
(setq doom-modeline-minor-modes nil)

;; If non-nil, a word count will be added to the selection-info modeline segment.
(setq doom-modeline-enable-word-count nil)

;; Major modes in which to display word count continuously.
;; Also applies to any derived modes. Respects `doom-modeline-enable-word-count'.
;; If it brings the sluggish issue, disable `doom-modeline-enable-word-count' or
;; remove the modes from `doom-modeline-continuous-word-count-modes'.
(setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))

;; Whether display the buffer encoding.
(setq doom-modeline-buffer-encoding t)

;; Whether display the indentation information.
(setq doom-modeline-indent-info nil)

;; Whether display the total line number。
(setq doom-modeline-total-line-number nil)

;; Whether display the icon of vcs segment. It respects option `doom-modeline-icon'."
(setq doom-modeline-vcs-icon t)

;; The maximum displayed length of the branch name of version control.
(setq doom-modeline-vcs-max-length 15)

;; The function to display the branch name.
(setq doom-modeline-vcs-display-function #'doom-modeline-vcs-name)

;; Alist mapping VCS states to their corresponding faces.
;; See `vc-state' for possible values of the state.
;; For states not explicitly listed, the `doom-modeline-vcs-default' face is used.
(setq doom-modeline-vcs-state-faces-alist
      '((needs-update . (doom-modeline-warning bold))
        (removed . (doom-modeline-urgent bold))
        (conflict . (doom-modeline-urgent bold))
        (unregistered . (doom-modeline-urgent bold))))

;; Whether display the icon of check segment. It respects option `doom-modeline-icon'.
(setq doom-modeline-check-icon t)

;; If non-nil, only display one number for check information if applicable.
(setq doom-modeline-check-simple-format nil)

;; The maximum number displayed for notifications.
(setq doom-modeline-number-limit 99)

;; Whether display the project name. Non-nil to display in the mode-line.
(setq doom-modeline-project-name t)

;; Whether display the workspace name. Non-nil to display in the mode-line.
(setq doom-modeline-workspace-name t)

;; Whether display the perspective name. Non-nil to display in the mode-line.
(setq doom-modeline-persp-name t)

;; If non nil the default perspective name is displayed in the mode-line.
(setq doom-modeline-display-default-persp-name nil)

;; If non nil the perspective name is displayed alongside a folder icon.
(setq doom-modeline-persp-icon t)

;; Whether display the `lsp' state. Non-nil to display in the mode-line.
(setq doom-modeline-lsp t)

;; Whether display the GitHub notifications. It requires `ghub' package.
(setq doom-modeline-github nil)

;; The interval of checking GitHub.
(setq doom-modeline-github-interval (* 30 60))

;; Whether display the modal state.
;; Including `evil', `overwrite', `god', `ryo' and `xah-fly-keys', etc.
(setq doom-modeline-modal t)

;; Whether display the modal state icon.
;; Including `evil', `overwrite', `god', `ryo' and `xah-fly-keys', etc.
(setq doom-modeline-modal-icon t)

;; Whether display the modern icons for modals.
(setq doom-modeline-modal-modern-icon t)

;; When non-nil, always show the register name when recording an evil macro.
(setq doom-modeline-always-show-macro-register nil)

;; Whether display the gnus notifications.
(setq doom-modeline-gnus t)

;; Whether gnus should automatically be updated and how often (set to 0 or smaller than 0 to disable)
(setq doom-modeline-gnus-timer 2)

;; Wheter groups should be excludede when gnus automatically being updated.
(setq doom-modeline-gnus-excluded-groups '("dummy.group"))

;; Whether display the IRC notifications. It requires `circe' or `erc' package.
(setq doom-modeline-irc t)

;; Function to stylize the irc buffer names.
(setq doom-modeline-irc-stylize 'identity)

;; Whether display the battery status. It respects `display-battery-mode'.
(setq doom-modeline-battery t)

;; Whether display the time. It respects `display-time-mode'.
(setq doom-modeline-time t)

;; Whether display the misc segment on all mode lines.
;; If nil, display only if the mode line is active.
(setq doom-modeline-display-misc-in-all-mode-lines t)

;; The function to handle `buffer-file-name'.
(setq doom-modeline-buffer-file-name-function #'identity)

;; The function to handle `buffer-file-truename'.
(setq doom-modeline-buffer-file-truename-function #'identity)

;; Whether display the environment version.
(setq doom-modeline-env-version t)
;; Or for individual languages
(setq doom-modeline-env-enable-python t)
(setq doom-modeline-env-enable-ruby t)
(setq doom-modeline-env-enable-perl t)
(setq doom-modeline-env-enable-go t)
(setq doom-modeline-env-enable-elixir t)
(setq doom-modeline-env-enable-rust t)

;; Change the executables to use for the language version string
(setq doom-modeline-env-python-executable "python") ; or `python-shell-interpreter'
;;(setq doom-modeline-env-ruby-executable "ruby")
;;(setq doom-modeline-env-perl-executable "perl")
;;(setq doom-modeline-env-go-executable "go")
;;(setq doom-modeline-env-elixir-executable "iex")
;;(setq doom-modeline-env-rust-executable "rustc")

;; What to display as the version while a new one is being loaded
(setq doom-modeline-env-load-string "...")

;; By default, almost all segments are displayed only in the active window. To
;; display such segments in all windows, specify e.g.

;; Hooks that run before/after the modeline version string is updated
(setq doom-modeline-before-update-env-hook nil)
(setq doom-modeline-after-update-env-hook nil)

(use-package dirvish
  :after evil
  :init (dirvish-override-dired-mode)
  :config (evil-define-key 'normal dirvish-mode-map (kbd "TAB") 'dirvish-subtree-toggle))

(use-package neotree
 :config
 (setq neo-smart-open t
       neo-show-hidden-files t
       neo-window-width 55
       neo-window-fixed-size nil
       inhibit-compacting-font-caches t
       projectile-switch-project-action 'neotree-projectile-action) 
       ;; truncate long file names in neotree
       (add-hook 'neo-after-create-hook
          #'(lambda (_)
              (with-current-buffer (get-buffer neo-buffer-name)
                (setq truncate-lines t)
                (setq word-wrap nil)
                (make-local-variable 'auto-hscroll-mode)
                (setq auto-hscroll-mode nil)))))

(use-package flycheck
  :ensure t
  :config (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package company
  :defer 2
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode)
  (setq treesit-language-source-alist
        '((javascript "https://github.com/tree-sitter/tree-sitter-javascript"))))

(use-package lsp-mode
  :init
  (setq lsp-auto-guess-root nil) 
  :hook 
  (csharp-mode . lsp-deferred)
  (python-mode . lsp-deferred)
  ;;(emacs-lisp-mode . lsp-deferred)
  (nix-mode . lsp-deferred)
  :config
  (lsp-enable-which-key-integration t)
  :commands (lsp lsp-deferred))

(use-package nix-mode
  :mode "\\.nix\\'")

;;lsp ui extensions
(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

;; ivy integrations for lsp mode
;; (use-package lsp-ivy)

(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(use-package projectile
  :config
  (projectile-mode -1))

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-startup-banner "~/.dotfiles/emacs/NixOS.png")  ;; use custom image as banner
  (setq dashboard-image-banner-max-height 200)
  (setq dashboard-image-banner-max-width 200)
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
			  ;;Why is this throwing an error??
                          ;; (projects . 3)
                          (registers . 3)))
  
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

;; (use-package jupyter
;;   :ensure (:host github :repo "emacs-jupyter/jupyter")
;;   :defer t
;;   :config
;;   ;; (add-to-list 'org-babel-load-languages '(jupyter . t))
  
;;   ;; (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
  
;;   (org-babel-do-load-languages
;;    'org-babel-load-languages
;;    '((emacs-lisp . t)
;;      (julia . t)
;;      (python . t)
;;      (jupyter . t)))
;;   ;; Generate kernel aliases from available kernelspecs
;;   (org-babel-jupyter-aliases-from-kernelspecs)

;;   (setq org-confirm-babel-evaluate nil)
;;   (setq org-babel-default-header-args:jupyter-python '((:async . "yes")
;; 						       (:session . "py")
;; 						       (:kernel . "python3")
;; 						       (:tangle . "jupyter-python/tangled.py")
;; 						       (:exports . "both"))))

(use-package jupyter
  :ensure t
  :after org
  :config
  ;; Enable Jupyter support in Org Babel
  (with-eval-after-load 'org
    (add-to-list 'org-babel-load-languages '(jupyter . t))
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (python . t)  ;; Optional: fallback to ob-python
       (shell . t)
       (jupyter . t)))

    ;; Don't ask for confirmation before evaluating
    (setq org-confirm-babel-evaluate nil)

    ;; Code block editing quality-of-life
    (setq org-src-fontify-natively t
          org-src-tab-acts-natively t
          org-src-preserve-indentation t)

    ;; Show images after executing a block (e.g., matplotlib inline)
    (add-hook 'org-babel-after-execute-hook #'org-display-inline-images)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package auctex
  :defer t
  :config
  ;; Basic AUCTeX settings
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-master nil)
  
  ;; Academic writing specific settings
  (setq LaTeX-babel-hyphen nil) ; Prevent issues with academic citations
  (setq LaTeX-electric-left-right-brace t)
  (setq TeX-electric-escape t)
  
  ;; Preview settings for academic documents
  (setq preview-scale-function 1.2)
  (setq preview-default-option-list '("displaymath" "floats" "graphics" "textmath" "sections" "footnotes"))
  
  ;; Enable folding for large academic documents
  (add-hook 'LaTeX-mode-hook 'TeX-fold-mode)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (add-hook 'LaTeX-mode-hook 'flyspell-mode))



(use-package citar
  :bind (("C-c b" . citar-insert-citation)
         :map minibuffer-local-map
         ("M-b" . citar-insert-preset))
  :custom
  ;; Point to your bibliography files
  (citar-bibliography '("~/Documents/references.bib" "~/Documents/additional-refs.bib"))
  
  ;; PDF and note directories for academic papers
  (citar-library-paths '("~/Documents/papers/" "~/Documents/pdfs/"))
  (citar-notes-paths '("~/Documents/notes/"))
  
  ;; Academic citation formats
  (citar-at-point-function 'embark-act)
  
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup))

;; Enhanced bibliography completion
(use-package citar-embark
  :after citar embark
  :config (citar-embark-mode))

;; Word count for academic papers
(use-package wc-mode
  :hook (LaTeX-mode . wc-mode)
  :config
  (setq wc-modeline-format "WC[%tw/%tcw]"))

;; Academic spell checking
(use-package flyspell
  :hook ((LaTeX-mode . flyspell-mode)
         (org-mode . flyspell-mode))
  :config
  ;; Use aspell for better academic vocabulary
  (setq ispell-program-name "aspell")
  (setq ispell-dictionary "en_US")
  
  ;; Academic-specific word list
  (setq ispell-personal-dictionary "~/.config/emacs/academic-dict.txt"))

;; Grammar checking with langtool
(use-package langtool
  :bind ("C-c g" . langtool-check)
  :config
  (setq langtool-language-tool-jar "~/LanguageTool/languagetool-commandline.jar")
  (setq langtool-default-language "en-US"))
