#!r6rs
;(library (ucl filesystem)
;  (export touch file-exists? file-contents
;          mkdir dir-exists? dir-contents
;          symlink remove-single remove-recursive
;          mkdir-parents)
  (import (rnrs) (ucl prelude) (ucl ffi))

  (define (touch path) (with-output-to-file path (lambda () #t)))
  ;; file-exists? is defined by R6RS, but we re-export it for completeness
  (define (file-contents path) (call-with-input-file path get-string-all))

  (define libc (load-library "libc.so.6" "libc.so"))

  (define raw-mkdir (get-function libc "mkdir" '(string sint) 'sint))
  (define raw-opendir (get-function libc "opendir" '(string) 'pointer))
  (define raw-readdir (get-function libc "readdir" '(pointer) 'pointer))
  (define raw-closedir (get-function libc "closedir" '(pointer) 'sint))

  (define (mkdir path)
    (unless (zero? (raw-mkdir path #x1FF))
      (error 'mkdir (print "unable to create directory '%'" path))))

  (define (dir-contents path)
    ;; hackishly search for an offset that puts both
    ;; the '.' and '..' filenames as the first two
    ;; directory entries
    (define (test-offset dot dotdot off)
      (and
        (equal? "." (dirent-name off dot))
        (equal? ".." (dirent-name off dotdot))))
    (define (find-offset dot dotdot)
      (let ((candidates (filter (curry test-offset dot dotdot) (range 0 32))))
        (assert (> (length candidates) 0))
        (car (reverse candidates))))
    (define (dirent-name off dp)
      (string-read (integer->pointer (+ (pointer->integer dp) off))))
    (with-error (print "unable to read contents of '%'" path)
      (let ((dirstream (raw-opendir path)))
        (assert (not (zero? (pointer->integer dirstream))))
        ;; OH GOD SO HACKISH
;        (let ((dot (raw-readdir dirstream))
;              (dotdot (raw-readdir dirstream)))
          (let ((name-offset 11))
            (let loop ((entries '()))
              (let ((dirent (raw-readdir dirstream)))
                (if (zero? (pointer->integer dirent))
                    (begin
                      (assert (zero? (raw-closedir dirstream)))
                      (reverse entries))
                    (loop (cons (dirent-name name-offset dirent) entries)))))))))

  (define (dir-exists? path)
    (let ((dirstream (raw-opendir path)))
      (if (zero? (pointer->integer dirstream))
          #f
          (begin
            (raw-closedir dirstream)
            #t))))

  (define raw-symlink (get-function libc "symlink" '(string string) 'sint))

  (define (symlink a b)
    (unless (zero? (raw-symlink a b))
      (error 'symlink (print "unable to create symlink % -> %" b a))))

  (define raw-remove (get-function libc "remove" '(string) 'sint))

  (define (remove-single path)
    (unless (zero? (raw-remove path))
      (error 'unlink (print "unable to remove file or directory '%'" path))))

  (define (remove-recursive path)
    (define (remove-subnode name)
      (remove-recursive (string-append path "/" name)))
    (when (dir-exists? path)
      (map remove-subnode (dir-contents path)))
    (remove-single path))

  (define (mkdir-parents path)
    (let ((bits (break-string #\/ path)))
      bits))
;)
