#!r6rs
(library (ucl filesystem compat)
  (export symlink mkdir dir-exists? dir-contents remove-file remove-dir)
  (import (rnrs)
    (only (ucl filesystem libc)
      symlink mkdir dir-exists? remove-file remove-dir)
    (only (ucl filesystem ls) dir-contents))
)
