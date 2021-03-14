#lang racket
(require "parser.rkt")

(define new-environment hash)
(define add-binding hash-set)
(define lookup-name hash-ref)

(define (eval code)
  (eval-program (parse code) (new-environment)))

(define (eval-program program env)
  (last (eval-expr-list (second program) env)))

(define (eval-expr-list expr-list env)
  (if (equal? expr-list null)
      null
      (cons (eval-expr (second expr-list) env) (eval-opt-expr-list (third expr-list) env))))

(define (eval-opt-expr-list opt-expr-list env)
  (if (< (length opt-expr-list) 2)
      null
      (eval-expr-list (second opt-expr-list) env)))

(define (eval-expr expr env)
  (if (equal? (first (second expr)) 'invocation)
      (eval-invocation (second expr) env)
      (eval-atom (second expr) env)))


(define (eval-atom atom env)
  (cond
    [(equal? (first (second atom)) 'number) (eval-number (second atom) env)]
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
    [(equal? name 'and) 'and]
    [(equal? name 'or) 'or]
    [else (error "Unknown rator!")]))

(define (eval-number number env)
  (second (second number)))

(define (check-special-form rator)
  (or
   (equal? rator 'and)
   (equal? rator 'or)
   ))

(define (eval-invocation invocation env)
  (let* ([list (eval-expr-list (third invocation) env)]
         [rator (first list)]
         [rands (rest list)])
    (if (check-special-form rator)
        (eval-special-form rator rands env)
        (apply rator rands))))

(define (eval-special-form rator rands env)
  (cond
    [(equal? rator 'and) (eval-and rands env)]
    [(equal? rator 'or) (eval-or rands env)]))

(define (eval-and rands env)
  (cond
    [(empty? rands) #t]
    [(equal? (length rands) 1) (first rands)]
    [else (if (first rands)
              (eval-and (rest rands env))
              #f)]))

(define (eval-or rands env)
  (cond
    [(empty? rands) #f]
    [(equal? (length rands) 1) (first rands)]
    [else (if (first rands)
              #t
              (eval-or (rest rands) env))]))

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
  (check-equal? (eval "(* 7 8)") 56)
  (check-equal? (eval "(* 7 (- 8))") -56)
  (check-equal? (eval "(* (+ 1 2) (/ 8 4))") 6)
  (check-equal? (eval "(string=? \"abc\" (string-append \"a\" \"b\" \"c\"))") #t)
  (check-equal? (eval "(string<? \"abc\" (string-append \"a\" \"b\" \"b\"))") #f)
  (check-equal? (eval "(not (string<? \"abc\" (string-append \"a\" \"b\" \"b\")))") #t)
  (check-exn exn:fail? (lambda ()
                         (eval "(list)")))
  (check-exn exn:fail? (lambda ()
                         (eval "(+ 1 \"a\")")))
  (check-exn exn:fail? (lambda ()
                         (eval "(string-append 1 \"a\")")))
  (check-exn exn:fail? (lambda ()
                         (eval "(/ 1 0)")))
  )
