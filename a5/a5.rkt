#lang racket
(require "a3.rkt")

(define (eval code)
  (eval-program (parse code)))

(define (eval-program program)
  (last (eval-expr-list (second program))))

(define (eval-expr-list expr-list)
  (if (equal? expr-list null)
      null
      (cons (eval-expr (second expr-list)) (eval-opt-expr-list (third expr-list)))))

(define (eval-opt-expr-list opt-expr-list)
  (if (< (length opt-expr-list) 2) ; (equal? opt-expr-list null)
      null
      (eval-expr-list (second opt-expr-list))))

; todo
(define (eval-expr expr)
  (if (equal? (first (second expr)) 'invocation)
      (eval-invocation (second expr))
      (eval-atom (second expr))))

;(define (eval-expr expr) expr)

#;(define (eval-atom atom)
  atom)

#;(define (eval-atom atom)
  (if (equal? (first (second atom)) 'number)
      (eval-number (second atom))
      ()))

(define (eval-atom atom)
  (cond
    [(equal? (first (second atom)) 'number) (eval-number (second atom))]
    ;[(equal? (first (second atom)) 'NAME) (second (second atom))]
    [(equal? (first (second atom)) 'NAME) (check-name (second (second atom)))]
    [(equal? (first (second atom)) 'STRING) (second (second atom))]
    [else (error "Unknown atom? [This should not happen]")]))

(define (check-name name)
  (cond
    [(equal? name '+) +]
    [(equal? name '-) -]
    [(equal? name '*) *]
    [(equal? name '/) /]
    [(equal? name 'string-append) string-append]
    [(equal? name 'string<?) string<?]
    [(equal? name 'string=?) string=?]
    [(equal? name 'not) not]
    [(equal? name '=) =]
    [(equal? name '<) <]
    [else (error "Unknown rator!")]))

(define (eval-number number)
  (second (second number)))

#;(define (eval-invocation invocation)
  (eval-expr-list (third invocation)))

(define (eval-invocation invocation)
  (let* ([list (eval-expr-list (third invocation))]
         [rator (first list)]
         [rands (rest list)])
    (apply rator rands)))

; Unit tests
(module+ test
  (require (only-in rackunit
                    check-equal?
                    check-exn
                    check-not-exn)))

(module+ test
  (check-equal? (eval "5") 5)
  (check-exn exn:fail? (lambda ()
                         (eval "foo")))
  )