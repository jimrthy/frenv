;;;; frenv.asd

(asdf:defsystem #:frenv
  :serial t
  :description "A cross-platform GUI layer for/in Common Lisp"
  :author "James Gatannah <james@gatannah.com>"
  :license "Eclipse Public Licens"
  :depends-on (#:cl-glfw3 #:bordeaux-threads #:log4cl)
  :components ((:file "package")
               (:file "frenv")))

