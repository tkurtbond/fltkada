

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Errors is


    procedure fl_error_default_warning
           (M : in Interfaces.C.char_array);
    pragma Import (C, fl_error_default_warning, "fl_error_default_warning");
    pragma Inline (fl_error_default_warning);

    procedure fl_error_default_error
           (M : in Interfaces.C.char_array);
    pragma Import (C, fl_error_default_error, "fl_error_default_error");
    pragma Inline (fl_error_default_error);

    procedure fl_error_default_fatal
           (M : in Interfaces.C.char_array);
    pragma Import (C, fl_error_default_fatal, "fl_error_default_fatal");
    pragma Inline (fl_error_default_fatal);

    procedure fl_error_set_hooks;
    pragma Import (C, fl_error_set_hooks, "fl_error_set_hooks");
    pragma Inline (fl_error_set_hooks);




    procedure Warning_Hook
           (C_Mess : in Interfaces.C.Strings.chars_ptr);
    pragma Export (C, Warning_Hook, "error_warning_hook");

    procedure Warning_Hook
           (C_Mess : in Interfaces.C.Strings.chars_ptr) is
    begin
        Current_Warning (Interfaces.C.Strings.Value (C_Mess));
    end Warning_Hook;


    procedure Error_Hook
           (C_Mess : in Interfaces.C.Strings.chars_ptr);
    pragma Export (C, Error_Hook, "error_error_hook");

    procedure Error_Hook
           (C_Mess : in Interfaces.C.Strings.chars_ptr) is
    begin
        Current_Error (Interfaces.C.Strings.Value (C_Mess));
    end Error_Hook;


    procedure Fatal_Hook
           (C_Mess : in Interfaces.C.Strings.chars_ptr);
    pragma Export (C, Fatal_Hook, "error_fatal_hook");

    procedure Fatal_Hook
           (C_Mess : in Interfaces.C.Strings.chars_ptr) is
    begin
        Current_Fatal (Interfaces.C.Strings.Value (C_Mess));
    end Fatal_Hook;




    procedure Default_Warning
           (Message : in String) is
    begin
        fl_error_default_warning (Interfaces.C.To_C (Message));
    end Default_Warning;


    procedure Default_Error
           (Message : in String) is
    begin
        fl_error_default_error (Interfaces.C.To_C (Message));
    end Default_Error;


    procedure Default_Fatal
           (Message : in String) is
    begin
        fl_error_default_fatal (Interfaces.C.To_C (Message));
    end Default_Fatal;


begin


    fl_error_set_hooks;


end FLTK.Errors;


