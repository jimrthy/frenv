(in-package #:frenv-widgets)

(let ((id 0))
  (defn get-next-id ()
    ;; TODO: This really needs to be made thread-safe
    (setf id (1+ id))))

;;;; Have to start with individual pieces somewhere

(defclass root ()
  ((id
    :initform (get-next-id))))

(defclass clickable (root)
  "Something that interacts with the mouse"
  ((convex-hull
    :initarg :hull
    :initform nil
    :accessor hull
    :documentation "Where is it possible for this widget to be clicked?")))

(defclass container (root)
  ((content
    :initarg :content
    :initform nil
    :accessor content
    :documentation "What does this contain?")
   (cursor-position
    :init-arg :curs
    :initform 0
    :accessor curs
    :documentation "Where's the index for the next insertion?")))
