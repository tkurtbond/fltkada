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

## Status

**PLAN.md** is the roadmap: it brings FLTKAda level with pofltk, the
Oberon-2 binding at `~/Repos/Oberon/pofltk`. That means pofltk's coverage,
its test suite and extra examples, and fixes for the FLTK bugs and
pitfalls in pofltk's `doc/fltk-issues.md`. Read PLAN.md's "Architecture
decisions" and "The issue triage" before fixing a bug or binding new API.
Work through the phases in order. Phase 0, the test infrastructure, comes
first, because every later fix is meant to start from a failing test.

Where findings go:

- **FLTKAda-BUGS.md**: bugs in FLTKAda's own code. Sections 1–14 are
  fixed; 17–21, 23–26, 28, 29, 41, 44 and 85 are open;
  22, 27, 30 to 40, 42, 43, 45 to 84 and 86 to 97 are fixed.
- **FLTK-issues.md**: FLTK issues pofltk's list doesn't have (F1, F2, …).
- **PLAN.md**: FLTKAda's verdict on each of pofltk's numbered issues, and
  every decision.
- **INCOMPATIBLE-CHANGES.md**: every change that can break a program
  written for upstream FLTKAda (see Conventions).

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

Built test executables land in `bin/`, the unit tests in `bin/unit/`.
The automated tests (PLAN.md Phase 0) run headless:

```sh
make check-headless       # unit tests + self-checking programs, Xvfb (X11)
make check-sway           # the same on a headless sway (Wayland)
make valgrind-headless    # the same under valgrind; also valgrind-sway
make smoke-headless       # every program starts and survives; also smoke-sway
```

Never run plain `make check`, `make valgrind` or `make smoke`: they use
whatever display is set, which is the user's desktop.

A unit test is a `test/unit/test_<area>.adb` using `Checks` and
`FLTK.Probe` (see `test_probe.adb`), listed in `Main` in
`tests_unit.gpr`; `make check` finds it there. A demo program goes in
`test/`, in `Main` and `Builder` in `tests.gpr`, and the smoke run picks
it up. Four of the existing programs check their own results and set
the exit status, and `make check` runs them: `preferences`,
`group_children`, `clear_image_chosen` and `column_widths`. (This file
first said eight, including `button`, `ask`, `dirlist` and `filename`.
That was wrong: `button` and `ask` wait for the user, and `dirlist` and
`filename` only print a result for their argument.)

## Tests and the display

Every FLTK program needs a display (`DISPLAY` or `WAYLAND_DISPLAY`), even
one whose widgets are never shown.

- **An agent never opens windows on the user's desktop.** That rules out
  running anything in `bin/` or `bin/examples/` directly,
  `FLTK_BACKEND=x11 ...` (XWayland is the desktop too), and a scratch
  program run directly. The user gave this instruction for pofltk on
  2026-10-06, and it applies here. Windows on the real desktop can take
  the user's keystrokes and clicks, and the user's input can make a test
  fail.
- **X11, headless:** `env -u WAYLAND_DISPLAY xvfb-run -a <program>`. A
  plain `xvfb-run` in a Wayland session leaves `WAYLAND_DISPLAY` set, and
  FLTK then prefers Wayland, which is the real desktop (pofltk 18). The
  default screen is 640x480. Pass `-s '-screen 0 1280x1024x24'` for
  larger windows.
- **Wayland, headless:** `tools/with-sway.sh <program>` (copied from
  pofltk). It runs the
  command on a headless sway with `DISPLAY` unset. Pop-up menus close
  at once there, as they do on the desktop, so menu tests need X11.
- **Screenshots:** under Xvfb, use `xwd -root -display :N | convert xwd:-
  out.png`, or `import -window root`. On the user's Sway desktop use
  grimshot, but don't open windows there in the first place.
- **Comparing with FLTK's C++:** build the C++ original with
  `fltk-config --compile foo.cxx`, run both under the same private Xvfb,
  and compare screenshots with `compare -metric AE` and diff the output.
  This is how sections 1–14 of FLTKAda-BUGS.md were verified.
- Tests drive themselves, without an input tool:
  - `Do_Callback`;
  - synthetic events from the test-only `FLTK.Probe` package
    (`test/unit/fltk-probe.ads`);
  - timeouts, or `Wait`/`Check` in a loop;
  - `FLTK.Probe.Modal` to answer a dialog.

## Valgrind

Run a test under valgrind with
`env -u WAYLAND_DISPLAY xvfb-run -a valgrind --leak-check=full <program>`.
FLTK, fontconfig, Pango and libdecor leak by design (PROBLEMS-OUTSTANDING.md
lists FLTK's font caches; see also pofltk 19). A leak is FLTKAda's only
if its allocator, the first frame after malloc or new, is in FLTKAda:
`(in .../libfltkada.so)`, a `body/c_fl_*.cpp` or `fltk*.ad[bs]` source,
or a GNAT name such as `fltk.widgets.boxes.forge.create`.
`test/vg-check.sh LOG` applies that test, and `make valgrind-headless`
runs it; read its header comment for the one exception (still-reachable
blocks from elaboration). Invalid reads
and writes are always errors, whoever allocated the memory. Valgrind
can't see a pointer into a dead stack frame or a reused buffer, so for
dangling strings check the actual value too.

## Reference material

| What | Where |
|---|---|
| FLTK 1.4.5 source (`src/`, `test/`, `examples/`) | `/usr/local/sw/src/lang/C++/fltk/fltk-1.4.5/` |
| FLTK headers | `/usr/include/FL/` |
| FLTK HTML documentation | `/usr/share/doc/fltk-devel/html/` |
| pofltk (Oberon-2 binding; reference for workarounds, tests and examples) | `~/Repos/Oberon/pofltk/` |
| pofltk's FLTK issues (numbered 1–138, cited as "pofltk N") | `~/Repos/Oberon/pofltk/doc/fltk-issues.md` |
| pofltk's shim code for each workaround (`ofl_*` functions) | `~/Repos/Oberon/pofltk/src/**/*.cpp` |
| pofltk's tests (`Test*.Mod`, `Halt*.Mod`, `Probe.Mod`/`.cpp`, `vg-check.sh`) | `~/Repos/Oberon/pofltk/test/` |
| pofltk's extra examples, with a README listing what each shows | `~/Repos/Oberon/pofltk/examples/` |
| pofltk's operational notes, including the BSD test hosts | `~/Repos/Oberon/pofltk/AGENTS.md` |

pofltk is Oberon-2, and its shim is written for a language without
exceptions or controlled types. Port each workaround's *idea* and C++
code, then express the Ada side idiomatically. For example, a pofltk halt
code becomes an Ada exception, and a module-level table becomes a
component of the Ada record.

## Directory layout

| Path | Contents |
|---|---|
| `spec/` | Ada package specs (`fltk-*.ads`) — the public API |
| `body/fltk-*.adb` | Ada package bodies |
| `body/c_fl_*.h`, `body/c_fl_*.cpp` | The C++ shim, one pair per bound FLTK class |
| `test/`, `test/.dir-locals.el` | Example/test programs (built by `tests.gpr`/`tests_2022.gpr`) |
| `test/unit/` | Unit tests, `Checks` and `FLTK.Probe` (built by `tests_unit.gpr` into `bin/unit/`) |
| `test/controls/` | Programs that test the tests: the negative controls, which must fail, and the N12 experiment (built by `test/controls/controls.gpr` into `bin/controls/`) |
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

## Conventions

- **Claim only what has been verified.** If a comment, a FLTKAda-BUGS.md
  entry or a PLAN.md decision depends on how FLTK actually behaves, check
  it with a scratch program run headless, or failing that in FLTK's
  source, and say which. Check actual values, not just that nothing
  crashed. When something recorded turns out to be wrong, correct it
  where it was recorded and say so; don't silently delete it. For
  example, PLAN.md's N6 is struck through, with the reason.
- **Before binding anything that takes a pointer**, find out from FLTK's
  source whether FLTK copies it or keeps it. If FLTK keeps it, never pass
  an `Interfaces.C.To_C` temporary. Use FLTK's `copy_*` method, or keep
  the copy in the Ada record or in the shim (PLAN.md, "Architecture
  decisions", 4). pofltk's issue list says, for most FLTK calls, which
  one it is.
- **Guards against memory errors are explicit checks that raise.** They
  are not `Pre` or predicates, which release builds don't check (PLAN.md,
  "Architecture decisions", 1).
- **No C++ exception may escape the shim.** Wrap any call that can throw
  (image loaders, `new` with a size from a file) in `try`/`catch`, and
  return an error code.
- **Record every FLTK problem as it is found.**
  - A problem pofltk already lists: note FLTKAda's verdict in PLAN.md.
  - A new one: add it to FLTK-issues.md in its form (what happens, the
    cause in FLTK's source, the effect on FLTKAda, how it was confirmed).
  - A bug in FLTKAda's own code: add it to FLTKAda-BUGS.md.
- **Record decisions and findings in PLAN.md as they happen.** Append to
  the relevant section, mark finished phases `[done]`, and strike
  through decided open questions, saying what was decided.
- **A file ported from pofltk** gets the new-file header plus these
  two lines, which release it into the public domain like the rest of
  FLTKAda (pofltk itself is BSD 3-Clause; its author, T. Kurt Bond,
  released the derived files):
  ```
  --  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
  --  author releases this derived work into the public domain, as FLTKAda is.
  ```
- **Keep progress.txt and doc/*.html in step** with what is bound
  (Workflow above).
- **Keep INCOMPATIBLE-CHANGES.md up to date.** Add an entry for any
  change that can stop a program written against upstream FLTKAda
  compiling, or make it behave differently: a removed, renamed or
  retyped declaration, a new enumeration literal, a narrowed range, or a
  call that now raises or gives a different result. Give it a sentence
  or two, and link the FLTKAda-BUGS.md section or PLAN.md entry that has
  the details.
- **A constant or enumerator that stands for an FLTK value** goes in
  `tools/gen-constants.py` too. Rerun the script with
  `python3 tools/gen-constants.py`, so that `test_constants` checks it.

## Git / commits

Only commit when explicitly asked. This repository's commit messages are
short and describe the "why", not a line-by-line summary of the diff —
match `git log` style already in the repo.
