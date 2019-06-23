(import (chicken tcp) (chicken repl) (chicken io))

(define (start)
  (print "Connecting to localhost:7421.")
  (define-values (in out) (tcp-connect "localhost" 7421))
  (write-line "\"Hello world\"" out)
  (close-output-port out)
  (let communicate ((next-input (read in)))
    (if (eq? next-input #!eof)
        (print "DONE")
        (begin
          (print "RESPONSE:")
          (print next-input)
          (communicate (read in)))))
  (close-input-port in))

(start)
