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

(defun generate ()
  (with-open-file (mkfile (output-fname) :direction :output :if-exists :supersede)
    (format 
     mkfile 
     ";; autogenerated by lispmake revision ~A~%;; DO NOT EDIT~%"
     *lispmake-version*)
    (run-plugin-pregen mkfile)
    (dolist (x *quickloads*)
      (lm-debug "generate" "generating quicklisp forms")
      (quickloads mkfile x))
    (dolist (x *sources*)
      (lm-debug "generate" "generating load forms")
      (loadfile mkfile x))
    (lm-debug "generate" "generating save-and-die form")
    (buildexe mkfile *outfile* *lm-package* *toplevel* *lisp-target*)
    (force-output mkfile)
    (run-plugin-postgen mkfile))
  (if *debugging*
      (format t "lispmake: doing build...~%"))
  (if *do-build*
      (run-build-process)))

(defun runner (forms)
  (if (not (listp forms))
      (lm-error "runner" "form not of type cons in LMakefile")
      (progn
	(let ((cmd (car forms))
	      (plug nil))
	  (dolist (x *plugins*)
	    (setf plug (car x))
	    (if (equal cmd plug)
		(progn
		  (lm-debug "runner" "running plugin")
		  (funcall (cadr x) (cdr forms)))))))))

(defun fix-and-eval (args)
  (eval (append '(progn) args)))

(defun main ()
  (in-package :lispmake)
  (handle-options)
  (if *debugging*
      (format t "lispmake r~A~%" *lispmake-version*)
      (disable-debugger))
  (install-plugin :package 'pl-package)
  (install-plugin :toplevel 'pl-toplevel)
  (install-plugin :file 'pl-file)
  (install-plugin :output 'pl-output)
  (install-plugin :quicklisp 'pl-quicklisp)
  (install-plugin :generate
		  (lambda (args)
		    (declare (ignore args))
		    (setf *generate* (not *generate*))))
  (install-plugin :eval
		  (lambda (args)
		    (fix-and-eval args)))
  (install-plugin :echo
		  (lambda (args)
		    (format t "~A~%" args)))
  (install-plugin :lisp
		  (lambda (args)
		    (setf *lisp-target* (car args))))
  (install-plugin :compile-file 'pl-compile-file)
  (install-plugin :build-with 'pl-lisp-executable)
  (install-plugin :do-build
		  (lambda (args)
		    (declare (ignore args))
		    (setf *do-build* (not *do-build*))))
  (install-plugin :exec 'pl-exec)
  (install-plugin :install 'pl-install)
  (install-plugin :delete 'pl-delete)
  (install-plugin :define 'pl-define)
  (install-plugin :configure 'pl-configure)
  (install-pregen-hook 'pl-compile-file-pregen)
  (with-open-file (lmkfile *lmakefile*)
    (loop for form = (read lmkfile nil nil)
	 until (eq form nil)
	 do (progn
	      (lm-debug "main" "reading form")
	      (runner form)))
    (if *generate*
	(progn
	  (lm-debug "main" (format nil "generating run-~A.lisp~%" (output-fname)))
	  (generate))))
  (if *debugging* (print *variables*))
  (format t "~%"))
