

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Command_Line,
    Interfaces.C.Strings;


package body FLTK.Args_Marshal is


    package ACom renames Ada.Command_Line;
    package IntC renames Interfaces.C;
    package ICS  renames Interfaces.C.Strings;


    function Create_Argv
        return ICS.chars_ptr_array
    is
        Result : ICS.chars_ptr_array (0 .. IntC.size_t (ACom.Argument_Count));
    begin
        Result (0) := ICS.New_String (ACom.Command_Name);
        for Index in Integer range 1 .. ACom.Argument_Count loop
            Result (IntC.size_t (Index)) := ICS.New_String (ACom.Argument (Index));
        end loop;
        return Result;
    end Create_Argv;


    procedure Free_Argv
           (Argv : in out Interfaces.C.Strings.chars_ptr_array) is
    begin
        for Ptr of Argv loop
            ICS.Free (Ptr);
        end loop;
    end Free_Argv;


    procedure Dispatch
           (Func : in Show_With_Args_Func;
            CObj : in Storage.Integer_Address)
    is
        Argv : ICS.chars_ptr_array := Create_Argv;
    begin
        Func (CObj, Argv'Length, Storage.To_Integer (Argv (Argv'First)'Address));
        Free_Argv (Argv);
    end Dispatch;


end FLTK.Args_Marshal;


