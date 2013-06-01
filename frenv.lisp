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
(asdf:oos 'asdf:load-op '#:bordeaux-threads)

(defun draw ()
  (error "Write this"))

(defun animate ()
  (error "Write this"))

(defun start-gui ()
"Kick off the windowing system.
The real kicker here is that the entire basic idea is bogus."
  (glfw:with-init-window (:title "Frenv" :width 800 :height 600
				 :depthbits 16 :mode glfw:+window+)
    (glfw:swap-interval 1)

    (draw)
    (animate)
    (glfw:swap-buffers)))

;;; This next piece is absolutely horrible and should never
;;; see the light of day. It totally violates the entire principle
;;; of everything. But I want some sort of API, even if it's
;;; going to be obsoleted and thrown out the window instantly.
(defun stupid-get-input (&optional prompt)
  (format t "~A " (if prompt
		      prompt
		      "=> "))
  (read))
