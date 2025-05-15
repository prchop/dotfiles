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

;; Load theme forcibly and silently
(load-theme 'gruvbox-dark-soft t)

;; Load evil mode
(setq evil-want-C-u-scroll t)
(require 'evil)
(require 'evil-commentary)
(evil-mode 1)
(evil-commentary-mode)

;;; display-line-numbers-mode
(global-display-line-numbers-mode 0)
(defun my/enable-line-numbers-if-file ()
  "Enable line numbers only for file-visiting buffers."
  (when buffer-file-name
    (display-line-numbers-mode 1)))

(add-hook 'prog-mode-hook #'my/enable-line-numbers-if-file)
(add-hook 'text-mode-hook #'my/enable-line-numbers-if-file)

(global-set-key (kbd "C-c l") 'display-line-numbers-mode)

(setq package-list '(dap-mode))
(dolist (package package-list)
  (unless (package-installed-p package) (package-install package)))

(package-install 'markdown-mode)
(package-install 'typescript-mode)
(package-install 'go-mode)
;;(package-install 'javascript-mode)
(package-install 'tree-sitter-langs)

(setq package-list '(dap-mode typescript-mode go-mode))
(setq package-list '(dap-mode typescript-mode go-mode tree-sitter tree-sitter-langs))

(require 'tree-sitter-langs)
(require 'tree-sitter)
(require 'go-mode)
(require 'markdown-mode)

;; Activate tree-sitter globally (minor mode registered on every buffer)
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
(defun my/disable-tree-sitter-in-go-mode ()
  "Disable tree-sitter and re-enable font-lock in Go mode."
  (when (derived-mode-p 'go-mode)
    (tree-sitter-mode -1)
    (tree-sitter-hl-mode -1)
    ;; Re-enable traditional font-lock
    (font-lock-mode 1)))

(add-hook 'tree-sitter-after-on-hook #'my/disable-tree-sitter-in-go-mode)

(setq package-list '(dap-mode typescript-mode go-mode tree-sitter tree-sitter-langs lsp-mode lsp-ui))
(setq lsp-headerline-breadcrumb-enable nil)
(require 'lsp-mode)
(add-hook 'typescript-mode-hook #'lsp-deferred)
(add-hook 'javascript-mode-hook #'lsp-deferred)
(add-hook 'go-mode-hook #'lsp-deferred)

(with-eval-after-load 'lsp-mode
  (define-key evil-normal-state-map (kbd "K") #'lsp-describe-thing-at-point))

;; Define a function to organize imports using lsp
(defun my/lsp-organize-imports ()
  "Run source.organizeImports code action via LSP."
  (interactive)
  ;; lsp-execute-code-action takes a predicate to filter actions
  (lsp-execute-code-action-by-kind "source.organizeImports"))

;; Bind organize imports to C-c i in go-mode
(with-eval-after-load 'go-mode
  (define-key go-mode-map (kbd "C-c i") #'my/lsp-organize-imports))

(defun my-setup-dap-node ()
  "Require dap-node feature and run dap-node-setup if VSCode module isn't already installed"
  (require 'dap-node)
  (unless (file-exists-p dap-node-debug-path) (dap-node-setup)))

(add-hook 'typescript-mode-hook #'my-setup-dap-node)
(add-hook 'javascript-mode-hook #'my-setup-dap-node)

(add-hook 'go-mode-hook
          (lambda ()
            (require 'dap-go)
            (dap-go-setup)))

;; Load markdown mode
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
;; Load go mode
(autoload 'go-mode "go-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

(require 'vterm)
(defun open-term ()
  "Open `term` with bash in a horizontal split."
  (interactive)
  (split-window-below)                           ;; Create horizontal split
  (other-window 1)                               ;; Move focus to the new window
  (let ((explicit-shell-file-name "/usr/bin/bash"))  ;; Force bash instead of sh
    (vterm explicit-shell-file-name)))

(global-set-key (kbd "C-c '") 'open-term)

(defun evil-markdown-specific ()
  "Remap j/k to gj/gk for screen-line navigation."
  (evil-define-key '(normal visual) (current-local-map)
    (kbd "j") 'evil-next-visual-line
    (kbd "k") 'evil-previous-visual-line))

(add-hook 'markdown-mode-hook #'evil-markdown-specific)

(add-hook 'before-save-hook 'gofmt-before-save)

; go path
(when (display-graphic-p)
  (require 'exec-path-from-shell)
  (setq exec-path-from-shell-variables '("PATH" "GOPATH" "GOROOT" "GOBIN"))
  (exec-path-from-shell-initialize))

(require 'xclip)
(xclip-mode 1)

; (require 'eglot)
; (add-hook 'prog-mode-hook #'eglot-ensure)

; (with-eval-after-load 'eglot
;   (define-key evil-normal-state-map (kbd "K") #'eldoc-doc-buffer))
; (defun my/eglot-organize-imports ()
;   "Run source.organizeImports action via Eglot."
;   (interactive)
;   (eglot-code-actions nil nil "source.organizeImports" t))


; (with-eval-after-load 'go-mode
;   (define-key go-mode-map (kbd "C-c i") #'my/eglot-organize-imports))


;;; .emacs end here
