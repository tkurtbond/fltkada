# FLTKAda Ada Formatting Standard

This document describes the formatting conventions actually used throughout
`spec/*.ads` and `body/*.ad[bs]`, so that new or edited code stays consistent
with the existing binding. It is descriptive (reverse-engineered from the
current source) rather than aspirational.

Most of the low-level rules below are already *enforced by the compiler* via
the GNAT style-check switches in `proj/common.gpr`:

```
-gnaty4aAbcefhiklM100nprt
```

which means: 4-space indentation, correct attribute/keyword/pragma/identifier
casing, aligned array-attribute indices, no trailing blanks, two-space `--`
comments, `end`/`exit` labels required, no tabs/form-feeds, standard
if/then and RM layout, 100-column limit, and standard token spacing. Anything
`gnaty` does not check (blank-line rhythm, banner comments, when to force a
subprogram spec onto multiple lines, parameter-list hanging indent) is a
house convention documented here instead.

## 1. Files and headers

Every `.ads`/`.adb` starts with two blank lines, the copyright/author
comment, then two more blank lines before the first `with`:

```ada


--  Programmed by Jedidiah Barber
--  Released into the public domain


with
    ...
```

Files end with a trailing blank line or two after the closing `end Xxx;`.
No tabs, no trailing whitespace (enforced by `-gnatyh`/`-gnatyb`).

## 2. Indentation

* **4 spaces** per level (`-gnaty4`). Never tabs.
* **100-column** line limit (`-gnatyM100`), the same limit used for C++.
* Ordinary continuation lines (wrapped expressions, wrapped call
  arguments, wrapped declarations) are indented **3 spaces** past the
  statement they continue, e.g.:

  ```ada
  This.Void_Ptr := new_fl_widget
     (Interfaces.C.int (X),
      Interfaces.C.int (Y),
      ...
  ```

* A wrapped **subprogram specification** uses a distinct, wider hanging
  indent for the parameter profile, and a shallower one for `return`:
  the parameter list is indented one full level *plus* a continuation
  (`4 + 7 = 11` columns from the enclosing construct), while `return`
  sits only one level in (4 columns):

  ```ada
      function RGB_Color
             (Light : in Greyscale)
          return Color;
  ```

  This two-tier indent (params deeper than `return`) is applied even when
  the whole thing would easily fit on one 100-column line — subprogram
  specs with at least one parameter are *always* split into
  name / parameters / return, never written on a single line.

## 3. `with` clauses

`with` (and `private with`, `limited with`, `use type`) always take the
form: the reserved word alone on its own line, a blank line, then one
context item per line indented 4 spaces, comma-terminated, semicolon on
the last:

```ada
with

    Ada.Finalization,
    System;

private with

    Ada.Unchecked_Conversion,
    Interfaces.C.Strings,
    System.Storage_Elements;
```

Never combine context items onto one line, even when there is only one.

## 4. Subprogram specifications

* Parameterless subprograms: name on one line, `return Type;` (functions)
  or nothing further (procedures) — no parameter line is emitted:

  ```ada
  function Version
      return Version_Number;
  ```

* One or more parameters: **always** three parts — name, parameter
  profile in parens (hanging indent, see §2), `return Type;` — regardless
  of whether it would fit on one line.
* Multiple parameters are aligned in a block: names padded to a common
  column, `:` aligned, mode (`in`, `in out`, `out`) padded so the types
  line up:

  ```ada
      procedure Extra_Init
             (This       : in out Widget;
              X, Y, W, H : in     Integer;
              Text       : in     String);
  ```

* Modes are written explicitly (`in` is not omitted) except where the
  project already elides it for `in` on very short/local declarations —
  prefer writing `in` explicitly for public API parameters.
* `pragma Import (C, ...)` / `pragma Inline (...)` immediately follow an
  imported subprogram spec, no blank line between the spec and its
  pragmas, but a blank line before the next declaration.

## 5. Subprogram bodies

* If the body needs a `declare`-style item list, `is` goes on its own
  line (aligned with the subprogram keyword), declarations are indented
  one level below it, and `begin` returns to the subprogram's own
  indentation:

  ```ada
      function Handle_Hook
             (U : in Storage.Integer_Address;
              E : in Interfaces.C.int)
          return Interfaces.C.int
      is
          Ada_Widget : constant access Widget'Class :=
              Widget_Convert.To_Pointer (Storage.To_Address (U));
      begin
          return Event_Outcome'Pos (Ada_Widget.Handle (Event_Kind'Val (E)));
      end Handle_Hook;
  ```

* If there are **no** local declarations, `is` stays attached to the end
  of the spec (same line as the closing paren or the name) and `begin`
  follows directly:

  ```ada
      procedure Finalize
             (This : in out Widget) is
      begin
          ...
      end Finalize;
  ```

* Every body ends with `end <Name>;` — the defining name is always
  repeated (`-gnatye`).

## 6. Control structures

`if`, `case`, and `exception` alternatives are **not** given an extra
indent level relative to their introducing keyword — `when` lines up
with `case`/`exception`, and `elsif`/`else` line up with `if`:

```ada
        case Value is
        when A0 .. Envelope => return Page_Format'Pos (Value);
        when Media => return fl_page_format_media;
        end case;
```

When the `when` labels are simple identifiers of comparable length, the
`=>` is aligned as a block instead:

```ada
        case Value is
        when Portrait    => return fl_page_layout_portrait;
        when Landscape   => return fl_page_layout_landscape;
        when Reversed    => return fl_page_layout_reversed;
        when Orientation => return fl_page_layout_orientation;
        end case;
```

```ada
        if Value = fl_page_layout_portrait then
            return Portrait;
        elsif Value = fl_page_layout_landscape then
            return Landscape;
        else
            return Orientation;
        end if;
    exception
    when Chk.Assertion_Error => raise Constraint_Error;
```

Multiple `when` alternatives whose bodies are single statements have
their `=>` aligned as a block, the same way parameter modes are aligned.
Statement bodies (inside `if`/`loop`/`case` when not written on the
`when`/`when ... =>` line itself) are indented one level (4 spaces) past
their header.

`for ... loop` / `while ... loop` follow the same rule: `loop`'s body is
indented one level, `end loop;` lines up with `for`/`while`.

## 7. Blank lines and section banners

Blank-line rhythm is used deliberately as visual structure, on top of
what `gnaty` checks:

* **4 blank lines** separate major, named sections of a file (a group of
  declarations that gets its own banner comment).
* **1 blank line** separates individual declarations/subprograms within
  a section.
* **0 blank lines** only for tightly-coupled pairs, e.g. an imported
  function immediately followed by its `pragma Import`/`pragma Inline`.

Two banner styles are used:

* In `.ads` specs, and for minor groupings inside `.adb` bodies, a plain
  two-dash banner:

  ```ada
      --  Color  --
  ```

* In `.adb` bodies, the top-level groupings additionally get a boxed
  banner (dashes above and below, matching the comment's width):

  ```ada
      ------------------------
      --  Functions From C  --
      ------------------------
  ```

Comments always use `--  ` (two spaces after `--`, `-gnatyc`) and are
written in sentence case.

## 8. Naming and casing

* Reserved words: lower case (`-gnatyk`).
* Identifiers (types, packages, subprograms, objects, exceptions): `Mixed_Case`
  with underscores between words, acronyms kept upper case
  (`FLTK`, `RGB`, `ABI`, `URL`-style names) — e.g. `Internal_FLTK_Error`,
  `RGB_Color`, `ABI_Version`.
* Every identifier is referred to with the exact casing used at its
  declaration (`-gnatyr`).
* Pragmas: `Mixed_Case` (`pragma Import`, `pragma Inline`, `pragma Assert`).
* Attributes: `Mixed_Case` (`'Class`, `'Address`, `'Unchecked_Access`).
* Numeric literals are written plainly, without underscore grouping
  (`1024`, not `1_024`), and `**` is written with a surrounding space on
  each side (`2 ** System.Word_Size`, not `2**System.Word_Size`).
* Renames of long package names use short, capitalized abbreviations
  local to the body, e.g. `package Chk renames Ada.Assertions;`,
  `package ICS renames Interfaces.C.Strings;`.

## 9. Packages

* Package spec/body files map 1:1 to `unit-name.ads` / `unit-name.adb`
  with dots replaced by dashes and lower-cased.
* A package body opens with any local `renames` and generic
  instantiations, each on its own statement, separated from the next
  group by 2 blank lines, before the first banner section.
* `private` and the private part are separated from the visible part by
  2 blank lines before and after.

## 10. What `gnatpp` cannot currently reproduce

The version of `gnatpp` available in this toolchain (the Libadalang-based
rewrite, "GNATPP Pro dev") has a much smaller switch surface than the
classic ASIS-based `gnatpp`, and cannot fully reproduce a few of the
conventions above. See `doc/gnatpp_configuration.md` for the recommended
configuration and a precise list of the remaining gaps (always-split
subprogram specs vs. line-length-driven splitting, the two-tier
parameter/return indent, one-context-item-per-line `with` clauses, and
multi-blank-line section banners).
