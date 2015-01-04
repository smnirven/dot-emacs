;; NOTE: This requires emacs 24
;; See: https://github.com/technomancy/emacs-starter-kit
;; HOW: symlink your .emacs.d directory to this project directory

(add-to-list 'exec-path "/Users/smnirven/bin")

;; load up a custom user init
(load-file (concat "~/" (user-login-name) ".el"))

;; (add-to-list 'load-path
;;              (concat (file-name-directory load-file-name) "auto-complete-1.3.1/"))

(set-default-font "-adobe-courier-medium-r-normal--16-180-75-75-m-110-iso8859-1")

;; show line nums
(global-linum-mode 1)

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(add-to-list 'package-pinned-packages '(cider . "melpa-stable") t)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages
  '(starter-kit
    maxframe
    clojure-mode
    color-theme
    cider
    elscreen
    midje-mode
    rainbow-delimiters
    find-file-in-project
    smex)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(elscreen-start)
(global-set-key (kbd "s-[") 'elscreen-previous)
(global-set-key (kbd "s-]") 'elscreen-next)
(global-set-key (kbd "s-k") 'elscreen-kill)
(global-set-key (kbd "s-n") 'elscreen-clone)

;;(require 'auto-complete)

;; (require 'auto-complete-config)
;; ;;(add-to-list 'ac-dictionary-directories "~/.emacs.d/dict")
;; (ac-config-default)

;; maxframe
;;(add-hook 'window-setup-hook 'maximize-frame t)

;; formats a clojure function doc string while keeping the binding
;;vector on a new line.
;;clojure-fill-docstring

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (sanityinc-solarized-dark)))
 '(custom-safe-themes
   (quote
    ("4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "fc2782b33667eb932e4ffe9dac475f898bf7c656f8ba60e2276704fabb7fa63b" default)))
 '(mf-display-padding-height 150)
 '(send-mail-function nil))

;; TODO: bind this to a command... this shrinks the window down --
;; useful for getting your window back after unplugging and external
;; monitor!

;;(set-frame-size (selected-frame) 189 55)

;; CLOJURE
(require 'clojure-mode)
(defun clojure-mode-untabify ()
 (save-excursion
   (goto-char (point-min))
   (while (re-search-forward "[ \t]+$" nil t)
     (delete-region (match-beginning 0) (match-end 0)))
   (goto-char (point-min))
   (if (search-forward "\t" nil t)
       (untabify (1- (point)) (point-max))))
 nil)

(add-hook 'clojure-mode-hook
  '(lambda () (add-hook 'write-contents-hooks 'clojure-mode-untabify nil t)))

(add-hook 'clojure-mode-hook 'paredit-mode)
(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))

;;CIDER
;;(require 'cider)
;;(setq cider-repl-popup-stacktraces t)
;;(setq cider-popup-stacktraces nil)
;;(setq cider-auto-select-error-buffer nil)

;; MIDJE
(add-to-list 'load-path "~/emacs.d/vendor")
(require 'midje-mode)
(add-hook 'clojure-mode-hook 'midje-mode)

;;(add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode)
;;(add-hook 'cider-repl-mode-hook 'paredit-mode)

(eval-when-compile
  (require 'color-theme))

(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;;(color-theme-charcoal-black)
;;(color-theme-monokai)
;;(color-theme-cobalt)
;;(require 'color-theme-github)
;;(color-theme-github)
;;(load-theme 'jazz t)
;;(load-theme 'solarized-dark t)
;; http://stackoverflow.com/questions/4177929/how-to-change-the-indentation-width-in-emacs-javascript-mode
(setq js-indent-level 2)
;;(setq c-basic-offset 2)

(require 'smex) ; Not needed if you use package.el
(smex-initialize) ; Can be omitted. This might cause a (minimal) delay
                                        ; when Smex is auto-initialized on its first run.

;; Set PATH
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

(defun clojure-docstring-start+end-points ()
  "Return the start and end points of the string at point as a cons."
  (if (and (fboundp 'paredit-string-start+end-points) paredit-mode)
      (paredit-string-start+end-points)
    (cons (clojure-string-start) (clojure-string-end))))

;; clojure-fill-docstring
(defun clojure-fill-docstring ()
  "Fill the definition that the point is on appropriate for Clojure.

Fills so that every paragraph has a minimum of two initial spaces,
with the exception of the first line.  Fill margins are taken from
paragraph start, so a paragraph that begins with four spaces will
remain indented by four spaces after refilling."
  (interactive)
  (if (and (fboundp 'paredit-in-string-p) paredit-mode)
      (unless (paredit-in-string-p)
        (error "Must be inside a string")))
  ;; Oddly, save-excursion doesn't do a good job of preserving point.
  ;; It's probably because we delete the string and then re-insert it.
  (let ((old-point (point)))
    (save-restriction
      (save-excursion
        (let* ((clojure-fill-column fill-column)
               (string-region (clojure-docstring-start+end-points))
               (string-start (car string-region))
               (string-end (cdr string-region))
               (string (buffer-substring-no-properties string-start
                                                       string-end)))
          (delete-region string-start string-end)
          (insert
           (with-temp-buffer
             (insert string)
             (let ((left-margin 2))
               (delete-trailing-whitespace)
               (setq fill-column clojure-fill-column)
               (fill-region (point-min) (point-max))
               (buffer-substring-no-properties (+ 2 (point-min)) (point-max))))))))
    (goto-char old-point)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
