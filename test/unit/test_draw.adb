--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestDraw: Draw overrides and FLTK.Draw, checked
--  by their pixels.  Each widget is drawn into an image (FLTK.Probe), as
--  FLTK would draw it in its window, which is never shown.  pofltk's
--  check that every widget is deleted has no counterpart: Ada finalizes
--  them, and valgrind covers it.  test_clip_box, test_restore_clip and
--  test_draw_shapes have more.


with

    Checks,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Draw is

    package Bxs renames FLTK.Widgets.Boxes;
    package Drw renames FLTK.Draw;
    package Grp renames FLTK.Widgets.Groups;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Prb.RGB;


    --  What the Draw overrides record.  They are here, not in the widgets,
    --  because FLTK calls Draw from Capture, whose parameter is in.
    Draws                  : Natural := 0;
    Inside, Outside        : Boolean := False;
    CX, CY, CW, CH         : Integer := -1;
    IX, IY, IW, IH, OW, OH : Integer := -1;
    Set_Font               : Font_Kind := Helvetica;
    Set_Size               : Font_Size := 0;
    Height                 : Integer := 0;


    --  Red, with a blue square at 10, 10 and a green line along Y = 30.
    type Swatch is new Bxs.Box with null record;

    overriding procedure Draw
           (This : in out Swatch) is
    begin
        Draws := Draws + 1;
        Drw.Set_Color (Red_Color);
        Drw.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        Drw.Set_Color (Blue_Color);
        Drw.Rect_Fill (This.Get_X + 10, This.Get_Y + 10, 10, 10);
        Drw.Set_Color (0, 255, 0);
        Drw.Ecks_Why_Line (This.Get_X, This.Get_Y + 30, This.Get_X + This.Get_W - 1);
    end Draw;


    --  A blue square clipped to the top left 10 by 10.
    type Clipped is new Bxs.Box with null record;

    overriding procedure Draw
           (This : in out Clipped)
    is
        X : constant Integer := This.Get_X;
        Y : constant Integer := This.Get_Y;
    begin
        Drw.Push_Clip (X, Y, 10, 10);
        Inside := Drw.Clip_Intersects (X + 2, Y + 2, 4, 4);
        Outside := Drw.Clip_Intersects (X + 20, Y + 20, 4, 4);
        declare
            C1 : constant Boolean := Drw.Clip_Box (X, Y, 20, 20, CX, CY, CW, CH);
            C2 : constant Boolean := Drw.Clip_Box (X + 2, Y + 3, 4, 5, IX, IY, IW, IH);
            C3 : constant Boolean := Drw.Clip_Box (X + 20, Y + 20, 4, 4, IX, IY, OW, OH);
            pragma Unreferenced (C1, C2, C3);
        begin
            null;
        end;
        Drw.Set_Color (Blue_Color);
        Drw.Rect_Fill (X, Y, This.Get_W, This.Get_H);
        Drw.Pop_Clip;
    end Draw;


    --  A black disc of radius 10 at 20, 20, as a transformed path.
    type Disc is new Bxs.Box with null record;

    overriding procedure Draw
           (This : in out Disc) is
    begin
        Drw.Push_Matrix;
        Drw.Translate (Long_Float (This.Get_X + 20), Long_Float (This.Get_Y + 20));
        Drw.Set_Color (Black_Color);
        Drw.Begin_Polygon;
        Drw.Circle (0.0, 0.0, 10.0);
        Drw.End_Polygon;
        Drw.Pop_Matrix;
    end Draw;


    --  "MMM" in black.
    type Texty is new Bxs.Box with null record;

    overriding procedure Draw
           (This : in out Texty) is
    begin
        Drw.Set_Font (Helvetica_Bold, 20);
        Set_Font := Drw.Get_Font;
        Set_Size := Drw.Get_Font_Size;
        Height := Drw.Font_Line_Spacing;
        Drw.Set_Color (Black_Color);
        Drw.Draw_Text (This.Get_X + 2, This.Get_Y + 20, "MMM");
    end Draw;


    --  FLTK's box and label, under a black dot of its own at 2, 2.
    type Framed is new Bxs.Box with null record;

    overriding procedure Draw
           (This : in out Framed) is
    begin
        This.Draw_Box;
        This.Draw_Label;
        Drw.Set_Color (Black_Color);
        Drw.Rect_Fill (This.Get_X + 2, This.Get_Y + 2, 2, 2);
    end Draw;


    --  Its first child alone, on white.
    type Pair is new Grp.Group with null record;

    overriding procedure Draw
           (This : in out Pair) is
    begin
        Drw.Set_Color (White_Color);
        Drw.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        This.Draw_Child (This.Child (1).Data.all);
    end Draw;


    White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);
    Black : constant Prb.RGB := Prb.To_RGB (0, 0, 0);
    Red   : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Green : constant Prb.RGB := Prb.To_RGB (0, 255, 0);


    --  The RGB that FLTK's colour Hue stands for.
    function To_RGB
           (Hue : in Color)
        return Prb.RGB
    is
        R, G, B : Color_Component;
    begin
        FLTK.Static.Get_Color (Hue, R, G, B);
        return Prb.To_RGB (Natural (R), Natural (G), Natural (B));
    end To_RGB;


    --  The number of pixels in X0 .. X1 - 1, Y0 .. Y1 - 1 that aren't
    --  white, or that aren't Than.
    function Not_Like
           (X0, Y0, X1, Y1 : in Integer;
            Than           : in Prb.RGB := White)
        return Natural
    is
        N : Natural := 0;
    begin
        for Y in Y0 .. Y1 - 1 loop
            for X in X0 .. X1 - 1 loop
                if Prb.Pixel (X, Y) /= Than then
                    N := N + 1;
                end if;
            end loop;
        end loop;
        return N;
    end Not_Like;


    Blue : constant Prb.RGB := To_RGB (Blue_Color);

    Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "Test_Draw");
    Sw     : constant Swatch := (Bxs.Forge.Create (Window, 10, 10, 50, 40) with null record);
    Cl     : constant Clipped := (Bxs.Forge.Create (Window, 70, 10, 30, 30) with null record);
    Dsc    : constant Disc := (Bxs.Forge.Create (Window, 110, 10, 40, 40) with null record);
    Tx     : constant Texty := (Bxs.Forge.Create (Window, 160, 10, 80, 30) with null record);
    Fr     : Framed := (Bxs.Forge.Create (Window, 10, 60, 60, 30) with null record);
    Plain  : Bxs.Box := Bxs.Forge.Create (Window, 80, 60, 30, 20);

begin

    --  A Draw override, drawing in the window's coordinates
    Check (Prb.Capture (Sw) and Draws = 1, "a Draw override runs, once per capture");
    Check (Prb.Pixel (0, 0) = Red and Prb.Pixel (49, 39) = Red,
        "Rect_Fill fills the whole widget with an indexed colour (Red_Color)");
    Check (Prb.Pixel (10, 10) = Blue and Prb.Pixel (19, 19) = Blue
            and Prb.Pixel (20, 20) = Red and Prb.Pixel (9, 9) = Red,
        "a filled square exactly where drawn, relative to the widget");
    Check (Prb.Pixel (0, 30) = Green and Prb.Pixel (49, 30) = Green
            and Prb.Pixel (25, 31) = Red,
        "Ecks_Why_Line in an RGB colour, one pixel high, end to end");

    --  Clipping
    Check (Prb.Capture (Cl), "capture a clipped Draw");
    Check (Prb.Pixel (0, 0) = Blue and Prb.Pixel (9, 9) = Blue
            and Prb.Pixel (10, 10) = White and Prb.Pixel (29, 0) = White,
        "Push_Clip: only the clip rectangle is drawn");
    Check (Inside and not Outside,
        "Clip_Intersects: True inside the clip, False outside");
    Check (CX = Cl.Get_X and CY = Cl.Get_Y and CW = 10 and CH = 10,
        "Clip_Box gives the visible part of a rectangle partly clipped");
    Check (IW = 4 and IH = 5 and (OW = 0 or OH = 0),
        "Clip_Box: all of a rectangle inside the clip, none of one outside");

    --  A path, transformed
    Check (Prb.Capture (Dsc), "capture a transformed path");
    Check (Prb.Pixel (20, 20) = Black and Prb.Pixel (14, 20) = Black
            and Prb.Pixel (20, 26) = Black and Prb.Pixel (2, 2) = White
            and Prb.Pixel (37, 37) = White and Prb.Pixel (32, 20) = White,
        "Circle in a polygon, translated: black inside, white outside");

    --  Text
    Check (Prb.Capture (Tx), "capture text");
    Check (Not_Like (0, 0, 80, 30) > 50 and Not_Like (0, 0, 80, 3) = 0,
        "Draw_Text draws ink, below the top of the widget");
    Check (Set_Font = Helvetica_Bold and Set_Size = 20 and Height >= 20,
        "the font set reads back; its height is at least its size");
    Drw.Set_Font (Helvetica, 20);
    Check (Drw.Width ("MMM") > Drw.Width ("M") and Drw.Width ("M") > 5.0
            and Drw.Width ("") = 0.0,
        "Width measures, outside any Draw");
    declare
        W, H : Natural;
    begin
        Drw.Measure ("MMM", W, H);
        Check (abs (W - Integer (Drw.Width ("MMM"))) <= 1 and H = Drw.Font_Line_Spacing,
            "Measure gives one line's width and height");
        Drw.Measure ("a" & ASCII.LF & "b", W, H);
        Check (H = 2 * Drw.Font_Line_Spacing, "Measure counts lines");
    end;

    --  FLTK's own box and label, from an override
    Fr.Set_Box (Flat_Box);
    Fr.Set_Background_Color (RGB_Color (255, 255, 0));
    Fr.Set_Label ("x");
    Fr.Set_Label_Color (Black_Color);
    Fr.Set_Alignment (Align_Inside + Align_Right);
    Check (Prb.Capture (Fr), "capture a Draw using Draw_Box and Draw_Label");
    Check (Prb.Pixel (2, 2) = Black and Prb.Pixel (10, 15) = Prb.To_RGB (255, 255, 0)
            and Prb.Pixel (59, 29) = Prb.To_RGB (255, 255, 0),
        "Draw_Box fills the box in the widget's colour, under the override's own drawing");
    Check (Not_Like (0, 0, 60, 30) > 0, "the capture isn't blank");
    Check (Not_Like (30, 0, 60, 30, Than => Prb.To_RGB (255, 255, 0)) > 0,
        "Draw_Label draws the label, on the right");

    --  The default Draw: FLTK's
    Plain.Set_Box (Flat_Box);
    Plain.Set_Background_Color (Dark_Green_Color);
    Check (Prb.Capture (Plain) and Prb.Pixel (0, 0) = To_RGB (Dark_Green_Color)
            and Prb.Pixel (29, 19) = To_RGB (Dark_Green_Color),
        "a Box's own Draw: a flat box in its colour");

    --  A group's Draw, drawing one child of its own choosing
    declare
        Two   : Pair := (Grp.Forge.Create (Window, 0, 200, 100, 50) with null record);
        Left  : Bxs.Box := Bxs.Forge.Create (Two, 0, 200, 50, 50);
        Right : Bxs.Box := Bxs.Forge.Create (Two, 50, 200, 50, 50);
    begin
        Left.Set_Box (Flat_Box);
        Left.Set_Background_Color (Red_Color);
        Right.Set_Box (Flat_Box);
        Right.Set_Background_Color (Red_Color);
        Check (Prb.Capture (Two), "a group drawing one child");
        Check (Prb.Pixel (10, 10) = Red and Prb.Pixel (60, 10) /= Red,
            "Draw_Child draws the child it is given, and no other");
        Prb.Release;
    end;

    --  Damage
    Plain.Redraw;
    Check (Plain.Get_Damage.Full, "Redraw sets Damage_Full");

    Prb.Release;
    Summary;

end Test_Draw;
