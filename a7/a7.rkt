#lang racket

(provide eval repl)

(require "parse.rkt")

(module+ test (require rackunit))

(define new-environment hash)
(define add-binding hash-set)
(define lookup-name hash-ref)

(define (eval code-string)
  (eval-program (parse code-string) (new-environment)))

(define (eval-program program-expr env)
  ;; program     := exprList
  (last (eval-exprList (second program-expr) env)))

(define (eval-exprList exprList-expr env)
  ;; exprList    := expr optExprList
  (let* ([expr-expr (second exprList-expr)]
         [expr-tag (first (second expr-expr))]
         [optExprList-expr (third exprList-expr)])
    (if (equal? expr-tag 'define)
      ;; define      := DEFINE NAME expr
      (let* ([define-expr (second expr-expr)]
             [name (second (third define-expr))]
             [value-expr (fourth define-expr)]
             [new-env (add-binding env name (eval-expr value-expr env))])
        (eval-optExprList (lookup-name new-env name)
                          optExprList-expr
                          new-env))
      ;; normal stuff
      (eval-optExprList (eval-expr expr-expr env)
                        optExprList-expr
                        env))))

(define (eval-optExprList value optExprList-expr env)
  ;; optExprList := ɛ | exprList
  (cons value (if (empty? (rest optExprList-expr))
                null
                (eval-exprList (second optExprList-expr) env))))

(define (eval-expr expr-expr env)
  ;; expr        := atom | invocation | let | define | lambda
  (let* ([expr-to-eval (second expr-expr)]
         [tag (first expr-to-eval)]
         [evaluator (case tag
                      [(atom) eval-atom]
                      [(invocation) eval-invocation]
                      [(let) eval-let]
                      ;; define case is handled in `eval-exprList`
                      [(lambda) eval-lambda])])
    (evaluator expr-to-eval env)))

(define (eval-atom atom-expr env)
  ;; atom        := NAME | STRING | number
  (let* ([name-string-number (second atom-expr)]
         [tag (first name-string-number)]
         [evaluator (case tag
                      [(NAME) eval-name]
                      [(STRING) eval-string]
                      [(number) eval-number])])
    (evaluator name-string-number env)))

(define (eval-name name-expr env)
  ;; + - * / string-append string<? string=? not = <
  (case (second name-expr)
    [(+) +]
    [(-) -]
    [(*) *]
    [(/) /]
    [(string-append) string-append]
    [(string<?) string<?]
    [(string=?) string=?]
    [(not) not]
    [(=) =]
    [(<) <]
    [else (lookup-name env (second name-expr))]))

(define (eval-string string-expr env) (second string-expr))
(define (eval-number number-expr env)
  ;; number      := INT | FLOAT
  (second (second number-expr)))

(define (eval-let let-expr env)
  ;; let         := LET OPAREN NAME expr CPAREN expr
  (let* ([name (second (fourth let-expr))]
         [value-expr (fifth let-expr)]
         [body-expr (seventh let-expr)])
    (eval-expr body-expr
               (add-binding env name (eval-expr value-expr env)))))

(define (eval-lambda lambda-expr env)
  ;; lambda      := LAMBDA OPAREN lambda-args CPAREN expr
  (let* ([names (rest (fourth lambda-expr))]
         [body-expr (sixth lambda-expr)])
    (lambda values
      (eval-expr body-expr
                 (add-bindings env names values)))))

(define (add-bindings env names values)
  (cond
    [(empty? names) (if (empty? values)
                      env
                      (error "too many values"))]
    [(empty? values) (if (empty? names)
                       env
                       (error "not enough values"))]
    [else (let ([name (second (first names))]
                [names (rest names)]
                [value (first values)]
                [values (rest values)])
            (add-bindings (add-binding env name value)
                          names values))]))

(define (eval-invocation invocation-expr env)
  ;; invocation  := OPAREN exprList CPAREN
  (let* ([exprList-expr (third invocation-expr)]
         [rator-expr (second (second exprList-expr))]
         [values (eval-exprList exprList-expr env)]
         [rator (first values)]
         [rands (rest values)])
    (apply rator rands)))

(define (repl)
  (parameterize ([current-read-interaction (lambda (_ in)
                                             (read-line in))]
                 [current-eval (lambda (e)
                                 (when (non-empty-string? (cdr e))
                                   (eval (cdr e))))])
    (read-eval-print-loop)))

(module+ test
  (check-equal? (eval "7") 7)
  (check-equal? (eval "7.7") 7.7)
  (check-equal? (eval "\"a string\"") "a string")
  (check-exn exn:fail? (thunk (eval "foo")))
  (check-exn exn:fail? (thunk (eval "(list)")))
  (check-equal? (eval "7 8") 8)
  (check-equal? (eval "(+)") 0)
  (check-equal? (eval "(+ 7)") 7)
  (check-equal? (eval "(+ 7 8)") 15)
  (check-equal? (eval "(+ 7 8 15.0)") 30.0)
  (check-exn exn:fail? (thunk (eval "(-)")))
  (check-equal? (eval "(- 7)") -7)
  (check-equal? (eval "(- 7 -8)") 15)
  (check-equal? (eval "(- 7 -8 15.0)") 0.0)
  (check-equal? (eval "(*)") 1)
  (check-equal? (eval "(* 7)") 7)
  (check-equal? (eval "(* 7 8)") 56)
  (check-equal? (eval "(* 7 8 15.0)") 840.0)
  (check-exn exn:fail? (thunk (eval "(/)")))
  (check-exn exn:fail? (thunk (eval "(/ 1 0)")))
  (check-equal? (eval "(/ 7)") 1/7)
  (check-equal? (eval "(/ 7 8)") 7/8)
  (check-equal? (eval "(/ 7 8 15.0)") (/ 7 8 15.0))
  (check-equal? (eval "(+ 7 (- 8 1))") (+ 7 (- 8 1)))
  (check-equal? (eval "(+ 7 (+ 8 1)) (+ 7 (- 8 1))") (+ 7 (- 8 1)))
  (check-equal? (eval "(string-append)") "")
  (check-equal? (eval "(string-append \"abc\")") "abc")
  (check-equal? (eval "(string-append \"abc\" \"def\")") (string-append "abc" "def"))
  (check-equal? (eval "(string-append \"abc\" \"def\" \"ghi\")") (string-append "abc" "def" "ghi"))
  (check-exn exn:fail? (thunk (eval "(string<?)")))
  (check-equal? (eval "(string<? \"abc\")") #t)
  (check-equal? (eval "(string<? \"abc\" \"def\")") (string<? "abc" "def"))
  (check-equal? (eval "(string<? \"def\" \"abc\")") (string<? "def" "abc"))
  (check-equal? (eval "(string<? \"abc\" \"def\" \"ghi\")") (string<? "abc" "def" "ghi"))
  (check-exn exn:fail? (thunk (eval "(string=?)")))
  (check-equal? (eval "(string=? \"abc\")") #t)
  (check-equal? (eval "(string=? \"abc\" \"def\")") (string=? "abc" "def"))
  (check-equal? (eval "(string=? \"abc\" \"abc\")") (string=? "abc" "abc"))
  (check-equal? (eval "(string=? \"abc\" \"def\" \"ghi\")") (string=? "abc" "def" "ghi"))
  (check-exn exn:fail? (thunk (eval "(not)")))
  (check-exn exn:fail? (thunk (eval "(not 1 2)")))
  (check-equal? (eval "(not 1)") #f)
  (check-equal? (eval "(not 1.0)") #f)
  (check-equal? (eval "(not (= 0 1))") #t)
  (check-exn exn:fail? (thunk (eval "(=)")))
  (check-equal? (eval "(= 1)") #t)
  (check-equal? (eval "(= 0 1)") #f)
  (check-equal? (eval "(= 1.0 1)") #t)
  (check-equal? (eval "(= 0 1 2)") #f)
  (check-equal? (eval "(= (+ 1 0) 1 (- 2 1))") #t)
  (check-exn exn:fail? (thunk (eval "(<)")))
  (check-equal? (eval "(< 1)") #t)
  (check-equal? (eval "(< 1 0)") #f)
  (check-equal? (eval "(< 0 1)") #t)
  (check-equal? (eval "(< 0 1 2)") #t)
  (check-equal? (eval "(< 0 1 2.0)") #t)
  (check-equal? (eval "(< (+ 1 0) 1 (- 2 1))") #f)

  (check-equal? (eval "(+ 7 (+ 8 1)) (+ 7 (- 8 1)) (< 1 1 1) \"end\"") "end")

  (check-equal? (eval "let (x (+ 1 2)) (+ x 3)") 6)
  ;; these are allowed to be implementation defined, so I just return a
  ;; procedure; there are other ways to proceed
  #;(check-equal? (eval "lambda (x) (* x x)")
                (list 'x
                      '(expr
                         (invocation
                           (OPAREN #f)
                           (exprList
                             (expr (atom (NAME *)))
                             (optExprList
                               (exprList
                                 (expr (atom (NAME x)))
                                 (optExprList (exprList (expr (atom (NAME x))) (optExprList))))))
                           (CPAREN #f)))
                      (new-environment)))
  #;(check-equal? (eval "let (y 1) lambda (x) (* y x)")
                (list 'x
                      '(expr
                         (invocation
                           (OPAREN #f)
                           (exprList
                             (expr (atom (NAME *)))
                             (optExprList
                               (exprList
                                 (expr (atom (NAME y)))
                                 (optExprList (exprList (expr (atom (NAME x))) (optExprList))))))
                           (CPAREN #f)))
                      #hash((y . 1))))
  (check-equal? (eval "(lambda (x) (* x x) 7)") 49)
  (check-equal? (eval "let (square lambda (x) (* x x)) (square 7)") 49)
  (check-equal? (eval "define foo 3") 3)
  (check-equal? (eval "define foo 3 foo") 3)
  (check-equal? (eval "define foo 3 4") 4)
  (check-equal? (eval "define foo 3 (+ 1 foo)") 4)
  (check-equal? (eval "define foo (/ 8 2) let (x (+ 1 2)) (+ x foo)") 7)
  (check-equal? (eval "define one lambda () 1 (one)") 1)
  (check-equal?
    (eval "define my-product lambda (x y) (* (- x y) (+ x y)) (my-product 5 3)")
    16)
  (check-equal?
    (eval "define ignore23 lambda (x y z) x (ignore23 7 8 9)")
    7)
)

(module+ test ;; massive integration test: recursive factorial via Church encodings
  (let ([program #<<EOF

define Z
  lambda (f)
    let (A lambda (x) (f lambda (v) ((x x) v)))
      (A A)

define czero lambda (f) lambda (x) x
define cone lambda (f) lambda (x) (f x)

define csucc lambda (n) lambda (f) lambda (x) (f ((n f) x))
define cplus lambda (m) lambda (n) lambda (f) lambda (x) ((m f) ((n f) x))
define cpred lambda (n) lambda (f) lambda (x) (((n lambda (g) lambda (h) (h (g f))) lambda (u) x) lambda (u) u)
define cmult lambda (m) lambda (n) lambda (f) (m (n f))

define c-to-nat
  lambda (n)
    ((n lambda (n) (+ n 1)) 0)

define ctrue lambda (a) lambda (b) a
define cfalse lambda (a) lambda (b) b

define c-to-bool
  lambda (b)
    ((b (= 1 1)) (= 0 1))

define czero? lambda (n) ((n lambda (x) cfalse) ctrue)

define cif lambda (p) lambda (a) lambda (b) ((p a) b)

define !-prime
  lambda (f)
    lambda (n)
      ((((cif (czero? n))
         lambda (x) cone)
        lambda (x) ((cmult n) (f (cpred n))))
       ;; this last just forces the thunk returned by cif
       ;; eta-expansion required because otherwise all arguments are fully
       ;; evaluated
       czero)

define ! (Z !-prime)
define c7 (csucc (csucc (csucc (csucc (csucc (csucc cone))))))

(c-to-nat (! c7))

EOF
])
    (check-equal? (eval program)
                  ;; 7!
                  5040)))
