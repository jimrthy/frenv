;;;; frenv.lisp

(in-package #:frenv)

(require '#:asdf)
(asdf:oos 'asdf:load-op '#:cl-glfw)
;; Fails because it tries to redefine a constant (+MAX_VARYING_COMPONENTS+)
;(asdf:oos 'asdf:load-op '#:cl-glfw-opengl-version_3_3)
;; Ditto
;(asdf:oos 'asdf:load-op '#:cl-glfw-opengl-version_3_2)
;; Ditto
;(asdf:oos 'asdf:load-op '#:cl-glfw-opengl-version_3_1)

;; I obviously need to get all those above errors fixed.
(asdf:oos 'asdf:load-op '#:cl-glfw-opengl-version_2_1)

;;; FIXME: Really do need to unify the various available
;;; OpenGL versions to present a common API to the outside
;;; world.

;;; After all, that pretty much *is* the entire point to this
;;; entire project.

;;; Or, at least, it's really the first major milestone.

;;; Set up a thread to listen on a socket...
(error "Get this written")
;; It seems highly probable that it will involve usocket and
;; bordeaux-threads
(asdf:oos 'asdf:load-op '#:bordeaux-threads)
(asdf:oos 'asdf:load-op '#:usocket)



;;; Kick off the windowing system
(error "Do that")

