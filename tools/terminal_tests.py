#!/usr/bin/env python3

#  Programmed by T. Kurt Bond and Claude Opus 5.5
#  Released into the public domain

#  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
#  author releases this derived work into the public domain, as FLTKAda is.

"""Writes test/terminal_tests.ads: the escape sequence tests of FLTK's
test/terminal.cxx, for test/terminal.adb.

Each test is an array of strings, one per element of its test[] array,
the element's string literals joined and its C escapes turned into
Ada's (ASCII.ESC and so on).  The first page, test_firstpage, is one
element.  UTF-8 is kept as it is: GNAT reads the source as Latin-1 and
keeps the bytes.

Run it from the repository root, with FLTK's source:

    python3 tools/terminal_tests.py [path/to/fltk/test/terminal.cxx]
"""

import re
import sys

SOURCE = "/usr/local/sw/src/lang/C++/fltk/fltk-1.4.5/test/terminal.cxx"
OUTPUT = "test/terminal_tests.ads"


def tokens(text):
    """The string literals, commas, parentheses and NULLs of text, with
    comments skipped."""
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if text.startswith("//", i):
            i = text.index("\n", i)
        elif text.startswith("/*", i):
            i = text.index("*/", i) + 2
        elif c == '"':
            j = i + 1
            while text[j] != '"':
                j += 2 if text[j] == "\\" else 1
            yield ("str", text[i + 1:j])
            i = j + 1
        elif c in ",();{}":
            yield (c, c)
            i += 1
        elif text.startswith("NULL", i):
            yield ("NULL", "NULL")
            i += 4
        else:
            i += 1


def elements(body):
    """The elements of a list of joined string literals, ending at NULL or
    the list's close."""
    out, cur = [], None
    for kind, val in tokens(body):
        if kind == "str":
            cur = (cur or "") + val
        elif kind in (",", ")", "NULL", "}"):
            if cur is not None:
                out.append(cur)
                cur = None
            if kind != ",":
                break
    return out


NAMED = {"033": "ASCII.ESC", "n": "ASCII.LF", "t": "ASCII.HT",
         "b": "ASCII.BS", "r": "ASCII.CR"}
RAW = {"\x1b": "ASCII.ESC", "\t": "ASCII.HT"}
PLAIN = {"\\": "\\", '"': '""', "'": "'"}


def pieces(element, where):
    """The element as a list of Ada pieces: string literal texts (quoted)
    and character names."""
    out, lit = [], ""
    i = 0
    while i < len(element):
        c = element[i]
        if c != "\\" and " " <= c and c != "\x7f":
            lit += c
            i += 1
            continue
        if c != "\\":
            #  A raw control character in FLTK's literal (one raw ESC)
            if lit:
                out.append(lit)
                lit = ""
            out.append(RAW.get(c, "Character'Val (%d)" % ord(c)))
            i += 1
            continue
        esc = element[i + 1:i + 4] if element[i + 1:i + 4] == "033" \
            else element[i + 1]
        if esc in PLAIN:
            lit += PLAIN[esc]
        elif esc in NAMED:
            if lit:
                out.append(lit)
                lit = ""
            out.append(NAMED[esc])
        else:
            sys.exit("%s: the escape \\%s isn't handled" % (where, esc))
        i += 1 + len(esc)
    if lit:
        out.append(lit)
    return out


def chunks(lit, size=48):
    """lit in pieces of at most size bytes of UTF-8, not splitting a
    character or a doubled quote."""
    out, cur, n, i = [], "", 0, 0
    while i < len(lit):
        c = lit[i:i + 2] if lit.startswith('""', i) else lit[i]
        b = len(c.encode("utf-8"))
        if n + b > size:
            out.append(cur)
            cur, n = "", 0
        cur += c
        n += b
        i += len(c)
    out.append(cur)
    return out


def expression(element, where):
    """The Ada lines of element's value, the first after ":= "."""
    items = []
    for p in pieces(element, where):
        if p.startswith(("ASCII.", "Character'Val")):
            items.append(p)
        else:
            items.extend('"%s"' % c for c in chunks(p))
    if not items:
        items = ['""']
    elif len(items) == 1 and not items[0].startswith('"'):
        items = ["(1 => %s)" % items[0]]  # a lone character
    lines, cur = [], items[0]
    for item in items[1:]:
        if len((cur + " & " + item).encode("utf-8")) > 72:
            lines.append(cur)
            cur = "& " + item
        else:
            cur += " & " + item
    lines.append(cur)
    return lines


def main():
    src = open(sys.argv[1] if len(sys.argv) > 1 else SOURCE,
               encoding="utf-8").read()
    order = re.search(r"static TestFunc \*tests\[\] = \{(.*?)\};", src, re.S)
    names = re.findall(r"\b(test_\w+)", re.sub(r"//.*", "", order.group(1)))
    out = ["--  Programmed by T. Kurt Bond and Claude Opus 5.5",
           "--  Released into the public domain", "",
           "--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose",
           "--  author releases this derived work into the public domain, as FLTKAda is.",
           "", "",
           "--  The escape sequence tests of FLTK 1.4.5's test/terminal.cxx, for",
           "--  terminal.adb.  Generated by tools/terminal_tests.py: don't edit.",
           "", "",
           "package Terminal_Tests is", "", "",
           "    type String_Access is access constant String;",
           "    type Test is array (Positive range <>) of String_Access;",
           "    type Test_Access is access constant Test;", ""]
    tables = []
    for t, name in enumerate(names, 1):
        m = re.search(r"int Application::%s\(bool reset\) \{" % name, src)
        rest = src[m.end():]
        if name == "test_firstpage":
            body = rest[rest.index("AppendTty(") + len("AppendTty("):]
        else:
            body = rest[rest.index("test[] = {") + len("test[] = {"):]
        els = elements(body)
        ada = name[len("test_"):].title()
        out.append("")
        out.append("    --  %s  --" % name)
        out.append("")
        refs = []
        for e, element in enumerate(els, 1):
            ident = "%s_%d" % (ada, e)
            refs.append(ident)
            lines = expression(element, "%s %d" % (name, e))
            out.append("    %s : aliased constant String :=" % ident)
            for k, line in enumerate(lines):
                end = ";" if k == len(lines) - 1 else ""
                out.append("        " + line + end)
            out.append("")
        out.append("    %s : aliased constant Test :=" % ada)
        if len(refs) == 1:
            out.append("        (1 => %s'Access);" % refs[0])
        else:
            for k, r in enumerate(refs):
                pre = "       (" if k == 0 else "        "
                end = ");" if k == len(refs) - 1 else ","
                out.append("%s%s'Access%s" % (pre, r, end))
        tables.append(ada)
        out.append("")
    out.append("")
    out.append("    --  In the order of terminal.cxx's tests[].")
    out.append("    Tests : constant array (1 .. %d) of Test_Access :=" % len(tables))
    for k, a in enumerate(tables):
        pre = "       (" if k == 0 else "        "
        end = ");" if k == len(tables) - 1 else ","
        out.append("%s%s'Access%s" % (pre, a, end))
    out += ["", "", "end Terminal_Tests;", ""]
    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("\n".join(out))
    print("%s: %d tests" % (OUTPUT, len(names)))


if __name__ == "__main__":
    main()
