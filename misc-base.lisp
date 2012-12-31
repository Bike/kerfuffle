;;;; misc-base.lisp
;;;; early misc utils

(in-package #:kerfuffle)

(defmacro defconst/bound (name value &optional documentation)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (unless (boundp ',name)
       (defconstant ,name ,value ,@(when documentation (list documentation))))))
