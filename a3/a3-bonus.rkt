#lang racket

;; Modified lex stuff is below.
;; This is the same as lex.rkt, but with a DEFINE special token, and comments removed
(define (token type [data #f])
  (list type data))

  (define (skip-match str) #f)

  (define (punctuation-token str)
    (token
      (case str
        [("(") 'OPAREN]
        [(")") 'CPAREN])))

(define (number-token type)
  (λ (str) (token type (string->number str))))

(define (string-token str)
  (let* ([len (string-length str)]
         [inner-string (substring str 1 (sub1 len))] ; strip first & last quotes
         [unescaped-char (λ (_ char) (if (equal? "n" char) "\n" char))]
         [unescaped-str (regexp-replace #rx"\\\\(.)"
                                        inner-string unescaped-char)])
    (token 'STRING unescaped-str)))

(define (name-token str)
  (if (equal? str "define")
      (token 'DEFINE)
      (token 'NAME (string->symbol str))))

(define re-table
  (list
    (list #rx"^[ \r\n\t]+" skip-match) ; whitespace
    (list #rx"^;\\*.*?\\*;" skip-match) ; /* */ comments
    (list #rx"^;;[^\n]+(\n|$)" skip-match) ; // comments
    (list #rx"^[()]" punctuation-token)
    (list #rx"^-?[0-9]+\\.[0-9]+(?=[\r\n\t (){},;.]|$)" (number-token 'FLOAT))
    (list #rx"^-?[0-9]+(?=[\r\n\t (){},;.]|$)" (number-token 'INT))
    (list #rx"^\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"(?=[\r\n\t (){},;.]|$)"
          string-token)
    (list #rx"^[^(){},;.\" \r\n\t0-9][^(){},;.\" \r\n\t]*(?=[\r\n\t (){},;.]|$)"
          name-token)))

(define (table-entry->result input entry)
  (let* ([regexp (first entry)]
         [process-match (second entry)]
         [matches (regexp-match regexp input)])
    (if (not matches)
      #f
      (let* ([match (first matches)]
             [token (process-match match)])
        (list (string-length match) match token)))))

(define (lex input)
  (if (zero? (string-length input))
    null
    (let ([match-results (filter-map (λ (entry) (table-entry->result input entry))
                                     re-table)])
      (if (empty? match-results)
        (list (token 'INVALID input))
        (let* ([longest-match-result (first (sort match-results > #:key first))]
               [longest-match-length (first longest-match-result)]
               [longest-match (second longest-match-result)]
               [token (third longest-match-result)]
               [remaining-input (substring input longest-match-length)])
          (if token
            (cons token (lex remaining-input))
            (lex remaining-input)))))))

(define tokens (make-parameter null))

(define (parse-program)
  (list 'program
        (parse-expr-list)))

(define (parse-expr-list)
  (list 'exprList
        (parse-expr)
        (parse-opt-expr-list)))

(define (parse-opt-expr-list)
  (if (or (check 'CPAREN) (empty? (tokens)))
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
        (parse-invocation-tail)))

(define (parse-invocation-tail)
  (if (check 'DEFINE)
      (list 'invocationTail
            (consume 'DEFINE)
            (consume 'NAME)
            (parse-expr)
            (consume 'CPAREN))
      (list 'invocationTail
            (parse-expr-list)
            (consume 'CPAREN))))

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

(define (parse code)
  (parameterize ([tokens (lex code)])
    (parse-program)))
