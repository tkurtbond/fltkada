# FLTKAda C++ Formatting Standard

This document describes the formatting conventions used in `body/*.cpp` and
`body/*.h` — the thin C shim layer that sits between FLTK's C++ API and the
Ada binding. Like the Ada standard (`doc/ada_formatting_standard.md`), it is
descriptive of the existing code, not a generic style guide.

The compiler flags already enforced for this layer, from `proj/common.gpr`,
constrain what's usable:

```
-std=c++11 -Wall -Wextra -Wpedantic -Werror -fPIC
```

so new code must compile warning-free under C++11 (no C++14/17/newer
features) with `-Wextra -Wpedantic`.

There is no automated formatter configured for this layer (no `.clang-format`
in the repo) — this document is the closest thing to one, and a
`.clang-format` derived from it is included at the end for convenience.

## 1. File layout

Every `.cpp`/`.h` starts with two blank lines, the header comment, then two
more blank lines:

```cpp


//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Box.H>
#include "c_fl_box.h"
#include "c_fl.h"
```

`#include` order: FLTK headers first (`<FL/...>`, angle brackets), then this
layer's own headers (`"c_fl_*.h"`, quotes), then any standard library headers
needed (`<cstdlib>`, etc., also angle brackets, placed with the FLTK block).

Header files use an include guard named `FL_<NAME>_GUARD` (no leading/trailing
underscore, no `#pragma once`):

```cpp
#ifndef FL_BOX_GUARD
#define FL_BOX_GUARD
...
#endif
```

## 2. Sections and blank lines

Each `.cpp` is organized into clearly labeled sections using a single-line
`//  Section Name` comment (two spaces after `//`, no closing `--`/box, no
trailing punctuation):

```cpp
//  Exports from Ada

//  Non-friend protected access

//  Attaching all relevant hooks and friends

//  Flattened C API
```

* **4 blank lines** separate major sections (matching the Ada convention).
* **1 blank line** separates individual function/class definitions within a
  section.
* Related one-line `extern "C"` declarations may be grouped with no blank
  line between them.

There are no block comments (`/* ... */`) anywhere in this layer — use `//`
exclusively, including for the file header.

## 3. Indentation and braces

* **4 spaces**, never tabs, 100-column soft limit (matching `-gnatyM100` on
  the Ada side — keep C++ lines under the same 100 columns for consistency).
* K&R / "attached" brace style: the opening brace stays on the same line as
  the `class`/function/`if`/`else` it belongs to; the closing brace starts
  its own line:

  ```cpp
  void My_Box::draw() {
      widget_draw_hook(this->user_data());
  }

  if (fl_inside_callback) {
      fl_delete_widget(b);
  } else {
      delete static_cast<My_Box*>(b);
  }
  ```

* `class` bodies: access specifiers (`public:`) are written at the **same**
  indentation as the class's opening brace (i.e. not indented), and members
  are indented one level (4 spaces) from that:

  ```cpp
  class My_Box : public Fl_Box {
  public:
      using Fl_Box::Fl_Box;

      friend void fl_box_draw(BOX n);
      friend int fl_box_handle(BOX n, int e);

      void draw();
      int handle(int e);
  };
  ```

* Space after `if`/`for`/`while`, before the `(`; no space between a
  function/method name and its `(`.

## 4. Pointers and casts

Spacing around `*` depends on context — this is followed consistently
enough to be a real rule, not noise:

| Context                              | Style           | Example                              |
|---------------------------------------|-----------------|---------------------------------------|
| Function parameters                   | space both sides | `void fl_box_extra_init(void * adaobj, ...)` |
| `typedef`s for opaque handles         | attached to type | `typedef void* BOX;`                 |
| Local variable declarations           | attached to name  | `My_Box *b = new My_Box(...);`       |
| `static_cast<T*>` / `reinterpret_cast<T*>` | attached to type, no space before `>` | `static_cast<My_Box*>(b)` |

Prefer `static_cast`/`reinterpret_cast` over C-style casts; the codebase
does not use C-style casts.

## 5. Naming conventions

* **Opaque handle typedefs** (the types crossing the Ada/C boundary):
  short, all-caps, no underscores — `BOX`, `WIDGET`, `MENUITEM`, `PREFS`.
* **Wrapper subclasses** that hook FLTK's virtual `draw`/`handle`, or add a
  reference count, are named `My_<FlClass>` (`My_Box`, `My_Preferences`,
  `My_Adjuster`). Classes that only exist to expose otherwise-protected
  members are named `Friend_<FlClass>` (`Friend_Text_Display`).
* **Exported C functions** (`extern "C"`), all lower snake_case, follow one
  of these shapes:
  * `new_fl_<thing>(...)` — allocate/construct.
  * `free_fl_<thing>(...)` — destroy.
  * `fl_<thing>_<action>(...)` — everything else (`fl_widget_activate`,
    `fl_box_draw`).
  * Hooks called *into* Ada are declared `extern "C"` and named
    `<thing>_hook` (`widget_draw_hook`, `box_extra_init_hook`).
* Function parameters are short lowercase abbreviations (`w`, `h`, `x`,
  `y`, `l`/`label`, `ud`, `e`), matching the corresponding FLTK constructor
  signature rather than being spelled out.
* Plain data members/locals: lower snake_case (`reference_count`).

## 6. Memory management pattern

Destructor-style functions consistently guard against FLTK's own callback
teardown with the same idiom — reproduce it exactly for new widget types:

```cpp
void free_fl_box(BOX b) {
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_Box*>(b);
    }
}
```

## 7. Operators

Binary operators are surrounded by a single space on each side
(`a + b`, `x <= y`, `count += 1`), argument lists use `, ` (comma-space)
between arguments. (One historical exception exists in `c_fl_menu.cpp`'s
`for (int i=0; i<fl_menu_size(m); i++)` — don't copy that; write
`for (int i = 0; i < fl_menu_size(m); i++)` in new code.)

## 8. Suggested `.clang-format`

`clang-format` cannot express the pointer-spacing-by-context rule (§4) or
the section-banner/blank-line rhythm (§2) exactly, but this configuration
gets indentation, braces, and general spacing close to the conventions
above for anything you run it on:

```yaml
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Never
ColumnLimit: 100
BreakBeforeBraces: Attach
AccessModifierOffset: -4
IndentAccessModifiers: false
SpaceBeforeParens: ControlStatements
PointerAlignment: Middle
DerivePointerAlignment: false
AlignConsecutiveDeclarations: false
SortIncludes: Never
Cpp11BracedListStyle: true
```

Because of the pointer-style and banner-comment gaps above, treat this as a
starting point to hand-tune a diff with, not something to run unattended
over the whole `body/` tree.
