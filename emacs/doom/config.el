;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'gruber-darker)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)
(setq display-line-numbers-width-start t)
;; (setq display-line-numbers-type nil)

(add-to-list 'load-path "~/Repos/github.com/akermu/emacs-libvterm")

;;; change leader key to default vim
(setq doom-leader-key ","
      doom-localleader-key "\\")

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/org/")

;; set font
(setq doom-font (font-spec :family "Iosevka Nerd Font" :size 18))
(setq doom-variable-pitch-font (font-spec :family "Iosevka Nerd Font" :size 18))
(setq doom-big-font (font-spec :family "Iosevka Nerd Font" :size 18))

;; disable save confirm
(setq confirm-kill-emacs nil)

(use-package! nerd-icons
  :custom
  ;; (nerd-icons-font-family  "Iosevka Nerd Font Mono")
  ;; (nerd-icons-scale-factor 2)
  ;; (nerd-icons-default-adjust -.075)
  (doom-modeline-major-mode-icon t))

(require 'ido-completing-read+)
(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(use-package! smex
  :config
  (smex-initialize)
  ;; Force override of M-x globally
  (define-key! global-map
    [remap execute-extended-command] #'smex)
  ;; Optional fallback
  (define-key! global-map
    (kbd "C-c C-c M-x") #'execute-extended-command))

;;(global-set-key (kbd "M-x") 'smex)
;;(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;;This is your old M-x.
;;(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; transparency
;; (unless (display-graphic-p)
;;   (set-face-background 'default "unspecified-bg"))

(add-hook 'doom-init-ui-hook (lambda () (solaire-global-mode -1)))

;; automatically organize imports
(add-hook 'go-mode-hook #'lsp-deferred)
(add-hook 'python-mode-hook #'lsp-deferred)

;; Make sure you don't have other goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(defun lsp-py-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-pyright-organize-imports t t))
(add-hook 'python-mode-hook #'lsp-py-install-save-hooks)

;; enable all analyzers; not done by default
(after! lsp-mode
  (setq  lsp-go-analyses '((nilness . t)
                           (shadow . t)
                           (unusedparams . t)
                           (unusedwrite . t)
                           (useany . t)
                           (unusedvariable . t)))
  )

(defun evil-markdown-specific ()
  "Remap j/k to gj/gk for screen-line navigation."
  (evil-define-key '(normal visual) (current-local-map)
    (kbd "j") 'evil-next-visual-line
    (kbd "k") 'evil-previous-visual-line))

(add-hook 'markdown-mode-hook #'evil-markdown-specific)
(add-hook 'markdown-mode-hook #'enable-wrapping)

(defun enable-wrapping ()
  "Enable both auto fill and visual line modes."
  (visual-line-mode 1))

(add-hook 'markdown-mode-hook #'enable-wrapping)
(add-hook 'org-mode-hook #'enable-wrapping)
(add-hook 'text-mode-hook #'enable-wrapping)
(add-hook 'markdown-mode-hook #'turn-off-smartparens-mode)

(require 'xclip)
(require 'ruff-format)
(xclip-mode 1)
(add-hook 'python-mode-hook 'ruff-format-on-save-mode)

;; keymap
(global-set-key (kbd "C-c l n") 'display-line-numbers-mode)
(global-set-key (kbd "C-c t t") 'solaire-global-mode)

;; thinner window divider
(custom-set-faces!
  '(vertical-border :foreground "#222222")
  '(vertical-border :background "#282828")) ;; Gruvbox dark gray

;; for markdown-mode
(after! markdown-mode
  (custom-set-faces!
    '(markdown-code-face :background nil)))

;; for python
(add-hook 'python-mode-hook
          (lambda ()
            ;; Setting 1:
            (setq indent-tabs-mode nil)))

;; markdown pandoc
(custom-set-variables
 '(markdown-command "/home/prchop/.local/bin/pandoc"))

;; change default split
(setq split-height-threshold nil)
(setq split-width-threshold 0)

;; cursor line
(setq global-hl-line-modes nil)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwiseDoom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
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
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
