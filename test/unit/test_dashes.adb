

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 136.  Fl_Cairo_Graphics_Driver::line_style
--  strcpys a dash pattern into linedash_[256], unchecked
--  (Fl_Cairo_Graphics_Driver.cxx:317-319), so 128 pairs or more overrun
--  it.  The pattern is a char *, signed on x86, so a length over 127 is
--  negative, and Cairo draws no line at all.  A length must be 1 to 127,
--  and there may be at most 127 pairs; anything else raises
--  Constraint_Error before FLTK sees it.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Dashes is

    package Drw renames FLTK.Draw;
    package Prb renames FLTK.Probe;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Pattern_Kind is (Short, Long, Most, Too_Many, Too_Long);

    --  Not static, so the compiler can't see 200 is out of range.
    function Big
        return Integer is
    begin
        return 127;
    end Big;

    Raised : Boolean := False;

    function Pattern
           (Kind : in Pattern_Kind)
        return Drw.Dash_Gap_Array is
    begin
        case Kind is
            when Short =>
                return (1 => (8, 8));
            when Long =>
                return (1 => (Drw.Dash_Length (Big), 4));
            when Most =>
                return (1 .. 127 => (8, 8));
            when Too_Many =>
                return (1 .. 150 => (8, 8));
            when Too_Long =>
                return (1 => (Drw.Dash_Length (Big + 73), 4));
        end case;
    end Pattern;


    type Dash_Box is new Bx.Box with record
        Kind : Pattern_Kind := Short;
    end record;

    overriding procedure Draw
           (This : in out Dash_Box);

    overriding procedure Draw
           (This : in out Dash_Box) is
    begin
        Drw.Set_Color (White_Color);
        Drw.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        Drw.Set_Color (Black_Color);
        Raised := False;
        begin
            Drw.Set_Line_Style (Width => 3, Dashes => Pattern (This.Kind));
        exception
            when Constraint_Error =>
                Raised := True;
        end;
        Drw.Line (This.Get_X, This.Get_Y + 10, This.Get_X + This.Get_W - 1, This.Get_Y + 10);
        Drw.Set_Line_Style;
    end Draw;


    Window : Win.Window := Win.Forge.Create (0, 0, 300, 100, "Test_Dashes");

    The_Box : Dash_Box :=
       (Bx.Forge.Create (Window, Flat_Box, 0, 0, 300, 20) with others => <>);

    function Dark
           (X : in Natural)
        return Boolean is
    begin
        return Prb.Pixel (X, 10) = Prb.To_RGB (0, 0, 0);
    end Dark;

    function Light
           (X : in Natural)
        return Boolean is
    begin
        return Prb.Pixel (X, 10) = Prb.To_RGB (255, 255, 255);
    end Light;

    procedure Try
           (Kind : in Pattern_Kind) is
    begin
        The_Box.Kind := Kind;
        if not Prb.Capture (The_Box) then
            Check (False, Pattern_Kind'Image (Kind) & ": the capture is the box's size");
        end if;
    end Try;

begin

    Try (Short);
    Check (not Raised, "a short pattern is taken");
    Check (Dark (4) and then Light (12) and then Dark (20) and then Light (28),
        "a short pattern draws dashes");
    Prb.Release;

    Try (Long);
    Check (not Raised, "a dash of 127 is taken");
    Check (Dark (4) and then Dark (120) and then Light (129),
        "a dash of 127 draws");
    Prb.Release;

    Try (Most);
    Check (not Raised, "127 pairs are taken");
    Check (Dark (4) and then Light (12), "127 pairs draw dashes");
    Prb.Release;

    Try (Too_Many);
    Check (Raised, "150 pairs raise");
    Prb.Release;

    Try (Too_Long);
    Check (Raised, "a dash of 200 raises");
    Prb.Release;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Dashes;


