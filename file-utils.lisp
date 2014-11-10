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

(defparameter *variables* '(prefix "/usr/local"
			    bindir "/usr/local/bin"
			    libdir "/usr/local/lib"
			    etcdir "/usr/local/etc"
			    default-mode 555))

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

(defun pl-exec (args)
  (if (listp args)
      (let* ((cmd (car args))
	     (cmd-args (cdr args)))
	(oth-run-executable cmd cmd-args))))

(defun pl-install (args)
  (if (listp args)
      (let* ((filename (varhdl (getf args :file)))
	     (target (varhdl (getf args :to)))
	     (mode (varhdl (getf args :mode)))
	     (options (varhdl (getf args :options))))
	(if (or (nilp filename)
		(nilp target))
	    (abort "filename or target equals nil"))
	(if (cl-fad:directory-exists-p target)
	    (cl-fad:copy-file
	     filename
	     (concatenate 'string
			  target
			  "/"
			  filename)
	     :overwrite t)
	    (abort "target directory doesn't exist"))
	(if (nilp mode)
	    (osicat-posix:chmod (concatenate 'string target "/" filename) 555)
	    (osicat-posix:chmod (concatenate 'string target "/" filename) mode)))
      (abort "args should be type list")))

(defun pl-delete (args)
  (if (stringp args)
      (delete-file args)
      (if (listp args)
	  (dolist (x args)
	    (if (stringp x) (delete-file x))))))

(defun pl-define (args)
  (if (and (listp args)
	   (equal (length args) 2))
      (let* ((varname (car args))
	     (value (cadr args)))
	(set-var varname value))))
