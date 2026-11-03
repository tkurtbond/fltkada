

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Control_Strings is


    procedure Leak
           (Text : in String)
    is
        Copy : Interfaces.C.Strings.chars_ptr := Interfaces.C.Strings.New_String (Text);
        pragma Warnings (Off, Copy);  --  never freed, and that is the point
    begin
        --  Work after the allocation, as a binding's setter has, so that
        --  New_String isn't a tail call and valgrind sees Leak's frame.
        if Interfaces.C.Strings.Strlen (Copy) /= Text'Length then
            raise Program_Error;
        end if;
        Copy := Interfaces.C.Strings.Null_Ptr;
    end Leak;


end FLTK.Control_Strings;


