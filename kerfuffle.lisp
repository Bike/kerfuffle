;;;; kerfuffle.lisp

(in-package #:kerfuffle)

;;; "kerfuffle" goes here. Hacks and glory await!

;;; it's one am so let me jot down the ideas making me do this crap
;;; basically: Maru + Kernel
;;; Kernel has multiple classes of applicative objects (operatives + applicatives)
;;; so why not use Maru's ideas for that?
;;; (except with generics instead of naïve type dispatch because i have a NEED for SPEED also CLOS)

;;; more sleep-vaguely:
;;; eval should just be a function, nothing magical about it.
;;; entails modern design principles (e.g. generics)

;;; evaluation semantics are agnostic to any particular programming environment as much as possible
;;; sleep-ideally this would mean you could do e.g. (eval (parse-fortran (read-file ...)) env)

;;; as few unevaluated symbols as possible.  i think i finally realize more the point of avoiding QUOTE
;;; free hygeine if macros return `(,progn (,something (,+ 1 2)) (,something-else))
;;; (instead of `(progn (something (+ 1 2)) (something-else)), since, after all,
;;;   the macro should be using definitions from its defining environment and not expansion environment
;;;   (for non-invocation-provided code, anyway))

;;; data is data is data.  separate out the the the the
;;; no reason you couldn't use appel-style ML datatypes as the object language and define eval methods on them

;; a basic compound operative; primitive operatives are not of this class, but FUNCTION instead
(defclass operative ()
  ((body :accessor operative-body :initarg :body)
   (env :accessor operative-environment :initarg :env)
   (env-param :accessor operative-env-param :initarg :env-param)
   (arglist :accessor operative-arglist :initarg :arglist)))

;; primitive and compound applicatives work exactly the same and are of this class
(defclass applicative ()
  ((underlying :accessor applicative-underlying :initarg :underlying)))

(defun wrap (combiner)
  ;; FIXME: type safety
  (make-instance 'applicative :underlying combiner))
(defun unwrap (combiner)
  ;; FIXME: type safety (i.e. a better error message than no-applicable-method)
  (applicative-underlying combiner))

;; i'm not thrilled with having COMBINE take an ENV but whatever I guess it's useful anyway
;; note that this is not the same as traditional apply:
;; (combine applicative args) = (apply (wrap applicative) args)
;; i.e., it evaluates arguments "an extra time" since it handles operatives.
(defgeneric combine (op args env))

;; CL functions = primitive operatives
(defmethod combine ((op function) args env)
  ;; primitive-operate along with all the define-ground-* crap above, is for dealing with
  ;; the differences between CL and Kernel convention.
  (primitive-operate op args env))

;; look ma, super fucking easy semantics
(defmethod combine ((op applicative) args env)
  (combine (unwrap op) (kmap1 (rcurry #'eval env) args) env))

;; same as kernel operatives: operative-environment is the defining environment, etc.
;; calling (lexical) environment is of course totally irrelevant
(defmethod combine ((op operative) args env)
  ;; eval rather than eval-progn or w/e means an operative should have one expression in it only :/
  ;; FIXME: Doesn't care about correctness of ptrees, etc.  Fix this at $vau time
  (eval (operative-body op)
	(augment-environment (augment-environment (operative-environment op)
						  (operative-arglist op)
						  args)
			     (operative-env-param op)
			     env)))

(defgeneric eval (form env))

(defmethod eval ((form symbol) env)
  (lookup/error form env))

(defmethod eval ((form cons) env)
  ;; COMBINE handles argument evaluation (or lack thereof)
  (combine (eval (first form) env) (rest form) env))

(defmethod eval (form env)
  (declare (ignore env))
  form)
