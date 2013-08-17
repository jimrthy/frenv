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

;;; The top-level windows into everything interesting.
;; It's tempting to filter out the ones that are iconified,
;; but that isn't really fair. It's totally possible that they're generating stuff
;; that needs to be drawn (as painful as it is, think about the way things work in
;; windos 8).
;; Let the window manager do the filtering, until/unless it actually needs to be
;; optimized at this level.
(defparameter *views* ())

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
  (dolist (view *views*)
    ;; The view really doesn't know whether it's visible or not.
    (let ((renderer (driver view))
	  (ctx (context view)))
      ;; I know I started writing alternatives. Why does this not match?
      (glfw:make-context-current ctx)
      (render renderer view))))

;;; The thing that any given view displays.
;;; Could be a web page, a bingo card, a level in a FPS, a text file
;;; to edit, or nothing at all if it makes more sense for something
;;; else to take more control over the animation than what's offered
;;; here.
(defparameter *models* ())

(defgeneric advance (model)
  :documentation "Advance a model's state by one 'tick.'
This could mean updating a rotation, advancing a lerp, switching
a button's texture because of a mouse click, stepping a physics
engine, or whatever.

One point that seems important to keep in mind:
User input is extremely important here. As is feedback from the
server: maybe the screen should flash red because the player just
got shot.

=> this should also take a sequence of messages intended for the
model as a parameter. WTF would this be tracking which messages
a model cares about?

alt: stream messages to the models as they arrive. Then they
update their own state appropriately. This seems like a bad
idea.

alt2: Stream messages to the model handler. It asks the model
for its reaction to the message, then replaces the model with 
the new state. This sounds ridiculous, but it's really the safest
option I've run across so far.")

(defun animate ()
  ;; this entire idea is wrong.
  ;; There *should* be a timer to let various pieces know that it's time
  ;; to take a step.
  ;; User input provides the same sort of motivation.
  ;; There's no real justification for this sort of function at this level.
  ;; The fact that the implementation's ugly doesn't make the basic idea
  ;; any more appealing.
  ;; Oh well. I have to start somewhere.
  (let ((altered-states nil))
    ;; Note that this is most definitely *not* thread safe, but
    ;; ...well, advance needs to be atomic.
    ;; And having one model disappear while the others are
    ;; being built would be a really bad idea.
    ;; Hmm. Really need two lists: one active, the other
    ;; inactive.
    ;; Swap them at the start of this, then process the
    ;; inactive, adding each result to the active.
    ;; Any model that wants to go away can just return nil.
    (dolist (model *models*)
      (if-let ((new-state (advance model)))
	;; I really want to use something like push here.
	;; What am I missing?
	(setf altered-states (cons new-state altered-states))))
    (setf *models* altered-states)))

(defun stupid-loop ()
  "Really just because I have to start somewhere"
  ;; Why can't this be anonymous?
  (glfw:def-error-callback err-hand (msg)
    (format t "~A" msg))
  (glfw:with-init
    ;; This next part isn't even worth considering:
    ;; I should really be basing this on either *views* or *models*
    ;; Even that isn't correct. All of those could be gone, but the
    ;; repl could still be ready and waiting to create a new
    ;; window.
    ;; But, this is a start.
    (glfw:with-window (:title "Frenv" :width 800 :height 600
			      :depthbits 16 :mode glfw:+window+)
      (glfw:swap-interval 1)

      (unwind-protect
	   ;; The until test is a complete and total failure,
	   ;; the second I add a second window.
	   (loop until (window-should-close-p)
	      do (draw)
	      do (animate)
	      do (glfw:swap-buffers)
	      do (poll-events))))))

(defparameter *graphics-lock* nil) ; think of python's GIL: try to avoid at all costs.
(defparameter *graphics-thread* nil)
(defun start ()
  "Kick off the windowing system."
  ;; If we're restarting, the lock may or may not be nil.
  (setf *graphics-lock* (bordeaux-threads:make-lock "Everybody's favorite renderer"))
  ;; This should really be redundant...we should most definitely be in a single-threaded
  ;; environment here above everywhere else. But just to be safe:
  (bordeaux-threads:with-lock-held (*graphics-lock*)
    ;; Run stupid-loop in a second thread.
    (setf *graphics-thread* (bordeaux-threads:makethread stupid-loop :name "graphics"))))

(defun stop ()
  ;; Nope. Does not work at all.
  ;; Well, might be OK for single-window setups.
  (acquire-lock *graphics-lock* t)
  (let ((lock *graphics-lock*))
    (set-window-should-close)
    (when *graphics-thread*
      (bordeaux-threads:join-thread *graphics-thread*)
      (setf *graphics-thread* nil))
    (release-lock *graphics-lock*)))

;;; This next piece is absolutely horrible and should never
;;; see the light of day. It totally violates the entire principle
;;; of everything I'm tryng to do. But I want some sort of 
;;; interaction, even if it's
;;; going to be obsoleted and thrown out the window instantly.
(defun stupid-get-input (&optional prompt)
  (error "No, really. Move forward.")
  (format t "~A " (if prompt
		      prompt
		      "=> "))
  (read))
