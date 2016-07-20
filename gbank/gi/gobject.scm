;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016
;;;; Free Software Foundation, Inc.

;;;; This file is part of GNU Gbank

;;;; GNU Gbank is free software: you can redistribute it and/or modify
;;;; it under the terms of the GNU General Public License as published
;;;; by the Free Software Foundation, either version 3 of the License,
;;;; or (at your option) any later version.

;;;; GNU Gbank is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; General Public License for more details.

;;;; You should have received a copy of the GNU General Public License
;;;; along with GNU Gbank.  If not, see <http://www.gnu.org/licenses/>.
;;;;

;;; Commentary:

;;; Code:

(eval-when (expand load eval)
  (use-modules (oop goops))
  (default-duplicate-binding-handler
    '(merge-generics replace warn-override-core warn last)))

(define-module (gbank gi gobject)
  #:use-module (system foreign)
  #:use-module (gbank support modules)
  #:use-module (gbank support goops)
  #:use-module (gbank support g-export)
  #:use-module (gbank support utils)
  #:use-module (gbank support enum)
  #:use-module (gbank gi init)
  #:use-module (gbank gi gobject type-info)
  #:use-module (gbank gi gobject enum-flags))

(eval-when (expand load eval)
  (re-export-public-interface (oop goops)
			      (system foreign)
			      (gbank support goops)
			      (gbank support g-export)
			      (gbank support utils)
			      (gbank support enum)
			      (gbank gi init)
			      (gbank gi gobject type-info)
			      (gbank gi gobject enum-flags)))