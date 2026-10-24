# AGENTS.md

Instructions for AI coding agents working in this repository.

## What this is

FLTKAda: a thick Ada binding to the [FLTK](https://www.fltk.org/) C++ GUI
toolkit, built on the standard C FFI (no libraries beyond FLTK, g++, GNAT,
and GPRbuild). Three layers, thinnest at the bottom:

```
Ada application code
        |
spec/fltk-*.ads / body/fltk-*.adb   -- Ada binding (tagged types, Forge
        |                              constructors, pragma Import/Export)
body/c_fl_*.h / c_fl_*.cpp          -- C++ shim (flattened extern "C" API,
        |                              "My_X" subclasses that thunk virtual
        |                              calls back into Ada)
      FLTK (C++)
```

**Read `doc/binding_architecture.md` before making any non-trivial change
to `spec/` or `body/`.** It documents the ownership model, the
constructor/`Forge`/`Extra_Init` lifecycle, and — critically — the
`Draw_Ptr`/`Handle_Ptr` trampoline mechanism that makes FLTK's virtual
`draw()`/`handle()` dispatch into Ada. None of that is guessable from
reading one file in isolation.

## Build, install, test

```sh
gprbuild fltkada.gpr              # build the library (release by default)
gprbuild fltkada.gpr -Xbuild=debug   # debug build: -O0 -gnata -gnato -g
gprinstall -p -m fltkada.gpr      # install
gprbuild tests.gpr                # build the test/example programs
gprbuild tests_2022.gpr           # build the Ada-2022-only test/example programs
gprbuild examples.gpr             # build the ports of FLTK 1.4.5's examples/ (bin/examples/)
gprbuild tools.gpr                # build tool/ (template.adb, a codegen helper)
```

Built test executables land in `bin/`. There is no automated test suite —
"testing" a new binding means writing a small `test/<name>.adb` (see
existing files under `test/` for the idiomatic shape), adding it to `Main`
and `Builder` in `tests.gpr`, and running it.

## Directory layout

| Path | Contents |
|---|---|
| `spec/` | Ada package specs (`fltk-*.ads`) — the public API |
| `body/fltk-*.adb` | Ada package bodies |
| `body/c_fl_*.h`, `body/c_fl_*.cpp` | The C++ shim, one pair per bound FLTK class |
| `test/`, `test/.dir-locals.el` | Example/test programs (built by `tests.gpr`/`tests_2022.gpr`) |
| `examples/` | Ada ports of every program in FLTK 1.4.5's `examples/` (built by `examples.gpr`, executables named after the C++ originals) |
| `tool/` | `template.adb`, an unrelated text-substitution codegen helper — not a widget template |
| `proj/common.gpr` | Shared `gprbuild` switches (style checks, warnings, `Pretty_Printer` config) for all the other `.gpr` files |
| `doc/` | `index.html` + one `<header>.html` per bound C++ header (hand-maintained C++↔Ada API map) plus the Markdown docs listed below |
| `progress.txt` | Hand-kept coverage checklist: Done / Partially Done / To-Do / Never, plus known bugs and incomplete APIs |

## Documentation to consult

- `doc/binding_architecture.md` — how the binding works end to end, and
  step-by-step recipes for adding a binding for an unbound FLTK class.
  Includes a coverage gap analysis (FLTK 1.4.5 classes not yet bound, not
  yet in `progress.txt` either) and a list of known pitfalls.
- `doc/ada_formatting_standard.md` — the Ada house style (indentation,
  blank-line rhythm, banner comments, naming, the "always split a
  multi-parameter subprogram spec into name/params/return" convention).
- `doc/cpp_formatting_standard.md` — the C++ shim's house style (brace
  style, the context-dependent `*`/`&` spacing rule, naming conventions
  for the C API, the `fl_inside_callback` double-free guard idiom).
- `doc/gnatpp_configuration.md` — `gnatpp` config matching the Ada style,
  and its known gaps (things you must still fix by hand).
- `readme.md` — build/install summary and two behavioral notes worth
  re-reading: Draw/Handle overrides change FLTK's behavior because FLTK
  calls them directly; overrides of things like `Push` that are normally
  called *from* `Handle` do not, unless `Handle` is also overridden.

## Code style — enforced, not optional

Ada style is enforced at compile time via `-gnaty4aAbcefhiklM100nprt` in
`proj/common.gpr` (4-space indent, no tabs, two-space `--` comments,
100-column limit, mandated casing, `end`/`exit` labels, and more — see the
intro of `doc/ada_formatting_standard.md` for what each letter means).
New C++ must compile clean under `-std=c++11 -Wall -Wextra -Wpedantic -Werror`
(`proj/common.gpr`, `CPP_Common`) — no C++14-or-later features.

If editing in Emacs, `.dir-locals.el` (root, `test/`, `tool/`)
auto-loads `ada-ts-mode-fltkada.el` and `cc-mode-fltkada.el`, which
configure `ada-ts-mode` and CC Mode to reproduce these styles while
typing/reindenting. Both were empirically validated against the entire
existing source tree (reindenting every file byte-for-byte matches the
original for the overwhelming majority of files); their header comments
list the small number of known exceptions.

`gnatpp -P fltkada.gpr` uses the `Pretty_Printer` package in
`proj/common.gpr` — see `doc/gnatpp_configuration.md` before running it
over a whole file, since it can't reproduce a few conventions exactly
(one-context-item-per-line `with` clauses, the file-header/section blank
line rhythm) and will disturb them if run unattended.

## Naming and API-mapping conventions (Ada side)

- Package hierarchy mirrors FLTK's C++ class hierarchy:
  `FLTK.Widgets.Buttons.Light.Check` etc. Not always 1:1 by name — e.g.
  `Fl_Preferences` is bound as `FLTK.Environment`; check `doc/index.html`
  before assuming a package name from a class name.
- Constructors live in a nested `Forge` package (`Forge.Create`), not as
  primitive operations on the type — keeps `Create` out of the
  dispatching set and avoids name clashes.
- Every bound class derives from `FLTK.Wrapper` and follows the
  `Initialize`/`Extra_Init`/`Extra_Final`/`Finalize` four-hook lifecycle
  described in `doc/binding_architecture.md` §2.4.

## Workflow when adding a binding for new FLTK API surface

1. Check `progress.txt` and `doc/binding_architecture.md` §7 (gap
   analysis) for whether it's already tracked and what package it should
   live under.
2. Follow the matching recipe in `doc/binding_architecture.md` §6 (new
   Widget subclass / new Image subclass / other).
3. Write a `test/<name>.adb`, register it in `tests.gpr`, build and run
   it.
4. Add `doc/<header>.html` (copy `doc/fl_box.html`'s structure) and link
   it from `doc/index.html`.
5. Update `progress.txt` (move to Done, or note what's left under
   "Incomplete APIs").

## Git / commits

Only commit when explicitly asked. This repository's commit messages are
short and describe the "why", not a line-by-line summary of the diff —
match `git log` style already in the repo.
