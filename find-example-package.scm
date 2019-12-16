(use-modules (guix packages)
             (guix build-system)
             (guix sets)
             (gnu packages)
             (srfi srfi-1)
             (ice-9 match))

(define (interesting? package)
  (and (not (null? (package-inputs package)))
       (< (length (package-inputs package))
          5)
       (< (length (package-native-inputs package))
          3)
       (< (length (package-propagated-inputs package))
          3)
       (not (null? (package-arguments package)))))

(define interesting-packages
  (fold-packages (lambda (package result)
                   (if (interesting? package)
                       (cons package result)
                       result))
                 '()))

(sort interesting-packages
      (lambda (a b)
        (< (length (package-inputs a))
           (length (package-inputs b)))))

(map package-name (take interesting-packages 20))
