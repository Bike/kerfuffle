;;;; ptree.lisp

(in-package #:kerfuffle)

(defun map-bindings (fun tree args)
  (labels ((aux (tree args)
	     (etypecase tree
	       (%ignore)
	       (null (assert (null args))) ; FIXME better error
	       (symbol (funcall fun tree args))
	       ((or cons kcons)
		(unless (consp args)
		  ;; this assertion blocks e.g. (a b) from matching (4)
		  ;; FIXME better error
		  (error "arg tree mismatch: ~s does not match ~s" tree args))
		(aux (car tree) (kar args))
		(aux (cdr tree) (kdr args))))))
    (aux tree args)
    (values)))

(defun ptree->assoc (tree args)
  (let (binds)
    (map-bindings (lambda (name val) (push (cons name val) binds)) tree args)
    binds))
