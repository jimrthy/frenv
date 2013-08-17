;;;; frenv.lisp

(in-package #:frenv)

(require '#:asdf)
;;(println "Get cl-glfw3 working and integrated")
(asdf:oos 'asdf:load-op '#:cl-glfw3)

;; This next point's debatable.
;; I want to be able to spawn a window from a REPL and keep using the REPL.
;; That doesn't mean that everyone else also wants that (though I have
;; a tough time imagining why they wouldn't).
;; Really should just present this as a fait accompli.
(println "Just accept that multiple windows really mean multiple threads")
;; OTOH...they don't. Especially since rendering isn't thread-safe.
;; The glfw3 docs are full of functions that must be called from the main thread.
;; OTOH: shouldn't ASDF and packaging take care of this for me?
(asdf:oos 'asdf:load-op '#:bordeaux-threads)

;;; The top-level aspects of everything interesting.
;;; From an MVC perspective, these represent both the models and the views.
;;; It's important to remember that there could easily be many views
;;; associated with any given model.
;;; OTOH, it's a mistake to complect those concepts.
;; It's tempting to filter out the ones that are iconified,
;; but that isn't really fair. It's totally possible that they're generating stuff
;; that needs to be drawn (as painful as it is, think about the way things work in
;; windos 8).
;; Let the window manager do the filtering, until/unless it actually needs to be
;; optimized at this level.
(defparameter *realities* ())

(defgeneric render (renderer view)
  :documentation "Renderer generates a stream of OpenGL commands to represent view.")

(defun draw ()
  ;; It's more than a little dumb to just loop through all top level
  ;; windows this way. Some don't need to be drawn. Others only need
  ;; to draw their icons. In a lot of ways, this is trying to replace
  ;; the window manager and do its job.
  ;; In other ways...the WM shouldn't be dictating how this process
  ;; draws its sub-windows. Even if there isn't any main window to
  ;; draw. (Why isn't there? At least for power users?)
  ;; If nothing else, every alternative that comes to mind qualifies
  ;; as premature optimization.
  (dolist (view (map 'list #'view *realities*))
    ;; The view really doesn't know whether it's visible or not.
    (let ((renderer (driver view))
	  (ctx (context view)))
      ;; I know I started writing alternatives. Why does this not match?
      (glfw:make-context-current ctx)
      (render renderer view))))

(defun animate ()
  ;; this entire idea is wrong.
  ;; There *should* be a timer to let various pieces know that it's time
  ;; to take a step.
  ;; User input provides the same sort of motivation.
  ;; There's no real justification for this sort of function at this level.
  (error "Write this"))

(defun start ()
  "Kick off the windowing system."
  ;; Why can't this be anonymous?
  (glfw:def-error-callback err-hand (msg)
    (format t "~A" msg))
  (glfw:initialize))

;; Cheap way for caller to wait on stupid-loop to exit.
;; Seriously. The entire thing is dumb. It just all happens
;; to qualify as "things I've managed to accomplish today"
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
