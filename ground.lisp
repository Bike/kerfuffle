;;;; ground.lisp
;;;; definitions for the ground environment.  mixing them all throughout fucks shit up

(in-package #:kerfuffle)

(define-ground-applicative make-environment (&rest environments)
  ;; remove cyclicity and copy as we go
  ;; (could be a separate function)
  (let (envs)
    (doklist (env environments) (push env envs))
    (make-instance 'kernel-environment
		   :parents envs
		   :bindings nil)))

(define-ground-operative $define! (definiend expression) env
  (map-bindings (curry #'kset env) definiend (eval expression env))
  +INERT+)

(define-ground-typep environment? environment)
(define-ground-typep symbol? ksymbol)
(define-ground-typep ignore? %ignore)
(define-ground-typep boolean? kbool)
(define-ground-typep inert? inert)
(define-ground-typep null? null) ; using CL null may bite me later (e.g. (symbolp nil) => T)
(define-ground-typep pair? (or cons kicons))
(define-ground-typep operative? operative)
(define-ground-typep applicative? applicative)

;;; TODO: better type errors
(define-ground-applicative set-car! (pair object)
  (rplaca pair object)
  +INERT+)
(define-ground-applicative set-cdr! (pair object)
  (rplacd pair object)
  +INERT+)

(define-ground-applicative cons (o1 o2) (cons o1 o2))

(define-ground-applicative copy-es-immutable (object) (copy-es-immutable object))

(define-ground-operative $if (test consequent alternative) env
  (let ((result (eval test env)))
    (check-type result kbool) ; FIXME: better error signaling
    (if (kbool-val result)
	(eval consequent env)
	(eval alternative env))))

(define-ground-applicative wrap (combiner)
  (wrap combiner))
(define-ground-applicative unwrap (combiner)
  (unwrap combiner))

(define-ground-operative $vau (formals eformal expr) env
  ;; FIXME: formals and eformal should be checked for validity here
  (make-instance 'operative
		 :body (copy-tree expr) ; should be an immutable copy but that's not really noticeable
		 :env env
		 :env-param eformal
		 :arglist formals))

;; this and ground EVAL are listed mostly to make it clear how they work.
;; the real definitions should be defined later, when generic functions (multimethods) are available.
;; (which, hopefully, will be in Kernel rather than CL)
;; other note: APPLY isn't a core primitive like everything else here.
(define-ground-applicative apply (applicative object &optional (environment (empty-environment)))
  ;; apply = (eval (cons (unwrap applicative) object) environment)
  (combine (unwrap applicative) object environment))

;; see above comment on APPLY
(define-ground-applicative eval (form env) (eval form env))
