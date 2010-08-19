#!r6rs

(import (rnrs) (ucl prelude) (ucl process) (ucl filesystem))

(define temp (shell "mktemp -u"))

(assert (not (path-exists? temp)))
(mkpath (string-append temp "/foo/bar"))
(assert (path-exists? temp))
(mkdir (string-append temp "/foo/baz"))
(assert (path-exists? (string-append temp "/foo/baz")))
(assert (path-dir? (string-append temp "/foo/baz")))
(assert (or (equal? '("bar" "baz") (dir-contents (string-append temp "/foo")))
            (equal? '("baz" "bar") (dir-contents (string-append temp "/foo")))))
(remove-dir (string-append temp "/foo/baz"))
(assert (equal? '("bar") (dir-contents (string-append temp "/foo"))))
(remove-recursive temp)
(assert (not (path-exists? temp)))

(display "success\n")
