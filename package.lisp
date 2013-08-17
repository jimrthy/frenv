;;;; package.lisp

(defpackage #:frenv
  (:use #:cl #:bordeaux-threads #:cl-glfw3 :log4cl)
  (:export #:stupid-get-input #:start #:stop))

(defpackage #:frenv-widgets
  (:use #:frenv :log4cl)
  (:export #:root))
