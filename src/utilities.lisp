;; Author: Juan Miguel Cejuela
;; Created: Wed Jul  9 19:13:54 2008 (CEST)

(in-package :cl-hmm)

;;;fastest search in a prob-float array, (see jmc.cl.utils)
(def-lin-search array-search prob-float (simple-array prob-float) >=)

(defun select-random (accum-array &key (indices-1 nil) (fixed-max nil) (fixed-pick nil))
  "Assumed but not checked that (= (length dims) (1+ (length indices-1)))"
  (declare (optimize (speed 3) (safety 0)))
  (let ((dims (array-dimensions accum-array)))
    (labels ((fstart (indices-1 dims-1 accum)
               (if (null indices-1)
                   accum
                   (fstart (cdr indices-1) (cdr dims-1) (+ accum (apply #'* (car indices-1) dims-1))))))
      (let* ((start (fstart indices-1 (cdr dims) 0))
             (end (+ start (car (last dims))))
             (max (if fixed-max fixed-max (row-major-aref accum-array (1- end))))
             (pick (if (zerop max) (return-from select-random nil) (if fixed-pick fixed-pick (random max))))
             (found-total-index (array-search pick accum-array start end))
             (relative-index (if found-total-index (- found-total-index start) nil)))
        relative-index))))

(defun array-map (array f)
  (declare (optimize (speed 3) (safety 0)) (inline array-map))
  (let ((out (make-array (array-dimensions array) :element-type (array-element-type array))))
    (dotimes (i (array-total-size array) out)
      (setf (row-major-aref out i) (funcall f (row-major-aref array i))))))

;;For maximum speed, create array-typed-mappers
(defmacro array-typed-map-create (final-fun-name array-type f)
  `(defun ,final-fun-name (array)
     (declare (optimize (speed 3) (safety 0)) (,array-type array))
     (let ((out (the ,array-type (make-array (array-dimensions array) :element-type (array-element-type array)))))
       (dotimes (i (array-total-size array) out)
         (setf (row-major-aref out i) (funcall ,f (row-major-aref array i)))))))

(array-typed-map-create log-array (simple-array prob-float) #'(lambda (x) (if (zerop x) +very-negative-prob-float+ (log x))))
(array-typed-map-create log-vector (simple-array prob-float (*)) #'(lambda (x) (if (zerop x) +very-negative-prob-float+ (log x))))

;;Kept for historical reasons and because it's still faster
(defun log-array-old (array)
  (declare ((prob-array (* *)) array))
  (let ((out (make-array (array-dimensions array) :element-type 'prob-float))
        (v +0-prob+))
    (declare ((prob-array (* *)) array) (prob-float v))
    (dotimes (i (array-dimension array 0) out)
      (dotimes (j (array-dimension array 1))
        (setf (aref out i j)
              (progn (setq v (aref array i j))
                     (if (zerop v) +very-negative-prob-float+ (the prob-float (log v)))))))))

;;; Copied from cl-utilities
(defun split-sequence (delimiter seq &key (count nil) (remove-empty-subseqs nil) (from-end nil) (start 0) (end nil) (test nil test-supplied) (test-not nil test-not-supplied) (key nil key-supplied))
  "Return a list of subsequences in seq delimited by delimiter.

If :remove-empty-subseqs is NIL, empty subsequences will be included
in the result; otherwise they will be discarded.  All other keywords
work analogously to those for CL:SUBSTITUTE.  In particular, the
behaviour of :from-end is possibly different from other versions of
this function; :from-end values of NIL and T are equivalent unless
:count is supplied. The second return value is an index suitable as an
argument to CL:SUBSEQ into the sequence indicating where processing
stopped."
  (let ((len (length seq))
        (other-keys (nconc (when test-supplied
                             (list :test test))
                           (when test-not-supplied
                             (list :test-not test-not))
                           (when key-supplied
                             (list :key key)))))
    (unless end (setq end len))
    (if from-end
        (loop for right = end then left
           for left = (max (or (apply #'position delimiter seq
                                      :end right
                                      :from-end t
                                      other-keys)
                               -1)
                           (1- start))
           unless (and (= right (1+ left))
                       remove-empty-subseqs) ; empty subseq we don't want
           if (and count (>= nr-elts count))
           ;; We can't take any more. Return now.
           return (values (nreverse subseqs) right)
           else
           collect (subseq seq (1+ left) right) into subseqs
           and sum 1 into nr-elts
           until (< left start)
           finally (return (values (nreverse subseqs) (1+ left))))
        (loop for left = start then (+ right 1)
           for right = (min (or (apply #'position delimiter seq
                                       :start left
                                       other-keys)
                                len)
                            end)
           unless (and (= right left)
                       remove-empty-subseqs) ; empty subseq we don't want
           if (and count (>= nr-elts count))
           ;; We can't take any more. Return now.
           return (values subseqs left)
           else
           collect (subseq seq left right) into subseqs
           and sum 1 into nr-elts
           until (>= right end)
           finally (return (values subseqs right))))))


(defun read-pair-observations-file (path)
  (with-open-file (stream path)
    (loop for line = (read-line stream nil)
       while line
       for (x_ y_ p) = (split-sequence #\Space line)
       for x = (mapcar #'parse-integer (split-sequence #\_ x_))
       for y = (mapcar #'parse-integer (split-sequence #\_ y_))
       with left-alphabet = (make-hash-table :test 'equalp)
       with right-alphabet = (make-hash-table :test 'equalp)
       do
         (loop for l in x do
              (setf (gethash l left-alphabet) nil))
         (loop for r in y do
              (setf (gethash r right-alphabet) nil))
       collecting (list (make-array (length x) :initial-contents x) (make-array (length y) :initial-contents y)) into observations
       finally (return (values observations (hash-table-size left-alphabet) (hash-table-size right-alphabet))))))
