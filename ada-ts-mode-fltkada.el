;;; ada-ts-mode-fltkada.el --- ada-ts-mode indentation for the FLTKAda style -*- lexical-binding: t; -*-

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Configures `ada-ts-mode' (the tree-sitter Ada major mode) so that
;; `indent-region'/`indent-according-to-mode' reproduce the house style
;; documented in doc/ada_formatting_standard.md:
;;
;;   - 4-space indentation, no tabs.
;;   - `when' aligned with `case' (no extra indent level).
;;   - A wrapped subprogram parameter profile gets a wider hanging
;;     indent (indent-offset + broken-offset) than a wrapped `return'
;;     (indent-offset alone) -- ada-ts-mode's built-in rules use the
;;     same value for both, so both are overridden here.
;;   - The first identifier/selected_component of a `with'/`use'
;;     clause (and, by the built-in rules, everything after it) lines
;;     up one full indent level in, not the shallower "continuation"
;;     indent ada-ts-mode uses by default.
;;   - `with Implicit_Dereference => ...' etc. on a record type
;;     definition indents one level in; other aspect specifications
;;     (e.g. a `with Pre => ...' on a subprogram, or `with
;;     Default_Value => ...' on an already-wrapped enumeration) line
;;     up flush with the declaration.
;;   - The first exception handler after `exception' lines up with
;;     `exception' itself, and a `raise ... with' message that wraps
;;     indents one level in from the `when' line -- both fall through
;;     to a "best effort" heuristic in ada-ts-mode that does not
;;     produce this, so they're handled with dedicated rules here.
;;
;; This does not attempt to be a complete formatter -- it only teaches
;; ada-ts-mode's *indentation* engine the house style; it doesn't
;; touch blank lines, doesn't reflow `with' clauses onto one line per
;; item, and doesn't force a subprogram spec that already fits on one
;; line to split.  See doc/gnatpp_configuration.md for the equivalent
;; (and similarly partial) gnatpp configuration and for the small set
;; of remaining constructs neither tool reproduces exactly (a rare
;; hand-written inconsistency in the source itself, not a rule).
;;
;; Usage: arrange for this file to be loaded wherever `ada-ts-mode' is
;; used on FLTKAda sources, e.g. from `.dir-locals.el':
;;
;;   ((ada-ts-mode
;;     . ((eval . (load (expand-file-name "ada-ts-mode-fltkada.el"
;;                         (locate-dominating-file default-directory
;;                                                  ".dir-locals.el")))))))
;;
;; or from init.el:
;;
;;   (load "/path/to/fltkada/ada-ts-mode-fltkada.el")

;;; Code:

(require 'treesit)
(require 'cl-lib)

(with-eval-after-load 'ada-ts-mode

  ;; Base indentation.  Setting `ada-ts-mode-indent-offset' first lets
  ;; ada-ts-mode's own `add-variable-watcher'-based recompute update
  ;; the derived offsets (broken-offset, subprogram-is-offset, record-
  ;; offset, label-offset) to match; `ada-ts-mode-indent-when-offset'
  ;; is then overridden explicitly since the house style differs from
  ;; ada-ts-mode's default for it (see below).
  (setq ada-ts-mode-indent-offset 4)

  ;; `when' aligns with `case'/`case ... is', not indented under it:
  ;;
  ;;     case Value is
  ;;     when A0 .. Envelope => return Page_Format'Pos (Value);
  ;;     when Media           => return fl_page_format_media;
  ;;     end case;
  (setq ada-ts-mode-indent-when-offset 0)

  ;;; -- Matcher/anchor helpers ------------------------------------

  (defun ada-ts-mode-fltkada--with-clause-first-item-p (node parent _bol)
    "Non-nil if NODE is the first context item of a with/use clause.
Subsequent items already align to this one via ada-ts-mode's own
rules; only the first item's own indentation needs overriding."
    (and node parent
         (member (treesit-node-type node) '("identifier" "selected_component"))
         (member (treesit-node-type parent) '("with_clause" "use_clause"))
         (not (equal (treesit-node-type (treesit-node-prev-sibling node)) ","))))

  (defun ada-ts-mode-fltkada--object-decl-init-expr-p (node parent _bol)
    "Non-nil if NODE is a wrapped `:=' initial value.
Covers both an object declaration's initial value and a parameter
specification's default expression -- except when the declared object
has its own inline anonymous array type (e.g. `X : array (...) of T
:= (...)'), which keeps ada-ts-mode's ordinary continuation indent."
    (and node parent
         (member (treesit-node-type parent) '("object_declaration" "parameter_specification"))
         (equal (treesit-node-type node) "expression")
         (equal (treesit-node-type (treesit-node-prev-sibling node)) ":=")
         (not (cl-some (lambda (c) (equal (treesit-node-type c) "array_type_definition"))
                       (treesit-node-children parent)))))

  (defun ada-ts-mode-fltkada--generic-name-p (node parent _bol)
    "Non-nil if NODE is the instantiated name of a generic instantiation.
E.g. the `Ada.Unchecked_Conversion (...)' part of
\"function Flag_To_UChar is new\\n    Ada.Unchecked_Conversion (...);\"."
    (and parent
         (equal (treesit-node-type parent) "generic_instantiation")
         (equal (treesit-node-field-name node) "generic_name")))

  (defun ada-ts-mode-fltkada--record-aspect-p (node parent _bol)
    "Non-nil if NODE is an aspect_specification on a record type.
E.g. `with Implicit_Dereference => Data;' after `... is limited null
record'.  Other aspect specifications (subprogram Pre/Post, an
already-wrapped enumeration's Default_Value, ...) instead align flush
with the declaration -- see the plain \"aspect_specification\" rule
below."
    (and node parent
         (equal (treesit-node-type node) "aspect_specification")
         (member (treesit-node-type (treesit-node-prev-sibling node))
                 '("record_type_definition" "record_definition"))))

  (defun ada-ts-mode-fltkada--first-exception-handler-p (node _parent _bol)
    "Non-nil if NODE is the exception handler right after `exception'.
ada-ts-mode's own rules correctly align every *subsequent* handler to
this one; it's only the first one, immediately following `exception',
that falls through to a \"best effort\" heuristic which does not
align it with `exception' the way this style expects."
    (and node
         (equal (treesit-node-type node) "exception_handler")
         (equal (treesit-node-type (treesit-node-prev-sibling node)) "exception")))

  (defun ada-ts-mode-fltkada--first-exception-handler-anchor (node _parent _bol)
    "Anchor position for `ada-ts-mode-fltkada--first-exception-handler-p'.
Anchors to the start of the preceding `exception' keyword's line."
    (save-excursion
      (goto-char (treesit-node-start (treesit-node-prev-sibling node)))
      (back-to-indentation)
      (point)))

  (defun ada-ts-mode-fltkada--raise-with-message-p (node parent _bol)
    "Non-nil if NODE is a wrapped `raise ... with MESSAGE;' message.
E.g. the `\"...\" & Interfaces.C.int'Image (Result);' part of
\"raise Internal_FLTK_Error with\\n    \\\"...\\\" & ...;\"."
    (and node parent
         (equal (treesit-node-type node) "expression")
         (equal (treesit-node-type parent) "raise_statement")
         (equal (treesit-node-type (treesit-node-prev-sibling node)) "with")))

  (defun ada-ts-mode-fltkada--exception-handler-bol-anchor (_node parent _bol)
    "Anchor position for `ada-ts-mode-fltkada--raise-with-message-p'.
Anchors to the start of the enclosing exception handler's `when' line
\(PARENT is the raise_statement; its parent is the exception_handler)."
    (save-excursion
      (goto-char (treesit-node-start (treesit-node-parent parent)))
      (back-to-indentation)
      (point)))

  ;;; -- Wiring the rules in ----------------------------------------

  (defun ada-ts-mode-fltkada--indent-setup ()
    "Prepend the FLTKAda style's indent rules for the `ada' language.
Rebuilds the buffer-local `treesit-simple-indent-rules' rather than
mutating the shared default value, and places these rules before
ada-ts-mode's own so they take precedence for the constructs they
match; every other construct still falls through to ada-ts-mode's
built-in rules unchanged."
    (setq-local indent-tabs-mode nil)
    (let* ((rules (cdr (assq 'ada treesit-simple-indent-rules)))
           (new-rules
            (append
             `((ada-ts-mode-fltkada--raise-with-message-p
                ada-ts-mode-fltkada--exception-handler-bol-anchor
                ,ada-ts-mode-indent-offset)
               (ada-ts-mode-fltkada--first-exception-handler-p
                ada-ts-mode-fltkada--first-exception-handler-anchor
                0)
               (ada-ts-mode-fltkada--with-clause-first-item-p
                parent-bol
                ,ada-ts-mode-indent-offset)
               ((node-is "formal_part")
                parent-bol
                ,(+ ada-ts-mode-indent-offset ada-ts-mode-indent-broken-offset))
               ((node-is "result_profile")
                parent-bol
                ,ada-ts-mode-indent-offset)
               (ada-ts-mode-fltkada--record-aspect-p
                parent-bol
                ,ada-ts-mode-indent-offset)
               ((node-is "aspect_specification")
                parent-bol
                0)
               (ada-ts-mode-fltkada--object-decl-init-expr-p
                parent
                ,ada-ts-mode-indent-offset)
               (ada-ts-mode-fltkada--generic-name-p
                parent
                ,ada-ts-mode-indent-offset))
             rules)))
      (setq-local treesit-simple-indent-rules
                  (cons (cons 'ada new-rules)
                        (assq-delete-all 'ada (copy-alist treesit-simple-indent-rules))))))

  (add-hook 'ada-ts-mode-hook #'ada-ts-mode-fltkada--indent-setup))

(provide 'ada-ts-mode-fltkada)

;;; ada-ts-mode-fltkada.el ends here
