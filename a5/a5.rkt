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
  (if (< (length opt-expr-list) 2)
      null
      (eval-expr-list (second opt-expr-list))))

(define (eval-expr expr)
  (if (equal? (first (second expr)) 'invocation)
      (eval-invocation (second expr))
      (eval-atom (second expr))))


(define (eval-atom atom)
  (cond
    [(equal? (first (second atom)) 'number) (eval-number (second atom))]
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

(define (eval-number number)
  (second (second number)))

(define (check-special-form rator)
  (or
   (equal? rator 'and)
   (equal? rator 'or)
   ))

(define (eval-invocation invocation)
  (let* ([list (eval-expr-list (third invocation))]
         [rator (first list)]
         [rands (rest list)])
    (if (check-special-form rator)
        (eval-special-form rator rands)
        (apply rator rands))))

(define (eval-special-form rator rands)
  (cond
    [(equal? rator 'and) (eval-and rands)]
    [(equal? rator 'or) (eval-or rands)]))

(define (eval-and rands)
  (cond
    [(empty? rands) #t]
    [(equal? (length rands) 1) (first rands)]
    [else (if (first rands)
              (eval-and (rest rands))
              #f)]))

(define (eval-or rands)
  (cond
    [(empty? rands) #f]
    [(equal? (length rands) 1) (first rands)]
    [else (if (first rands)
              #t
              (eval-or (rest rands)))]))

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
