#lang racket

(define (token type [data #f])
  (list type data))

; Token types
(define (skip-match str) #f)

(define (punctuation-token str)
  (token
    (case str
      [("(") 'OPAREN]
      [(")") 'CPAREN]
      [("{") 'OBRACE]
      [("}") 'CBRACE]
      [(",") 'COMMA]
      [(";") 'SEMICOLON]
      [(".") 'PERIOD])))

(define (number-token str)
  (if (string-contains? str ".")
      (token 'FLOAT (string->number str))
      (token 'INT (string->number str))))

(define (string-token str)
  (token 'STRING (substring str 1 (- (string-length str) 1))))

(define (name-or-keyword-token str)
  (case str
    [("def" "fun" "if" "not" "and" "or")
     (token (string->symbol (string-upcase (string-trim str))))]
    [else (token 'NAME (string->symbol str))]))

(define (invalid-token str)
  (token 'INVALID str))

; Matching table
(define re-table
  (list
    (list #px"^[ \r\n\t]+" skip-match) ; whitespace
    (list #px"^//[^\n]+(\n|$)" skip-match) ; // comments
    (list #px"^/\\*(?:.|\n)*\\*/" skip-match) ; /* comments */
    (list #px"^[(){},;.]" punctuation-token)
    (list #px"^-?\\d+(?:\\.\\d+)?(?=[\r\n\t (){},;.]|$)" number-token)
    (list #px"^\"[^\"]*\"(?=[\r\n\t (){},;.]|$)" string-token)
    (list #px"^[^(){},;.\" \r\n\t\\d][^(){},;.\" \r\n\t]*(?=[\r\n\t (){},;.]|$)" name-or-keyword-token)
    (list #px"^.+" invalid-token))) ; anything else basically

; Lex function
(define (f-if-empty n) (if (empty? n) #f n))

(define (lexer-inner str)
  (f-if-empty (car (filter-map (lambda (re)
         (if (regexp-match? (car re) str)
             (cons
              ((second re) (car (regexp-match (car re) str)))
              (substring str
                         (string-length (car (regexp-match (car re) str)))
                         (string-length str)))
             #f)) re-table))))

(define (lex str)
  (letrec ([n-if-empty (lambda (lst)
                         (if (empty? lst) null lst))]
           
           [lex-inner (lambda (str)
                          (n-if-empty (car (filter-map (lambda (re)
         (if (regexp-match? (car re) str)
             (cons
              ((second re) (car (regexp-match (car re) str)))
              (substring str
                         (string-length (car (regexp-match (car re) str)))
                         (string-length str)))
             #f)) re-table))))]
           [lex-inner2 (lambda (str)
                         (if (car (lex-inner str))
                             (cons
                              (car (lex-inner str))
                              (if (equal? (cdr (lex-inner str)) "") null (lex-inner2 (cdr (lex-inner str)))))
                             (if (equal? (cdr (lex-inner str)) "") ; if space
                              null
                              (lex-inner2 (cdr (lex-inner str))))))])
    (if (equal? str "") null (lex-inner2 str))))

(module+ test
  (require (only-in rackunit
                    check-equal?))
  (check-equal? (lex "") null)
  )

