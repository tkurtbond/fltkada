

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Clock test program functionality reproduced in Ada


with

    FLTK.Static,
    FLTK.Widgets.Clocks.Updated.Round,
    FLTK.Widgets.Groups.Windows.Double;


function Clock
    return Integer
is


    package CL renames FLTK.Widgets.Clocks.Updated;
    package CR renames FLTK.Widgets.Clocks.Updated.Round;
    package WD renames FLTK.Widgets.Groups.Windows.Double;
    package Stc renames FLTK.Static;


    Window_One :          WD.Double_Window := WD.Forge.Create (220, 220, "Fl_Clock");
    Clock_One  : constant CL.Updated_Clock := CL.Forge.Create (Window_One, 0, 0, 220, 220);

    Window_Two :          WD.Double_Window := WD.Forge.Create (220, 220, "Fl_Round_Clock");
    Clock_Two  : constant CR.Round_Clock   := CR.Forge.Create (Window_Two, 0, 0, 220, 220);


    --  Closing either window hides both, and ends the program.
    procedure Close_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        while Stc.Get_First_Window /= null loop
            Stc.Get_First_Window.Hide;
        end loop;
    end Close_Callback;


begin


    Window_One.Set_Callback (Close_Callback'Unrestricted_Access);
    Window_Two.Set_Callback (Close_Callback'Unrestricted_Access);

    Window_One.Set_Resizable (Clock_One);
    Window_Two.Set_Resizable (Clock_Two);

    Window_One.Set_X_Class ("Fl_Clock");
    Window_Two.Set_X_Class ("Fl_Clock");

    Window_One.Show_With_Args;
    Window_Two.Show;

    return FLTK.Run;


end Clock;


