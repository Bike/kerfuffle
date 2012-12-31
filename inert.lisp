;;;; inert.lisp

(in-package #:kerfuffle)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defstruct inert))

(defmethod print-object ((object inert) stream)
  (princ "#inert" stream)
  object)

(defconst/bound +INERT+ (make-inert))
