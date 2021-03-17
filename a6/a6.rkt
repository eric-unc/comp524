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
  (let ([type (first (second expr))]
        [val (second expr)])
    (case type
      ['atom (eval-atom val env)]
      ['invocation (eval-invocation val env)]
      ['let (eval-let val env)]
      ['define (eval-define val env)]
      ['lambda (eval-lambda val env)])))

(define (eval-let let-expr env)
  (let ([name (second (fourth let-expr))]
        [val (eval-expr (fifth let-expr) env)]
        [body (seventh let-expr)])
    (eval-expr body
               (add-binding env name val))))

(define (eval-define define-expr env) ; TODO
  (let* ([name (second (third define-expr))]
        [val (eval-expr (fourth define-expr) env)]
        [newenv (add-binding env name val)])
    val))

(define (eval-lambda lambda-expr env) ; TODO
  null)

(define (eval-atom atom env)
  (let ([type (first (second atom))]
        [val (second atom)])
    (case type
      ['number (eval-number val env)]
      ['NAME (let ([name (check-name (second val))])
               (if (equal? name null)
                 (lookup-name env (second val))
                 name))]
      ['STRING (second val)]
      [else (error "Unknown atom? [This should not happen]")])))

(define (check-name name)
  (case name
    ['+ +]
    ['- -]
    ['* *]
    ['/ /]
    ['string-append string-append]
    ['string<? string<?]
    ['string=? string=?]
    ['not not]
    ['= =]
    ['< <]
    ['and 'and]
    ['or 'or]
    [else null]))

(define (eval-number number env)
  (second (second number)))

(define (check-special-form rator)
  (or
   (equal? rator 'and)
   (equal? rator 'or)))

(define (eval-invocation invocation env)
  (let* ([list (eval-expr-list (third invocation) env)]
         [rator (first list)]
         [rands (rest list)])
    (if (check-special-form rator)
        (eval-special-form rator rands env)
        (apply rator rands))))

(define (eval-special-form rator rands env)
  (case rator
    ['and (eval-and rands env)]
    ['or (eval-or rands env)]))

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

  ; A6 specific
  (check-equal? (eval "let (x 5) x") 5)
  (check-equal? (eval "let (x (+ 1 2)) (+ x 3)") 6)
  )
