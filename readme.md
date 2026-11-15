
## FLTKAda

This is a thick, high level binding for the [FLTK](https://www.fltk.org/)
graphical widget library to the Ada programming language using only the
standard C FFI.

Types have been marshalled. Class hierarchies have been mapped to equivalent
packages and tagged records. Controlled types have been used to make allocation
and deallocation automatic for objects. Overrideable methods called from the
FLTK event loop have been thunked. Iterators have been implemented. And a few
convenience subprograms have been provided.

Some of the FLTK test and example programs have also been ported. All of the
programs in FLTK 1.4.5's own `examples` directory have been ported to Ada in
the `examples` subdirectory; build them with `gprbuild examples.gpr`, and they
will be placed in `bin/examples`, named after the C++ originals.

For documentation on what C++ function, method, or class corresponds to what
Ada function, procedure, or package, see `index.html` in the `doc`
subdirectory.



#### Dependencies

Build time:
<ul>
  <li>FLTK</li>
  <li>g++</li>
  <li>GNAT</li>
  <li>GPRbuild</li>
</ul>

Run time:
<ul>
  <li>FLTK</li>
</ul>

It may be possible to use alternate compilation tooling but this has not been
tested. If attempted, some manual modification of project files may be
necessary.

FLTKAda targets FLTK 1.4.5. It binds classes that first appeared in FLTK 1.4
(such as `Fl_Flex`, `Fl_Grid` and `Fl_Terminal`), so it will not build against
FLTK 1.3.



#### Building and Installation

This repository is written to use the GNAT Project Manager build tools. To
build, use the following command

`gprbuild fltkada.gpr`

There is a build switch of `-Xbuild` which can have a value of `release`
(the default) or `debug`. The other project files in the main directory can be
used with similar build commands to build tests, examples, and tools.

By default the binding is built as a shared library. To build a static
library instead, add `-Xlibrary_type=static` (the default is `dynamic`):

`gprbuild -Xlibrary_type=static fltkada.gpr`

To install the binding, use

`gprinstall -p -m fltkada.gpr`

This installs whichever library kind was last built. To install both the
static and dynamic libraries side by side, build and install each with a
distinct `--build-name`, sharing `library_type` as the installed project's
build-selection variable via `--build-var`:

```
gprbuild -p -Xlibrary_type=dynamic fltkada.gpr
gprinstall -p -m -Xlibrary_type=dynamic fltkada.gpr \
    --build-name=dynamic --build-var=library_type

gprbuild -p -Xlibrary_type=static fltkada.gpr
gprinstall -p -m -Xlibrary_type=static fltkada.gpr \
    --build-name=static --build-var=library_type
```

The Makefile's `install-dynamic` and `install-static` targets do each
pair, passing `-f` so a reinstall replaces the files already installed;
`GPRINSTALL` gives the installer and its options
(`make install-dynamic GPRINSTALL="gprinstall --prefix=DIR"`).

A project that depends on the installed binding can then select which
library to link against with the same `-Xlibrary_type=static` or
`-Xlibrary_type=dynamic` switch.

For further information on the build tools, consult the
[GPRbuild docs](https://docs.adacore.com/gprbuild-docs/html/gprbuild_ug.html).



#### Testing

The test and demonstration programs are built by these project files:

```
gprbuild tests.gpr        # demos and FLTK test ports, in bin/
gprbuild tests_2022.gpr   # the ones that need Ada 2022, in bin/
gprbuild tests_unit.gpr   # the unit tests, in bin/unit/
gprbuild examples.gpr     # ports of FLTK's examples/, in bin/examples/
```

The Makefile builds them all and runs them:

| Target | What it does |
|---|---|
| `make check` | The unit tests in `test/unit`, and the programs in `test/` that check their own results. Fails if any fails. |
| `make valgrind` | The same under valgrind. A memory error fails a test, and so does a leak of memory FLTKAda allocated (`test/vg-check.sh`); FLTK and the libraries under it leak some by design. |
| `make smoke` | Starts every program in `bin/` and `bin/examples/`, and checks that it is still running a few seconds later, or ends by itself with status 0. |
| `make check-headless`, `valgrind-headless`, `smoke-headless` | The same, on a virtual X server (`xvfb-run`, with the X11 back end), with `WAYLAND_DISPLAY` unset and an empty `XDG_RUNTIME_DIR` of their own, since FLTK otherwise tries a `wayland-0` there. |
| `make check-sway`, `valgrind-sway`, `smoke-sway` | The same, on a headless sway, a Wayland compositor with no screen (`tools/with-sway.sh`). |
| `make check-desktop` | The few tests only a person can answer, such as the native file chooser and print dialog. They open on the desktop and wait. |

The plain `check`, `valgrind` and `smoke` targets use whatever display
is set, so their windows open on your desktop, where your typing and
clicks can disturb them. The `-headless` targets need Xvfb (`xvfb-run`),
the `-sway` targets need sway, and the `valgrind` ones need valgrind.
`TIMEOUT` (default 60) sets the seconds a test may run before it counts
as hung.



#### Technical Notes

As part of its normal operation, FLTK calls a Widget's Draw and Handle methods
from its main loop to deal with draw and input events, and its Resize method
as a window or group lays out its children. Since it's another part of the
program that is invoking them, even if it's a part the programmer has no direct
control over, this binding is set up so that if you override Draw, Handle or
Resize the behaviour will change.

On the other hand, something like the Push method in tabbed groups is usually
invoked from within that same tabbed group widget's Handle method. Therefore,
keeping consistency with Ada semantics, overriding the Push method will NOT
change the behaviour of the corresponding Handle method. You must also override
Handle.

#### Portability Notes

To compile this on NetBSD using the RavenPorts GNAT, first set the
following environment variables so it will compile:

``` bash
export CPATH=/usr/pkg/include
export LIBRARY_PATH=/usr/pkg/lib
```

There are a bunch of link errors about "reference to compatibility X"
where X is socket or __kevent50(), etc., but I haven't figured those
out yet.

Before running any of the test programs, you have to set the following
environment variable:

``` bash
export LIBRARY_PATH=/usr/pkg/lib
```

#### Credits and Licensing

Written by Jedidiah Barber.

Released into the public domain. For details see `unlicense.txt`.

Some tests, tools and examples are derived from pofltk, the Oberon-2 FLTK
binding by T. Kurt Bond, which is under the BSD 3-Clause license. Its
author releases those derived files into the public domain like the rest
of FLTKAda; each says so in its header.


