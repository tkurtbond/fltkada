

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/howto-draw-an-x.cxx: a plain widget
--  subclass whose overriding Draw paints a white background with a
--  black 'X' over it.


with

    FLTK.Draw,
    FLTK.Widgets,
    FLTK.Widgets.Groups.Windows.Double;


function Howto_Draw_An_X
    return Integer
is


    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Wdg renames FLTK.Widgets;


    type Draw_X is new Wdg.Widget with null record;

    overriding procedure Draw
           (This : in out Draw_X);

    procedure Draw
           (This : in out Draw_X)
    is
        X1 : constant Integer := This.Get_X;
        Y1 : constant Integer := This.Get_Y;
        X2 : constant Integer := This.Get_X + This.Get_W - 1;
        Y2 : constant Integer := This.Get_Y + This.Get_H - 1;
    begin
        --  Draw background - a white filled rectangle
        FLTK.Draw.Set_Color (FLTK.White_Color);
        FLTK.Draw.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        --  Draw black 'X' over base widget's background
        FLTK.Draw.Set_Color (FLTK.Black_Color);
        FLTK.Draw.Line (X1, Y1, X2, Y2);
        FLTK.Draw.Line (X1, Y2, X2, Y1);
    end Draw;


    The_Window : Dbl.Double_Window := Dbl.Forge.Create (200, 200, "Draw X");

    Win_W : constant Integer := The_Window.Get_W;
    Win_H : constant Integer := The_Window.Get_H;

    --  put our widget 10 pixels within window edges
    The_X : Draw_X :=
        (Wdg.Forge.Create (The_Window, 10, 10, Win_W - 20, Win_H - 20) with null record);


begin


    The_X.Set_Background_Color (FLTK.White_Color);   --  make widget's background white
    The_Window.Set_Resizable (The_X);
    The_Window.Show;

    return FLTK.Run;


end Howto_Draw_An_X;
