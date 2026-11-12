

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Button/callback test program functionality reproduced in Ada


with

    Ada.Command_Line,
    FLTK.Asks,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;


function Button
    return Integer
is


    package ACom renames Ada.Command_Line;

    package Ask renames FLTK.Asks;
    package Wdg renames FLTK.Widgets;
    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;


    procedure Beep_Callback
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Ask.Beep;
    end Beep_Callback;


    The_Window : Win.Window := Win.Forge.Create (320, 65);


    procedure Exit_Callback
           (Ignore : in out Wdg.Widget'Class) is
    begin
        ACom.Set_Exit_Status (ACom.Success);
        The_Window.Hide;
    end Exit_Callback;


    Button_One   : Btn.Button := Btn.Forge.Create (The_Window,  20, 20, 80, 25, "&Beep");
    Button_Two   : Btn.Button := Btn.Forge.Create (The_Window, 120, 20, 80, 25, "&no op");
    Button_Three : Btn.Button := Btn.Forge.Create (The_Window, 220, 20, 80, 25, "E&xit");


begin


    Button_One.Set_Callback   (Beep_Callback'Unrestricted_Access);
    Button_Three.Set_Callback (Exit_Callback'Unrestricted_Access);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Button;


