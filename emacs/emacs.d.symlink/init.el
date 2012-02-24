;;; init.el --- the primary initialization script

;; Common lisp goodies, loop
(require 'cl)

;; Make sure that Emacs can find our homebrew binaries
;; (Needed for git and bzr.)
(push "/usr/local/bin" exec-path)

;; ELPA packages
;; -------------

(require 'package)
(add-to-list 'package-archives '("tromey"      . "http://tromey.com/elpa/")             t)
(add-to-list 'package-archives '("technomancy" . "http://repo.technomancy.us/emacs/")   t)
(add-to-list 'package-archives '("marmalade"   . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;; el-get packages
;; ---------------

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

;; Detect if el-get is installed, and install it if it's not.
;; (Unfortunately this requires an internet connection at program start.)
(unless (require 'el-get nil t)
  (url-retrieve
   "https://github.com/dimitri/el-get/raw/master/el-get-install.el"
   (lambda (s)
     (end-of-buffer)
     (eval-print-last-sexp))))

;; Now either el-get is `require'd already, or has been `load'ed by the el-get
;; installer, so there's no need to do either ourselves.

;; Simple list of recipes that don't require any configurationAditional
;; recipes that don't require any configuration
(setq
 my:el-get-packages
 '(el-get         ; el-get is self-hosting
   keywiz         ; Emacs shortcut quiz
   textmate       ; Textmate-esque file searching (standalone, or integrated with PeepOpen)
   coffee-mode    ; Coffe script major mode
   escreen        ; Screen for emacs, "C-\ C-h"
   switch-window  ; Takes over "C-x o"
   auto-complete  ; Complete as you type, using overlays
   color-theme))  ; Nice looking emacs

;; And here are all the other recipes that reuire some pre/post action.
(setq
 el-get-sources
 '((:name buffer-move         ; Have to add our own keys
          :after (lambda ()
									 (global-set-key (kbd "<C-S-up>")    'buf-move-up)
									 (global-set-key (kbd "<C-S-down>")  'buf-move-down)
									 (global-set-key (kbd "<C-S-left>")  'buf-move-left)
									 (global-set-key (kbd "<C-S-right>") 'buf-move-right)))

   (:name ecb                 ; An Emacs-style IDE type thingy
					:after (lambda ()
									 (setq stack-trace-on-error t)
									 (add-to-list 'load-path "~/.emacs.d/el-get/ecb/")
									 (require 'ecb)
									 (setq ecb-tip-of-the-day nil)
									 (setq ecb-primary-secondary-mouse-buttons (quote mouse-1--mouse-2))
									 (ecb-activate)))

   (:name smex                ; A better (ido like) M-x
					:after (lambda ()
									 (setq smex-save-file "~/.emacs.d/.smex-items")
									 (global-set-key (kbd "M-x") 'smex)
									 (global-set-key (kbd "M-X") 'smex-major-mode-commands)))

   (:name magit               ; Git meets Emacs, and a binding
          :after (lambda ()
                   (global-set-key (kbd "C-x C-z") 'magit-status)))
   
   (:name goto-last-change    ; Move pointer back to last change
					:after (lambda ()
									 ;; When using AZERTY keyboard, consider C-x C-_
									 (global-set-key (kbd "C-x C-/") 'goto-last-change)))

;;   (:name pretty-mode         ; Substitude symbols and greek letters
;;					:after (lambda ()
;;									 (require 'pretty-mode)
;;									 (global-pretty-mode 1)))

   (:name zenburn-theme :type http
					:url "https://github.com/djcb/elisp/raw/master/themes/zenburn-theme.el")))

(setq my:el-get-packages
      (append
       my:el-get-packages
       (loop for src in el-get-sources collect (el-get-source-name src))))

;; Install new packages and init already installed packages.
(el-get 'sync my:el-get-packages)

;; Basic configuration
;; -------------------

(setq make-backup-files nil)
(setq query-replace-highlight t)
(setq search-highlight t)
(fset 'yes-or-no-p 'y-or-n-p)
(setq require-final-newline t)
(setq major-mode 'text-mode)

(show-paren-mode t) ;; turn on paren maching
(setq show-paren-style 'mixed)

(setq default-directory "~/") ;; Start in user folder

;; Code editing settings...
;; ------------------------

(setq-default tab-width 2) ;; Default tab width of 2.

(setq c-default-style "linux" ; Set C indentation style
			c-basic-offset 2)

;; Visual settings...
;; ------------------

(require 'zenburn-theme) ;; Use the beautiful zenburn theme.

(setq inhibit-startup-screen t) ; No startup screen.
(setq inhibit-splace-screen t) ; No splash screen.
(tool-bar-mode -1)             ; No tool-bar with icons.
(scroll-bar-mode -1)           ; No scroll bars.
(line-number-mode 1)           ; Always show line numbers.
(column-number-mode 1)         ; Always show column numbers.

;; On mac, the menu is always drawn. This prevents it from being empty.
(unless (string-match "apple-darwin" system-configuration) (menu-bar-mode -1))

;; Choose a good font for the current system.
;;(set-face-font 'default (cond ((string= "windows-nt" system-type) "Consolas-10") ;; Windows font
;;                              ((string= "darwin" system-type) "Inconsolata-11")  ;; Mac font
;;                              (t "Monospace-10")))                               ;; Default font (TODO: Pick something way way better.)

(setq default-frame-alist '((font . "menlo-10")))
(add-to-list 'default-frame-alist '(alpha . 100)) ;; Avoid compiz manager rendering bugs
(push '(font-backend xft x) default-frame-alist) ;; Get back font antialiasing

(global-font-lock-mode t)
(setq font-lock-maximum-decoration '((c-mode . 1) (t . 3)))

(global-hl-line-mode)  ; highlight the current line
(global-linum-mode 1)  ; add line numbers on the left

(cua-mode) ;; Copy/Paste/Cut with C-c and C-v and C-x. (Also, C-RET.)
(setq x-select-enable-clipboard t) ;; Use the clipboard, so that copy/paste works as expected.

;; Mac specific key remapping and misc. settings.
;; Command -> Meta and Option -> nothing.
(when (string= "apple-darwin" system-configuration)
  (setq mac-allow-anti-aliasing t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none))

;; Navigate windows with M-<arrows>
(windmove-default-keybindings 'meta)
(setq windmove-wrap-around t)

;; Whenever an external process changes a file under emacs, and there are no
;; unsaved changes in the corresponding buffer, just revert it's content to
;; reflect what's currently on disk.
(global-auto-revert-mode 1)

;; Use ido for minibuffer completion.
(require 'ido)
(ido-mode t)
(setq ido-save-directory-list-file "~/.emacs.d/.ido.last")
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point 'guess)
(setq ido-show-dot-for-dired t)

;; Default key to switch buffer is C-x b, but that's not easy enough.
;; To kill emacs either close its frame from the window manager or do
;; M-x kill-emacs. Don't need a nice shortcut for a once-a-day action.
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
(global-set-key (kbd "C-x C-C") 'ido-switch-buffer)
(global-set-key (kbd "C-x B") 'ibuffer)

;; go full screen (os x and fullscreen brew install of emacs 23 only)
(global-set-key (read-kbd-macro "C-x t") 'ns-toggle-fullscreen)

;; C-x C-j opens dired with the cursor right on the file you're editing.
(require 'dired-x)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ecb-options-version "2.40"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Integration with XCode
;; ----------------------

(setq auto-mode-alist
      (cons '("\\.m$" . objc-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.mm$" . objc-mode) auto-mode-alist))

(defun bh-compile ()
  (interactive)
  (let ((df (directory-files "."))
				(has-proj-file nil))
    (while (and df (not has-proj-file))
      (let ((fn (car df)))
        (if (> (length fn) 10)
						(if (string-equal (substring fn -10) ".xcodeproj")
								(setq has-proj-file t))))
      (setq df (cdr df)))
    (if has-proj-file
        (compile "xcodebuild -configuration Debug")
      (compile "make"))
	)
)

;; Make colours in Emacs' shell look normal
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

