;;;; list.lisp
;;;; kernel lists.  mutable conses are CL conses, immutable conses are a CL struct.

(in-package #:kerfuffle)

(defstruct kicons kar kdr) ; kernel immutable cons

;;; helpful things
(defun kar (kons)
  (etypecase kons
    (cons (car kons))
    (kicons (kicons-kar kons))))
(defun kdr (kons)
  (etypecase kons
    (cons (cdr kons))
    (kicons (kicons-kdr kons))))

(deftype knull () 'null)
(deftype klist () '(or list kicons knull))

(defconst/bound +NULL+ nil)

(defun klist (&rest elems) (apply #'list elems))

(defun klistp (obj) (typep obj 'klist))
(defun knull (obj) (typep obj 'knull))

(defun copy-es-immutable (obj)
  ;; works on conses, and on anything else in that anything else will just be returned
  (let ((cache nil))
    (labels ((aux (obj)
	       (if (consp obj)
		   (or (cdr (assoc obj cache :test #'eq))
		       (let ((new (make-kicons)))
			 (push (cons obj new) cache)
			 (setf (kicons-kar new) (aux (car obj))
			       (kicons-kdr new) (aux (cdr obj)))
			 new))
		   obj)))
      (aux obj))))

(defmacro doklist ((var klist &optional result) &body body)
  ;; FIXME: naïve (O(n) space).  motherfuck i hate cyclic structures
  (with-gensyms (pair seen)
    `(do ((,pair ,klist (kdr ,pair))
	  (,seen nil (cons ,pair ,seen)))
	 ((or (knull ,pair) (find ,pair ,seen))
	  ;; "At the time result-form is processed, var is bound to nil."
	  (let ((,var nil))
	    (declare (ignorable ,var))
	    ,result))
       ;; DO should take care of the block and tagbody
       (let ((,var (kar ,pair)))
	 ,@body))))

(defun kevery (pred klist)
  (doklist (elem klist (kbool t))
    (unless (funcall pred elem)
      (return (kbool nil)))))

(defun kmap1 (function klist)
  ;; FIXME: [something about inefficiency]
  (if (knull klist)
      klist
      (let* ((last (list (funcall function (kar klist))))
	     (result last)
	     (seen (list (cons klist last))))
	(do ((pair (kdr klist) (kdr pair)))
	    ((knull pair) (return result))
	  (let ((assoc (assoc pair seen :test #'eq)))
	    (cond (assoc (setf (cdr last) (cdr assoc)) (return result))
		  (t (setf (cdr last) (list (funcall function (kar pair)))
			   last (cdr last))
		     (push (cons pair last) seen))))))))
