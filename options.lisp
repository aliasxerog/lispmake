(in-package :lispmake)

;; lispmake, written by Matthew Veety, et al.
;; (c) Matthew Veety 2012,2013,2014. Under BSD License.
;; 
;; This is a hacked together program designed to generate the build
;; files that are required for a client's lisp set up. If you find
;; bugs or better ways to do things then send in patches.
;; 
;; Things that need doing:
;;     * Support for clisp, cmucl, ccl, and I guess others
;;     * build targets (ala make) (could be a plugin)
;;     * testing. It works for me, it might not for you

(defvar *cmd-options* nil)
(defvar *lmfname* *lmakefile*)
(defvar *target* nil)
(defparameter *variables* '(prefix "/usr/local"
			    bindir "/usr/local/bin"
			    libdir "/usr/local/lib"
			    etcdir "/usr/local/etc"
			    default-mode 555))

(defun split-equal (string)
  (let* ((bf (split-sequence:split-sequence #\= string)))
    (if (equal (length bf) 2)
	bf
	nil)))

(defun handle-options ()
  (setf *cmd-options* (unix-options:cli-options))
  (dolist (x *cmd-options*)
    (let* ((bf (split-equal x)))
      (if (not (equal bf nil))
	  (let* ((var (car bf))
		 (value (cadr bf)))
	    (cond
	      ((equal var "target")
	       (setf *target* value))
	      ((equal var "file")
	       (setf *lmfname* value))
	      ((equal var "debug")
	       (if (or  ;; This is a shitshow. I should fix this.
		    (equal value "true")
		    (equal value "TRUE")
		    (equal value "yes")
		    (equal value "YES")
		    (equal value "y")
		    (equal value "t")
		    (equal value "T")
		    (equal value "Y")
		    (equal value "1"))
		   (setf *debugging* T)
		   (setf *debugging* nil))))))))
  (if (equal *target* nil)
      (setf *lmakefile* *lmfname*)
      (setf *lmakefile*
	    (concatenate 'string *lmakefile* "." *target*)))
  (if *debugging*
      (progn
	(format
	 t
	 "lispmake: debug: handle-options: lmakefile=~A~%"
	 *lmakefile*)
	(format t "lmakefile=~A~%target=~A~%file=~A~%"
		*lmakefile* *target* *lmfname*)))
  nil)

(defun get-var (varname)
  (getf *variables* varname))

(defun set-var (varname value)
  (let* ((vstat (getf *variables* varname)))
    (if (equal vstat nil)
	(progn
	  (pushnew value *variables*)
	  (pushnew varname *variables*))
	(setf (getf *variables* varname) value))))

(defun parg (arg)
  (if (symbolp arg)
      (getf *variables* arg)
      arg))

(defun string-to-symbol (string)
  (if (stringp string)
      (intern (string-upcase string))
      nil))

(defun string-to-keyword (string)
  (if (stringp string)
      (intern (string-upcase string) "KEYWORD")
      nil))

(defun symbol-to-keyword (symbol)
  (if (symbolp symbol)
      (let* ((s (string symbol)))
	(intern (string-upcase s) "KEYWORD"))
      nil))

(defun varhdl (form)
  (if (symbolp form)
      (let ((bf (getf *variables* form)))
	(if (not (equal bf nil))
	    bf
	    form))
      form))

(defmacro nilp (form)
  `(equal ,form nil))
