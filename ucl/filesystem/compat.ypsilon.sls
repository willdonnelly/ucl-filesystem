#!r6rs
(library (ucl filesystem compat)
  (export symlink mkdir dir-exists? dir-contents remove-dir)
  (import (rnrs) (core files)
    (only (ucl filesystem libc)
      symlink mkdir dir-exists? remove-dir))

  (define (dir-contents path)
    (define (not-dots p) (not (or (equal? p ".") (equal? p ".."))))
    (filter not-dots (directory-list path)))
)
