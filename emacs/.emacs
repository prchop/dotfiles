;;; Commentary: Set and load custom-file early
(setq custom-file  "~/.emacs.custom.el")
(if (file-exists-p custom-file)
  (load custom-file))

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Disable UI clutter
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(show-paren-mode 1)

;; Frame and display settings
(add-to-list 'default-frame-alist '(font . "Iosevka Nerd Font Medium"))
(setq default-frame-alist '((left . 0) (width . 122) (height . 31)))
(setq fill-column 78)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq make-backup-files nil)
(add-hook 'prog-mode-hook #'hl-line-mode)

;;; display-line-numbers-mode
(global-display-line-numbers-mode 0)
(defun my/enable-line-numbers-if-file ()
  "Enable line numbers only for file-visiting buffers."
  (when buffer-file-name
    (display-line-numbers-mode 1)))

(add-hook 'prog-mode-hook #'my/enable-line-numbers-if-file)
(add-hook 'text-mode-hook #'my/enable-line-numbers-if-file)

;; Load theme forcibly and silently
(load-theme 'gruvbox-dark-soft t)

;; Load evil mode
(setq evil-want-C-u-scroll t)
(require 'evil)
(evil-mode 1)

(require 'markdown-mode)
(require 'go-mode)
(require 'eglot)
;; Load markdown mode
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; Load go mode
(autoload 'go-mode "go-mode" nil t)

(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

(defun open-term ()
  "Open `term` with bash in a horizontal split."
  (interactive)
  (split-window-below)                           ;; Create horizontal split
  (other-window 1)                               ;; Move focus to the new window
  (let ((explicit-shell-file-name "/usr/bin/bash"))  ;; Force bash instead of sh
    (term explicit-shell-file-name)))

(global-set-key (kbd "C-c '") 'open-term)

(defun evil-markdown-specific ()
  "Remap j/k to gj/gk for screen-line navigation."
  (evil-define-key '(normal visual) (current-local-map)
    (kbd "j") 'evil-next-visual-line
    (kbd "k") 'evil-previous-visual-line))

(add-hook 'markdown-mode-hook #'evil-markdown-specific)

(add-hook 'prog-mode-hook #'eglot-ensure)

(with-eval-after-load 'eglot
  (define-key evil-normal-state-map (kbd "K") #'eldoc-doc-buffer))

(defun my/eglot-organize-imports ()
  "Run source.organizeImports action via Eglot."
  (interactive)
  (eglot-code-actions nil nil "source.organizeImports" t))

(with-eval-after-load 'go-mode
  (define-key go-mode-map (kbd "C-c i") #'my/eglot-organize-imports))

(defun my/go-mode-organize-imports-on-save ()
  (add-hook 'before-save-hook #'my/eglot-organize-imports nil t))

(add-hook 'go-mode-hook #'my/go-mode-organize-imports-on-save)

(when (display-graphic-p)
  (require 'exec-path-from-shell)
  (setq exec-path-from-shell-variables '("PATH" "GOPATH" "GOROOT"))
  (exec-path-from-shell-initialize))

(require 'xclip)
(xclip-mode 1)

; (use-package go-mode
;   :ensure t
;   :hook ((go-mode . lsp-deferred)
;          (before-save . gofmt-before-save))
;   :config (setq gofmt-command "goimports"))
;
; (use-package lsp-mode
;   :ensure t
;   :hook (go-mode . lsp-deferred)
;   :commands lsp lsp-deferred)
;
; (use-package lsp-ui
;   :ensure t
;   :commands lsp-ui-mode
;   :hook (lsp-mode . lsp-ui-mode))

; (use-package flycheck
;   :ensure t
;   :init (global-flycheck-mode))

; (autoload 'go-mode "go-mode" nil t)
; (add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

;;; .emacs end here
