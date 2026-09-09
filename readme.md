
## FLTKAda

This is a thick, high level binding for the [FLTK](https://www.fltk.org/)
graphical widget library to the Ada programming language using only the
standard C FFI.

Types have been marshalled. Class hierarchies have been mapped to equivalent
packages and tagged records. Controlled types have been used to make allocation
and deallocation automatic for objects. Overrideable methods called from the
FLTK event loop have been thunked. Iterators have been implemented. And a few
convenience subprograms have been provided.

Some of the FLTK test and example programs have also been ported.

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

Note that at this time only FLTK 1.3 is supported.



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
    --build-name=relocatable --build-var=library_type

gprbuild -p -Xlibrary_type=static fltkada.gpr
gprinstall -p -m -Xlibrary_type=static fltkada.gpr \
    --build-name=static --build-var=library_type
```

A project that depends on the installed binding can then select which
library to link against with the same `-Xlibrary_type=static` or
`-Xlibrary_type=dynamic` switch.

For further information on the build tools, consult the
[GPRbuild docs](https://docs.adacore.com/gprbuild-docs/html/gprbuild_ug.html).



#### Technical Notes

As part of its normal operation, FLTK calls a Widget's Draw and Handle methods
from its main loop to deal with draw and input events. Since it's another part
of the program that is invoking them, even if it's a part the programmer has no
direct control over, this binding is set up so that if you override Draw or
Handle the behaviour will change.

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


