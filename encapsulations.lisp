;;;; encapsulations.lisp

(in-package #:kerfuffle)

(defstruct encapsulation type content)

(defmethod print-object ((object encapsulation) stream)
  (print-unreadable-object (object stream :identity t)
    (princ "kernel encapsulation (" stream)
    (princ (encapsulation-type object) stream)
    (princ ") " stream)
    (princ (encapsulation-content object) stream)))

(define-ground-applicative make-encapsulation-type ()
  (let ((type (gensym "ENCAPSULATION")))
    (klist (klambda (object) (make-encapsulation :type type :content object))
	   (klambda (&rest object)
	     (kbool (kevery (conjoin (of-type 'encapsulation)
				     (compose (curry #'eq) #'encapsulation-type))
			    object)))
	   (klambda (object)
	     (unless (and (encapsulation-p object) (eq (encapsulation-type object) type))
	       (error "bad encapsulation bluh bluh error"))
	     (encapsulation-content object)))))
