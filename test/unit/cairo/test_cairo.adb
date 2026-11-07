

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK.Cairo and Cairo_Drawn_Window:  windows drawn with cairo, their
--  contexts, and gradients, after pofltk's TestCairo and its halt tests.
--  HaltCairoStale and HaltCairoClosed are Raises checks here.
--  HaltCairoAntialias, HaltCairoSlant and HaltCairoExtend, a mode cairo
--  hasn't, can't be written in Ada:  the modes are enumerations.
--  HaltCairoNil, a null pattern, can't either:  Set_Source takes a
--  Pattern'Class, not an access.


with

    Ada.Numerics,
    Checks,
    FLTK.Cairo,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;

use

    Checks;


procedure Test_Cairo is

    package Bx  renames FLTK.Widgets.Boxes;
    package Cai renames FLTK.Cairo;
    package CDW renames FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Prb.RGB;


    Red   : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Green : constant Prb.RGB := Prb.To_RGB (0, 255, 0);
    Blue  : constant Prb.RGB := Prb.To_RGB (0, 0, 255);
    White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);

    --  Of waits, so that valgrind has time.
    Limit : constant := 500;

    Ignore_Time : Long_Float;


    --  A window that counts its draws.
    type Counted is new CDW.Cairo_Drawn_Window with record
        Draws : Natural := 0;
    end record;

    --  Waits until Item has drawn more than Before times, then lets FLTK
    --  finish the flush that drew it.
    procedure Wait
           (Item   : in Counted'Class;
            Before : in Natural)
    is
        Ignore : Boolean;
    begin
        for I in 1 .. Limit loop
            exit when Item.Draws /= Before;
            Ignore_Time := FLTK.Wait (0.01);
        end loop;
        Ignore := FLTK.Check;
    end Wait;


    --  Whether Color is within 12 of R, G, B, in each.
    function Near
           (Color   : in Prb.RGB;
            R, G, B : in Integer)
        return Boolean is
    begin
        return Color >= 0
            and then abs (Color / 16#1_0000# mod 256 - R) <= 12
            and then abs (Color / 16#100# mod 256 - G) <= 12
            and then abs (Color mod 256 - B) <= 12;
    end Near;




    --  Halves  --

    --  Red on its left half and blue on its right.
    type Halves is new Counted with null record;

    overriding procedure Draw_Cairo
           (This    : in out Halves;
            Context : in     Cai.Context)
    is
        W : constant Long_Float := Long_Float (This.Get_W / 2);
    begin
        This.Draws := This.Draws + 1;
        Cai.Set_Source_RGB (Context, 1.0, 0.0, 0.0);
        Cai.Rectangle (Context, 0.0, 0.0, W, Long_Float (This.Get_H));
        Cai.Fill (Context);
        Cai.Set_Source_RGB (Context, 0.0, 0.0, 1.0);
        Cai.Rectangle (Context, W, 0.0, Long_Float (This.Get_W) - W, Long_Float (This.Get_H));
        Cai.Fill (Context);
    end Draw_Cairo;


    procedure Test_Halves is
        Window : Halves := (CDW.Forge.Create (100, 60, "cairo") with others => <>);
        Kid    : Bx.Box := Bx.Forge.Create (Window, FLTK.Flat_Box, 0, 0, 100, 60);
        Before : Natural;
    begin
        Kid.Set_Background_Color (FLTK.Green_Color);
        Check (Window.Draws = 0, "nothing drawn before it is shown");
        Window.Show;
        Wait (Window, 0);
        Check (Window.Draws > 0, "Draw_Cairo is called");
        Check (Prb.Shown_Pixel (Window, 10, 10) = Red
            and Prb.Shown_Pixel (Window, 90, 50) = Blue,
            "it draws in the window's coordinates, over the widgets");
        Before := Window.Draws;
        Window.Redraw;
        Wait (Window, Before);
        Check (Window.Draws > Before, "again at each redraw");
        Check (Prb.Shown_Pixel (Window, 90, 50) = Blue, "the same again");

        Before := Window.Draws;
        Kid.Resize (0, 0, 200, 60);
        Window.Resize (Window.Get_X, Window.Get_Y, 200, 60);
        Window.Redraw;
        Wait (Window, Before);
        Check (Prb.Shown_Pixel (Window, 90, 50) = Red, "resized, its left half is wider");
        Check (Prb.Shown_Pixel (Window, 190, 50) = Blue, "and it draws on the new part");

        declare
            Second : Halves := (CDW.Forge.Create (80, 40) with others => <>);
        begin
            Second.Show;
            Wait (Second, 0);
            Check (Prb.Shown_Pixel (Second, 70, 30) = Blue, "a second window");
            Check (Prb.Shown_Pixel (Window, 190, 50) = Blue, "leaves the first");
        end;

        --  A surface isn't the display:  the widgets are shown, without cairo.
        Before := Window.Draws;
        Check (Prb.Capture (Window), "captured");
        Check (Prb.Pixel (10, 10) = Green and Window.Draws = Before,
            "on another surface, Draw_Cairo isn't called");
        Prb.Release;
        Check (Prb.Shown_Pixel (Window, 10, 10) = Red, "and the window is as it was");
    end Test_Halves;




    --  Sticky  --

    --  What a draw leaves, for the next to find.
    type Sticky is new Counted with record
        Saved_Ok : Boolean := False;   --  a Restore with its Save was fine
        Broke    : Boolean := False;   --  the context went wrong at the first draw
        Fresh    : Boolean := False;   --  and was right at a later one
    end record;

    overriding procedure Draw_Cairo
           (This    : in out Sticky;
            Context : in     Cai.Context) is
    begin
        This.Draws := This.Draws + 1;
        if This.Draws = 1 then
            --  A scale and a Save, then more Restores than Saves.
            Cai.Scale (Context, 0.5, 0.5);
            Cai.Save (Context);
            Cai.Restore (Context);
            This.Saved_Ok := Cai.Is_Ok (Context);
            Cai.Restore (Context);
            This.Broke := not Cai.Is_Ok (Context);
            Cai.Set_Source_RGB (Context, 1.0, 0.0, 0.0);
            Cai.Paint (Context);
        else
            This.Fresh := Cai.Is_Ok (Context);
            Cai.Set_Source_RGB (Context, 0.0, 0.0, 1.0);
            Cai.Rectangle (Context, 0.0, 0.0, Long_Float (This.Get_W), Long_Float (This.Get_H));
            Cai.Fill (Context);
        end if;
    end Draw_Cairo;


    procedure Test_Sticky is
        Window : Sticky := (CDW.Forge.Create (100, 60) with others => <>);
    begin
        Window.Show;
        Wait (Window, 0);
        Check (Window.Saved_Ok, "a Restore with its Save is fine");
        Check (Window.Broke, "a Restore too many:  Is_Ok is False");
        Window.Redraw;
        Wait (Window, 1);
        Check (Window.Fresh, "the next draw has a good context");
        Check (Prb.Shown_Pixel (Window, 90, 50) = Blue, "with no scale left from the last");
    end Test_Sticky;




    --  A Draw of a Program's Own  --

    type Own is new Counted with record
        Base        : Boolean := True;
        Cairo_Draws : Natural := 0;
    end record;

    overriding procedure Draw
           (This : in out Own);

    overriding procedure Draw_Cairo
           (This    : in out Own;
            Context : in     Cai.Context);

    overriding procedure Draw
           (This : in out Own) is
    begin
        This.Draws := This.Draws + 1;
        if This.Base then
            CDW.Cairo_Drawn_Window (This).Draw;
        end if;
    end Draw;

    overriding procedure Draw_Cairo
           (This    : in out Own;
            Context : in     Cai.Context) is
    begin
        This.Cairo_Draws := This.Cairo_Draws + 1;
        Cai.Set_Source_RGB (Context, 1.0, 0.0, 0.0);
        Cai.Paint (Context);
    end Draw_Cairo;


    procedure Test_Own is
        Window : Own := (CDW.Forge.Create (100, 60) with others => <>);
    begin
        Window.Show;
        Wait (Window, 0);
        Check (Window.Draws > 0 and Window.Cairo_Draws > 0,
            "the parent's Draw draws with cairo");
        Check (Prb.Shown_Pixel (Window, 50, 30) = Red, "and shows it");
        Window.Base := False;
        Window.Cairo_Draws := 0;
        Window.Draws := 0;
        Window.Redraw;
        Wait (Window, 0);
        Check (Window.Draws > 0 and Window.Cairo_Draws = 0,
            "and without it Draw_Cairo isn't called");
    end Test_Own;




    --  Patterns  --

    type Graded is new Counted with record
        Closed : Boolean := False;   --  its pattern is closed before it is used
        Bad    : Boolean := False;   --  it draws with a scale cairo refuses
        Ok     : Boolean := False;
    end record;

    overriding procedure Draw_Cairo
           (This    : in out Graded;
            Context : in     Cai.Context)
    is
        P : Cai.Pattern := Cai.Forge.Create_Linear (0.0, 0.0, Long_Float (This.Get_W), 0.0);
    begin
        This.Draws := This.Draws + 1;
        if This.Bad then
            Cai.Scale (Context, 0.0, 0.0);
        end if;
        P.Add_Color_Stop_RGB (0.0, 1.0, 0.0, 0.0);
        P.Add_Color_Stop_RGBA (1.0, 0.0, 0.0, 1.0, 1.0);
        P.Set_Extend (Cai.Pad_Extend);
        Cai.Set_Source (Context, P);
        if This.Closed then
            P.Close;
            P.Close;
        end if;
        Cai.Paint (Context);
        This.Ok := Cai.Is_Ok (Context) and (P.Is_Closed = This.Closed);
        P.Close;
    end Draw_Cairo;


    procedure Test_Patterns is
        Window      : Graded := (CDW.Forge.Create (100, 60) with others => <>);
        Left, Right : Prb.RGB;
        Before      : Natural;
    begin
        Window.Show;
        Wait (Window, 0);
        Check (Window.Ok, "a gradient");
        Left := Prb.Shown_Pixel (Window, 1, 30);
        Right := Prb.Shown_Pixel (Window, 98, 30);
        Check (Near (Left, 250, 0, 0) and Near (Right, 0, 0, 250), "from red to blue");
        Before := Window.Draws;
        Window.Closed := True;
        Window.Redraw;
        Wait (Window, Before);
        Check (Window.Ok and Prb.Shown_Pixel (Window, 98, 30) = Right,
            "cairo keeps a closed one it was set");
        Before := Window.Draws;
        Window.Bad := True;
        Window.Redraw;
        Wait (Window, Before);
        Check (not Window.Ok, "a scale cairo refuses:  Is_Ok is False");
        Before := Window.Draws;
        Window.Bad := False;
        Window.Redraw;
        Wait (Window, Before);
        Check (Window.Ok, "which lasts that draw");
    end Test_Patterns;


    procedure Test_Closed is
        P : Cai.Pattern := Cai.Forge.Create_Linear (0.0, 0.0, 1.0, 0.0);

        procedure Stop is
        begin
            P.Add_Color_Stop_RGB (0.0, 1.0, 0.0, 0.0);
        end Stop;

        procedure Stop_Alpha is
        begin
            P.Add_Color_Stop_RGBA (0.0, 1.0, 0.0, 0.0, 1.0);
        end Stop_Alpha;

        procedure Extend is
        begin
            P.Set_Extend (Cai.Repeat_Extend);
        end Extend;

        procedure Ok is
            Ignore : constant Boolean := P.Is_Ok;
        begin
            null;
        end Ok;
    begin
        Check (P.Is_Ok and not P.Is_Closed, "a new pattern is open and good");
        P.Close;
        Check (P.Is_Closed, "Close closes it");
        P.Close;
        Check (P.Is_Closed, "and may be called again");
        Raises (Stop'Access, Program_Error'Identity, "a closed pattern:  Add_Color_Stop_RGB");
        Raises (Stop_Alpha'Access, Program_Error'Identity, "Add_Color_Stop_RGBA");
        Raises (Extend'Access, Program_Error'Identity, "Set_Extend");
        Raises (Ok'Access, Program_Error'Identity, "Is_Ok");
    end Test_Closed;




    --  Text  --

    type Texted is new Counted with record
        Extents : Cai.Text_Extents := (others => 0.0);
        Ok      : Boolean := False;
    end record;

    overriding procedure Draw_Cairo
           (This    : in out Texted;
            Context : in     Cai.Context) is
    begin
        This.Draws := This.Draws + 1;
        Cai.Select_Font_Face (Context, "Sans", Cai.Oblique_Slant, Cai.Bold_Weight);
        Cai.Set_Font_Size (Context, 40.0);
        This.Extents := Cai.Get_Text_Extents (Context, "Ada");
        Cai.Set_Source_RGB (Context, 0.0, 0.0, 0.0);
        Cai.Move_To (Context, 10.0, 50.0);
        Cai.Show_Text (Context, "Ada");
        Cai.Move_To (Context, 10.0, 100.0);
        Cai.Text_Path (Context, "Ada");
        Cai.Set_Source_RGB (Context, 0.0, 0.0, 1.0);
        Cai.Fill_Preserve (Context);
        Cai.Set_Line_Width (Context, 1.0);
        Cai.Stroke_Preserve (Context);
        Cai.New_Path (Context);
        This.Ok := Cai.Is_Ok (Context);
    end Draw_Cairo;


    procedure Test_Text is
        Window : Texted := (CDW.Forge.Create (200, 120) with others => <>);
        Dark   : Natural := 0;
    begin
        Window.Set_Background_Color (FLTK.White_Color);
        Window.Show;
        Wait (Window, 0);
        Check (Window.Ok, "text");
        Check (Window.Extents.Width > 0.0 and Window.Extents.Height > 0.0
            and Window.Extents.X_Advance > 0.0 and Window.Extents.Y_Bearing < 0.0,
            "Get_Text_Extents");
        for Y in 0 .. 119 loop
            for X in 0 .. 199 loop
                if Prb.Shown_Pixel (Window, X, Y) /= White then
                    Dark := Dark + 1;
                end if;
            end loop;
        end loop;
        Check (Dark > 100, "Show_Text, Text_Path and their fill draw");
    end Test_Text;




    --  Shapes  --

    --  A square in each corner, each by another of cairo's ways.
    type Shapes is new Counted with null record;

    overriding procedure Draw_Cairo
           (This    : in out Shapes;
            Context : in     Cai.Context) is
    begin
        This.Draws := This.Draws + 1;
        Cai.Set_Antialias (Context, Cai.No_Antialias);
        Cai.Set_Source_RGB (Context, 1.0, 0.0, 0.0);
        Cai.Save (Context);
        Cai.Translate (Context, 100.0, 0.0);
        Cai.Scale (Context, 2.0, 2.0);
        Cai.Rectangle (Context, 0.0, 0.0, 10.0, 10.0);
        Cai.Fill (Context);
        Cai.Restore (Context);
        Cai.Save (Context);
        Cai.Rectangle (Context, 0.0, 0.0, 10.0, 10.0);
        Cai.Clip (Context);
        Cai.Paint (Context);
        Cai.Restore (Context);
        Cai.Set_Source_RGB (Context, 0.0, 0.0, 1.0);
        Cai.Move_To (Context, 0.0, 100.0);
        Cai.Line_To (Context, 10.0, 100.0);
        Cai.Line_To (Context, 10.0, 110.0);
        Cai.Line_To (Context, 0.0, 110.0);
        Cai.Close_Path (Context);
        Cai.Fill (Context);
        Cai.Set_Line_Width (Context, 4.0);
        Cai.Arc (Context, 105.0, 105.0, 8.0, 0.0, 2.0 * Ada.Numerics.Pi);
        Cai.Stroke (Context);
        Cai.Save (Context);
        Cai.Translate (Context, 60.0, 60.0);
        Cai.Rotate (Context, Ada.Numerics.Pi);
        Cai.Rectangle (Context, -5.0, -5.0, 10.0, 10.0);
        Cai.Curve_To (Context, 0.0, 0.0, 1.0, 1.0, 2.0, 2.0);
        Cai.Fill (Context);
        Cai.Restore (Context);
    end Draw_Cairo;


    procedure Test_Shapes is
        Window : Shapes := (CDW.Forge.Create (120, 120) with others => <>);
    begin
        Window.Set_Background_Color (FLTK.White_Color);
        Window.Show;
        Wait (Window, 0);
        Check (Prb.Shown_Pixel (Window, 5, 5) = Red, "Clip and Paint");
        Check (Prb.Shown_Pixel (Window, 11, 11) = White, "Restore ends the clip");
        Check (Prb.Shown_Pixel (Window, 115, 15) = Red
            and Prb.Shown_Pixel (Window, 99, 5) = White,
            "Translate and Scale");
        Check (Prb.Shown_Pixel (Window, 5, 105) = Blue, "a path of lines");
        Check (Prb.Shown_Pixel (Window, 113, 105) = Blue
            and Prb.Shown_Pixel (Window, 105, 105) = White,
            "an arc stroked");
        Check (Prb.Shown_Pixel (Window, 60, 60) = Blue, "Rotate");
    end Test_Shapes;




    --  A Window in a Window  --

    procedure Test_Inner is
        Outer : Win.Window := Win.Forge.Create (200, 100);
        Inner : constant Halves := (CDW.Forge.Create (Outer, 40, 20, 100, 60) with others => <>);
    begin
        Outer.Show;
        Wait (Inner, 0);
        Check (Prb.Shown_Pixel (Inner, 10, 10) = Red
            and Prb.Shown_Pixel (Inner, 90, 50) = Blue,
            "a window in a window");
    end Test_Inner;




    --  Stale Contexts  --

    Kept : Cai.Context;

    type Keeper is new Counted with null record;

    overriding procedure Draw_Cairo
           (This    : in out Keeper;
            Context : in     Cai.Context) is
    begin
        This.Draws := This.Draws + 1;
        Kept := Context;
        Cai.Set_Source_RGB (Kept, 1.0, 0.0, 0.0);
        Cai.Paint (Kept);
    end Draw_Cairo;


    procedure Use_Kept is
    begin
        Cai.Set_Source_RGB (Kept, 1.0, 0.0, 0.0);
    end Use_Kept;

    procedure Use_Default is
        Never : Cai.Context;
    begin
        Cai.Paint (Never);
    end Use_Default;


    procedure Test_Stale is
        Window : Keeper := (CDW.Forge.Create (100, 60) with others => <>);
    begin
        Raises (Use_Default'Access, Program_Error'Identity,
            "a context no draw gave raises Program_Error");
        Window.Show;
        Wait (Window, 0);
        Check (Prb.Shown_Pixel (Window, 50, 30) = Red, "a copy works during its draw");
        Raises (Use_Kept'Access, Program_Error'Identity,
            "and raises Program_Error after it");
    end Test_Stale;




    --  An Exception From Draw_Cairo  --

    type Raiser is new Counted with record
        Raising : Boolean := True;
    end record;

    overriding procedure Draw_Cairo
           (This    : in out Raiser;
            Context : in     Cai.Context) is
    begin
        This.Draws := This.Draws + 1;
        if This.Raising then
            raise Constraint_Error with "from Draw_Cairo";
        end if;
        Cai.Set_Source_RGB (Context, 0.0, 0.0, 1.0);
        Cai.Paint (Context);
    end Draw_Cairo;


    procedure Test_Raise is
        Window : Raiser := (CDW.Forge.Create (100, 60) with others => <>);
        Raised : Boolean := False;
    begin
        Window.Show;
        begin
            for I in 1 .. Limit loop
                Ignore_Time := FLTK.Wait (0.01);
                exit when Window.Draws > 0;
            end loop;
            Ignore_Time := FLTK.Wait (0.01);
        exception
            when Constraint_Error =>
                Raised := True;
        end;
        Check (Window.Draws > 0 and Raised,
            "an exception in Draw_Cairo is raised again from Wait");
        Window.Raising := False;
        Window.Draws := 0;
        Window.Redraw;
        Wait (Window, 0);
        Check (Prb.Shown_Pixel (Window, 50, 30) = Blue, "and the next draw works");
    end Test_Raise;


    --  Without X11 or Wayland, Forge refuses.
    procedure Make is
        Window : Halves := (CDW.Forge.Create (100, 60) with others => <>);
        pragma Unreferenced (Window);
    begin
        null;
    end Make;


begin
    Test_Closed;
    if CDW.Is_Supported then
        Test_Halves;
        Test_Sticky;
        Test_Own;
        Test_Patterns;
        Test_Text;
        Test_Shapes;
        Test_Inner;
        Test_Stale;
        Test_Raise;
    else
        Raises (Make'Access, FLTK.Unsupported_Error'Identity,
            "without X11 or Wayland, Forge raises Unsupported_Error");
        Skip ("this FLTK has neither X11 nor Wayland:  no window draws with cairo");
    end if;
    Summary;
end Test_Cairo;


