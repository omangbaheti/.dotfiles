(setq inhibit-startup-message t)
(push '(background-color . "#2E3440") default-frame-alist)
(setq initial-scratch-message nil)
(tool-bar-mode -1)                 ; disable toolbar
(tooltip-mode -1)                  ; disable tooltips
(scroll-bar-mode -1)               ; disable scrollbar
(menu-bar-mode -1)                 ; disable menubar
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq gc-cons-threshold most-positive-fixnum)
(setq package-enable-at-startup nil)
