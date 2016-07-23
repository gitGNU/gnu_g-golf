;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016
;;;; Free Software Foundation, Inc.

;;;; This file is part of GNU G-Golf

;;;; GNU G-Golf is free software; you can redistribute it and/or modify
;;;; it under the terms of the GNU Lesser General Public License as
;;;; published by the Free Software Foundation; either version 3 of the
;;;; License, or (at your option) any later version.

;;;; GNU G-Golf is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; Lesser General Public License for more details.

;;;; You should have received a copy of the GNU Lesser General Public
;;;; License along with GNU G-Golf.  If not, see
;;;; <https://www.gnu.org/licenses/lgpl.html>.
;;;;

;;; Commentary:

;;; Code:


(define-module (golf gi utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign)
  #:use-module (golf gi glib)

  #:export (%gpointer-size
	    golf-pointer-new
	    golf-pointer-inc
	    with-gerror
	    golf-gtype->scm
	    golf-attribute-iter-new
	    golf-gstudly-caps-exand
	    %golf-gtype-name->scm-name-exceptions
	    golf-gtype-name->scm-name
	    golf-gtype-name->class-name
	    gtype-class-name->method-name))


(define %gpointer-size 8)
  
(define (golf-pointer-new)
  ;; (bytevector->pointer (make-bytevector %gpointer-size 0))
  ;; The above would work iif none of Glib, Gobject and GI would ever call
  ;; any of there respective *_free functions upon pointers returned by
  ;; this procedure [it segfaults - C can't free Guile's mem]. This
  ;; statement is _not_ guaranteed, hence we have to allocate using the
  ;; glib API.
  (golf-gl-malloc0 %gpointer-size))

(define* (golf-pointer-inc pointer
			    #:optional
			    (offset %gpointer-size))
  (make-pointer (+ (pointer-address pointer)
		   offset)))

(define-syntax with-gerror
  (syntax-rules ()
    ((with-gerror ?var ?body)
     (let* ((?var (golf-pointer-new))
	    (result ?body)
	    (d-pointer (dereference-pointer ?var)))
       (if (null-pointer? d-pointer)
	   (begin
	     (golf-gl-free ?var)
	     result)
	   (match (parse-c-struct d-pointer
				  (list uint32 int8 '*))
	     ((domain code message)
	      (golf-gl-free ?var)
	      (error (pointer->string message)))))))))

(define (golf-gtype->scm gvalue gtype)
  (case gtype
    ((gchar**) (gchar**->scm gvalue))
    ((gchar*,) (gchar*,->scm gvalue))
    ((gchar*) (pointer->string gvalue))
    ((gboolean) (gboolean->scm gvalue))
    (else
     (error "no such gtype: " gtype))))

(define (golf-attribute-iter-new)
  (make-c-struct (list '* '* '* '*)
		 (list %null-pointer
		       %null-pointer
		       %null-pointer
		       %null-pointer)))


;;;
;;; golf-gtype->scm procedures
;;;

(define (gchar**->scm pointer)
  (define (gchar**->scm-1 pointer result)
    (receive (d-pointer)
	(dereference-pointer pointer)
    (if (null-pointer? d-pointer)
	(reverse! result)
	(gchar**->scm-1 (golf-pointer-inc pointer)
			(cons (pointer->string d-pointer)
			      result)))))
  (gchar**->scm-1 pointer '()))

(define (gchar*,->scm pointer)
  (string-split (pointer->string pointer)
		#\,))

(define (gboolean->scm value)
  (if (= value 0) #f #t))


;;;
;;; Name Transformatin
;;;

;; Based on Guile-Gnome (gobject gw utils)

(define (golf-gstudly-caps-exand nstr)
  ;; GStudlyCapsExpand
  (do ((idx (- (string-length nstr) 1)
	    (- idx 1)))
      ((> 1 idx)
       (string-downcase nstr))
    (cond ((and (> idx 2)
                (char-lower-case? (string-ref nstr (- idx 3)))
                (char-upper-case? (string-ref nstr (- idx 2)))
                (char-upper-case? (string-ref nstr (- idx 1)))
                (char-lower-case? (string-ref nstr idx)))
           (set! idx (- idx 1))
           (set! nstr
                 (string-append (substring nstr 0 (- idx 1))
                                "-"
                                (substring nstr (- idx 1)
                                           (string-length nstr)))))
          ((and (> idx 1)
                (char-upper-case? (string-ref nstr (- idx 1)))
                (char-lower-case? (string-ref nstr idx)))
           (set! nstr
                 (string-append (substring nstr 0 (- idx 1))
                                "-"
                                (substring nstr (- idx 1)
                                           (string-length nstr)))))
          ((and (char-lower-case? (string-ref nstr (- idx 1)))
                (char-upper-case? (string-ref nstr idx)))
           (set! nstr
                 (string-append (substring nstr 0 idx)
                                "-"
                                (substring nstr idx
                                           (string-length nstr))))))))

;; Default name transformations can be overridden, but golf won't define
;; exceptions for now, let's see.
(define %golf-gtype-name->scm-name-exceptions
  '(;; (GEnum . genum)
    ))

(define (golf-gtype-name->scm-name type-name)
  (or (assoc-ref %golf-gtype-name->scm-name-exceptions type-name)
      (string-trim-right (golf-gstudly-caps-exand
			  ;; only change _ to -
			  ;; other chars are not valid in a type name
			  (string-map (lambda (c) (if (eq? c #\_) #\- c))
				      type-name))
			 #\-)))

;; "GtkAccelGroup" => <gtk-accel-group>
;; "GSource*" => <g-source*>
(define (golf-gtype-name->class-name type-name)
  (string->symbol (string-append "<"
				 (golf-gstudly-caps-exand type-name)
				 ">")))

;; Not sure this is used but let's keep it as well
(define (gtype-class-name->method-name class-name name)
  (let ((class-string (symbol->string class-name)))
    (string->symbol
     (string-append (substring class-string 1 (1- (string-length class-string)))
                    ":" (symbol->string name)))))