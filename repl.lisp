;;;; repl.lisp

(in-package #:kerfuffle)

(defvar *repl-environment* (make-instance 'kernel-environment :bindings nil :parents (list *ground-environment*)))

(defun repl ()
  (let ((*package* (find-package '#:kerfuffle)) ; make sure symbols work alright
	(*readtable* (make-kernel-readtable)))
    (with-simple-restart (abort "Return to CL.")
      (loop
	 (with-simple-restart (abort "Return to Kerfuffle.")
	   (fresh-line)
	   (princ "KERFUFFLE> ")
	   (let ((form (read)))
	     (fresh-line)
	     (write (eval form *repl-environment*))))))))
