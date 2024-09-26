Mark Shroyer's Emacs Dotfiles
=============================

This is my global Emacs configuration directory, `~/.emacs.d/`.  It
contains my Emacs settings and abbreviation files, as well as numerous
extensions for the editor which I have either copied from elsewhere or
written myself.


Installation
------------

Aside from checking out this repository to `~/.emacs.d/`, no special
installation actions are required on Unix-like systems.  However, make sure
you don't have an old `~/.emacs` or `~/.emacs.el` file sitting around on
your system, as this will supersede `~/.emacs.d/init.el` in GNU Emacs's
search path.

Also, if you're installing on Windows, set the environment variable HOME to
reference your home directory.  If this variable is not set my Emacs
startup script will attempt to infer it from the Windows HOMEDRIVE and
HOMEPATH variables, but I don't know how reliable this method is.


External Dependencies
---------------------

External dependencies are installed from the ELPA and MELPA Stable
repositories, and are managed using the selected packages mechanism.  When
setting up this configuration on a new machine, install these dependencies
by running:

    M-x package-install-selected-packages

Then restart Emacs.


Local Customizations
--------------------

My startup script will look for a file named `~/.emacs.local.el`; if it is
found, this file will be loaded during Emacs startup.  This provides a
method for making machine-local customizations to the Emacs startup.

Provided below is a collection of some local customization recipes that may
prove useful:

### Default coding system for new files ###

    (setf (default-value 'buffer-file-coding-system) 'utf-8-unix)

### Common Lisp implementation for SLIME ###

    (when (featurep 'slime)
      (setq inferior-lisp-program "clisp")
      (add-to-list 'slime-lisp-implementations '(clisp ("clisp"))))

### Tramp settings compatible with both Cygwin and NT Emacs ###

    (if (eql system-type 'windows-nt)
	(setq tramp-default-method "plink")
      (setq tramp-default-method "ssh"))

### Specify edit servers to run ###

    (setq local-server-selection '(:emacs))

### PostScript printing on Windows ###

Adjust `ps-lpr-command` for your machine's `gswin32c.exe` executable path.

    (setq ps-lpr-command "C:/Program Files/gs/gs8.64/bin/gswin32c.exe"
	  ps-lpr-switches '("-q" "-dNOPAUSE" "-dBATCH" "-sDEVICE=mswinpr2")
	  ps-printer-name t)

### Geographic details ###

    (setq calendar-longitude -80.39
	  calendar-latitude 27.64
	  calendar-location-name "Vero Beach, FL")

    (setq calendar-time-zone -300
	  calendar-standard-time-zone-name "EST"
	  calendar-daylight-time-zone-name "EDT")

### Enable a color theme ###

    (setq local-color-theme 'color-theme-classic)

### M-x sudoku skill level ###

    (setq sudoku-level "medium")
hi
there
