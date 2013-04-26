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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set up a thread to listen on a socket...
;(error "Get this written")
;; It seems highly probable that it will involve usocket and
;; bordeaux-threads
;; FIXME: These should be listed as requirements in the ASD.
;(asdf:oos 'asdf:load-op '#:bordeaux-threads)
(asdf:oos 'asdf:load-op '#:usocket)

(defun nrepl (stream)
  (declare (type stream stream))
  ;; FIXME: Do something worthwhile here
  (terpri stream))

;;; Pick a default port at random.
;;; I have serious doubts about making this multi-threaded
(defparameter *networked-controller*
  (usocket:socket-server "localhost" 6857 nrepl
			 :in-new-thread T
			 :multi-threading T))

(defun draw ()
  (error "Write this"))

(defun animate ()
  (error "Write this"))

;;; Kick off the windowing system
(glfw:with-init-window (:title "Frenv" :width 800 :height 600
			       :depthbits 16 :mode glfw:+window+)
    (glfw:swap-interval 1)

    (draw)
    (animate)
    (glfw:swap-buffers))

