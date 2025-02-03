

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Hello, World! program functionality reproduced in Ada


with

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;


function Hello
    return Integer
is


    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;


    The_Window : Win.Window := Win.Forge.Create (340, 180);

    The_Box : Bx.Box := Bx.Forge.Create (The_Window, 20, 40, 300, 100, "Hello, World!");


begin


    The_Box.Set_Box (FLTK.Up_Box);
    The_Box.Set_Label_Font (FLTK.Helvetica_Bold_Italic);
    The_Box.Set_Label_Size (36);
    The_Box.Set_Label_Kind (FLTK.Shadow_Label);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Hello;


