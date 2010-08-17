#!r6rs
(library (ucl filesystem libc)
  (export symlink mkdir dir-exists? dir-contents remove-file remove-dir)
  (import (rnrs) (ucl prelude) (ucl ffi))

  (define libc (load-library "libc.so.6" "libc.so"))

  (define raw-symlink (get-function libc "symlink" '(string string) 'sint))
  (define (symlink a b)
    (unless (zero? (raw-symlink a b))
      (error 'symlink (template "unable to create symlink % -> %" b a))))

  (define raw-mkdir (get-function libc "mkdir" '(string sint) 'sint))
  (define (mkdir path)
    (unless (zero? (raw-mkdir path #x1FF))
      (error 'mkdir (template "unable to create directory '%'" path))))

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
    (error 'dir-contents "not implemented in the FFI fallback yet, sorry"))

  (define raw-unlink (get-function libc "unlink" '(string) 'sint))
  (define (remove-file path)
    (unless (zero? (raw-unlink path))
      (error 'remove-file (template "unable to remove file '%'" path))))

  (define raw-rmdir  (get-function libc "rmdir"  '(string) 'sint))
  (define (remove-dir path)
    (unless (zero? (raw-rmdir path))
      (error 'remove-dir (template "unable to remove directory '%'" path))))
)
