#!/bin/sh
# Programmed by T. Kurt Bond and Claude Opus 5.5
# Released into the public domain
# Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
# author releases this derived work into the public domain, as FLTKAda is.
#
# vg-check.sh LOG: succeed unless a loss record in the valgrind log LOG
# (from --leak-check=full --show-leak-kinds=all) is memory that FLTKAda
# allocated: a record whose allocator - the first frame after malloc,
# calloc, realloc or operator new - is in FLTKAda's library. Each one
# found is printed. Ported from pofltk's test/vg-check.sh.
#
# FLTKAda's frames are those in libfltkada (the shim's fl_* functions and
# My_* classes, and the Ada bodies), which valgrind shows as
# "(in .../libfltkada.so)", or, with debug information, by source file:
# body/c_fl_*.cpp, or the Ada units, which valgrind names fltk.<unit>.
#
# FLTK's display stack leaks by design: fontconfig, Pango's font cache,
# libdecor's window decorations on Wayland, and FLTK's own font caches
# (PROBLEMS-OUTSTANDING.md; pofltk 19). Their allocators are in those
# libraries or in libfltk, so they pass. Leaks don't count as valgrind
# errors in make valgrind-headless (--errors-for-leak-kinds=none); this
# script is what fails a test for one.
#
# valgrind names some functions in angle brackets, GNAT's allocator among
# them ("<__gnat_malloc> (s-memory.adb:79)"), and C++'s operator new by
# its mangled name ("<_Znwm>"), so the allocator patterns allow both.
# Without that, every leak from an Ada allocator or a new in FLTKAda
# passed, as a negative control showed (PLAN.md, Phase 0).
#
# One kind of FLTKAda's memory passes: a block still reachable at exit
# that a unit's elaboration (fltk'Elab_Spec, fltk'Elab_Body) allocated.
# That is a library-level object, made once and kept for the program's
# life, such as Clipboard_Image in spec/fltk.ads, whose length GNAT
# doesn't know until it runs. Lost blocks from elaboration still fail.
awk '
  / bytes in [0-9,]+ blocks are .* in loss record / {
    inrec = 1; seen = 0; rec = $0; reachable = ($0 ~ /are still reachable/); next
  }
  inrec && /(at|by) 0x/ {
    if ($0 ~ /: <?(malloc|calloc|realloc|__gnat_malloc|__gnat_realloc)>? \(/ || $0 ~ /: <?(operator new|_Znw|_Zna)/) next
    if (!seen) {
      seen = 1
      if (reachable && $0 ~ /\047Elab_(Spec|Body) /) next
      if ($0 ~ /\(in [^)]*libfltkada[^)]*\)/ || $0 ~ /\((c_fl_[a-z_0-9]*\.cpp|fltk[a-z_0-9-]*\.ad[bs]):[0-9]+\)/ || $0 ~ /: fltk\./) { print rec; print; bad = 1 }
    }
    next
  }
  inrec && /^==[0-9]+== *$/ { inrec = 0 }
  END { exit bad }
' "$1"
