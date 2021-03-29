#lang racket

;; To use this module, save this code as lex.rkt in the same directory as your
;; code and add the following line to your file:
;;
;; (require (only-in (file "lex.rkt") lex))

(provide lex)

;; The `[data #f]` is a default value for the 2nd positional argument.
;; That way, this function can take 1 arg or 2 args.
(define (token type [data #f])
  (list type data))

;;;; Token creator functions
;;;;
;;;; Given a string matching a regexp, return a token for that input or #f for
;;;; no token.

(define (skip-match str) #f)

(define (punctuation-token str)
  (token
    (case str
      [("(") 'OPAREN]
      [(")") 'CPAREN]
      [("{") 'OBRACE]
      [("}") 'CBRACE])))

(define (number-token type)
  ;; Note the indirection here: the first call returns a function of 1 argument.
  (λ (str) (token type (string->number str))))

(define (string-token str)
  (let* ([len (string-length str)]
         [inner-string (substring str 1 (sub1 len))] ; strip first & last quotes
         [unescaped-char (λ (_ char) (if (equal? "n" char) "\n" char))]
         [unescaped-str (regexp-replace #rx"\\\\(.)"
                                        inner-string unescaped-char)])
    (token 'STRING unescaped-str)))

(define (name-token str)
  (token 'NAME (string->symbol str)))

(define (name-or-keyword-token str)
  (case str
    [("let") (token 'LET)]
    [("define") (token 'DEFINE)]
    [("lambda") (token 'LAMBDA)]
    [("class") (token 'CLASS)]
    [("new") (token 'NEW)]
    [("send") (token 'SEND)]
    [("super") (token 'SUPER)]
    [("set") (token 'SET)]
    [else (name-token str)]))

;;;; Lexing rules table
;;;;
;;;; Each item in the table is a 2-tuple (i.e. list of 2 elements):
;;;; 1. a regexp to detect a token at the beginning of a string
;;;; 2. a function (from above) to take the matched string and create a token

(define re-table
  (list
    (list #rx"^[ \r\n\t]+" skip-match) ; whitespace
    (list #rx"^;\\*.*?\\*;" skip-match) ; /* */ comments
    (list #rx"^;;[^\n]+(\n|$)" skip-match) ; // comments
    (list #rx"^[(){}]" punctuation-token)
    (list #rx"^-?[0-9]+\\.[0-9]+(?=[\r\n\t (){},;.]|$)" (number-token 'FLOAT))
    (list #rx"^-?[0-9]+(?=[\r\n\t (){},;.]|$)" (number-token 'INT))
    (list #rx"^\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"(?=[\r\n\t (){},;.]|$)"
          string-token)
    (list #rx"^[^(){},;.\" \r\n\t0-9][^(){},;.\" \r\n\t]*(?=[\r\n\t (){},;.]|$)"
          name-or-keyword-token)))

;;;; Lexing engine

;; Given the current input string and a lexing rule tuple, try to match. If no
;; match, return #f. If match, return the match and the corresponding token.
(define (table-entry->result input entry)
  (let* ([regexp (first entry)]
         [process-match (second entry)]
         [matches (regexp-match regexp input)])
    (if (not matches)
      #f
      (let* ([match (first matches)]
             [token (process-match match)])
        (list (string-length match) match token)))))

;; Break the input string up into a list of tokens.
;; This function is recursive, returning a pair of the front token and the
;; result of a recursive call on the remaining input.
(define (lex input)
  (if (zero? (string-length input))
    null
    ;; filter-map calls map (which calls the function once per item) and
    ;; removes #f results.
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

(module+ test
  (require (only-in rackunit
                    check-equal?))

  (check-equal? (lex "") null)
  (check-equal? (lex " \n\t\r ") null)
  (check-equal? (lex ";; comment1") null)
  (check-equal? (lex ";; comment1\n7") (list (token 'INT 7)))
  (check-equal? (lex ";* comment2 \n *;\n8") (list (token 'INT 8)))
  (check-equal? (lex "\"\"") (list (token 'STRING "")))
  (check-equal? (lex "\"abc\"") (list (token 'STRING "abc")))
  (check-equal? (lex "if1") (list (token 'NAME 'if1)))
  (check-equal? (lex "1if") (list (token 'INVALID "1if")))
  (check-equal? (lex "9.8") (list (token 'FLOAT 9.8)))
  (check-equal? (lex "9") (list (token 'INT 9)))
  (check-equal? (lex "1a") (list (token 'INVALID "1a")))
  (check-equal? (lex "123\"456\"") (list (token 'INVALID "123\"456\"")))
  (check-equal? (lex "\"123\"456") (list (token 'INVALID "\"123\"456")))
  (check-equal? (lex "abc\"def\"") (list (token 'INVALID "abc\"def\"")))
  (check-equal? (lex "\"abc\"def") (list (token 'INVALID "\"abc\"def")))
  (check-equal? (lex "\"\\\\\"\"") (list (token 'INVALID "\"\\\\\"\"")))
  (check-equal? (lex "\"a\\\\nbc\"") (list (token 'STRING "a\\nbc")))
  (check-equal? (lex "\"\\\"\"") (list (token 'STRING "\"")))
  (check-equal? (lex "\"\\n\"") (list (token 'STRING "\n")))
  (check-equal? (lex "\"\\\\\"") (list (token 'STRING "\\")))
  (check-equal? (lex "let letter define defined lambda plambda")
                (list (token 'LET #f)
                      (token 'NAME 'letter)
                      (token 'DEFINE #f)
                      (token 'NAME 'defined)
                      (token 'LAMBDA #f)
                      (token 'NAME 'plambda)))

  (define example-program "
def factorial = fun (n)
  ;; first check base case
  if(<(n 0.9)
     1
     factorial(-(n 1)) ;* recursive case *; )

print(+(\"5! is \" factorial(5)))")

  (define example-program-tokens
    (list
      (list 'NAME      'def)
      (list 'NAME      'factorial)
      (list 'NAME      '=)
      (list 'NAME      'fun)
      (list 'OPAREN    #f)
      (list 'NAME      'n)
      (list 'CPAREN    #f)
      (list 'NAME      'if)
      (list 'OPAREN    #f)
      (list 'NAME      '<)
      (list 'OPAREN    #f)
      (list 'NAME      'n)
      (list 'FLOAT     0.9)
      (list 'CPAREN    #f)
      (list 'INT       1)
      (list 'NAME      'factorial)
      (list 'OPAREN    #f)
      (list 'NAME      '-)
      (list 'OPAREN    #f)
      (list 'NAME      'n)
      (list 'INT       1)
      (list 'CPAREN    #f)
      (list 'CPAREN    #f)
      (list 'CPAREN    #f)
      (list 'NAME      'print)
      (list 'OPAREN    #f)
      (list 'NAME      '+)
      (list 'OPAREN    #f)
      (list 'STRING    "5! is ")
      (list 'NAME      'factorial)
      (list 'OPAREN    #f)
      (list 'INT       5)
      (list 'CPAREN    #f)
      (list 'CPAREN    #f)
      (list 'CPAREN    #f)))

  (check-equal? (lex example-program) example-program-tokens))
