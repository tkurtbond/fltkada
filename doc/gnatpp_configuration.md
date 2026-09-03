# gnatpp Configuration for the FLTKAda Style

This documents the `gnatpp` configuration added to `proj/common.gpr` (package
`Pretty_Printer`), what it reproduces, and what it can't — see
`doc/ada_formatting_standard.md` for the style itself.

The `gnatpp` on this machine (`gnatpp --version` → `GNATPP Pro dev`) is the
modern Libadalang-based rewrite. It has a much smaller switch surface than
the classic ASIS-based `gnatpp` (no per-construct alignment switches, no
"separate line for return" toggle, no blank-line-count control), which is
why some of the house style below can't be reproduced by switches alone.

## Usage

```sh
# whole project
gnatpp -P fltkada.gpr -U

# a single file, using the project's configured switches
gnatpp -P fltkada.gpr spec/fltk-widgets.ads

# preview without touching the file
gnatpp -P fltkada.gpr -pipe spec/fltk-widgets.ads | less
```

`package Pretty_Printer` in `proj/common.gpr` is `renamed` into
`fltkada.gpr`, `tools.gpr`, `tests.gpr`, and `tests_2022.gpr`, so `-P` works
against any of them.

## The configured switches, and why

| Switch | Reproduces |
|---|---|
| `--indentation=4` | 4-space base indentation (`-gnaty4`) |
| `--indent-continuation=3` | Ordinary wrapped-expression/wrapped-call indent (§2 of the Ada standard) |
| `--par-threshold=0` | Force every subprogram spec with ≥1 parameter to split into name / parameter-profile / `return`, instead of only splitting when it doesn't fit |
| `--max-line-length=100` | The project's 100-column limit (`-gnatyM100`) |
| `--decimal-grouping=0`, `--based-grouping=0` | Disable automatic `_` grouping in numeric literals (source writes `1024`, not `1_024`) |
| `--keyword-lower-case` | `-gnatyk` |
| `--attribute-mixed-case` | `'Class`, `'Address`, etc. |
| `--name-case-as-declared`, `--type-case-as-declared`, `--enum-case-as-declared`, `--number-case-as-declared` | Preserve `Mixed_Case` identifiers/types/literals exactly as declared (`-gnatyr`) |
| `--pragma-mixed-case` | `pragma Import`, `pragma Inline`, ... |
| `--eol=lf` | Unix line endings |

`--call-threshold` is deliberately left at its default (not forced to `0`):
unlike parameter *profiles*, named-association aggregates and calls in this
codebase (e.g. `(Release => True, Interact => True, others => False)`) are
kept on one line when they fit, and only wrap on length. Forcing
`--call-threshold=0` would incorrectly explode every such aggregate.

## Known gaps (things you must still do by hand)

Verified by running the configured `gnatpp` over real files in this repo and
diffing the result against the original:

1. **The source uses two different hanging indents for a wrapped
   subprogram spec — 7 columns for the parameter profile, 4 columns for
   `return`/`is` — but gnatpp only has one `--indent-continuation` value,
   applied to both.**
   * `--indent-continuation=3` (recommended above) makes `return`/`is`
     land exactly right (4 columns past the subprogram keyword) but the
     parameter list lands only 3 columns past it, 4 short of the source's
     7.
   * `--indent-continuation=7` makes the parameter list land exactly
     right, but then pushes `return`/`is` to 8 columns past the keyword,
     4 too many.

   There is no single value that gets both right at once; `3` was chosen
   because `return`/`is` placement is far more frequent and visually
   load-bearing than the exact width of the parameter block. If matching
   the parameter block takes priority instead, override with
   `--indent-continuation=7` for that run.
2. **`with` clauses are always reflowed onto one line**, even `--layout=minimal`
   collapses a hand-broken, one-item-per-line `with` list. gnatpp has no
   switch to keep one context item per line.
3. **Leading/section blank-line counts are not preserved exactly.** gnatpp
   collapses some multi-blank-line gaps (e.g. between the file header and
   the first `with`, or before `private`). The 4-blank/1-blank section
   rhythm and the boxed banners in `.adb` bodies are not something gnatpp
   understands at all — it only reformats code, not comment layout.
4. **`when`/`exception` alternatives not gaining an extra indent level**
   relative to `case`/`exception` is *not* controllable — this happens to
   match this tool's default output already, so no switch is needed for
   it, but there's also no switch to change it if a file drifts.

### Working around the gaps: `--pp-off` / `--pp-on`

For the pieces gnatpp will not leave alone — `with` clauses and banner
comments — wrap them in the standard pretty-printer on/off markers so
`gnatpp` skips exactly that span and reformats everything else in the file
normally:

```ada
--!pp off
with

    Ada.Finalization,
    System;
--!pp on
```

This has been verified to work with the switches above: the marked region
is passed through byte-for-byte while the rest of the file is still
reformatted.

## Recommended workflow

Given the gaps above, `gnatpp -P fltkada.gpr -U` is safe to run on
**subprogram bodies** (declare/begin/end blocks, if/case/loop statements,
parameter alignment) without much manual cleanup, but running it
unattended over whole files will disturb `with` clauses and blank-line
structure. Prefer:

* `gnatpp` on a diff/single subprogram, reviewed before committing, or
* wrapping the file-level `with` clauses and section banners in
  `--!pp off` / `--!pp on` first, then running `gnatpp` over the whole
  file.
