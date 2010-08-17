#!r6rs
(library (ucl filesystem ls)
  (export dir-contents)
  (import (rnrs) (ucl prelude) (ucl process))

(define (dir-contents d)
  (define (strip-prefix pre str)
    (let ((sl (string-length str))
          (pl (string-length pre)))
      (if (< sl pl) ""
        (if (not (equal? pre (substring str 0 pl))) ""
          (substring str pl sl)))))
  (unless (equal? d "/")
    (set! d (string-append d "/"))) ;; more slashes are always good except on /
  (let ((p (process-launch "/usr/bin/env" "find" d "-maxdepth" "1" "-print0")))
    (cleanup (process-close p)
      (replace-error (error 'dir-contents "unable to list directory contents" d)
        (filter (lambda (s) (> (string-length s) 0))
          (map (curry strip-prefix d)
            (map (lambda (bv) (bytevector->string bv (native-transcoder)))
              (map u8-list->bytevector
                (break-on (curry = 0)
                  (bytevector->u8-list
                    (get-bytevector-all
                      (process-stdout p))))))))))))
)
