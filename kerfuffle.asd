;;;; kerfuffle.asd

(asdf:defsystem #:kerfuffle
  :description "Describe kerfuffle here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:alexandria)
  :components ((:file "package")
	       (:file "primdef" :depends-on ("package"))
	       (:file "bool" :depends-on ("package"))
	       (:file "env" :depends-on ("ptree" "package"))
	       (:file "misc-base" :depends-on ("package"))
	       (:file "ignore" :depends-on ("misc-base" "package"))
	       (:file "inert" :depends-on ("misc-base" "package"))
	       (:file "list" :depends-on ("inert" "misc-base" "package"))
	       (:file "ptree" :depends-on ("list" "ignore" "package"))
	       (:file "read" :depends-on ("package" "bool"))
	       (:file "symbol" :depends-on ("package"))
	       (:file "ground" :depends-on ("package" "primdef" "kerfuffle" "list" "symbol" "ignore" "inert" "bool"))
               (:file "kerfuffle" :depends-on ("package" "list" "env"))
	       (:file "repl" :depends-on ("package" "ground" "kerfuffle"))))
