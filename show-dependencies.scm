#!/usr/bin/env -S guile -s
!#

(use-modules (guix packages)
             ((gnu packages)  #:select (specification->package
                                        specification->package+output))
             ((srfi srfi-1)   #:select (delete-duplicates))
             ((srfi srfi-11)  #:select (let-values))
             ((ice-9 match)   #:select (match))
             ((ice-9 format)  #:select (format)))

(define (package->specification package)
  (format #f "~a@~a"
          (package-name package)
          (package-version package)))

(define (input->specification input)
  (match input
    ((label (? package? package) . _)
     (package->specification package))
    ((label (? origin? origin))
     (format #f "[source code from ~a]"
             (origin-uri origin)))
    (other-input
     (format #f "~a" other-input))))

(define (unique-inputs inputs)
  (delete-duplicates
   (map input->specification inputs)))

(define (main args)

  (define packages
    (map specification->package args))
  (define inputs
    (sort
     (delete-duplicates
      (apply append
             (map (lambda (package)
                    (unique-inputs
                     (package-direct-inputs package)))
                  packages)))
     string<))
  (define build-inputs
    (sort
     (delete-duplicates
      (apply append
             (map (lambda (package)
                    (unique-inputs
                     (bag-direct-inputs
                      (package->bag package))))
                  packages)))
     string<))
  (define closure
    (sort
     (delete-duplicates
      (map package->specification
           (package-closure packages)))
     string<))

  (format #t "Packages: ~d\n ~{ ~a~}\n"
          (length packages)
          (sort
           (map package->specification packages)
           string<))
  (format #t "Package inputs: ~d packages\n ~{ ~a~}\n"
          (length inputs)
          inputs)
  (format #t "Build inputs: ~d packages\n ~{ ~a~}\n"
          (length build-inputs)
          build-inputs)
  (format #t "Package closure: ~d packages\n ~{ ~a~}\n"
          (length closure)
          closure))

(main (cdr (command-line)))
