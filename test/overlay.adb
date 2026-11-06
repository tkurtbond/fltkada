--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/overlay.cxx: a red rectangle in a window's overlay, made
--  wider, narrower, taller and shorter by four buttons, or by the keys a,
--  b, c and d.  A colour number on the command line is used for the red.
--  X11 and Wayland have no true overlay, so FLTK draws the window again
--  under it.


with

    Ada.Command_Line,
    Interfaces.C.Strings,
    FLTK.Draw,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double.Overlay;

use type

    FLTK.Color;


function Overlay
    return Integer
is


    package Drw renames FLTK.Draw;
    package Stc renames FLTK.Static;
    package Wdg renames FLTK.Widgets;
    package Btn renames FLTK.Widgets.Buttons;
    package Ovl renames FLTK.Widgets.Groups.Windows.Double.Overlay;


    Width, Height : Integer := 10;


    type Overlaid is new Ovl.Overlay_Window with null record;

    overriding procedure Draw_Overlay
           (This : in out Overlaid);

    procedure Draw_Overlay
           (This : in out Overlaid) is
    begin
        Drw.Set_Color (FLTK.Red_Color);
        Drw.Rect ((This.Get_W - Width) / 2, (This.Get_H - Height) / 2, Width, Height);
    end Draw_Overlay;


    Window : Overlaid := (Ovl.Forge.Create (400, 400) with null record);


    procedure Wider
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Width := Width + 20;
        Window.Redraw_Overlay;
    end Wider;

    procedure Narrower
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Width := Width - 20;
        Window.Redraw_Overlay;
    end Narrower;

    procedure Taller
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Height := Height + 20;
        Window.Redraw_Overlay;
    end Taller;

    procedure Shorter
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Height := Height - 20;
        Window.Redraw_Overlay;
    end Shorter;


    --  C's atoi, as the C++ reads the number with, so that the same
    --  arguments give the same colour.
    function C_Atoi
           (Text : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.int
    with Import, Convention => C, External_Name => "atoi";

    --  A number other than 0 is the colour to use for red.  The C++ makes
    --  it an Fl_Color, which is unsigned, so a negative number is a colour
    --  too.
    function Arg
           (Index : in Positive)
        return Natural
    is
        Text   : Interfaces.C.Strings.chars_ptr :=
            Interfaces.C.Strings.New_String (Ada.Command_Line.Argument (Index));
        Number : constant FLTK.Color := FLTK.Color'Mod (C_Atoi (Text));
        R, G, B : FLTK.Color_Component;
    begin
        Interfaces.C.Strings.Free (Text);
        if Number = 0 then
            return 0;
        end if;
        Stc.Get_Color (Number, R, G, B);
        Stc.Set_Color (FLTK.Red_Color, R, G, B);
        return 1;
    end Arg;


    B1 : Btn.Button := Btn.Forge.Create (Window, 50, 50, 100, 100, "wider" & ASCII.LF & "(a)");
    B2 : Btn.Button :=
        Btn.Forge.Create (Window, 250, 50, 100, 100, "narrower" & ASCII.LF & "(b)");
    B3 : Btn.Button := Btn.Forge.Create (Window, 50, 250, 100, 100, "taller" & ASCII.LF & "(c)");
    B4 : Btn.Button :=
        Btn.Forge.Create (Window, 250, 250, 100, 100, "shorter" & ASCII.LF & "(d)");

    Count : Natural;


begin


    --  Fl::args with a handler, as the C++ calls it, stops at an argument
    --  it doesn't know, and says nothing.
    begin
        Stc.Parse_Args (Count, Arg'Unrestricted_Access);
    exception
    when Stc.Argument_Error =>
        null;
    end;

    B1.Set_Callback (Wider'Unrestricted_Access);
    B1.Set_Shortcut (FLTK.Press ('a'));
    B2.Set_Callback (Narrower'Unrestricted_Access);
    B2.Set_Shortcut (FLTK.Press ('b'));
    B3.Set_Callback (Taller'Unrestricted_Access);
    B3.Set_Shortcut (FLTK.Press ('c'));
    B4.Set_Callback (Shorter'Unrestricted_Access);
    B4.Set_Shortcut (FLTK.Press ('d'));

    Window.Set_Resizable (Window);
    Window.Show_With_Args;
    Window.Redraw_Overlay;
    return FLTK.Run;


end Overlay;
