


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 127: fl_read_image doesn't clip to the window
--  or surface, and Wayland's read_win_rectangle reads past its buffer.
--  What FLTK reads it then stretches to the size asked for
--  (fl_read_image.cxx:75).  Read_Image of a rectangle partly or wholly
--  outside gives what is inside in its place, and zeros elsewhere.


with

    Ada.Exceptions,
    Checks,
    FLTK.Devices.Surface.Image,
    FLTK.Draw,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Read_Outside is

    package Dr  renames FLTK.Draw;
    package Img renames FLTK.Devices.Surface.Image;
    package Win renames FLTK.Widgets.Groups.Windows;

    --  What Read_Image should give of a surface Surface_W by Surface_H, all
    --  red, read at X, Y, W, H.
    function Expected
           (Surface_W, Surface_H : in Integer;
            X, Y, W, H           : in Integer;
            Alpha                : in Integer := 0)
        return Color_Component_Array
    is
        Depth  : constant Size_Type := (if Alpha = 0 then 3 else 4);
        Result : Color_Component_Array (1 .. Size_Type (W) * Size_Type (H) * Depth) :=
            (others => 0);
        Place  : Size_Type;
    begin
        for Row in 0 .. H - 1 loop
            for Column in 0 .. W - 1 loop
                if X + Column in 0 .. Surface_W - 1 and then Y + Row in 0 .. Surface_H - 1 then
                    Place := (Size_Type (Row) * Size_Type (W) + Size_Type (Column)) * Depth + 1;
                    Result (Place) := 255;
                    if Depth = 4 then
                        Result (Place + 3) := 255;
                    end if;
                end if;
            end loop;
        end loop;
        return Result;
    end Expected;

    --  Where Got first differs from Want, for a message.
    function Differ
           (Got, Want : in Color_Component_Array)
        return String is
    begin
        if Got'Length /= Want'Length then
            return " length" & Size_Type'Image (Got'Length)
                & " for" & Size_Type'Image (Want'Length);
        end if;
        for N in Got'Range loop
            if Got (N) /= Want (N - Got'First + Want'First) then
                return " byte" & Size_Type'Image (N - Got'First + 1) & " is"
                    & Color_Component'Image (Got (N)) & ", not"
                    & Color_Component'Image (Want (N - Got'First + Want'First));
            end if;
        end loop;
        return "";
    end Differ;

    type Rectangle is record
        X, Y, W, H, Alpha : Integer;
    end record;

    Window_W : constant := 100;
    Window_H : constant := 80;

    Cases : constant array (Positive range <>) of Rectangle :=
       ((10, 10, 20, 10, 0),
        (90, 70, 20, 20, 0),
        (-5, -5, 10, 10, 0),
        (-5, 30, 110, 4, 0),
        (200, 200, 10, 10, 0),
        (90, 70, 20, 20, 255),
        (10, 10, 0, 5, 0));

    type Text_Access is access constant String;
    type Data_Access is access Color_Component_Array;

    Names : constant array (Cases'Range) of Text_Access :=
       (new String'("a rectangle inside"),
        new String'("one past the right and bottom"),
        new String'("one past the left and top"),
        new String'("one wider than the window"),
        new String'("one wholly outside"),
        new String'("one past the right and bottom, with alpha"),
        new String'("one with no width"));

    Results : array (Cases'Range) of Data_Access;
    Raised  : Text_Access := null;
    Draws   : Natural := 0;

    type Red_Window is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Red_Window);

    overriding procedure Draw
           (This : in out Red_Window) is
    begin
        Draws := Draws + 1;
        if Draws > 1 then
            return;
        end if;
        Dr.Rect_Fill (0, 0, Window_W, Window_H, 255, 0, 0);
        for N in Cases'Range loop
            Results (N) := new Color_Component_Array'(Dr.Read_Image
               (Cases (N).X, Cases (N).Y, Cases (N).W, Cases (N).H, Cases (N).Alpha));
        end loop;
    exception
    when Occurrence : others =>
        Raised := new String'(Ada.Exceptions.Exception_Information (Occurrence));
    end Draw;

    procedure Read_Nothing is
        Got : constant Color_Component_Array := Dr.Read_Image (0, 0, 10, 10);
    begin
        Check (Got'Length = 0, "never reached");
    end Read_Nothing;

    Window : Red_Window :=
        (Win.Forge.Create (0, 0, Window_W, Window_H, "Test_Read_Outside") with null record);

begin

    Window.Show;
    for N in 1 .. 40 loop
        exit when Draws > 0 or else FLTK.Wait (0.05) < 0.0;
    end loop;

    Check (Draws > 0, "the window was drawn");
    Check (Raised = null, "nothing raised: " & (if Raised = null then "" else Raised.all));
    for N in Cases'Range loop
        if Results (N) /= null then
            declare
                C    : Rectangle renames Cases (N);
                Want : constant Color_Component_Array :=
                    Expected (Window_W, Window_H, C.X, C.Y, C.W, C.H, C.Alpha);
            begin
                Check (Results (N).all = Want, "a window, " & Names (N).all & ":"
                    & Differ (Results (N).all, Want));
            end;
        end if;
    end loop;
    Window.Hide;

    --  Outside any draw, with the window hidden, nothing is drawn on.
    Raises (Read_Nothing'Access, Dr.Draw_Error'Identity,
        "Read_Image with nothing drawn on raises Draw_Error");

    --  An image surface.
    declare
        Surface : Img.Image_Surface := Img.Forge.Create (20, 20);
    begin
        FLTK.Devices.Surface.Push_Current (Surface);
        Dr.Rect_Fill (0, 0, 20, 20, 255, 0, 0);
        declare
            Got  : constant Color_Component_Array := Dr.Read_Image (10, 15, 20, 10);
            Want : constant Color_Component_Array := Expected (20, 20, 10, 15, 20, 10);
        begin
            FLTK.Devices.Surface.Pop_Current;
            Check (Got = Want, "an image surface, past its right and bottom:" & Differ (Got, Want));
        end;
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Read_Outside;


