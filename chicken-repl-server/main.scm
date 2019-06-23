(import (chicken tcp) (chicken io) (chicken condition) (chicken port))

(define-constant PORT 7421)

(define (until-end-of-transmission? c) (not (equal? c #\null)))

(define (read/eval-code in)
  (define code (read-token until-end-of-transmission? in))
  (print "Received code:" code)
  (call-with-current-continuation
   (lambda (cc)
     (with-exception-handler
         (lambda (exn)
           (let ((exn-message ((condition-property-accessor 'exn 'message) exn)))
             (print "Exception:" exn-message)
             (cc exn-message)))
       (lambda ()
         (with-input-from-string code
           (lambda ()
             (define (read/eval) (eval (read)))
             (let eval-next ((result (read/eval))
                             (latest #f))
               (print "Result:" result)
               (if (equal? result #!eof)
                   latest
                   (eval-next (read/eval) result))))))))))

(define (repl port)
  (define listen-port (tcp-listen 7421))
  (print "Listening on port 7421.")
  (let loop ()
    (define-values (in out) (tcp-accept listen-port))
    (print "Connection received.")
    (let ((response (read/eval-code in)))
      (print "Sending reponse.")
      (display response out)
      (close-output-port out)
      (close-input-port in)
      (print "Connection closed."))
    (loop))
  )

(define (start)
  (call-with-output-file
      ".log-chicken-server-repl"
    (lambda (logfile)
      (current-error-port logfile)
      (current-output-port (current-error-port))
      (repl PORT))))

(start)
