


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Extending a widget, after pofltk's examples/Swatch.Mod:  a box with its
--  own Draw, and a button whose callback changes it.
--
--  The swatch fills itself with its colour and writes on it.  The button
--  moves it to the next of FLTK's first eight colours, and asks for a
--  redraw.


with

    FLTK.Draw,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;


function Swatch
    return Integer
is


    package Drw renames FLTK.Draw;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;


    --  FLTK's first eight colours, Black_Color to White_Color.
    type Hue_Index is mod 8;


    type Swatch_Box is new Bx.Box with record
        Hue : Hue_Index := 1;  --  red
    end record;

    overriding procedure Draw
           (This : in out Swatch_Box);


    procedure Draw
           (This : in out Swatch_Box)
    is
        Hue : constant FLTK.Color := FLTK.Color (This.Hue);
    begin
        Drw.Set_Color (Hue);
        Drw.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        Drw.Set_Color (FLTK.Contrast (FLTK.Black_Color, Hue));
        Drw.Set_Font (FLTK.Helvetica, 14);
        Drw.Draw_Text (This.Get_X + 10, This.Get_Y + 20, "drawn by Ada");
    end Draw;


    Window : Win.Window := Win.Forge.Create (320, 200, "Swatch");
    Sample : Swatch_Box := (Bx.Forge.Create (Window, 10, 10, 300, 120) with others => <>);
    Next   : Btn.Button := Btn.Forge.Create (Window, 10, 140, 300, 40, "Next colour");


    procedure Next_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Sample.Hue := Sample.Hue + 1;
        Sample.Redraw;
    end Next_CB;


begin


    Next.Set_Callback (Next_CB'Unrestricted_Access);
    Window.Show;

    return FLTK.Run;


end Swatch;


