

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Command_Line,
    Interfaces.C;


package body FLTK.Args_Marshal is


    package ACom renames Ada.Command_Line;
    package IntC renames Interfaces.C;
    package ICS  renames Interfaces.C.Strings;


    --  A constrained array, allocated, so that valgrind sees the pointer to
    --  the start of its block, as it doesn't for an unconstrained array's
    --  data, after its bounds.
    type Argv_Array is array (0 .. IntC.size_t (ACom.Argument_Count) + 1) of ICS.chars_ptr;

    type Argv_Access is access Argv_Array;

    function Create_Argv
        return Argv_Access
    is
        Result : constant Argv_Access := new Argv_Array;
    begin
        Result (0) := ICS.New_String (ACom.Command_Name);
        for Index in Integer range 1 .. ACom.Argument_Count loop
            Result (IntC.size_t (Index)) := ICS.New_String (ACom.Argument (Index));
        end loop;
        Result (Result'Last) := ICS.Null_Ptr;
        return Result;
    end Create_Argv;

    The_Argv : constant Argv_Access := Create_Argv;


    function Argc
        return Interfaces.C.int is
    begin
        return IntC.int (The_Argv'Length - 1);
    end Argc;


    function Argv
        return Storage.Integer_Address is
    begin
        return Storage.To_Integer (The_Argv.all'Address);
    end Argv;


    procedure Dispatch
           (Func : in Show_With_Args_Func;
            CObj : in Storage.Integer_Address) is
    begin
        Func (CObj, Argc, Argv);
    end Dispatch;


end FLTK.Args_Marshal;


