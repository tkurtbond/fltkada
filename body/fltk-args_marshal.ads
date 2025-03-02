

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


private package FLTK.Args_Marshal is


    function Create_Argv
        return Interfaces.C.Strings.chars_ptr_array;

    procedure Free_Argv
           (Argv : in out Interfaces.C.Strings.chars_ptr_array);




    --  Used for implementing show(argc,argv)

    --  Dispatch marshalls the data, calls the function, then does cleanup

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


