;;;; eq.lisp
;;;; equality predicates

(in-package #:kerfuffle)

(defmacro 2typecase ((k1 k2) block &body cases)
  (once-only (k1 k2)
    (flet ((make-case (case)
	     (let ((type (first case))
		   (body (rest case)))
	       `((and (typep ,k1 ',type)
		      (if (typep ,k2 ',type)
			  t
			  ;; not of the same type, bail early
			  (return-from ,block nil)))
		 ,@body))))
      `(cond ,@(mapcar #'make-case cases)))))

;; FIXME: doubtfully correct
(defun keq (o1 o2)
  (or (eq o1 o2)
      (2typecase (o1 o2) keq
	(number (= o1 o2))
	(character (char= o1 o2))
	(kcons (klist-equal o1 o2))
	(kbool
	 ;; nand that shit
	 (if (kbool-val o1)
	     (kbool-val o2)
	     (not (kbool-val o2))))
	;; these should be singletons but let's check anyway
	(ignore t)
	(inert t))))

;; FIXME: even less correct!
(defun kequal (o1 o2)
  (or (keq o1 o2)
      (2typecase (o1 o2) nil
	(cons (klist-equal o1 o2)))))

;; FIXME: seriously fuck
(defun klist-equal (c1 c2)
  (let (seen)
    (labels ((aux (c1 c2)
	       (2typecase (c1 c2) aux
		 (null t)
		 (knull t)
		 (kcons (or (eq c1 c2)
			    (find c2 (assoc-value c1 seen :test #'eq) :test #'eq)
			    (progn (push c2 (assoc-value c1 seen))
				   (and (aux (kcons-kar c1) (kcons-kar c2))
					(aux (kcons-kdr c1) (kcons-kdr c2))))))
		 (cons (or (eq c1 c2)
			   (find c2 (assoc-value c1 seen :test #'eq) :test #'eq)
			   (progn (push c2 (assoc-value c1 seen))
				  (and (aux (car c1) (car c2))
				       (aux (cdr c1) (cdr c2))))))
		 (t (kequal c1 c2)))))
      (aux c1 c2))))

(define-ground-applicative eq? (object1 object2) (kbool (keq object1 object2)))

(define-ground-applicative equal? (object1 object2) (kbool (kequal object1 object2)))
