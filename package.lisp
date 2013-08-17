;;;; package.lisp

(defpackage #:frenv
  (:use #:cl #:bordeaux-threads #:cl-glfw3)
  (:export #:stupid-get-input #:start #:stop))

(defpackage #:frenv-widgets
  (:use #:frenv)
  (:export #:root))
