;;; package --- Emacs init.el file
;;; Commentary:

;;; Code:

(load "~/myconf/emacs/basic.el")
(load "~/myconf/emacs/loader.el")
(load "~/myconf/emacs/packages.el")
(setq custom-file "~/myconf/emacs/custom.el")
(load custom-file)
;;; init.el ends here
(put 'scroll-left 'disabled nil)
