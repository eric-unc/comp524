#lang racket

(require (only-in (file "lex.rkt") lex))

(define tokens (make-parameter null))

(define (parse-program)
  (list 'program
        (parse-expr-list)))

(define (parse-expr-list)
  (list 'exprList
        (parse-expr)
        (parse-opt-expr-list)))

(define (parse-opt-expr-list)
  (if (empty? (tokens))
      (list 'optExprList)
      (list 'optExprList (parse-expr-list))))

(define (parse-expr)
  (list
   'expr
  (if (check 'OPAREN)
      (parse-invocation)
      (parse-atom))))

(define (parse-atom)
  (list 'atom
        (if (check 'NAME)
            (consume 'NAME)
            (if (check 'STRING)
                (consume 'STRING)
                (parse-number)))))

(define (parse-number)
  (list 'number
        (if (check 'INT)
            (consume 'INT)
            (consume 'FLOAT))))

(define (parse-invocation)
  (list 'invocation
        (consume 'OPAREN)
        (parse-expr-list)
        (consume 'CPAREN)))

(define (check type)
  (if (empty? (tokens))
      #f
      (equal? type (first (first (tokens))))))

(define (consume type)
  (when (empty? (tokens))
    (error (~a "expected token of type " type " but no remaining tokens")))
  (let ([token (first (tokens))])
    (when (not (equal? type (first token)))
      (error (~a "expected token of type " type " but actual token was " token)))
    (tokens (rest (tokens)))  ; update tokens: remove first token
    token))

; TODO https://piazza.com/class/kjvqyzyra2out?cid=69
(define (parse code)
  (parameterize ([tokens (lex code)])
    (parse-program)))
