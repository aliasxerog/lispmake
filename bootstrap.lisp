;; autogenerated by lispmake revision 14
;; DO NOT EDIT
(ql:quickload 'UNIX-OPTIONS)
(ql:quickload 'SPLIT-SEQUENCE)
(ql:quickload 'OSICAT)
(ql:quickload 'CL-FAD)
(load #P"package.lisp")
(load #P"vars.lisp")
(load #P"debug.lisp")
(load #P"lisp-specific.lisp")
(load #P"plugin.lisp")
(load #P"options.lisp")
(load #P"core.lisp")
(load #P"file-utils.lisp")
(load #P"asdf.lisp")
(load #P"asdf-deps.lisp")
(load #P"lispmake.lisp")
#+sbcl (sb-ext:save-lisp-and-die "lispmake" :executable t :toplevel #'LISPMAKE:MAIN)
#+ccl (ccl:save-application lispmake :toplevel-function #'LISPMAKE:MAIN :prepend-kernel t)
#+clisp (ext:saveinitmem lispmake :init-function #'LISPMAKE:MAIN :executable t :norc t)
