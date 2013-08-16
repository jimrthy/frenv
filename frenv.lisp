;;;; frenv.lisp

(in-package #:frenv)

(require '#:asdf)
(println "Get cl-glfw3 working and integrated")
#|(asdf:oos 'asdf:load-op '#:cl-glfw3)|#

;; This next point's debatable.
;; I want to be able to spawn a window from a REPL and keep using the REPL.
;; That doesn't mean that everyone else also wants that (though I have
;; a tough time imagining why they wouldn't).
;; Really should just present this as a fait accompli.
(println "Just accept that multiple windows really mean multiple threads")
;; OTOH...they don't. Especially since rendering isn't thread-safe.
;; The glfw3 docs are full of functions that must be called from the main thread.
(asdf:oos 'asdf:load-op '#:bordeaux-threads)

(defun draw ()
  (error "Write this"))

(defun animate ()
  (error "Write this"))

(defun start ()
  "Kick off the windowing system."
  ;; Why can't this be anonymous?
  (glfw:def-error-callback err-hand (msg)
    (format t "~A" msg))
  (glfw:initialize))

(defparameter *exited* ())
(defun stupid-loop ()
  "Really just because I have to start somewhere"
  (glfw:with-window (:title "Frenv" :width 800 :height 600
			    :depthbits 16 :mode glfw:+window+)
    (glfw:swap-interval 1)

    (unwind-protect
	 (loop until (window-should-close-p)
	    do (draw)
	    do (animate)
	    do (glfw:swap-buffers)
	    do (poll-events))
      (setf *exited* t))))

(defun stop ()
  (set-window-should-close)
  ;; Really should be smarter about waiting for stupid-loop to exit
  (loop until *exited*
       (do (sleep 0.1)))
  (glfw:terminate))

;;; This next piece is absolutely horrible and should never
;;; see the light of day. It totally violates the entire principle
;;; of everything I'm tryng to do. But I want some sort of 
;;; interaction, even if it's
;;; going to be obsoleted and thrown out the window instantly.
(defun stupid-get-input (&optional prompt)
  (format t "~A " (if prompt
		      prompt
		      "=> "))
  (read))
