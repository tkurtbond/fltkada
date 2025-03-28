
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

There is a single build switch of `-Xbuild` which can have a value of `release`
(the default) or `debug`. The other project files in the main directory can be
used with similar build commands to build tests, examples, and tools.

To install the binding, use

`gprinstall -p -m fltkada.gpr`

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



#### Credits and Licensing

Written by Jedidiah Barber.

Released into the public domain. For details see `unlicense.txt`.


