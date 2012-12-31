;;;; bool.lisp
;;;; kernel booleans

(in-package #:kerfuffle)

(defstruct kbool (val))

(defmethod print-object ((object kbool) stream)
  (princ (if (kbool-val object) "#t" "#f") stream)
  object)

(defun kbool (val)
  (if (kbool-p val)
      val
      (make-kbool :val val)))
