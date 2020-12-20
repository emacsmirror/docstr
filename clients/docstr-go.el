;;; docstr-go.el --- Document string for Golang  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Shen, Jen-Chieh <jcs090218@gmail.com>

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Document string for Golang.
;;

;;; Code:

(require 'docstr)

(declare-function docstr-writers-c++ "ext:docstr-c++.el")

(defcustom docstr-go-style 'godoc
  "Style specification for document string in Golang."
  :type '(choice (const :tag "No specify" nil)
                 (const :tag "Document String in Golang" godoc))
  :group 'docstr)

(defcustom docstr-go-prefix "// "
  "Prefix you use on each newline."
  :type 'string
  :group 'docstr)

(defun docstr-go-config-godoc ()
  "Configre for convention, GoDoc."
  (docstr-util-default-format)
  (setq-local docstr-go-prefix "// "
              docstr-format-type "{%s}"
              docstr-format-var "%s -"
              docstr-show-type-name nil))

(defun docstr-go-config ()
  "Automatically configure style according to variable `docstr-go-style'."
  (cl-case docstr-go-style
    (godoc (docstr-go-config-godoc))
    (t (docstr-util-default-format))))

;;;###autoload
(defun docstr-writers-golang (search-string)
  "Insert document string for Golang using SEARCH-STRING."
  (docstr-go-config)
  (let* ((start (point)) (prefix docstr-go-prefix)
         (paren-param-list (docstr-writers--paren-param-list-behind search-string))
         (param-types (nth 0 paren-param-list))
         (param-vars (nth 1 paren-param-list))
         ;; Get the return data type.
         (return-type-str (docstr-writers--return-type-behind search-string))
         docstring-type)

    ;; Determine the docstring type.
    (save-excursion
      (backward-char 1)
      (if (docstr-util-current-char-equal-p "*")
          (setq docstring-type 'javadoc) (setq docstring-type 'godoc)))

    (cl-case docstring-type
      (javadoc (docstr-writers-c++ search-string))
      (godoc
       (end-of-line) (insert " ")
       (docstr-writers--insert-param param-types param-vars prefix)
       (docstr-writers--insert-return return-type-str nil prefix)
       (docstr-writers-after start t t t)))))

;;;###autoload
(defun docstr-trigger-golang (&rest _)
  "Trigger document string inside Golang."
  (when (and (docstr--doc-valid-p) (docstr-util-looking-back "//" 2))
    (docstr--insert-doc-string (docstr--c-style-search-string 1))))

(provide 'docstr-go)
;;; docstr-go.el ends here
