;; --- FILE:  init.begin.el
;; Provide timestamp to *Messages* logs
(load "~/myconf/emacs/log.el")

;; Backup files: https://www.johndcook.com/blog/emacs_windows/#backup
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Try to speed up start-up
(setq-default gc-cons-threshold (* 100 1024 1024))
;;(let ((file-name-handler-alist nil)) "~/myconf/emacs/init.el")

;; Follow git symlinks
(setq vc-follow-symlinks t)


(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))

; activate all the packages (in particular autoloads)
(package-initialize)

; fetch the list of packages available 
(unless package-archive-contents
  (package-refresh-contents))

; list the packages you want
(setq package-list '(use-package diminish edit-server buffer-move monokai-theme))

; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(eval-when-compile
  (require 'use-package))

(use-package diminish
  :ensure t)

(use-package bind-key
  :ensure t)

; set the path for manually installed packages
(add-to-list 'load-path "~/.emacs.d/packages")
;; --- FILE:  bars-and-title.el
;; --- Bars & title
(setq inhibit-startup-message t)
(tool-bar-mode -1) ;; removes tool-bar
(menu-bar-mode -1) ;; removes tool-bar
(scroll-bar-mode t)
(setq default-directory "~/")
(setq frame-title-format '("tom@" (:eval (format "%s" system-type))
                           ": "(:eval (if (buffer-file-name)
                                          (buffer-file-name) "%b"))))

;; (setq initial-frame-alist
;;       '((background-color . "honeydew")))

;; (setq default-frame-alist
;;       '((background-color . "honeydew")))

;; --- Miscellaneous
(setq set-mark-command-repeat-pop t) ;; https://emacs.stackexchange.com/a/2818/6957
(setq-default indent-tabs-mode nil) ;; Use spaces instead of tabs
(delete-selection-mode 1) ;; Allows to delete without kill-ring & inserting over selection.
(global-unset-key (kbd "C-x C-z")) ;; Unbind suspend-frame
(setq split-width-threshold nil) ;; Split window vertically by default
;; https://stackoverflow.com/questions/7997590/how-to-change-the-default-split-screen-direction


;; --- Disable all version control
;; since Emacs gets terribly slow
;; http://shallowsky.com/blog/linux/editors/no-emacs-version-control.html
(setq vc-handled-backends nil)
;; --- FILE:  column-and-line-numbers.el
;; --- Columns, line-numbers, etc.
(column-number-mode t)
(global-linum-mode t) ;; line numbers in all buffers

;; https://stackoverflow.com/q/9990370/316232
(global-hl-line-mode t) ;; highlight current line
(make-variable-buffer-local 'global-hl-line-mode)

(load-theme 'monokai t)

;; current line highlighted color
(set-face-background hl-line-face "#404040")

;; region highlight color
(set-face-attribute 'region nil :background "#848000") ;;

;; fringe color (between line numbers and buffer)
(set-face-attribute 'fringe nil :background "#505050")

;; --- FILE:  paren-indent.el
;; --- Paren stuff
(show-paren-mode 1)
(electric-pair-mode 1)
(defvar electric-pair-pairs) ;; make electric-pair-mode work on more brackets
(setq electric-pair-pairs '( (?\" . ?\") (?\{ . ?\}) ) )
(electric-indent-mode 1) ;; indent after enter

(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %.  ARG."
  (interactive "p")
  (cond ((looking-at "\\s(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

;; --- Wrap region: https://stackoverflow.com/a/2747142/316232
(wrap-region-mode t)
;; --- FILE:  cond-mac-linux-win.el
(cond
 ;; --- Mac OS X stuff ---
 ((string-equal system-type "darwin")
  (message "System: Mac")
  (setq mac-option-modifier 'command)
  (setq mac-command-modifier 'meta)
  (global-set-key (kbd "M-w") 'kill-this-buffer) ;; this works on Mac too
  (define-key global-map (kbd "C-<f2>")
    (lambda ()
      (interactive)
      (x-popup-menu (list '(0 0) (selected-frame))
                    (mouse-menu-bar-map))))
  (set-face-attribute 'default nil :height 200))

 ;; --- Windows stuff ---
 ((string-equal system-type "windows-nt")
  (message "System: Windows")
  (set-face-attribute 'default nil :family "Consolas" :height 140)
  (add-to-list 'exec-path "%HOME%/scoop/apps/git/current/usr/bin")
  (setenv "PATH" (mapconcat #'identity exec-path path-separator))

  (add-to-list 'exec-path "c:/Users/etomort/hunspell/bin/")
  (setq ispell-program-name (locate-file "hunspell"
                                         exec-path exec-suffixes 'file-executable-p))
  (setq-default buffer-file-coding-system 'utf-8-unix)
  (setq-default default-buffer-file-coding-system 'utf-8-unix)
  (set-default-coding-systems 'utf-8-unix)
  (prefer-coding-system 'utf-8-unix)
  (setq find-program "%HOME%/scoop/apps/git/current/usr/bin/find.exe")
  (setq compile-command "build.bat")
  )
 
 ;; --- Linux stuff ---
 ((message "System: Linux")
  (set-face-attribute 'default nil :family "Consolas" :height 140)

  ;; --- Persistent sessions
  ;; https://github.com/thierryvolpiatto/psession
  ;; https://github.com/emacs-helm/helm/issues/2028
  ;;  (psession-mode 1)

  ;; This makes Emacs on Windows unusable...
  ;; So set it only on Linux
  ;; https://github.com/emacs-helm/helm/issues/1976
  (setq x-wait-for-event-timeout nil)
  )
 )
;; --- FILE:  duplicate-line.el
;; Duplicate line
(defun duplicate-line (ARG)
  "Duplicate current line, ARG, leaving point in lower line."
  (interactive "*p")

  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))

  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion

      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))

      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count ARG))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )

      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let

  ;; put the point in the lowest line and return
  (next-line ARG))

;; --- FILE:  xah-cut-copy.el
;; --- Cut, Copy, Paste from Xah Lee functions   ---
;; Check http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html
(defun xah-cut-line-or-region ()
  "Cut current line, or text selection.
When `universal-argument' is called first, cut whole buffer (respects `narrow-to-region').

URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2015-06-10"
  (interactive)
  (if current-prefix-arg
      (progn ; not using kill-region because we don't want to include previous kill
        (kill-new (buffer-string))
        (delete-region (point-min) (point-max)))
    (progn (if (use-region-p)
               (kill-region (region-beginning) (region-end) t)
             (kill-region (line-beginning-position) (line-beginning-position 2))))))


(defun xah-copy-line-or-region ()
  "Copy current line, or text selection.
When called repeatedly, append copy subsequent lines.
When `universal-argument' is called first, copy whole buffer (respects `narrow-to-region').

URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2017-07-08"
  (interactive)
    (if current-prefix-arg
      (progn
        (kill-ring-save (point-min) (point-max))
        (message "All visible buffer text copied"))
      (if (use-region-p)
        (progn
          (kill-ring-save (region-beginning) (region-end))
          (message "Active region copied"))
    (if (eq last-command this-command)
          (if (eobp)
              (progn (message "empty line at end of buffer." ))
            (progn
              (kill-append "\n" nil)
              (kill-append
               (buffer-substring-no-properties (line-beginning-position) (line-end-position))
               nil)
              (message "Line copy appended")
        (progn
            (end-of-line)
                (forward-char))))
        (if (eobp)
            (if (eq (char-before) 10 )
                (progn (message "empty line at end of buffer." ))
              (progn
                (kill-ring-save (line-beginning-position) (line-end-position))
                (end-of-line)
                (message "line copied")))
      (progn
            (kill-ring-save (line-beginning-position) (line-end-position))
    (end-of-line)
    (forward-char)
            (message "line copied")))))))
;; --- FILE:  dired.el
;; --- Dired ---
;; TODO: Sort dired by time date as default 
;; https://superuser.com/questions/875241/emacs-dired-sorting-by-time-date-as-default

(use-package dired
  :bind (:map dired-mode-map
              ("f" . dired-find-alternate-file)
              ("M-p" . backward-paragraph)
              ("F" . find-name-dired)
              ("j" . dired-find-file)
              ("e" . ora-ediff-files)
              ("P" . peep-dired)
              ("<M-return>" . dired-w32-browser)
              )
  :config
  (define-key dired-mode-map (kbd ".") (lambda () (interactive) (find-alternate-file "..")))
  (put 'dired-find-alternate-file 'disabled nil)
  (setq dired-listing-switches "-lkt")

  ;; Auto-refresh dired on file change
  (setq dired-auto-revert-buffer t)

  (setq diredp-hide-details-initially-flag nil)
  (add-hook 'dired-mode-hook 'auto-revert-mode)
  (require 'dired-x)
  (require 'dired+)
  (require 'bind-key)
  (unbind-key "C-o" dired-mode-map)
  (unbind-key "C-w" dired-mode-map)


  (cond
   ((string-equal system-type "darwin")
    ;; Mac stuff
    )

   ((string-equal system-type "windows-nt")
    ;; Windows stuff
    (setq dired-guess-shell-alist-user '(("\\.pdf\\'" "AcroRd32.exe")
                                         ("\\.doc\\'" "WINWORD.EXE")
                                         ("\\.docx\\'" "WINWORD")
                                         ("\\.ppt\\'" "POWERPNT.EXE")
                                         ("\\.pptx\\'" "POWERPNT.EXE")
                                         ("\\.xls\\'" "EXCEL.EXE")
                                         ("\\.xlsx\\'" "EXCEL.EXE")
                                         ("\\.jpg\\'" "mspaint.exe")
                                         ("\\.png\\'" "mspaint.exe")
                                         ("\\.java\\'" "idea")))
    ) 
   (;; Ubuntu stuff
    (setq dired-guess-shell-alist-user '(("\\.pdf\\'" "evince")
                                         ("\\.doc\\'" "libreoffice")
                                         ("\\.docx\\'" "libreoffice")
                                         ("\\.ppt\\'" "libreoffice")
                                         ("\\.pptx\\'" "libreoffice")
                                         ("\\.xls\\'" "libreoffice")
                                         ("\\.xlsx\\'" "libreoffice")
                                         ("\\.jpg\\'" "pinta")
                                         ("\\.png\\'" "pinta")
                                         ("\\.java\\'" "idea")))
    )
   )



  )

;; This does not seem to be loaded... Why?
;; (setq dired-guess-shell-alist-user '(("\\.pdf\\'" "evince")
;;                                      ("\\.doc\\'" "libreoffice")
;;                                      ("\\.docx\\'" "libreoffice")
;;                                      ("\\.ppt\\'" "libreoffice")
;;                                      ("\\.pptx\\'" "libreoffice")
;;                                      ("\\.xls\\'" "libreoffice")
;;                                      ("\\.xlsx\\'" "libreoffice")
;;                                      ("\\.jpg\\'" "pinta")
;;                                      ("\\.png\\'" "pinta")
;;                                      ("\\.java\\'" "idea")))

(use-package peep-dired
  :ensure t)

;; Esta función usa dired-jump para abrir en dired el buffer actual
;; O a través de ibuffer
(defun open-in-dired ()
  "Show current buffer on dired."
  (interactive)
  (if (equal major-mode 'ibuffer-mode)
      (ibuffer-visit-buffer-in-dired)
    (if (buffer-file-name)
        (dired-jump nil (buffer-file-name))
      (message "This buffer is not a file in the filesystem."))))

(defun ibuffer-visit-buffer-in-dired (&optional noselect)
  "Visit the buffer on this line in dired."
  (interactive)
  (let ((buf (ibuffer-current-buffer t)))
    (bury-buffer (current-buffer))
    (dired-jump nil (buffer-file-name buf))
    (message (buffer-file-name buf))))



(setq find-args "")
(defun find-dired-by-date (dir args)
  (interactive (list (read-directory-name "Run find in directory: " nil "" t)
		     (read-string "Run find (with args): " find-args
				  '(find-args-history . 1))))
  ;; Set to this value in order to get a find sorted by date
  (setq find-ls-option '("-exec ls -lt {} + | cut -d ' ' -f5-" . "-lt"))
  (find-dired dir args)
  (setq find-ls-option '("-ls" . "-dilsb")))

(defun find-dired-by-size (dir args)
  (interactive (list (read-directory-name "Run find in directory: " nil "" t)
		     (read-string "Run find (with args): " find-args
				  '(find-args-history . 1))))
  ;; Set to this one to get it sorted by size
  (setq find-ls-option '("-exec ls -lSr {} + | cut -d ' ' -f5-" . "-lSr"))
  (find-dired dir args)
  (setq find-ls-option '("-ls" . "-dilsb")))
;; --- FILE:  movement.el
;; --- Move end of line / Join line
(defun move-end-of-line-newline-and-indent ()
  "Insert a newline, then indent according to major mode."
  (interactive "*")
  (move-end-of-line 1)
  (newline)
  (indent-according-to-mode))

;;; It allows you to move the current line using M-up / M-down
;; If a region is marked, it will move the region instead.
(use-package move-text
  :ensure t
  :config (move-text-default-bindings))
;; --- FILE:  buffers-utils.el
(defun switch-to-previous-buffer ()
  "Swap to previous buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(defun indent-buffer ()
  "Select current buffer and indent it."
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max) nil)))

(global-auto-revert-mode t) ;; automatically revert buffer when file changes

;; --- Uniquify 
(require 'uniquify)
;;(setq uniquify-buffer-name-style 'forward)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers
;;(toggle-uniquify-buffer-names) ;; Different buffer name for same name files


;; --- Ibuffer ----
(use-package ibuffer
  :config 
  (define-key ibuffer-mode-map (kbd "C-o") nil) ;; unbind from default
  (define-key ibuffer-mode-map (kbd "C-i") nil) ;; unbind from default
  (define-key ibuffer-mode-map (kbd "M-h") 'toggle-ibuffer-groups) ;; unbind from default
  (define-key ibuffer-mode-map (kbd "<tab>") 'ibuffer-forward-filter-group) ;; unbind from default
  )


;; how-can-i-make-ibuffer-auto-refresh-the-list-of-buffers
;; Not using this one
;; https://emacs.stackexchange.com/a/2178/6957
;;(add-hook 'ibuffer-mode-hook (lambda () (ibuffer-auto-mode 1))) ;; Update ibuffer automatically

;; Using this one
;; https://emacs.stackexchange.com/a/2179/6957
(defun my-ibuffer-stale-p (&optional noconfirm)
  ;; let's reuse the variable that's used for 'ibuffer-auto-mode
  (frame-or-buffer-changed-p 'ibuffer-auto-buffers-changed))

(defun my-ibuffer-auto-revert-setup ()
  (set (make-local-variable 'buffer-stale-function)
       'my-ibuffer-stale-p)
  (set (make-local-variable 'auto-revert-verbose) nil)
  (auto-revert-mode 1))

(add-hook 'ibuffer-mode-hook 'my-ibuffer-auto-revert-setup)


;; --- Ibuffer extension ---
(use-package ibuf-ext
  :config 
  ;; Following lines eliminates annoying *Minibuf-, *Echo Area, etc., but also *magit: buffers
  ;; (add-to-list 'ibuffer-never-show-predicates " .*")

  ;; Remove the buffers that match these regexp
  (add-to-list 'ibuffer-never-show-predicates " .*\\*grip-.*")
  (add-to-list 'ibuffer-never-show-predicates " .*NeoTree.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*lsp.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*Metahelp*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*tip*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*git-credential.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*Minibuf-.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*Echo Area.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*Custom.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*Python.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*DOC.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*SPP.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*temp.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*edit.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*ediff-tmp.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*emacs-query.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*autoload.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*spool.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*code-conver.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*helm.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*Deletions.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*http.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*RNC.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*elpy.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*server.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*org.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\*org.*")
  (add-to-list 'ibuffer-never-show-predicates " .*\\Marked.*")
  (add-to-list 'ibuffer-never-show-predicates "^\\*helm ag")
  (add-to-list 'ibuffer-never-show-predicates "^\\*helm mini")
  (add-to-list 'ibuffer-never-show-predicates "^\\*helm find")
  (add-to-list 'ibuffer-never-show-predicates "^\\*helm grep exts")
  (add-to-list 'ibuffer-never-show-predicates "^\\*helm M-x")
  (add-to-list 'ibuffer-never-show-predicates "^\\*helm-mode")
  (add-to-list 'ibuffer-never-show-predicates "^\\*helm buffers")
  (add-to-list 'ibuffer-never-show-predicates "^\\*helm man woman*")
  (add-to-list 'ibuffer-never-show-predicates "^\\*Helm Swoop")
  (add-to-list 'ibuffer-never-show-predicates "^\\*Messages")
  (add-to-list 'ibuffer-never-show-predicates "^\\*Disabled")
  (add-to-list 'ibuffer-never-show-predicates "^\\*Help")
  (add-to-list 'ibuffer-never-show-predicates "^\\*tramp")
  (add-to-list 'ibuffer-never-show-predicates "^\\*JDEE")
  (add-to-list 'ibuffer-never-show-predicates "^\\*magit.*process")
  (add-to-list 'ibuffer-never-show-predicates "^\\*magit.*diff")
  (add-to-list 'ibuffer-never-show-predicates "^\\*magit.*log")
  )

;; From: http://martinowen.net/blog/2010/02/03/tips-for-emacs-ibuffer.html


(defun my-ibuffer-saved-groups ()
  (setq ibuffer-saved-filter-groups
        '(("home"
           ("myconf" (or (filename . "myconf")
                         (filename . "emacs-config")))
           ("SMIP" (filename . "smip"))
           ("Org" (or (mode . org-mode)
                      (filename . "OrgMode")))
           ("playground" (filename . "playground"))
           ("/usr/include/" (filename . "/usr/include/"))
           ("SDL" (filename . "tomas/SDL/"))
           ("raylib" (filename . "raylib"))
           )
          ("default")
          ))
  (ibuffer-switch-to-saved-filter-groups "home" ))


(add-hook 'ibuffer-mode-hook 'my-ibuffer-saved-groups)


(setq ibuffer-expert t)
(setq ibuffer-show-empty-filter-groups nil)

;; Ibuffer formats like column width
(define-ibuffer-column vtime
  (:name "Time" :inline t)
  (string ?a ?b ?c ?d)
  )

(setq ibuffer-formats 
      '((mark modified read-only " "
              (name 30 30 :left :elide) ; change: 30s were originally 18s
              " "
              (vtime 4 4 :left)
              " "
              (size 9 -1 :right)
              " "
              (mode 16 16 :left :elide)

              " " filename-and-process)
        (mark " "
              (name 16 -1)
              " " filename)))
;; --- FILE:  elisp.el
;; --- Elisp related
(require 'hl-defined)

(add-hook 'emacs-lisp-mode-hook 'hdefd-highlight-mode 'APPEND)

;; http://emacsredux.com/blog/2014/06/18/quickly-find-emacs-lisp-sources/
(define-key 'help-command (kbd "C-l") 'find-library)
(define-key 'help-command (kbd "C-f") 'find-function)
(define-key 'help-command (kbd "C-k") 'find-function-on-key)
(define-key 'help-command (kbd "C-v") 'find-variable)

;; --- FILE:  keybindings.el
(require 'iso-transl) ;; Make dead keys work

;; NOTE: Do not bind C-y & M-w to anything.
;; NOTE: That way I keep their original function, in case I need it...
;; NOTE: M-w (kill-ring-save)
;; NOTE: C-y (yank) or (cua-paste)

;; --- Cua mode 
(cua-mode t) ;; Ctrl+Z, Ctrl+X, Ctrl+C, Ctrl+V (Cmd+ in Mac OSX)

;; --- Search with C-f like MOST apps...
(global-set-key (kbd "C-f") 'isearch-forward)
(define-key isearch-mode-map (kbd "C-f") 'isearch-repeat-forward)
(define-key isearch-mode-map [down] 'isearch-repeat-forward)
(define-key isearch-mode-map [up] 'isearch-repeat-backward)
(global-set-key (kbd "C-s") 'save-buffer) ;; Use C-s to save

;; Check: http://emacs.stackexchange.com/questions/22621/cutting-selection-with-cua-mode-bindings-after-searching/
(define-key isearch-mode-map (kbd "C-x") nil)

;; --- Scroll up & down
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)


;; --- Line operations
(global-set-key (kbd "M-j") 'move-end-of-line-newline-and-indent) ;; general.el
(global-set-key (kbd "M-h") 'join-line) 
;; I used to set it to C-j... in order to be similar to vi J key
;; join-line function is a defalias of delete-indentation.

(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "C-d") 'kill-whole-line)
(global-set-key (kbd "C-l") 'duplicate-line) ;; duplicate-line.el
(global-set-key (kbd "M-s M-s") 'delete-horizontal-space)
(global-set-key (kbd "M-s s") 'delete-horizontal-space)
;; Same position as US keyboard layout (M-\) [US keyboard has \, Spanish ç]
;; http://stackoverflow.com/questions/445225/emacs-command-to-delete-up-to-non-whitespace-character
;; In that SO question says to use delete-indentation function
;; Tomi, what is the difference between both?

;; --- Paren operations
(global-set-key "%" 'match-paren) ;; Like vim
(global-set-key (kbd "C-M-j") 'down-list) ;; As C-M-u does backward-up-list


;; --- FX keys
(global-set-key (kbd "<f2>") 'xah-cut-line-or-region) ; cut
(global-set-key (kbd "<f3>") 'xah-copy-line-or-region) ; copy
(global-set-key (kbd "<f4>") 'yank) ; paste

(global-set-key (kbd "<f5>") 'revert-buffer)
(global-set-key (kbd "<f6>") 'mark-whole-buffer)
(global-set-key (kbd "<f7>") 'neotree-toggle)
(global-set-key (kbd "<f8>") 'ibuffer)

;; TODO: When switch-to-previous-buffer , minibuffer shows 'Mark set',
;; and sometimes need to hit the key twice... 
;;(global-set-key (kbd "<fXX>") 'switch-to-previous-buffer) ;; buffer-utils.el
(global-set-key (kbd "<f9>") 'indent-buffer) ;; buffer-utils.el
(global-set-key (kbd "<f10>") 'kmacro-start-macro)
(global-set-key (kbd "<f11>") 'kmacro-end-and-call-macro)
(global-set-key (kbd "<f12>") 'recompile)


;; --- Buffers
(global-unset-key (kbd "C-w"))
(global-set-key (kbd "C-w") 'kill-this-buffer) ;; Just like Chrome, etc..
(global-set-key (kbd "C-0") 'switch-to-previous-buffer)


;; --- Windows
(global-set-key [C-tab] 'other-window)
(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-3") 'split-window-below)
(global-set-key (kbd "M-o") 'find-file-other-window)

(defun split-window-right-and-other-window () "Does that" (interactive)
       (split-window-right)
       (other-window 1))
(global-set-key (kbd "M-2") 'split-window-right-and-other-window)
(global-set-key (kbd "M-0") 'delete-window)

(global-set-key [C-next] 'windmove-right)
(global-set-key [C-prior] 'windmove-left)

;; TODO: change by use-package
(require 'buffer-move)
(defun win-swap () "Swap windows using buffer-move.el" (interactive)
       (if (null (windmove-find-other-window 'right))
           (buf-move-left)
         (buf-move-right)))
(global-set-key (kbd "C-2") 'win-swap)
(global-set-key (kbd "C-S-o") 'find-file-other-window)

;; --- Font-size & split-pane size
(global-set-key (kbd "C-=") 'text-scale-adjust)

;; (global-set-key (kbd "C-x =") 'enlarge-window)
;; (global-set-key (kbd "C-x -") 'shrink-window)
;; (global-set-key (kbd "C-x +") 'shrink-window-if-larger-than-buffer)
;; (global-set-key (kbd "C-x _") 'balance-windows)


;; --- Comments
(defun comment-line-or-region ()
  "Emulate comment code as Eclipse does it."
  (interactive)
  (let ((start (line-beginning-position))
        (end (line-end-position)))
    (when (or (not transient-mark-mode) (region-active-p))
      (setq start (save-excursion
                    (goto-char (region-beginning))
                    (beginning-of-line)
                    (point))
            end (save-excursion
                  (goto-char (region-end))
                  (end-of-line)
                  (point))))
    (comment-or-uncomment-region start end)))

(global-set-key (kbd "M-/") 'comment-dwim)
(global-set-key (kbd "C-/") 'comment-line-or-region)
(global-set-key (kbd "C-S-c") 'comment-line-or-region) ; Eclipse has this one too


;; --- Miscellaneous
(global-set-key (kbd "C-S-r") 'query-replace) ;; Seems to remind me r=replace
(global-set-key (kbd "C-.") 'repeat) ;; Like . in vim
(global-set-key (kbd "C-,") 'iedit-mode)

(global-set-key (kbd "M-y") 'company-complete)
(global-set-key (kbd "M-;") 'hippie-expand)
(global-set-key (kbd "C-;") 'company-files)

(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x C-g") 'magit-status)
(global-set-key (kbd "M-z") 'recenter-top-bottom)

(global-set-key (kbd "M-<f4>") 'kill-emacs)
(global-set-key (kbd "<escape>") 'keyboard-quit)

;; --- Differenciate C-i & TAB
;; https://stackoverflow.com/q/1792326/316232

;; (setq local-function-key-map (delq '(kp-tab . [9]) local-function-key-map))
;; ;; (global-set-key (kbd "C-i") (lambda () (interactive) (message "C-i")))
;; (global-set-key (kbd "<tab>") 'indent-for-tab-command)

;; Translate the problematic keys to the function key Hyper:
(keyboard-translate ?\C-i ?\H-i)
;; (global-set-key (kbd "<tab>") 'indent-for-tab-command)
(define-key help-mode-map (kbd "<tab>") 'forward-button) 

;; Paste with middle mouse button
;; https://stackoverflow.com/a/13043670/316232
(setq mouse-drag-copy-region t)
(setq select-active-regions nil)
(global-set-key [mouse-2] 'mouse-yank-at-click)
;; --- FILE:  keybasic.el
(global-set-key (kbd "C-o") 'find-file)
(global-set-key (kbd "H-i") 'switch-to-buffer)
;; --- FILE:  cua.el
(defun special-c-return-in-dired ()
  (interactive)
  (if (derived-mode-p 'dired-mode)
      (dired-w32explore)
    (cua-set-rectangle-mark))
  )

(define-key cua-global-keymap [C-return] 'special-c-return-in-dired)

;; --- FILE:  init.end.el
;; TODO: Print date in scratch buffer
;; (message (format-time-string "%H:%M:%S.%3N"))
;; (setq myscratch (get-buffer "*scratch*"))
;; (print (format-time-string "%H:%M:%S.%3N") myscratch)
;; (print "rubbish"  myscratch)

;;(setq custom-file "~/myconf/emacs/custom.el")
;;(load custom-file) 
(put 'scroll-left 'disabled nil)


;;(load "~/myconf/emacs/rg.el")
;;(load "~/myconf/emacs/smart-line.el")
;;(load "~/myconf/emacs/spaceline.el")

(server-start) ;; emacs server
(message "Emacs ready with init.el !")
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Problem when hitting Alt+Tab on Windows
;;(global-set-key (kbd "<Scroll_Lock>") '(lambda () (interactive) nil ))
(global-set-key (kbd "<Scroll_Lock>") 'ignore)

;; --- Recent files stuff
(recentf-mode 1)
(setq recentf-max-menu-items 10)
(defalias 'recf 'recentf-open-files)

;; --- Font-size & split-pane size
;; For some reason this get disabled if I put it in keybinding.el
(global-set-key (kbd "C-=") 'text-scale-adjust)

;; --- Custom variables

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (lorem-ipsum flymd zenburn-theme yaml-mode yafolding xah-lookup wgrep web-beautify use-package typing transpose-frame tabbar sx switch-window strace-mode stem sqlplus sql-indent speed-type spaceline-all-the-icons smart-mode-line-powerline-theme scss-mode rpm-spec-mode rainbow-mode rainbow-delimiters racket-mode pyenv-mode py-autopep8 puppet-mode psession projectile processing-snippets processing-mode prettier-js peep-dired paredit pandoc-mode org2blog org-pandoc openwith nhexl-mode move-text monokai-theme micgoline mediawiki markdown-toc magit love-minor-mode log4j-mode load-theme-buffer-local lispy json-mode jedi impatient-mode hl-defined highlight-chars hideshowvis helm-swoop helm-smex helm-gtags helm-etags-plus helm-descbinds helm-css-scss helm-company groovy-mode groovy-imports google-this google-c-style gnuplot-mode ggtags function-args fold-dwim flymake-json flycheck-irony flycheck-color-mode-line flx fill-column-indicator exec-path-from-shell evil etags-select esup elpy elisp-slime-nav edit-server dumb-jump doremi-frm doremi-cmd direx dired-toggle-sudo dired+ diminish diff-hl counsel company-irony company-c-headers color-theme-monokai color-theme-emacs-revert-theme color-theme-eclipse color-theme-buffer-local cmake-mode cmake-ide buffer-move better-defaults bash-completion base16-theme awk-it auto-complete-nxml auto-complete-clang auto-complete-c-headers aggressive-indent))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

