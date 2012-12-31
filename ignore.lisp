;;;; ignore.lisp

(in-package #:kerfuffle)

(eval-when (:compile-toplevel :load-toplevel :execute)
  ;; whoops, CL:IGNORE exists -_-
  (defstruct %ignore))

(defmethod print-object ((object %ignore) stream)
  (princ "#ignore" stream)
  object)

(defconst/bound +IGNORE+ (make-%ignore))
