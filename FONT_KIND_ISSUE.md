# The Font_Kind issue

Status: **decided 2026-11-05: option 1**, and done as FLTKAda-BUGS.md 88.
This blocked the Phase 14 port of FLTK's `test/fonts.cxx`. Written
2026-11-05.

## The problem

`FLTK.Font_Kind` (`spec/fltk.ads:402-419`) is an enumeration with 17
values, one for each of FLTK's 16 built-in fonts (`Helvetica` to
`Zapf_Dingbats`, positions 0 to 15) plus `Free_Font` (position 16, which
is `FL_FREE_FONT`).

FLTK's font is an `int` (`Fl_Font`), and FLTK has as many fonts as a
program sets up:

- `Fl::set_fonts` adds every system font, numbered from `FL_FREE_FONT`
  (16) upward. A desktop has hundreds of them.
- `Fl::set_font (n, name)` can set any number `n`, and the table grows
  to fit it (`fl_set_font.cxx:49-61`).

FLTKAda binds `Fl::set_fonts` as `FLTK.Static.Setup_Fonts`
(`body/fltk-static.adb:1522-1532`). It returns how many fonts there now
are, but there is no `Font_Kind` for any of them past 16. So a program can
load the system fonts but can't name one, list it, ask its sizes, or draw
or label in it.

`test/fonts.cxx` does all of those things. It calls `Fl::set_fonts("-*")`,
and then, for each font `i` from 0 up to the count:

- `Fl::get_font_name (i, &attributes)` fills the font list, in bold or
  italic according to `attributes` (`FL_BOLD`, `FL_ITALIC`);
- `Fl::get_font_sizes (i, sizes)` fills the size list;
- a `FontDisplay` widget draws sample text with `fl_font (font, size)`.

None of these can be written for `i` > 16 against the current API.

## Evidence from the source

Counted in `spec/` and `body/` on 2026-11-05.

- **185 mentions of `Font_Kind`** in `spec/` and `body/`.
- **Setters:** 33 uses of `Font_Kind'Pos`, which converts a `Font_Kind` to
  the C `int`. Any setter can take only 0 to 16.
- **Getters:** 23 uses of `Font_Kind'Val` in 22 body files, each converting
  a C `int` back into a `Font_Kind`. Examples:
  - `body/fltk-menu_items.adb:478`
  - `body/fltk-devices-graphics.adb:150`
  - `body/fltk-widgets-groups-help_views.adb:686`
  - `body/fltk-widgets-charts.adb:467`
  - `body/fltk-tooltips.adb:364`
  - `body/fltk-labels.adb:239`
  - `body/fltk-widgets-groups-browsers.adb:1144`
- **Specs that take a `Font_Kind`** include:
  - `spec/fltk-draw.ads:100, 105, 220, 230` (`Set_Font`, `Font_Height`, …)
  - `spec/fltk-devices-graphics.ads:62`
  - `spec/fltk-asks.ads:177`
  - `spec/fltk-tooltips.ads:97`
  - `spec/fltk-draw-opengl.ads:47`
  - `spec/fltk-tree_items.ads:108`
- **One array indexed by `Font_Kind`:** `Font_Overrides : array (Font_Kind)
  of Interfaces.C.Strings.chars_ptr`, in the private part of
  `spec/fltk-static.ads:730`. It keeps the names passed to
  `Set_Font_Kind`, because FLTK keeps the pointer (bug 33, pofltk 130).
- **Nothing relies on `Font_Kind` being an enumeration.** I searched
  `spec/`, `body/`, `test/`, `examples/` and `tools/` and found no
  `Font_Kind'Image`, `'Value`, `'Succ`, `'Pred`, `'First`, `'Last` or
  `'Range`, no loop over `Font_Kind`, no `case` on a `Font_Kind`, and no
  other array indexed by it. This was a text search; programs outside the
  repository may use any of these.
- **`tools/gen-constants.py:81-86`** checks `Font_Kind` as an `enum`
  against FLTK's `FL_HELVETICA` … `FL_FREE_FONT`.
- **`Font_Image`** is `Fl::get_font` and **`Font_Family_Image`** is
  `Fl::get_font_name` without the attributes
  (`body/c_fl_static.cpp:323-336`). The binding has no way to get the
  attributes, which `fonts.cxx` needs.
- **Bounds.** pofltk 130: FLTK's font table has a private `table_size`,
  and nothing checks a font number against it. `get_font` past the table
  returns garbage, `get_font_name` crashes, and on Cairo a widget whose
  label font is past the table crashes when it is drawn. FLTKAda's fix
  for 130 (PLAN.md Phase 5) is `fl_static_grow_fonts`, which grows the
  table the first time `Free_Font` is used. Because the enumeration stops
  at 16, FLTKAda never has to check a font number against the table. An
  integer font would have to be checked.

## Consequences today

- **The fonts port can't be done** with the current API, except with only
  the 17 built-in fonts (option 3 below).
- **A getter would raise `Constraint_Error`** if it read back a font past
  16. The build switches show that range checks are on: release is
  `-O3 -gnatn` and debug is `-O0 -gnata -gnato -g`, neither with `-gnatp`.
  This is inferred from the switches; I haven't run it. Pure Ada code
  can't set such a font today, so only C or C++ code that changes a
  widget's font can make this happen. Under option 2 below, Ada code
  could cause it too.
- **`Setup_Fonts` is nearly useless.** It loads fonts the program can't
  then use.

## How pofltk does it

pofltk (`~/Repos/Oberon/pofltk/src/Fl.Mod`) makes every font an
`INTEGER`:

- The built-in fonts are constants: `Helvetica* = 0` … `FreeFont* = 16`
  (`Fl.Mod:204-220`).
- `LabelFont`, `SetLabelFont`, `TooltipFont` and the others take and
  return an `INTEGER`.
- The shim keeps `font_end`. `ofl_set_fonts` and `set_font` raise it
  (`src/Fl.cpp:147, 163, 1280-1284`), and `Fl.FontEnd()` returns it.
- `CheckFont` halts on a number outside `0 .. FontEnd() - 1`. Font names
  are kept in a `std::map<int, …>` (`font_names`).
- `GetFontName (f, name, attributes)` returns the attributes.
- As in FLTKAda, a widget's font isn't checked against the table in every
  setter. pofltk leaves it to the program to stay below `Fl.FontEnd()`.

`examples/Fonts.Mod` is its port of `fonts.cxx`, and stores `font` as an
`INTEGER`.

## Options

### 1. Make `Font_Kind` an integer type, with constants (recommended)

```ada
type Font_Kind is new Natural;
Helvetica     : constant Font_Kind := 0;
...
Zapf_Dingbats : constant Font_Kind := 15;
Free_Font     : constant Font_Kind := 16;
```

- **What still works:** every call that names a font, such as
  `Set_Label_Font (FLTK.Courier)`, `Drw.Set_Font (FLTK.Helvetica, 14)`
  and comparisons. That is every use in the repository.
- **What breaks:** programs outside the repository that use `'Image`,
  `'Succ`, `'Pred`, `'First`, `'Last`, `'Range`, a `case` over the fonts,
  or an array indexed by `Font_Kind`.
- **The body changes are mechanical.** The 33 `'Pos` and 23 `'Val` become
  plain conversions. Since they're spread over 22+ files, it would be one
  scripted pass with a count asserted for each file.
- **`Font_Overrides`** becomes a growable store keyed by font number, an
  `Ada.Containers.Ordered_Maps` from `Font_Kind` to `chars_ptr` (or the
  shim keeps the names, as pofltk's does). Its finalization frees each
  name.
- **Bounds:** port pofltk's `font_end`. Add `Font_End` (or `Font_Count`)
  to `FLTK.Static`. `Font_Image`, `Font_Family_Image`, `Font_Sizes`,
  `Set_Font_Kind` and `FLTK.Draw.Set_Font` would raise a named exception
  on a number at or past it. That check must be explicit, not a `Pre`
  (PLAN.md, "Architecture decisions", 1). As in pofltk, a widget's font
  setters stay unchecked, and this is documented.
- **New:** a `Font_Family_Image (Kind, Attributes : out …)` overload, or a
  separate function, for `get_font_name`'s attributes, with `Bold` and
  `Italic` constants. `fonts.cxx` needs it under any option.
- **Also to update:**
  - `tools/gen-constants.py`: from `enum` to constants (rerun it, so that
    `test_constants` checks them);
  - `doc/enumerations.html`, which lists `Font_Kind` as an enumeration,
    and the other `doc/*.html` pages that mention it;
  - `progress.txt`;
  - a FLTKAda-BUGS.md entry (number 88), because `Setup_Fonts` loads fonts
    that the API can't name;
  - a PLAN.md decision.
- **Tests first:** a unit test that calls `Setup_Fonts`, then names, sizes
  and labels a box in font 17. It fails today. Plus a check that a number
  past `Font_End` raises.

This is the closest match to FLTK and to pofltk, and the smallest public
API.

### 2. Keep the enumeration and add a separate `Font_Number` type

```ada
type Font_Number is new Natural;
function To_Number (Kind : Font_Kind) return Font_Number;
```

Every setter and getter would then get a `Font_Number` overload.

- **Nothing breaks.**
- **The API doubles in size**, across about 30 setters, 23 getters and
  their docs.
- **The getters still have a problem.** A `Font_Kind` getter on a widget
  whose font was set by number still raises `Constraint_Error` (or would
  need a fallback). So each getter needs a `Get_…_Font_Number` twin, and
  a program has to know which of the two to call.
- Bounds checking and the attributes call are as in option 1.

### 3. Port `fonts` with only the built-in fonts

- **No API change.** Write `test/fonts.adb` for fonts 0 to 16 only, and
  record the gap in FLTKAda-BUGS.md and progress.txt.
- **The port wouldn't match `fonts.cxx`,** whose main point is listing the
  system's fonts. A screenshot comparison with the C++ would differ.
- **`Setup_Fonts` stays nearly useless.**
- The attributes call is still needed for the bold and italic list
  entries, though only for the built-in fonts.

## Recommendation

**Option 1.** It is what FLTK and pofltk do. It keeps every existing call
in the repository compiling unchanged. It removes the `Constraint_Error`
risk in the getters, rather than spreading it across two types as option 2
would. Its cost is that FLTKAda has to check font numbers itself, which
pofltk already shows how to do. It breaks only programs that treat fonts
as an enumeration (`'Image`, `'Succ`, `case`), and none in this
repository do.

## Decision

**Option 1**, chosen by the user on 2026-11-05, and recorded in PLAN.md's
Phase 14 decisions. As done (FLTKAda-BUGS.md 88):

- `Font_Kind` is `new Natural`, with the 17 constants.
- **`FLTK.Static.Last_Font`** comes from the shim's `font_end`, which
  starts at `Free_Font`.
- **`Max_Font`** is 65535.
- **`Font_Family_Attributes`** returns a `Font_Attributes` record of
  `Bold` and `Italic`.
- **`Font_Overrides`** is an `Ada.Containers.Ordered_Maps`.
- **Every font argument is checked,** through the private `FLTK.To_C`,
  which replaced every `'Pos`. That includes the widget setters, which
  this file's option 1 said would stay unchecked.

The `Constraint_Error` in the getters, under "Consequences today", was
never run against the old code. It can't happen now, because a getter
converts with `Font_Kind (...)`.

Every program in the repository compiled unchanged. The only other file
that needed a change was tools/gen-constants.py, whose output,
test/unit/fltk-test_constants.adb, now converts each constant with
`Long_Long_Integer` instead of `'Pos`.
