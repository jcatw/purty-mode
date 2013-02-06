;;; purty-mode.el --- Safely pretty-print greek letters, mathematical
;;; symbols, or anything else.

;; Author: James Atwood <jatwood@cs.umass.edu>

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This source is essentially an extension of Mark Trigg's lambda-mode.el.

;; purty-mode is a minor mode which swaps whatever-regexp-you-want for
;; whatever-symbol-you-want on the fly.  Given that the text itself is
;; left untouched, purty-mode can safely be used when writing code or
;; latex or org or whatever.

;;; Setup:

;; Just place purty-mode.el somewhere on your load path, and add
;; (require 'purty-mode) to your .emacs.

;;; Customization:

;; Substitutions can be added by appending (regexp . string) pairs to
;; purty-regexp-symbol-pairs:
;;
;;    (setq purty-regexp-symbol-pairs (cons '(" Xi " . " Ξ ") purty-regexp-symbol-pairs))

;;; Code:
(defvar purty-regexp-symbol-pairs
  '(;; greek symbols
	("[\\]?alpha"		. "α")
	("[\\]?beta"		. "β")
	("[\\]?gamma"		. "γ")
	("[\\]?epsilon"		. "ε")
	("[\\]?lambda"		. "λ")
	("[\\]?mu"		. "μ")
	("[\\]?pi"		. "π")
	("[\\]?theta"		. "θ") 
	 
    ;; operators	    
	("[\\]?[Ss]um"		. "Σ")
	("[\\]?[Pp]roduct"	. "Π")
	("[\\]prod"		. "Π")
	("[Ee]lement"		. "∈")
	("[\\]in"		. "∈")))
	
  "List of (regexp . string) pairs to be substituted when
  purty-mode is active.  Substitutions can be added by appending
  pairs:

    (setq purty-regexp-symbol-pairs (cons '(\" Xi \" . \" Ξ \") purty-regexp-symbol-pairs))"

(setq purty-regexp-symbol-pairs
  )

(defun purty-fontify (beg end)
  (save-excursion
    (purty-unfontify beg end)
    (purty-fontify-symbols beg end purty-regexp-symbol-pairs)))
      

(defun purty-fontify-symbols (beg end regexp-symbol-pairs)
  (cond ((not regexp-symbol-pairs) t)
	(t (purty-fontify-symbol beg end (car regexp-symbol-pairs))
	   (purty-fontify-symbols beg end (cdr regexp-symbol-pairs)))))

(defun purty-fontify-symbol (beg end regexp-symbol-pair)
  (save-excursion
    (goto-char beg)
    (let ((reg (car regexp-symbol-pair))
	  (sym (cdr regexp-symbol-pair)))
      (while (re-search-forward reg end t)
	(let ((o (car (overlays-at (match-beginning 0)))))
	  (unless (and o (eq (overlay-get o 'type) 'purty))
	    (let ((overlay (make-overlay (match-beginning 0) (match-end 0))))
	      (overlay-put overlay 'type 'purty)
	      (overlay-put overlay 'evaporate t)
	      (overlay-put overlay 'display sym))))))))

(defun purty-unfontify (beg end)
  (mapc #'(lambda (o)
            (when (eq (overlay-get o 'type) 'purty)
              (delete-overlay o)))
        (overlays-in beg end)))

(define-minor-mode purty-mode
  "Indicate where only a single space has been used."
  nil " purty" nil
  (cond ((not purty-mode)
         (jit-lock-unregister 'purty-fontify)
         (purty-unfontify (point-min) (point-max)))
        (t (purty-fontify (point-min) (point-max))
           (jit-lock-register 'purty-fontify))))


(provide 'purty-mode)
;;; purty-mode.el ends here
