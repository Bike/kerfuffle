Not really any documentation right now.

But this should be a mostly conforming Kernel.  Try repl, eval (with *repl-environment*), kernel-read.

Kernel's homepage is http://web.cs.wpi.edu/~jshutt/kernel.html


I'd like to combine Kernel and Maru (http://www.piumarta.com/software/maru/).

I scribbled some notes in kerfuffle.lisp but it boils down to: EVAL and APPLY (or, I decided, COMBINE) are generic functions.

So with Kernel, COMBINE has a method on primitive operatives (magic), compound operatives (eval body etc.), and applicatives (recurse with unwrapped applicative and eval'd arglist).  Hopefully this is a nice design.

Kernel doesn't have methods (which isn't to say they couldn't be added) and subclassing is mostly disallowed from creating new behavior with standard combiners so that's nonstandard, but Kernel isn't exactly highly used anyway.

Part of the idea here is to allow something like this eventually:

($provide! ($macro macro? macro-operator)
  ($define! (enc macro? macro-operator) (make-encapsulation-type))
  ($define! $macro (compose enc $vau)) ; hopefully it makes sense for (compose app op) to be an op)

;; util

($defun! constantly (obj) ($lambda #ignore obj))

;; (if it's not obvious, I'm more used to CL.  $defun! is pretty easily defined in Kernel of course)
;; actually that could help

;; as an operative
($define! $defun!
  ($vau (name args . body) env
    ((wrap $define!) name (eval (list* $lambda args body) env))))

;; as a macro (i.e. returning a form which is then evaluated)
($define! $defun!
  ($macro (name args . body) #ignore
    (list $define! name (list* $lambda args body))))

;; anyway, and then with Maru we can integrate this

($defmethod! combine (operator args env) (macro? (constantly #t) (constantly #t))
  (eval (combine (macro-operative operator) args env) env))

;; (there are issues with representing a type with its predicate but pretend there aren't)

;; (where combine on operatives is just like ($lambda (op args env) (eval (cons op args) env)),
;;  as explained in the Kernel spec's APPLY entry; it's here for Maru purposes)

;; so now macros can be used as a disjoint type of combiner in usual source etc.
;; That is, EVAL (which is also generic incidentally, so you can define Lisp For Vectors!) is defined in terms of COMBINE.



;; I am toying with this because I think it could also be used to simplify compilation:

($defmethod! compile-combination (operator args env) (macro? (constantly #t) (constantly #t))
  (compile (combine operator args env) env))

;; i.e. extensible compilation semantics, making it easier to do optimizations like this
;; (in this case, never leaving macros in compiled code)

;; with a defined enough compilation protocol you could define things like load-time-value like this as well
;; but I'm not nearly that far yet.
