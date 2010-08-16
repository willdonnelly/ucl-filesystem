#!r6rs
(library (ucl filesystem)
  (export touch symlink mkdir mkpath
          path-exists? path-file? path-dir?
          file-contents dir-contents
          remove-file remove-dir remove-recursive)

  (import (rnrs) (ucl prelude) (ucl filesystem compat))

  (define (touch path) (with-output-to-file path (lambda () #t)))

  ; symlink comes from the compat module

  ; mkdir comes from the compat module

  (define (cumulative xs)
    (map reverse (reverse (cumulative* (reverse xs)))))
  (define (cumulative* xs)
    (if (null? xs) '() (cons xs (cumulative* (cdr xs)))))
  (define (pathify abs ds)
    (define main (apply string-append (intersperse "/" ds)))
    (if abs (string-append "/" main) main))
  (define (path-bits path)
    (when (zero? (string-length path))
      (error 'path-bits "path string is empty"))
    (if (equal? "/" path)
        '("/")
        (let ((absolute (equal? #\/ (string-ref path 0)))
              (dir-bits (break-string #\/ path)))
          (map (curry pathify absolute) (cumulative dir-bits)))))
  (define (mkpath path)
    (for ((dir (path-bits path)))
      (unless (and (path-exists? dir) (path-dir? dir))
        (mkdir dir))))

  (define (path-exists? path)
    (or (file-exists? path) (dir-exists? path)))
  (define (path-file? path)
    (and (file-exists? path) (not (dir-exists? path))))
  (define (path-dir? path)
    (dir-exists? path))

  (define (file-contents path) (call-with-input-file path get-string-all))

  ; dir-contents comes from the compat module

  ; remove-file comes from the compat module

  ; remove-dir comes from the compat module

  (define (remove-recursive path)
    (define (remove-subnode name)
      (remove-recursive (string-append path "/" name)))
    (if (path-dir? path)
        (begin
          (map remove-subnode (dir-contents path))
          (remove-dir path))
        (remove-file path)))

)
