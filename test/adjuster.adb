

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Adjuster test program functionality duplicated in Ada


with

    Ada.Command_Line,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Adjusters;


function Adjuster
    return Integer
is


    package ACom renames Ada.Command_Line;
    package BX renames FLTK.Widgets.Boxes;
    package DW renames FLTK.Widgets.Groups.Windows.Double;
    package AD renames FLTK.Widgets.Valuators.Adjusters;


    type My_Adjuster is new AD.Adjuster with record
        Rect : access BX.Box;
    end record;


    procedure Adjust_Callback
           (This : in out FLTK.Widgets.Widget'Class)
    is
        Just : My_Adjuster renames My_Adjuster (This);
    begin
        Just.Rect.Set_Label (Just.Format);
        Just.Rect.Redraw;
    end Adjust_Callback;


    The_Window : DW.Double_Window :=
        DW.Forge.Create (320, 100, ACom.Command_Name);

    Box_One : aliased BX.Box :=
        BX.Forge.Create (The_Window, FLTK.Down_Box, 20, 30, 80, 25);
    Just_One : My_Adjuster :=
       (AD.Forge.Create (The_Window, 20 + 80, 30, 3 * 25, 25)
        with Rect => Box_One'Access);

    Box_Two : aliased BX.Box :=
        BX.Forge.Create (The_Window, FLTK.Down_Box, 20 + 80 + 4 * 25, 30, 80, 25);
    Just_Two : My_Adjuster :=
       (AD.Forge.Create (The_Window, Box_Two.Get_X + Box_Two.Get_W, 10, 25, 3 * 25)
        with Rect => Box_Two'Access);


begin


    Box_One.Set_Background_Color (FLTK.White_Color);
    Just_One.Set_Callback (Adjust_Callback'Unrestricted_Access);
    Just_One.Do_Callback;

    Box_Two.Set_Background_Color (FLTK.White_Color);
    Just_Two.Set_Callback (Adjust_Callback'Unrestricted_Access);
    Just_Two.Do_Callback;

    The_Window.Set_Resizable (The_Window);
    The_Window.Show_With_Args;

    return FLTK.Run;


end Adjuster;


