;;;; env.lisp

;;;; lisp-1.  oh well.

(in-package #:kerfuffle)

(defgeneric flat-lookup (name env)
  (:argument-precedence-order env name))

(defgeneric lookup (name env)
  (:argument-precedence-order env name))

(defgeneric augment-environment (env names values))

(defclass environment () ()) ; "extensible"

(defclass kernel-environment (environment)
  ((parents :accessor environment-parents :initarg :parents)
   (bindings :accessor environment-bindings :initarg :bindings)))

(defun empty-environment () (make-instance 'kernel-environment :parents nil :bindings nil))

(defvar *ground-environment* (empty-environment))

(defmethod flat-lookup (name (env kernel-environment))
  (let ((assoc (assoc name (environment-bindings env))))
    (if assoc
	(values (cdr assoc) t)
	(values nil nil))))

;; derp, this is breadth-first
;; why did I think kernel used breadth-first?
#+(or)
(defmethod lookup (name (env kernel-environment))
  (let ((envs (list env)))
    (loop while envs do
	 (dolist (env envs)
	   (multiple-value-bind (val found)
	       (flat-lookup name env)
	     (when found (return-from lookup (values val t)))))
	 (setf envs (mappend #'environment-parents envs))
	 finally (return (values nil nil)))))

(defmethod lookup (name (env kernel-environment))
  (multiple-value-bind (val found) (flat-lookup name env)
    (if found
	(values val found)
	(dolist (env (environment-parents env) (values nil nil))
	  (multiple-value-bind (val found) (lookup name env)
	    (when found (return (values val found))))))))

(declaim (inline lookup/error))
(defun lookup/error (name env)
  (multiple-value-bind (val found)
      (lookup name env)
    (if found
	val
	;; FIXME less shitty error
	(error "~s not bound in ~a" name env))))

(defgeneric augment-environment (env tree args))

(defmethod augment-environment ((env kernel-environment) tree args)
  (make-instance (class-of env)
		 :parents (list env)
		 :bindings (ptree->assoc tree args)))

(defgeneric kset (env name val))

(defmethod kset ((env kernel-environment) name val)
  (let ((assoc (assoc name (environment-bindings env))))
    (if assoc
	(setf (cdr assoc) val)
	(push (cons name val) (environment-bindings env))))
  (values))
