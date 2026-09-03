;;; cc-mode-fltkada.el --- CC Mode C++ indentation for the FLTKAda style -*- lexical-binding: t; -*-

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Defines a CC Mode style, "fltkada", that reproduces the house style
;; documented in doc/cpp_formatting_standard.md for `body/*.cpp' and
;; `body/*.h', and installs it on `c-mode-common-hook' (covering both
;; `c-mode' and `c++-mode', in case a `.h' file is ever visited in
;; `c-mode').
;;
;; It's built on CC Mode's built-in "stroustrup" style (4-space
;; offset, K&R-attached braces already) with the following added or
;; overridden, each verified by stripping the indentation from real
;; files under body/ and reindenting them with `indent-region':
;;
;;   - `access-label' at -c-basic-offset (i.e. flush with the class's
;;     own opening line) and `inclass' at +c-basic-offset, so
;;
;;         class My_Box : public Fl_Box {
;;         public:
;;             void draw();
;;         };
;;
;;   - `comment-intro' at 0.  CC Mode sums the offsets of every
;;     syntactic element on a line, and a comment that's the first
;;     line of a block gets both `defun-block-intro'/
;;     `statement-block-intro' *and* `comment-intro'; leaving the
;;     latter at its default double-indents such a comment relative to
;;     the code around it.
;;   - `inher-intro'/`inher-cont' at 0, so a base-class list broken
;;     across an `#ifdef' (as in c_fl_cairo_window.cpp) stays flush
;;     with the `class' line instead of indenting under it.
;;   - `topmost-intro-cont' at +c-basic-offset, for a top-level
;;     declaration whose parameter list starts on its own line, e.g.
;;
;;         extern "C" void check_button_extra_init_hook
;;             (void * aobj, int x, int y, int w, int h, const char * l);
;;
;;   - `arglist-intro'/`arglist-cont'/`arglist-cont-nonempty' at
;;     +c-basic-offset (flat, not aligned under the opening paren) and
;;     `arglist-close' at 0, matching how a wrapped function signature
;;     or call's argument list is indented in most of the source, e.g.
;;
;;         void fl_scroll_recalc_scrollbars(SCROLL s,
;;             int &cb_x, int &cb_y, int &cb_w, int &cb_h,
;;             ...
;;             int &ssize)
;;         {
;;
;; This does not attempt to be a complete formatter -- it only
;; teaches CC Mode's *indentation* engine the house style, not the
;; context-dependent `*'/`&' spacing described in
;; doc/cpp_formatting_standard.md (CC Mode has no notion of that; see
;; that file's suggested `.clang-format' for a rough approximation of
;; spacing instead).  A few constructs in the source aren't even
;; internally consistent enough for indentation rules to reproduce --
;; verified against every file under body/ (110/115 `.cpp' files and
;; 114/115 `.h' files reindent byte-for-byte identically to the
;; original with this style):
;;
;;   - c_fl_preferences.cpp indents its one `public:' one level in,
;;     unlike every other class in the codebase (see
;;     doc/cpp_formatting_standard.md, section 3) -- this style
;;     reindents it to the documented, dominant convention instead.
;;   - c_fl_cairo_window.cpp is the only file that indents `#ifdef'/
;;     `#else'/`#endif' to match the surrounding block; the other 57
;;     preprocessor conditionals in body/*.cpp sit at column 0, which
;;     is what this style (and CC Mode's default) produces.
;;   - A minority of wrapped function signatures/calls (e.g. in
;;     c_fl_draw.cpp/.h, c_fl_text_display.cpp,
;;     c_fl_postscript_file_device.cpp) align continuation lines under
;;     the opening parenthesis instead of the flat indent above; CC
;;     Mode's `arglist-cont'/`statement-cont' machinery can produce
;;     one behavior or the other, but not both depending on context,
;;     so these need hand adjustment after `indent-region'.
;;
;; Usage: arrange for this file to be loaded wherever `c++-mode' is
;; used on FLTKAda sources, e.g. from `.dir-locals.el':
;;
;;   ((c++-mode
;;     . ((eval . (load (expand-file-name "cc-mode-fltkada.el"
;;                         (locate-dominating-file default-directory
;;                                                  ".dir-locals.el")))))))
;;
;; or from init.el:
;;
;;   (load "/path/to/fltkada/cc-mode-fltkada.el")

;;; Code:

(require 'cc-mode)

(c-add-style
 "fltkada"
 '("stroustrup"
   (c-basic-offset . 4)
   (indent-tabs-mode . nil)
   (c-offsets-alist
    . ((access-label . -)
       (inclass . +)
       (comment-intro . 0)
       (inher-intro . 0)
       (inher-cont . 0)
       (topmost-intro-cont . +)
       (arglist-intro . +)
       (arglist-cont . +)
       (arglist-cont-nonempty . +)
       (arglist-close . 0)))))

(defun cc-mode-fltkada--setup ()
  "Select the \"fltkada\" CC Mode style and related buffer-local settings."
  (c-set-style "fltkada")
  (setq indent-tabs-mode nil))

(add-hook 'c-mode-common-hook #'cc-mode-fltkada--setup)

(provide 'cc-mode-fltkada)

;;; cc-mode-fltkada.el ends here
