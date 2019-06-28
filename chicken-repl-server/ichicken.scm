(module ichicken
    (ichicken-repl ichicken-port-number ichicken-command-delimiter)

  (import scheme (chicken base)
    (chicken tcp) (chicken io) (chicken condition) (chicken port))

(define ichicken-port-number (make-parameter 7421))
(define ichicken-command-delimiter (make-parameter #\null))

(define (until-end-of-transmission? c) (not (equal? c (ichicken-command-delimiter))))

(define (read/eval-code in)
  (define code (read-token until-end-of-transmission? in))
  (print "Received code:" code)
  (define latest #f)
  (define stdout-stderr
    (call-with-output-string
     (lambda (output-string)
       (parameterize ((current-output-port output-string)
                      (current-error-port output-string))
         (call-with-current-continuation
          (lambda (cc)
            (with-exception-handler
                (lambda (exn)
                  (let ((exn-message ((condition-property-accessor 'exn 'message) exn)))
                    (print "Exception:" exn-message)
                    (cc (void))))
              (lambda ()
                (with-input-from-string code
                  (lambda ()
                    (define (read/eval) (eval (read)))
                    (let eval-next ((result (read/eval)))
                      (if (equal? result #!eof)
                          (void)
                          (begin
                            (set! latest result)
                            (eval-next (read/eval)))))))))))))))
  (print "Captured stdout/stderr: " stdout-stderr)
  (print "Last eval returned: " latest)
  (values stdout-stderr latest))

(define (ichicken-repl port)
  (define listen-port (tcp-listen port))
  (print "Listening on port: " port)
  (let handle-connection ()
    (define-values (in out) (tcp-accept listen-port))
    (print "Connection received.")
    (let-values (((out-err result) (read/eval-code in)))
      (print "Sending reponse.")
      (display out-err out)
      (display result out)
      (close-output-port out)
      (close-input-port in)
      (print "Connection closed."))
    (handle-connection)))
)
