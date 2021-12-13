;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Fira Code" :size 16) ;; :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "sans" :size 16))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-laserwave)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Set path to zsh configuration
(let ((path (shell-command-to-string ". $HOME/.zshrc; echo -n $PATH")))
  (setenv "PATH" path)
  (setq exec-path
        (append
         (split-string-and-unquote path ":")
         exec-path)))

;; Automatically start lsp and smartparens
(defun run-custom-hooks (fill)
  (lsp 1)
  (smartparens-mode 1)
  (setq-default fill-column fill)
  (auto-fill-mode 1)
  )

(defun run-tex-hooks ()
  (setq-default fill-column 60)
  (auto-fill-mode 1)
  (flyspell-mode 1)
  )

(add-hook 'c-mode-hook (lambda() (run-custom-hooks 100)))
(add-hook 'c++-mode-hook (lambda() (run-custom-hooks 100)))
(add-hook 'python-mode-hook (lambda() (run-custom-hooks 80)))

(add-hook 'LaTeX-mode-hook 'run-tex-hooks)

;; open pdf file with evince when using org-mode
(add-hook 'org-mode-hook
          '(lambda ()
             (delete '("\\.pdf\\" . default) org-file-apps)
             (add-to-list 'org-file-apps '("\\.pdf\\'" . "evince %s"))))

;; doom emacs uses 'better-jumper', however 'xref-go-back' is better
(map! [remap xref-go-back] nil)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flyspell-incorrect ((t (:background "red" :underline nil)))))

;; Key bindings for olivetti and focus
(map! :leader
      (:prefix "t"
        :desc "Olivetti" "o" #'olivetti-mode
        :desc "Focus" "c" #'focus-mode
        ))
