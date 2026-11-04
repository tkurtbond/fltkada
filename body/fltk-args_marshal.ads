

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


private package FLTK.Args_Marshal is


    --  The program's argc and argv, for Fl::arg, Fl::args and
    --  Fl_Window::show (argc, argv).  The argv is the program's name and
    --  arguments, then a null pointer, as C's argv has: FLTK reads argv[i+1]
    --  before checking i against argc (Fl_arg.cxx:177-178), so an option
    --  last on the line read past the array without it (FLTKAda-BUGS.md 61).
    --  It is made once and kept for the program's life, as C's is, since
    --  FLTK keeps pointers into it: the title, which becomes a window's
    --  label (Fl_arg.cxx:195, 313), and the colors (Fl_arg.cxx:200-207),
    --  which every show (argc, argv) reads again (Fl_arg.cxx:290,
    --  Fl_Screen_Driver.cxx:210-211) (FLTKAda-BUGS.md 62).
    function Argc
        return Interfaces.C.int;

    function Argv
        return Storage.Integer_Address;




    --  Used for implementing show(argc,argv)

    --  Dispatch calls Func with the program's argc and argv.

    type Show_With_Args_Func is access procedure
           (CObj : in Storage.Integer_Address;
            Argc : in Interfaces.C.int;
            Argv : in Storage.Integer_Address);

    procedure Dispatch
           (Func : in Show_With_Args_Func;
            CObj : in Storage.Integer_Address);


private


    pragma Convention (C, Show_With_Args_Func);


end FLTK.Args_Marshal;


