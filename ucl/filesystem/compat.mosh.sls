#!r6rs
(library (ucl filesystem compat)
  (export symlink mkdir dir-exists? dir-contents remove-dir)
  (import (rnrs) (mosh file))

  (define symlink create-symbolic-link)
  (define mkdir create-directory)
  (define dir-exists? file-directory?)
  (define (dir-contents path)
    (define (not-dots p) (not (or (equal? p ".") (equal? p ".."))))
    (filter not-dots (directory-list path)))
  (define remove-dir delete-directory)
)
