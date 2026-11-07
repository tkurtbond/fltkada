

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK.Environment.Plugins, after pofltk's examples/Plugins.Mod:  two
--  plugins, found by their class and run, when the program knows only the
--  class.  A plugin is an object of the program's own type, here a Painter,
--  opened under a class and a name.  The browser and the canvas find them
--  through a Plugin_Manager of the class, by number or by name, and know
--  nothing of Circle and Cross.  These two are opened here; a library
--  loaded with Plugins.Load would make its own as it loaded.


with

    FLTK.Draw,
    FLTK.Environment.Plugins,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Windows.Double;


function Plugins
    return Integer
is


    package Bx  renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Hld renames FLTK.Widgets.Groups.Browsers.Textline.Hold;
    package Plg renames FLTK.Environment.Plugins;


    Class : constant String := "painter";


    package Painters_Of is

        type Painter is abstract new Plg.Plugin with null record;

        procedure Paint
               (This       : in Painter;
                X, Y, W, H : in Integer) is abstract;


        type Circle is new Painter with null record;

        overriding procedure Paint
               (This       : in Circle;
                X, Y, W, H : in Integer);


        type Cross is new Painter with null record;

        overriding procedure Paint
               (This       : in Cross;
                X, Y, W, H : in Integer);

    end Painters_Of;

    use Painters_Of;


    --  Chosen is the plugin's number in its class; 0 for none.
    type Canvas is new Bx.Box with record
        Chosen : Natural := 0;
    end record;

    overriding procedure Draw
           (This : in out Canvas);


    Painters : constant Plg.Plugin_Manager := Plg.Forge.Create (Class);


    package body Painters_Of is

        procedure Paint
               (This       : in Circle;
                X, Y, W, H : in Integer)
        is
            pragma Unreferenced (This);
        begin
            FLTK.Draw.Set_Color (FLTK.Red_Color);
            FLTK.Draw.Pie (X + 10, Y + 10, W - 20, H - 20, 0.0, 360.0);
        end Paint;


        procedure Paint
               (This       : in Cross;
                X, Y, W, H : in Integer)
        is
            pragma Unreferenced (This);
        begin
            FLTK.Draw.Set_Color (FLTK.Blue_Color);
            FLTK.Draw.Line (X + 10, Y + 10, X + W - 11, Y + H - 11);
            FLTK.Draw.Line (X + 10, Y + H - 11, X + W - 11, Y + 10);
        end Paint;

    end Painters_Of;


    procedure Draw
           (This : in out Canvas) is
    begin
        FLTK.Draw.Set_Color (FLTK.White_Color);
        FLTK.Draw.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        if This.Chosen /= 0 then
            Painter'Class (Painters.Plugin_At (This.Chosen).all).Paint
               (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        end if;
    end Draw;


    The_Circle : Circle;
    The_Cross  : Cross;

    Window : Dbl.Double_Window := Dbl.Forge.Create (340, 200, "Plugins");
    List   : Hld.Hold_Browser := Hld.Forge.Create (Window, 10, 10, 120, 180);
    Area   : Canvas := (Bx.Forge.Create (Window, 140, 10, 190, 180) with Chosen => 0);


    --  The plugin of the line chosen, whichever it is.
    procedure Chosen
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Area.Chosen := List.Selected_Index;
        Area.Redraw;
    end Chosen;


begin


    The_Circle.Open (Class, "circle");
    The_Cross.Open (Class, "cross");

    for I in 1 .. Painters.Number_Of_Plugins loop
        List.Add (Painters.Plugin_Name (I));
    end loop;
    List.Set_Callback (Chosen'Unrestricted_Access);

    Window.Set_Resizable (Area);
    Window.Show;

    return FLTK.Run;


end Plugins;
