;;;; package.lisp

(defpackage #:kerfuffle
  (:use #:cl #:alexandria)
  (:export #:repl #:*repl-environment*)
  (:export #:eval #:combine)
  (:export #:kernel-read #:kernel-read-from-string)
  (:shadow #:eval))
