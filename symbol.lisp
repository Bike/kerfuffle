;;;; symbol.lisp

(in-package #:kerfuffle)

(deftype ksymbol () 'symbol)

(defun ksymbol (sym) sym)
(defun ksymbolp (obj) (typep obj 'ksymbol))

