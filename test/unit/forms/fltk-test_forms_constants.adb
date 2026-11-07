--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.
--
--  Written by tools/gen-constants.py; edit that, not this.


--  Checks each of FLTKAda's constants against FLTK's value, from
--  c_forms_constants.cpp.  A child of FLTK, so it can see the private
--  conversions.  Run by test_forms_constants.adb.


with

    Checks,
    FLTK.Widgets.Forms.Frees,
    FLTK.Widgets.Forms.Timers;


procedure FLTK.Test_Forms_Constants is


    package Frees renames FLTK.Widgets.Forms.Frees;
    package Timers renames FLTK.Widgets.Forms.Timers;


    type Value_Array is array (1 .. 8) of Long_Long_Integer;
    pragma Convention (C, Value_Array);

    FLTK_Values : Value_Array;
    pragma Import (C, FLTK_Values, "c_forms_constants");


    procedure Same
           (Ada_Value : in Long_Long_Integer;
            Index     : in Positive;
            Label     : in String)
    is
        FLTK_Value : constant Long_Long_Integer := FLTK_Values (Index);
    begin
        if Ada_Value = FLTK_Value then
            Checks.Check (True, Label & " =" & Long_Long_Integer'Image (FLTK_Value));
        else
            Checks.Check
               (False, Label & ": FLTKAda has" & Long_Long_Integer'Image (Ada_Value) &
                ", FLTK" & Long_Long_Integer'Image (FLTK_Value));
        end if;
    end Same;


begin

    --  Timer kinds (Fl_Timer::type)
    Same
       (Timers.Timer_Kind'Pos (Timers.Normal_Timer),
        1,
        "Timers.Timer_Kind'Pos (Timers.Normal_Timer) = FL_NORMAL_TIMER");
    Same
       (Timers.Timer_Kind'Pos (Timers.Value_Timer),
        2,
        "Timers.Timer_Kind'Pos (Timers.Value_Timer) = FL_VALUE_TIMER");
    Same
       (Timers.Timer_Kind'Pos (Timers.Hidden_Timer),
        3,
        "Timers.Timer_Kind'Pos (Timers.Hidden_Timer) = FL_HIDDEN_TIMER");

    --  Free kinds (Fl_Free::type); a representation clause gives FLTK's values
    Same
       (Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.Normal_Free)),
        4,
        "Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.Normal_Free)) = FL_NORMAL_FREE");
    Same
       (Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.Sleeping_Free)),
        5,
        "Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.Sleeping_Free)) = FL_SLEEPING_FREE");
    Same
       (Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.Input_Free)),
        6,
        "Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.Input_Free)) = FL_INPUT_FREE");
    Same
       (Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.Continuous_Free)),
        7,
        "Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.Continuous_Free))" &
        " = FL_CONTINUOUS_FREE");
    Same
       (Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.All_Free)),
        8,
        "Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.All_Free)) = FL_ALL_FREE");

end FLTK.Test_Forms_Constants;
