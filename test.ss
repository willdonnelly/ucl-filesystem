#!r6rs

(import (rnrs) (ucl prelude) (ucl filesystem))

(for ((dir (dir-contents "/home/will")))
  (write dir)
  (newline))
