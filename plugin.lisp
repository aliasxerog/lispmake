(in-package :lispmake)

;; lispmake, written by Matthew Veety, et al.
;; (c) Matthew Veety 2012-2021. Under BSD License.

(defun load-plugin (name file toplevel init-toplevel)
  (setf toplevel (car toplevel))
  (setf init-toplevel (car init-toplevel))
  (lm-debug "load-plugin" "loading a plugin")
  (format t "debug: toplevel=~A init-toplevel=~A~%"
		  (type-of toplevel) (type-of init-toplevel))
  (format t "debug: toplevel=~A init-toplevel=~A~%"
		  toplevel init-toplevel)
  (if *debugging*
      (format t 
			  "lispmake: debug: installing plugin ~A from file ~A with 
toplevel ~A and running ~A~%" 
			  name file toplevel init-toplevel))
  (if (equal (type-of name) 'keyword)
      (progn
		(load file)
		(setf *plugins* (append *plugins* (list (list name toplevel))))
		(lm-debug "load-plugin" "running toplevel function")
		(funcall init-toplevel))
      (lm-error "load-plugin" "arg name should be type keyword")))

(defun install-plugin (name toplevel)
  (if *debugging*
      (format t "lispmake: debug: installing plugin ~A with toplevel ~A~%"
			  name (if (functionp toplevel)
					   "#<FUNCTION>"
					   toplevel)))
  (if (or (functionp toplevel)
		  (symbolp toplevel))
      (if (keywordp name)
		  (setf *plugins* (append *plugins* (list name toplevel)))
		  (lm-error "install-plugin" "arg name should by type keyword"))
      (lm-error "install-plugin" "arg toplevel should be type symbol")))

(defmacro install-fn-plugin (name &body list-of-forms)
  `(install-plugin
    ,name
    (lambda (args) ,@list-of-forms)))

(defun run-plugin-pregen (x)
  (lm-debug "run-plugin-pregen" "running pre-generation hooks")
  (let ((*standard-output* x))
    (if (not (equal *pregen-hooks* nil))
		(dolist (y *pregen-hooks*)
		  (funcall y))
		nil)))

(defun run-plugin-postgen (x)
  (lm-debug "run-plugin-postgen" "running post-generation hooks")
  (let ((*standard-output* x))
    (if (not (equal *postgen-hooks* nil))
		(dolist (y *postgen-hooks*)
		  (funcall y))
		nil)))

(defun install-pregen-hook (fname)
  (lm-debug "install-pregen-hook" (format nil "adding pre-generation hook ~A" fname))
  (if (not (equal (type-of fname) 'symbol))
      (lm-warning "install-pregen-hook" "fname is not of type symbol")
      (setf *pregen-hooks* (append *pregen-hooks* (list fname)))))

(defun install-postgen-hook (fname)
  (lm-debug "install-postgen-hook" (format nil "adding post-generation hook ~A" fname))
  (if (not (equal (type-of fname) 'symbol))
      (lm-warning "install-postgen-hook" "fname is not of type symbol")
      (setf *postgen-hooks* (append *postgen-hooks* (list fname)))))

(defun pl-plugin (args)
  (if (not (equal (length args) 4))
      (lm-error "pl-plugin" "error parsing plugin def")
      (load-plugin (car args) (cadr args) (caddr args) (cadddr args))))

