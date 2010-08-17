#!r6rs
(library (ucl filesystem compat)
  (export symlink mkdir dir-exists? dir-contents
          remove-file remove-dir)
  (import (rnrs) (scheme mpair)
    (only (scheme base)
      make-directory directory-exists?
      path->string directory-list
      make-file-or-directory-link
      delete-file delete-directory))

  (define (symlink a b) (make-file-or-directory-link a b))
  (define mkdir make-directory)
  (define dir-exists? directory-exists?)
  (define (dir-contents path)
    (map path->string
      (list->mlist
        (directory-list path))))
  (define remove-file delete-file)
  (define remove-dir delete-directory)
)
