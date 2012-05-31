;;; -*- Mode: Emacs-Lisp; -*-
;;;
;;; ~/.emacs
;;;
;;; My global Emacs configuration file.
;;;
;;; Mark Shroyer
;;; http://markshroyer.com/

(require 'cl)

;;; UTILITY FUNCTIONS

(defun char (str i)
  "Return character at position i in str"
  (string-to-char (substring str i)))

(defun last-char (str)
  "Return last character in str"
  (char str (- (length str) 1)))

;; Generate a simple list of tab stops, 'stop-width characters in between
;; and up to 'text-width characters long in total.
(defun simple-tab-stop-list (stop-width text-width)
  "Generate a simple list of tab stops"

  (do ((stop stop-width (+ stop stop-width))
        (stop-list nil))
      ((> stop text-width) stop-list)
    (setq stop-list (append stop-list (list stop)))))

;; Install the paredit minor mode as a hook for the given mode name, but
;; only if paredit is available.
(defmacro add-paredit-hook (mode-name)
  (let* ((hook-name (concat (symbol-name mode-name)
                            "-hook"))
         (hook (intern hook-name)))
    `(if (or (featurep 'paredit) (fboundp 'paredit-mode))
         (add-hook (quote ,hook)
                   (lambda ()
                     (paredit-mode t))))))

;; Flattens an assoc-list tree of paths (such as the user-elisp paths)
;; depth-first into a plain list of paths
(defun flatten-path-tree (path-tree)
  (if (null path-tree)
      nil
    (let* ((sub-tree  (car path-tree))
           (this-dir  (if (eql (last-char (car sub-tree))
                               (string-to-char "/"))
                          (car sub-tree)
                        (concat (car sub-tree) "/"))))
      (cons this-dir
            (append (if (not (null (cdr sub-tree)))
                        (mapcar (lambda (sub-path)
                                  (concat this-dir sub-path))
                                (flatten-path-tree (cdr sub-tree))))
                    (flatten-path-tree (cdr path-tree)))))))

;; Check local-server-selection variable (possibly set in ~/.emacs.local.el)
;; to decide whether we should run the server in question
(defun should-start-server (server-name)
  (and (boundp 'local-server-selection)
       (member server-name local-server-selection)))


;;; SYSTEM

;; The HOME environment variable may not necessarily be set on Windows
;; systems.  If it isn't already set, try to synthesize it from other
;; standard Windows environment variables.
(when (and (or (eql system-type 'windows-nt)
               (eql system-type 'msdos))
           (not (getenv "HOME")))
  (setenv "HOME" "$HOMEDRIVE$HOMEPATH" t))

;; User Emacs directories
(setq user-emacs-directory "~/.emacs.d/"
      user-elisp-directory (concat user-emacs-directory "elisp/")
      generated-autoload-file (concat user-emacs-directory
				      "loaddefs.el"))

;; Tree(s) of paths containing user Emacs Lisp files.  These will be added
;; to the load path, but will not be scanned recursively.
(setq user-elisp `((,user-elisp-directory
                    ("auto-complete")
                    ("slime")
                    ("swank-chicken")
                    ("clojure-mode")
                    ("swank-clojure")
                    ("fuel")
                    ("pymacs")
                    ("org-mode/lisp")
                    ("org-mode/contrib/lisp")
                    ("haskellmode-emacs")
                    ("erlang")
                    ("cperl-mode")
                    ("emacs_chrome/servers")
                    ("yasnippet")
                    ("scala-mode")
                    ("lua")
                    ("android-mode")
                    ("magit")
                    ("egg")
                    ("monky")
                    ("color-theme-solarized")
                    ("nyan-mode")
                    ("tuareg-mode"))))

;; Prepend user elisp directories to the elisp load path.  Then, prepare
;; any autoloads contained in our user load paths.
(let ((my-load-path (remove-if-not #'file-exists-p
                                   (flatten-path-tree user-elisp))))
  (setq load-path (append my-load-path load-path))
  (apply #'update-directory-autoloads my-load-path))


;;; EMACS EXTENSIONS

;; Contains autoloads processed from the user-elisp tree.
(load generated-autoload-file)

;; Required features
(require 'org)
(require 'calendar)
(require 'diary-lib)
(require 'paredit)
(require 'git)
(require 'git-blame)
(require 'tramp)
(require 'android)

;; Autoload features
(autoload 'markdown-mode
  "markdown-mode.el"
  "Major mode for editing Markdown files."
  t)
(autoload 'yaml-mode
  "yaml-mode.el"
  "Major mode for editing YAML files."
  t)
(autoload 'visual-basic-mode
  "visual-basic-mode"
  "Visual Basic mode."
  t)
(autoload 'powershell-mode
  "powershell-mode"
  "Major mode for editing PowerShell scripts."
  t)
(autoload 'php-mode
  "php-mode"
  "Major mode for editing php code."
  t)
(autoload 'vala-mode
  "vala-mode"
  "Major mode for editing Vala code."
  t)
(autoload 'fsharp-mode
  "fsharp"
  "Major mode for editing F# code."
  t)
(autoload 'run-fsharp
  "inf-fsharp"
  "Run an inferior F# process."
  t)
(autoload 'tuareg-mode
  "tuareg"
  "Major mode for editing OCaml code."
  t)
(autoload 'tuareg-run-ocaml
  "tuareg"
  "Run an inferior OCaml process."
  t)
(autoload 'ocamldebug
  "ocamldebug"
  "Run the OCaml debugger"
  t)
(autoload 'lua-mode
  "lua-mode"
  "Lua editing mode."
  t)
(autoload 'magit-status
  "magit"
  "Open a Magit status buffer"
  t)
(autoload 'egg-status
  "egg"
  "Open an Egg status buffer"
  t)
(load-file (concat user-elisp-directory "fuel/fu.el"))

;; Optional features
(require 'auto-complete-config nil t)
(require 'pymacs nil t)
(require 'slime nil t)
(require 'eperiodic nil t)
(require 'sudoku nil t)
(require 'epa-file nil t)
(require 'edit-server nil t)
(require 'yasnippet nil t)
(require 'scala-mode nil t)
(require 'android-mode nil t)
(require 'chicken-slime nil t)
(require 'pymacs nil t)
(require 'monky nil t)
(require 'color-theme-solarized nil t)
(require 'nyan-mode nil t)

;; Initialization
(let ((nxhtml-init (concat user-elisp-directory "nxhtml/autostart.el")))
  (load nxhtml-init t))


;;; MAC OS X-SPECIFIC CONFIGURATIONS

(when (eq system-type 'darwin)
  ;; Use the Option/Alt key for Meta in Emacs.app
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'meta)

  ;; Rig up cmd-H so that it hides the application window, rather than mark
  ;; the current paragraph...
  (global-set-key "\M-h" 'ns-do-hide-emacs))


;;; FILE HANDLING

;; Auto-save every four minutes, and delete auto-save files when the buffer
;; is saved or killed
(setq auto-save-interval 240
      delete-auto-save-files t)

;; Like Vim's ":set backupcopy=yes"; save files in-place so things like
;; Mutt or Cygwin's permissions don't get screwed up.
(setq make-backup-files t
      backup-by-copying t)

;; Keep versioned backups in ~/.emacs.d/backups
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      version-control t
      kept-new-versions 6
      kept-old-versions 2
      delete-old-versions t)

;; Make sure the last line of a file ends in a carriage return
(setq require-final-newline t)

;; ido mode for switching buffers and finding files
(ido-mode 1)
(setq ido-enable-flex-matching t
      ido-max-directory-size 1000000
      ido-auto-merge-work-directories-length -1
      ido-default-file-method 'selected-window
      ido-default-buffer-method ido-default-file-method)


;;; GENERAL INTERFACE SETTINGS

;; Don't display startup message
(setq inhibit-startup-message t)

;; Get rid of the toolbar, if applicable
(if (fboundp 'tool-bar-mode)
    (tool-bar-mode 0))

;; By default, if we aren't running in a window system, turn off the menu
;; bar but enable xterm mouse control.
(when (not window-system)
  (menu-bar-mode 0)
  (xterm-mouse-mode 1))

;; Specify Unix system EOL mnemonics (these settings won't be the default
;; on Windows versions of Emacs)
(setq eol-mnemonic-unix ":"
      eol-mnemonic-dos  "(DOS)"
      eol-mnemonic-mac  "(MAC)")

;; Display current time and load average on mode line
(display-time)

;; Enable paredit in the minibuffer, but only for the command eval-expression
(add-hook 'minibuffer-setup-hook
          (lambda ()
            (if (eql this-command 'eval-expression)
                (paredit-mode t))))

;; Show column number on the mode line
(column-number-mode t)

;; Use visual bell
(setq visible-bell t)

;; Show continuation lines
(setq truncate-lines nil
      truncate-partial-width-windows nil)

;; Don't make me type out long answers...
(fset 'yes-or-no-p 'y-or-n-p)

;; Scroll one line at a time, like Vim
(setq scroll-conservatively 2)

;; Show at least three lines of context around the cursor while scrolling
;; (like :set scrolloff=3 in Vim)
(setq scroll-margin 3)

;; Don't use transient mark mode / Zmacs mode (note that this disables
;; region highlighting)
(transient-mark-mode 0)

;; Don't mess around with this disabled commands nonsense
(setq disabled-command-hook nil)

;; Confirm that we want to quit Emacs
(setq confirm-kill-emacs 'y-or-n-p)

;; Add a keystroke for renaming a buffer
(global-set-key "\C-cr" 'rename-buffer)

;; Don't use graphical confirmation dialogs; these cause a number of
;; problems, including hanging Emacs when we try to perform a system
;; shutdown in OS X.
;;
;; Borrowed from:
;; http://superuser.com/questions/125569/how-to-fix-emacs-popup-dialogs-on-mac-os-x
(defadvice yes-or-no-p (around prevent-dialog activate)
  "Prevent yes-or-no-p from activating a dialog"
  (let ((use-dialog-box nil))
    ad-do-it))
(defadvice y-or-n-p (around prevent-dialog-yorn activate)
  "Prevent y-or-n-p from activating a dialog"
  (let ((use-dialog-box nil))
    ad-do-it))


;;; EDITING OPTIONS

;; Text mode abbreviations
(setq-default abbrev-mode t)
(setq abbrev-file-name (concat user-emacs-directory "abbrev_defs")
      save-abbrevs     t)

;; Quick entry for commonly used symbols
(defconst specialchar-en-dash #x2013)
(defconst specialchar-em-dash #x2014)
(global-set-key "\C-c-" (lambda (&optional arg)
                          (interactive "*P")
                          (if arg
                              (ucs-insert specialchar-em-dash)
                            (ucs-insert specialchar-en-dash))))

;; Set up syntax coloring
(global-font-lock-mode 1)

;; Turn on paren matching (this is a Lisp editor, is it not?)
(show-paren-mode t)
(setq show-paren-style 'mixed)

;; ;; Use spaces for indentation, not tab chracters
(setq-default indent-tabs-mode nil
              tab-width 8)
(setq standard-indent 4
      c-indent-level 4)

;; Always use auto-fill in text mode; wrap to 75 characters by default
(setq-default fill-column 75)

;; Show trailing whitespace
(if (>= emacs-major-version 21)
    (setq show-trailing-whitespace t))

;; Swap to C-j for raw newline, C-m for newline-and-indent because we will
;; typically want to indent when we press the Enter key
(global-set-key "\C-m" 'newline-and-indent)
(global-set-key "\C-j" 'newline)
(global-set-key (kbd "<C-M-return>") 'indent-new-comment-line)

;; Shortcut to enable flyspell for buffer
(global-set-key "\C-cs" 'flyspell-enable)

;; Another keystroke alias for this command, which should work reliably in
;; the terminal.
(global-set-key "\C-c," 'flyspell-goto-next-error)

;; Always start a new ispell process for flyspell checking; to not do so is
;; unbearably slow with aspell on Windows.
(setq flyspell-large-region 0)

;; Global command for entering iimage-mode
(global-set-key "\C-ci" 'iimage-mode)

;; Don't nag about saving the personal dictionary every time we add a new
;; word with ispell
(setq ispell-silently-savep t)

;; Don't spell check HTML/XML tags and attributes
(set-default 'ispell-skip-html t)

;; Blame mode formatting
(setq git-blame-prefix-format "%h %28.28A:")

;; Auto complete options
(when (featurep 'auto-complete-config)
  (add-to-list 'ac-dictionary-directories (concat user-elisp-directory
                                                  "auto-complete/dict"))
  (ac-config-default))

;; Yasnippet options
(when (featurep 'yasnippet)
  (setq yas/prompt-functions '(yas/dropdown-prompt
                               yas/ido-prompt
                               yas/x-prompt
                               yas/completing-prompt
                               yas/no-prompt))
  (yas/load-directory (concat user-elisp-directory "yasnippet/snippets/")))


;;; CUSTOM COMMANDS

(global-set-key "\C-cu" 'calc)
(global-set-key "\C-cm" 'timestamp-insert)
(global-set-key "\C-cg" 'create-tags)
(global-set-key "\C-cp" 'compile)


;;; EXTERNAL PROGRAMS

(defvar ctags-program-name "ctags")


;;; SLIME

;; Use Paredit in Inferior SLIME
(when (featurep 'slime)
  (add-paredit-hook slime-repl-mode)
  (add-hook 'slime-repl-mode-hook
            (lambda ()
              (make-local-variable 'scroll-margin)
              (setq scroll-margin 0)))
  (slime-setup '(slime-repl)))

;; Settings for swank-chicken if it's installed
(when (featurep 'chicken-slime)
  (setq swank-chicken-path (concat user-elisp-directory
                                   "swank-chicken/swank-chicken.scm"))
  (add-hook 'scheme-mode-hook
            (lambda ()
              (slime-mode t))))


;;; PYMACS

(when (featurep 'pymacs)
  (pymacs-load "ropemacs" "rope-")
  (setq ropemacs-enable-autoimport t))


;;; Factor FUEL

(add-hook 'fuel-listener-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))


;;; TRAMP

;; Assume SCP if no explicit method
(setq tramp-default-method "scp")


;;; LOCAL SETTINGS

;; Retrieve any local configurations from ~/.emacs.local.el, if the file
;; exists on this system
(let ((local-settings "~/.emacs.local.el"))
  (if (file-exists-p local-settings)
      (load-file local-settings)))

;; Borrowed from: http://goo.gl/Q3qpr
(defun mrc-xwin-look (frame)
  "Setup to use if running in an X window"
  (when (and (boundp 'color-theme-local)
             (not (null color-theme-local)))
    (require 'color-theme)
    (color-theme-initialize)
    (funcall color-theme-local)))

(defun mrc-terminal-look (frame)
  "Setup to use if running in a terminal")

(defun mrc-setup-frame (frame)
  (set-variable 'color-theme-is-global nil)
  (select-frame frame)
  (cond
   ((window-system)
    (mrc-xwin-look frame)
    (tool-bar-mode -1))
   (t (mrc-terminal-look frame))))

(add-hook 'after-make-frame-functions 'mrc-setup-frame)

(add-hook 'after-init-hook
          (lambda ()
            (mrc-setup-frame (selected-frame))))


;;; ORG MODE / DIARY

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cb" 'org-iswitchb)
(global-set-key "\C-ck" 'mshroyer/org-show-unblocked-todo-tree)
(global-set-key "\C-ci" 'mshroyer/org-show-inbox)

(setq org-agenda-files (mapcar (lambda (file)
                                 (concat org-directory file))
                               '("/todo.org"))
      diary-file (concat org-directory "/diary")

      org-agenda-include-diary t
      org-enforce-todo-dependencies t
      org-agenda-dim-blocked-tasks nil
      org-agenda-todo-ignore-scheduled nil
      org-agenda-remove-tags 'prefix
      org-deadline-warning-days 7
      org-stuck-projects '("+LEVEL=1/-DONE"
                           ("TODO" "WAIT")
                           nil
                           nil)

      org-agenda-custom-commands
      '(("a" agenda "Agenda")
        ("w" "Waiting-for items by context" todo "WAIT"
         ((org-agenda-sorting-strategy '(todo-state-up tag-up time-up))
          (org-agenda-prefix-format "")
          (org-agenda-todo-keyword-format "")
          (org-agenda-skip-function 'mshroyer/org-skip-inactive)))
        ("d" "Non-dated action items by context" todo "TODO"
         ((org-agenda-sorting-strategy '(todo-state-up tag-up time-up))
          (org-agenda-prefix-format "%16T:")
          (org-agenda-todo-keyword-format "")
          (org-agenda-skip-function 'mshroyer/org-skip-inactive)))))

(defun mshroyer/org-todo-active-p ()
  "Determines whether the current todo item is active

Returns non-nil if the todo item currently under the point can
currently be worked on; returns nil if the item is blocked from
completion by either dependency on another todo item or because
it is scheduled at a future timestamp.

We use this as a custom skip function for org todo views rather
than just setting org-agenda-dim-blocked-tasks because we still
want to show blocked deadline tasks on the agenda view.
Likewise, we use a custom implementation of future scheduled
tasks logic rather than set org-agenda-todo-ignore-scheduled to
'future because, because that only ignores tasks on future dates;
it doesn't work for future timestamps on the current date."
  (let* ((subtree-end (save-excursion
                        (org-end-of-subtree t)))
         (scheduled-time (save-excursion
                           (if (re-search-forward org-scheduled-time-regexp
                                                  subtree-end t)
                               (org-time-string-to-time (match-string 1))
                             nil)))
         (time> (lambda (a b)
                  (cond ((not (car a))       nil)
                        ((not (car b))       t)
                        ((< (car a) (car b)) nil)
                        ((> (car a) (car b)) t)
                        (t (funcall time> (cdr a) (cdr b)))))))
    (save-excursion
      (and (reduce (lambda (a b)
                     (and a b))
                   (mapcar (lambda (f)
                             (funcall (symbol-function f)
                                      '(:type todo-state-change :to done)))
                           org-blocker-hook))
           (not (and scheduled-time
                     (funcall time> scheduled-time (org-current-time))))))))

(defun mshroyer/org-skip-inactive ()
  "Skip function based on mshroyer/org-todo-active-p"
  (let ((subtree-end (save-excursion
                       (org-end-of-subtree t))))
    (if (mshroyer/org-todo-active-p)
        nil
      subtree-end)))

(defun mshroyer/org-show-inbox ()
  "Show the Org Mode GTD inbox file"
  (interactive)
  (find-file (concat org-directory "/inbox.org")))

(defun mshroyer/org-show-unblocked-todo-tree ()
  "Show currently unblocked action items

Builds a sparse tree which highlights only action items which are
not blocked by other tasks and which are not scheduled into the
future."
  (interactive)
  (find-file (concat org-directory "/todo.org"))
  (org-occur (concat "^" org-outline-regexp " *" org-not-done-regexp)
             nil
             'mshroyer/org-todo-active-p))

;; Setup org capture, but only if we're using a newer version of Org Mode
;; that includes this feature...
(when (require 'org-capture nil t)
  (setq org-default-notes-file (concat org-directory "/inbox.org")
        org-capture-templates
        '(("i" "Inbox" entry (file (concat org-directory "/inbox.org"))
           "* %?\n"))
        org-refile-use-outline-path t
        org-outline-path-complete-in-steps nil
        org-refile-targets
        '((("~/org/todo.org") . (:level . 1))))
  (define-key global-map "\C-cc" 'org-capture))

; Only show holidays that I actually care about
(setq calendar-holidays
      '((holiday-fixed 1 1 "New Year's Day")
        (holiday-float 1 1 3 "Martin Luther King Day")
        (holiday-fixed 2 2 "Groundhog Day")
        (holiday-fixed 2 14 "Valentine's Day")
        (holiday-float 2 1 3 "President's Day")
        (holiday-fixed 3 17 "St. Patrick's Day")
        (holiday-fixed 4 1 "April Fools' Day")
        (holiday-float 5 0 2 "Mother's Day")
        (holiday-float 5 1 -1 "Memorial Day")
        (holiday-fixed 6 14 "Flag Day")
        (holiday-float 6 0 3 "Father's Day")
        (holiday-fixed 7 4 "Independence Day")
        (holiday-float 9 1 1 "Labor Day")
        (holiday-float 10 1 2 "Columbus Day")
        (holiday-fixed 10 31 "Halloween")
        (holiday-fixed 11 11 "Veteran's Day")
        (holiday-float 11 4 4 "Thanksgiving")
        (holiday-easter-etc)
        (holiday-fixed 12 25 "Christmas")
        (holiday-chinese-new-year)
        (solar-equinoxes-solstices)
        (holiday-sexp calendar-daylight-savings-starts
                      (format "Daylight Saving Time Begins %s"
                              (solar-time-string
                               (/ calendar-daylight-savings-starts-time
                                  (float 60))
                               calendar-standard-time-zone-name)))
        (holiday-sexp calendar-daylight-savings-ends
                      (format "Daylight Saving Time Ends %s"
                              (solar-time-string
                               (/ calendar-daylight-savings-ends-time
                                  (float 60))
                               calendar-daylight-time-zone-name)))))


;;; EDITING MODE HOOKS AND SETTINGS

;; Org mode...

; Backtab in terminal emulators such as gnome-terminal, konsole, etc.:
(define-key org-mode-map "\M-[z" 'org-shifttab)
; Use C-ct as an alternative for C-cC-t, so that we don't have to use quite
; as many keystrokes with GNU Screen's escape bound to C-t
(define-key org-mode-map "\C-ct" 'org-todo)
(setq org-cycle-separator-lines 2
      org-special-ctrl-a/e t
      org-agenda-start-on-weekday 0
      org-completion-use-ido t
      org-agenda-window-setup 'current-window)
; Always show context when creating sparse trees:
(setq org-show-siblings t)

;; Calendar mode...
(global-set-key "\C-cl" 'calendar)
(add-hook 'calendar-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))

;; Diary mode...
(defun diary-range (first &optional last on-sexps off-sexps)
  "Diary entry for a event spanning over a range of dates."
  (and
   (or (null first)
       (not (calendar-date-compare (list date) (list first))))
   (or (null last)
       (not (calendar-date-compare (list last) (list date))))
   (or (null on-sexps)
       (eql on-sexps t)
       (eval (cons 'or (mapcar #'(lambda (d)
                                   (not (null (eval d)))) on-sexps))))
   (or (null off-sexps)
       (not (eval (cons 'or (mapcar #'(lambda (d)
                                   (not (null (eval d)))) off-sexps)))))
   (cons diary-marking-entries-flag entry)))

(defun diary-weekdays (&rest args)
  (if (find (calendar-day-of-week date) args)
      (cons diary-marking-entries-flag entry)
    nil))

(global-set-key "\C-cd" 'diary)
(add-hook 'diary-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (make-local-variable 'tab-stop-list)
            (setq tab-stop-list '(4 16))
            (local-set-key (kbd "TAB") 'tab-to-tab-stop)))
(setq diary-display-function 'diary-fancy-display)
(add-hook 'list-diary-entries-hook 'include-other-diary-files)
(add-hook 'mark-diary-entries-hook 'mark-included-diary-files)

;; HTML mode...
(add-to-list 'auto-mode-alist '("\\.mtml$" . html-mode))
(add-hook 'html-mode-hook
          (lambda ()
            (auto-fill-mode 0)
            (setq indent-tabs-mode nil)
            (set (make-local-variable 'sgml-basic-offset) 2)
            (sgml-guess-indent)
            (local-set-key "\C-m" 'newline-and-indent)
            (local-set-key "\C-j" 'newline)))

;; Markdown mode...
(setq auto-mode-alist
      (append '(("\\.mk?d$" . markdown-mode)
                ("\\.markdown$" . markdown-mode))
              auto-mode-alist))
(add-hook 'markdown-mode-hook
          (lambda ()
            (auto-fill-mode t)))

;; YAML mode...
(setq auto-mode-alist
      (append '(("\\.yaml$" . yaml-mode))
              auto-mode-alist))
(add-hook 'yaml-mode-hook
          (lambda ()
            (local-set-key "\C-cn" 'new-yaml-ab-entry)
            (make-local-variable 'tab-stop-list)
            (setq tab-stop-list (simple-tab-stop-list 2 75))))

;; C mode...
(setq-default c-block-comment-prefix "* ")
(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))
(c-add-style
 "linux-tabs-only"
 '("linux" (c-offsets-alist
            (arglist-cont-nonempty
             c-lineup-gcc-asm-reg
             c-lineup-arglist-tabs-only))))
(c-add-style
 "ilchymis"
 '("gnu"
   (c-offsets-alist . ((arglist-intro . +)
                       (arglist-cont  . 0)
                       (arglist-close . 0)))
   (c-basic-offset  . 4)))
(add-hook 'c-initialization-hook
          (lambda ()
            (define-key c-mode-base-map "\C-m" 'c-context-line-break)
            (setq c-default-style "ilchymis")))
(add-hook 'c-mode-hook
          (lambda ()
            (make-local-variable 'paragraph-start)
            (setq indent-tabs-mode nil
                  show-trailing-whitespace t
                  paragraph-start "^[ ]*\\(//+\\|\\**\\)[ ]*\\([ ]*$\\|@[a-zA-Z].*\\)\\|^\f")))

;; GUD mode...
(add-hook 'gud-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))

;; ASM mode...
(setq asm-comment-char 59)
(add-hook 'asm-mode-hook
          (lambda ()
            (setq fill-prefix ";; ")
            (setq tab-width 4)
            (make-local-variable 'tab-stop-list)
            (setq tab-stop-list (simple-tab-stop-list 4 75))
            (local-set-key (kbd "TAB") 'tab-to-tab-stop)
            (local-set-key "\C-m" 'newline-and-indent)
            (local-set-key "\C-j" 'newline)))

;; Go mode...
(when (featurep 'go-mode)
  (add-hook 'go-mode-hook
            (lambda ()
              (setq tab-width 4))))

;; Perl mode...
(defalias 'perl-mode 'cperl-mode)
(add-to-list 'auto-mode-alist '("\\.\\([pP][Llm][wW]?\\|al\\|t\\)\\'" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl5" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("miniperl" . cperl-mode))
(setq cperl-close-paren-offset -4
      cperl-continued-statement-offset 4
      cperl-indent-level 4
      cperl-indent-parens-as-block t
      cperl-tab-always-indent t)
(add-hook 'cperl-mode-hook
          (lambda ()
            (set-fill-column 78)
            (setq cperl-indent-level 4)
            (setq cperl-continued-statement-offset 8)
            (abbrev-mode 0)
            (local-set-key "\C-cj" 'perl-doc-sub)
            (local-set-key "\C-cp" 'perl-doc-pod)))

;; Python mode...
(add-hook 'python-mode-hook
          (lambda ()
            (abbrev-mode 0)
            (setq show-trailing-whitespace t)))
(add-hook 'inferior-python-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin         0
                  comint-process-echoes t)))
(when (featurep 'pymacs)
  (pymacs-load "ropemacs" "rope-")
  (setq ropemacs-enable-autoimport t))
(setq python-check-command "pyflakes")

;; JavaScript mode...
(add-to-list 'auto-mode-alist '("\\.js\\'" . javascript-mode))

;; Emacs Lisp mode...
(add-paredit-hook emacs-lisp-mode)

;; Common Lisp mode...
(add-hook 'lisp-mode-hook
          (lambda ()
            (setq lisp-indent-function 'common-lisp-indent-function)))
(add-paredit-hook lisp-mode)

;; Scheme mode...
(add-hook 'scheme-mode-hook
          (lambda ()
            (setq lisp-indent-function 'scheme-indent-function)))
(add-paredit-hook scheme-mode)
(add-hook 'inferior-scheme-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))
(add-paredit-hook inferior-scheme-mode)

;; Clojure mode...
(add-paredit-hook clojure-mode)

;; Scala mode...
(when (featurep 'scala-mode)
  (add-to-list 'auto-mode-alist '("\\.scala$" . scala-mode))
  (add-hook 'scala-mode-hook
            (lambda ()
              (local-set-key (kbd "RET") 'reindent-then-newline-and-indent)))
  (when (featurep 'yasnippet)
    (yas/load-directory (concat user-elisp-directory
                                "scala-mode/contrib/yasnippet/"))
    (add-hook 'scala-mode-hook
              (lambda ()
                (yas/minor-mode-on)))))

;; Lua mode...
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;; Groovy mode...
(add-to-list 'auto-mode-alist '("\\.groovy$" . groovy-mode))
(add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode))

;; Haskell mode...
(load "haskell-site-file" t)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
;(if (featurep 'haskell-mode)
;    (setq haskell-indent-look-past-empty-line nil))
(add-hook 'inferior-haskell-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))

;; Erlang mode...
(add-to-list 'auto-mode-alist '("\\.erl$" . erlang-mode))
(add-hook 'erlang-shell-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))

;; Vala mode...
(add-to-list 'auto-mode-alist '("\\.vala$" . vala-mode))
(add-to-list 'auto-mode-alist '("\\.vapi$" . vala-mode))
(add-to-list 'file-coding-system-alist '("\\.vala$" . utf-8))
(add-to-list 'file-coding-system-alist '("\\.vapi$" . utf-8))

;; C# mode...
(add-to-list 'auto-mode-alist '("\\.cs$" . csharp-mode))

;; F# mode...
(add-to-list 'auto-mode-alist '("\\.fs[iylx]?$" . fsharp-mode))
(add-hook 'inferior-fsharp-mode-hooks
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))

;; Tuareg mode...
(setq auto-mode-alist (append '(("\\.ml[iylp]?$" . tuareg-mode))
                              auto-mode-alist))
(add-hook 'tuareg-interactive-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))

;; Visual Basic mode...
(setq auto-mode-alist (append '(("\\.\\(frm\\|bas\\|vbs\\|cls\\)$" .
                                visual-basic-mode)) auto-mode-alist))
(setq visual-basic-mode-indent 4)

;; PowerShell mode...
(setq auto-mode-alist (append '(("\\.\\ps1$" . powershell-mode))
                              auto-mode-alist))

;; PHP mode...
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))

;; Text mode...
(define-key text-mode-map "\C-m" 'newline)
(define-key text-mode-map "\C-j" 'newline-and-indent)
(define-key text-mode-map "\C-cn" 'new-journal-entry)
(add-hook 'text-mode-hook
          (lambda ()
            (setq tab-width 8
                  indent-tabs-mode t)
            (auto-fill-mode 1)))

;; Paragraph indent text mode...
(add-to-list 'auto-mode-alist '("\\.txt$" . text-mode))

;; AUCTeX / LaTeX mode...
(when (featurep 'tex-site)
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (local-set-key "\C-m" 'newline-and-indent)
              (local-set-key "\C-j" 'newline)
              (setq tab-width 4)
              (auto-fill-mode 1))))

;; Mail mode...
(add-to-list 'auto-mode-alist '("mutt-.*" . mail-mode))
(add-hook 'mail-mode-hook
          (lambda ()
            (set-fill-column 72)
            (flyspell-enable)
            (search-forward "-- ")
            (previous-line)
            (open-line 1)))

;; Shell mode...
(add-hook 'shell-mode-hook
          (lambda ()
            (make-local-variable 'scroll-margin)
            (setq scroll-margin 0)))


;;; HACKED BUILTIN FUNCTIONS

;; Modify this asm-mode function so that FASM "private" labels (beginning
;; with a period) are also indented correctly...
(defun asm-colon ()
  "Insert a colon; if it follows a label, delete the label's indentation."
  (interactive)
  (let ((labelp nil))
    (save-excursion
      (skip-syntax-backward "w_.")
      (skip-syntax-backward " ")
      (if (setq labelp (bolp)) (delete-horizontal-space)))
    (call-interactively 'self-insert-command)
    (when labelp
      (delete-horizontal-space)
      (tab-to-tab-stop))))


;;; CUSTOM EXTENDED COMMANDS

;; Show an ASCII table
;; (Inspired by http://www-cdf.fnal.gov/~sthrlnd/emacs_help.html)
(defun ascii-table ()
  "Show a table of ASCII characters by decimal, hex, and octal value."

  (interactive)
  (switch-to-buffer "*ASCII*")
  (erase-buffer)
  (let ((min 1) (max 255)
        (special-chars '(
                         (1 . "%c  SOH (start of heading)")
                         (2 . "%c  STX (start of text)")
                         (3 . "%c  ETX (end of text)")
                         (4 . "%c  EOT (end of transmission)")
                         (5 . "%c  ENQ (enquiry)")
                         (6 . "%c  ACK (acknowledge)")
                         (7 . "%c  BEL (bell)")
                         (8 . "%c  BS  (backspace)")
                         (9 . "    TAB (horizontal tab)")
                         (10 . "    LF  (NL line feed, new line)")
                         (11 . "%c  VT  (vertical tab)")
                         (12 . "    FF  (NP form feed, new page)")
                         (13 . "%c  CR  (carriage return)")
                         (14 . "%c  SO  (shift out)")
                         (15 . "%c  SI  (shift in)")
                         (16 . "%c  DLE (data link escape)")
                         (17 . "%c  DC1 (device control 1)")
                         (18 . "%c  DC2 (device control 2)")
                         (19 . "%c  DC3 (device control 3)")
                         (20 . "%c  DC4 (device control 4)")
                         (21 . "%c  NAK (negative acknowledge)")
                         (22 . "%c  SYN (synchronous idle)")
                         (23 . "%c  ETB (end of trans. block)")
                         (24 . "%c  CAN (cancel)")
                         (25 . "%c  EM  (end of medium)")
                         (26 . "%c  SUB (substitute)")
                         (27 . "%c  ESC (escape)")
                         (28 . "%c  FS  (file separator)")
                         (29 . "%c  GS  (group separator)")
                         (30 . "%c  RS  (record separator)")
                         (31 . "%c  US  (unit separator)")
                         (32 . "%c       (space)")
                         (9999)
                         )))
    (insert (format "ASCII characters %d-%d\n\n" min max))
    (insert " Dec   Hex   Oct    Character\n")
    (let ((i 0))
      (while (< i 60)
        (insert "=")
        (setq i (+ i 1))))
    (insert "\n")
    (let ((i min))
      (while (<= i max)
        (let ((line "%4d  0x%02X  %04o    ") (char "%c"))
          (while (> i (car (car special-chars)))
            (setq special-chars (cdr special-chars)))
          (if (= (car (car special-chars)) i)
              (setq char (cdr (car special-chars))))
          (insert (format (concat line char "\n") i i i i))
          (setq i (+ i 1))))))
  (beginning-of-buffer))


;; Yoinked from http://stackoverflow.com/questions/1242352/get-font-face-under-cursor-in-emacs
(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))


;; Generate tags for directory with Exuberant Ctags
(defun create-tags (dir-name)
  "Create tags file with Exuberant Ctags."
  (interactive "DDirectory: ")

  ;; We have to manually expand the tilde for Windows...
  (let ((dir-file (replace-regexp-in-string "^~"
                                            (replace-regexp-in-string "\\\\"
                                                                      "/"
                                                                      (getenv "HOME"))
                                            (directory-file-name dir-name))))
    (shell-command (format "\"%s\" -f \"%s/TAGS\" -e -R \"%s\""
                   ctags-program-name
                   dir-file
                   dir-file))))


(defun prompt-user-selection (choices &optional message)
  "Prompt user to make selection from given set of choices

The selection is specified as an assoc list of single-character
strings to choice descriptions, e.g.:

\(prompt-user-selection '((\"1\" . \"one\")
                         (\"2\" . \"two\"))\)

Choices are case-sensitive.  The function keeps prompting until
user makes a valid selection, or presses the quit keystroke.  The
return value is the chosen assoc list element; to get just the
user's choice, take the car of the return value.  An optional
message argument causes this function to display the given
message as a prompt above the list of choices.
"

  (let ((answer nil))
    (while (null answer)

      ;; Show a list of choices
      (unless (null message)
        (princ (concat message "\n\n") t))
      (dolist (option choices)
        (princ (concat (car option)
                       ": "
                       (cdr option)
                       "\n")
               t))

      ;; Wait for the user to make a selection
      (setq answer (assoc (char-to-string (read-char))
                          choices)))
    answer))


(defun perl-doc-sub ()
  "Insert standard comment for a Perl sub

Creates a comment for the current sub, if any, which follows the
basic format outlined in _Perl Best Practices_.
"

  (interactive)
  (move-end-of-line nil)
  (if (search-backward-regexp "^sub\s")
      (let* ((sub-choices '(("c" . "CLASS METHOD")
                            ("i" . "INSTANCE METHOD")
                            ("s" . "INTERFACE SUB")
                            ("u" . "INTERNAL UTILITY")))
             (sub-label (cdr (prompt-user-selection sub-choices
                                                    "Choose subroutine type:"))))
        (progn (insert "### " sub-label " ###\n"
                       "# Purpose    : \n"
                       "# Returns    : \n"
                       "# Parameters : \n"
                       "# Throws     : No exceptions\n"
                       "# Comments   : None\n"
                       "# See Also   : N/A\n")
               (previous-line 6)
               (move-end-of-line nil)))))


(defun perl-doc-pod ()
  "Insert a Perl POD documentation template for the current module"

  (interactive)
  (let* ((doc-choices '(("m" . "MODULE")
                        ("a" . "APPLICATION")))
         (doc-type (car (prompt-user-selection doc-choices
                                               "Choose POD documentation template:")))
         (doc-template-dir (concat user-emacs-directory "templates/documentation/"))
         (doc-template-file (cond
                             ((equal doc-type "m") "perl-pod-module")
                             ((equal doc-type "a") "perl-pod-application")))
         (lic-choices '(("n" . "NONE")
                        ("p" . "PERL ARTISTIC")
                        ("a" . "APACHE")))
         (lic-type (car (prompt-user-selection lic-choices
                                               "Choose a software license:")))
         (lic-template-dir (concat user-emacs-directory "templates/license/"))
         (lic-template-file (cond
                             ((equal lic-type "p") "perl-artistic")
                             ((equal lic-type "a") "apache"))))
    (end-of-buffer)
    (insert-file-contents (concat doc-template-dir doc-template-file))
    (if lic-template-file
        (progn
          (end-of-buffer)
          (insert-file-contents (concat lic-template-dir lic-template-file))))))


(defun calendar-zone-to-tz-offset (minutes)
  "Converts minutes off from UTC into a TZ offset string

Converts from a number of minutes off from UTC (as in the
calendar-time-zone variable) to a timezone specification in the
format returned by (format-time-string \"%z\" now).
"

  (let ((sign ""))
    (when (< minutes 0)
      (setq minutes (* minutes -1)
            sign    "-"))
    (concat sign (format "%02d%02d" (floor minutes 60) (mod minutes 60)))))


(defun timestamp-string ()
  "Returns a Unix date(1)-format timestamp

Will try figure out the timezone name from your
calendar-standard-time-zone-name and
calendar-daylight-time-zone-name variables if the system doesn't
return a time zone name -- as with NT Emacs as of version 23.2,
for example.
"

  (let* ((now (current-time))
         (str-date (format-time-string "%a %b %e" now))
         (str-time (format-time-string "%H:%M:%S" now))
         (sys-tz   (format-time-string "%Z" now))
         (str-year (format-time-string "%Y" now))
         (str-tz (if (> (length sys-tz) 0)
                     sys-tz
                     (let ((off-tz (format-time-string "%z" now)))
                       (cond ((equal off-tz
                                     (calendar-zone-to-tz-offset
                                      calendar-time-zone))
                              calendar-standard-time-zone-name)

                             ((equal off-tz
                                     (calendar-zone-to-tz-offset
                                      (+ 60 calendar-time-zone)))
                              calendar-daylight-time-zone-name)

                             (t
                              nil))))))
    (if str-tz
        (concat str-date " " str-time " " str-tz " " str-year)
        (concat str-date " " str-time " " str-year))))


(defun timestamp-insert ()
  "Inserts a Unix date(1)-format timestamp in the current buffer"

  (interactive)
  (insert (timestamp-string)))


;; Create a new journal entry
(defun new-journal-entry ()
  "Make a new journal entry with a Unix `date`-style timestamp"

  (interactive)
  (end-of-buffer)
  (if (re-search-backward "[^ \t\n]" nil t)
      (progn
        (end-of-line)
        (let ((beg (point)))
          (end-of-buffer)
          (delete-region beg (point)))
        (dotimes (i 3)
          (newline))))
  (insert (timestamp-string))
  (dotimes (i 2)
    (newline)))


;; New YAML address book item
(defun new-yaml-ab-entry ()
  "Make a new entry in a YAML address book"

  (interactive)

  (if (re-search-backward "^\\\.\\\.\\\.$" nil t)
      (next-line)
    (beginning-of-buffer))
  (insert "---")
  (newline)

  (mapcar (lambda (item)
            (let ((name   (car item))
                  (tabify (cdr item)))
              (when tabify
                (tab-to-tab-stop))
              (insert (concat name ": "))
              (newline)))
          '(("name"      . nil)
            ("family"    . t)
            ("given"     . t)
            ("email"     . nil)
            ("telephone" . nil)
            ("mobile"    . t)
            ("address"   . nil)
            ("street"    . t)
            ("city"      . t)
            ("state"     . t)
            ("zip"       . t)))

  (insert "...")
  (newline)

  (re-search-backward "^---$")
  (dotimes (i 2)
    (next-line))
  (end-of-line))


;; Count words in region (like M-= except for words)
(defun wc ()
  (interactive)
  (message "Word count: %s" (how-many "\\w+" (point-min) (point-max))))


;; Consolidate flyspell commands
(defun flyspell-enable ()
  "Enable flyspell for the current buffer"

  (interactive)

  (flyspell-mode 1)
  (flyspell-buffer))


;;; EDITOR SERVERS

;; Builtin Emacs server
(when (should-start-server :emacs)
  (server-start)

  ;; Open files for "emacsclient" in a new frame...
  (add-hook 'server-switch-hook
            (lambda ()
              (let ((server-buf (current-buffer)))
                (bury-buffer)
                (switch-to-buffer-other-frame server-buf))))

  ;; ...and clean up when we're done with the client.
  (add-hook 'server-done-hook
            (if (>= emacs-major-version 23)

                ;; It seems that Emacs 23 takes care of closing the
                ;; emacslcient frame for us, so if we're using that version
                ;; we don't need to explicitly delete the frame; doing so
                ;; will inadvertently delete the last used GUI emacsclient
                ;; frame as well.
                (lambda ()
                  (kill-buffer nil)
                  (redraw-display))

              (lambda ()
                (kill-buffer nil)
                (delete-frame)
                (redraw-display)))))

;; Chrome "Edit with Emacs" server
;; https://chrome.google.com/extensions/detail/ljobjlafonikaiipfkggjbhkghgicgoh
(when (and (featurep 'edit-server)
           (should-start-server :chrome-edit))

  (edit-server-start)

  ;; Enable word wrap in the edit window
  (add-hook 'edit-server-text-mode-hook
            (lambda ()
              (auto-fill-mode nil)
              (longlines-mode t))))


;; Custom variables from the Emacs configuration editor
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(LaTeX-verbatim-environments (quote ("verbatim" "verbatim*" "Verbatim")))
 '(safe-local-variable-values (quote ((TeX-master . "manual") (TeX-master . t)))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(fixed-pitch ((t (:inherit nil)))))


