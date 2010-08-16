#!r6rs
(library (ucl filesystem libc)
  (export symlink mkdir dir-exists? dir-contents remove-file remove-dir)
  (import (rnrs) (ucl prelude) (ucl ffi))

  (define libc (load-library "libc.so.6" "libc.so"))

  (define raw-symlink (get-function libc "symlink" '(string string) 'sint))
  (define (symlink a b)
    (unless (zero? (raw-symlink a b))
      (error 'symlink (print "unable to create symlink % -> %" b a))))

  (define raw-mkdir (get-function libc "mkdir" '(string sint) 'sint))
  (define (mkdir path)
    (unless (zero? (raw-mkdir path #x1FF))
      (error 'mkdir (print "unable to create directory '%'" path))))

  (define raw-opendir (get-function libc "opendir" '(string) 'pointer))
  (define raw-readdir (get-function libc "readdir" '(pointer) 'pointer))
  (define raw-closedir (get-function libc "closedir" '(pointer) 'sint))

  (define (dir-exists? path)
    (let ((dirstream (raw-opendir path)))
      (if (zero? (pointer->integer dirstream))
          #f
          (begin
            (raw-closedir dirstream)
            #t))))

  (define (dir-contents path)
    (define (notdots p) (not (or (equal? "." p) (equal? ".." p))))
    (filter notdots (dir-contents* path)))

  (define (dir-contents* path)
;    (error 'dir-contents "not implemented in the FFI fallback yet, sorry"))
;    ;; hackishly search for an offset that puts both
;    ;; the '.' and '..' filenames as the first two
;    ;; directory entries
;    (define (test-offset dot dotdot off)
;      (and
;        (equal? "." (dirent-name off dot))
;        (equal? ".." (dirent-name off dotdot))))
;    (define (find-offset dot dotdot)
;      (let ((candidates (filter (curry test-offset dot dotdot) (range 0 32))))
;        (assert (> (length candidates) 0))
;        (car (reverse candidates))))
    (define (dirent-name off dp)
      (string-read (integer->pointer (+ (pointer->integer dp) off))))
    (with-error (print "unable to read contents of '%'" path)
      (let ((dirstream (raw-opendir path)))
        (assert (not (zero? (pointer->integer dirstream))))
          (let ((name-offset 11)) ; some day i'll figure out how to get this offset, and
                                  ; then this code will work on BSD
            (let loop ((entries '()))
              (let ((dirent (raw-readdir dirstream)))
                (if (zero? (pointer->integer dirent))
                    (begin
                      (assert (zero? (raw-closedir dirstream)))
                      (reverse entries))
                    (loop (cons (dirent-name name-offset dirent) entries)))))))))

  (define raw-unlink (get-function libc "unlink" '(string) 'sint))
  (define (remove-file path)
    (unless (zero? (raw-unlink path))
      (error 'remove-file (print "unable to remove file '%'" path))))

  (define raw-rmdir  (get-function libc "rmdir"  '(string) 'sint))
  (define (remove-dir path)
    (unless (zero? (raw-rmdir path))
      (error 'remove-dir (print "unable to remove directory '%'" path))))
)
