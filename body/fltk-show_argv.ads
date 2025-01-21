

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


private package FLTK.Show_Argv is


    --  Used for implementing show(argc,argv)

    type Show_With_Args_Func is access procedure
           (CObj : in Storage.Integer_Address;
            Argc : in Interfaces.C.int;
            Argv : in Storage.Integer_Address);

    procedure Dispatch
           (Func : in Show_With_Args_Func;
            CObj : in Storage.Integer_Address);


private


    pragma Convention (C, Show_With_Args_Func);


end FLTK.Show_Argv;


