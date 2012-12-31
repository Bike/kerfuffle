;;;; primdef.lisp
;;;; utilities for defining kernel primitives

(in-package #:kerfuffle)

;;;; macros in this file expand into calls to functions that won't be defined until later.
;;;; (this is of course ok, i just wanted to note it)

;;;; this also means that NIL is used instaed of #ignore to indicate an ignored parameter.

(defun ll->ptree-bindings (lambda-list top)
  ;; takes a CL macro lambda-list (except without keyword stuff, &environment, or &whole)
  ;; (that is, it's a list, not a kernel list)
  (let (binds)
    (labels ((aux (ll path)
	       (cond ((null ll))
		     ((symbolp ll) (push (cons ll path) binds))
		     ((not (listp ll)) (error "bad lambda-list"))
		     ((symbolp (car ll))
		      (case (car ll)
			((&optional)
			 (let ((bind (second ll)))
			   (push (list (if (consp bind) (first bind) bind)
				       `(if (knull ,path)
					    ,(if (consp bind) (second bind) nil) ; default
					    (kar ,path)))
				 binds)
			   (when (and (consp bind) (third bind))
			     (push (list (third bind) `(knull ,path)) binds)))
			 (aux (cddr ll) `(kdr ,path)))
			((&rest)
			 (push (list (second ll) path) binds)
			 (assert (null (cddr ll))))
			(otherwise (push (list (car ll) `(kar ,path)) binds)
				   (aux (cdr ll) `(kdr ,path)))))
		     (t (aux (car ll) `(kar ,path))
			(aux (cdr ll) `(kdr ,path))))))
      (aux lambda-list top)
      binds)))

(defun ll->typecheck (lambda-list)
  ;; TODO: spice up (wow)
  (declare (ignore lambda-list))
  ;; but, no primitive combinator works on a nonpair (like (combiner . 4)) I don't think
  'klist)

;; FIXME: these may cause spurious warnings if formals is nil?

(defun parse-operative (formals eformal body)
  (check-type eformal (or ksymbol %ignore))
  (with-gensyms (object env)
  `(lambda (,object ,(if (null eformal) env eformal))
     (declare ,@(when (null eformal) (list `(ignore ,env))))
     (check-type ,object ,(ll->typecheck formals))
     (let (,@(ll->ptree-bindings formals object))
       ,@body))))

(defun parse-applicative (formals body)
  (with-gensyms (object env)
    `(lambda (,object ,env)
       (declare (ignore ,env))
       (check-type ,object ,(ll->typecheck formals))
       (let (,@(ll->ptree-bindings formals object))
	 ,@body))))

(defmacro define-ground-operative (name formals eformal &body body)
  `(kset *ground-environment*
	 (ksymbol ',name)
	 ,(parse-operative formals eformal body)))

(defmacro kvau (args envparam &body body)
  (parse-operative args envparam body))

(defmacro define-ground-applicative (name formals &body body)
  `(kset *ground-environment*
	 (ksymbol ',name)
	 (wrap ,(parse-applicative formals body))))

(defmacro klambda (args &body body)
  `(wrap ,(parse-applicative args body)))

;; convenience
(defmacro define-ground-typep (name typespec)
  `(define-ground-applicative ,name (&rest object)
     (kbool (kevery (of-type ',typespec) object))))

(defun primitive-operate (function args env)
  (funcall function args env))
