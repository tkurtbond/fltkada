--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 2: Cairo's clip_box compares the box with the
--  clip, not the result with the box, so it says "changed" for a box wholly
--  inside and "unchanged" for one clipped, and for a box wholly outside it
--  returns before setting H (Fl_Cairo_Graphics_Driver.cxx:693-726).
--  Clip_Box is True exactly when the rectangle it gives differs from the
--  box, and a box wholly outside gives a width and height of 0.  Checked
--  on an image surface and in a window's Draw.


with

    Ada.Exceptions,
    Checks,
    FLTK.Devices.Surface.Image,
    FLTK.Draw,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Clip_Box is

    package Dr  renames FLTK.Draw;
    package Img renames FLTK.Devices.Surface.Image;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Rectangle is record
        X, Y, W, H : Integer;
    end record;

    function Image
           (R : in Rectangle)
        return String is
    begin
        return "(" & Integer'Image (R.X) & "," & Integer'Image (R.Y) & ","
            & Integer'Image (R.W) & "," & Integer'Image (R.H) & " )";
    end Image;

    type Case_Type is record
        Box, Want : Rectangle;
        Changed   : Boolean;
    end record;

    --  With the clip at (10, 10, 50, 50).  A Want of width 0 is any empty
    --  rectangle.
    Cases : constant array (Positive range <>) of Case_Type :=
       (((20, 20, 10, 10), (20, 20, 10, 10), False),
        ((0, 0, 30, 30), (10, 10, 20, 20), True),
        ((50, 50, 30, 30), (50, 50, 10, 10), True),
        ((0, 0, 100, 100), (10, 10, 50, 50), True),
        ((10, 10, 50, 50), (10, 10, 50, 50), False),
        ((100, 100, 10, 10), (0, 0, 0, 0), True),
        ((20, 100, 10, 10), (0, 0, 0, 0), True));

    type Text_Access is access constant String;

    Names : constant array (Cases'Range) of Text_Access :=
       (new String'("a box inside"),
        new String'("a box over the top left"),
        new String'("a box over the bottom right"),
        new String'("a box around the clip"),
        new String'("the clip itself"),
        new String'("a box wholly outside"),
        new String'("a box below"));

    type Result_Type is record
        Got     : Rectangle := (-1, -1, -1, -1);
        Changed : Boolean := False;
    end record;

    type Result_Array is array (Cases'Range) of Result_Type;

    procedure Measure
           (Results : out Result_Array) is
    begin
        Dr.Push_Clip (10, 10, 50, 50);
        for N in Cases'Range loop
            declare
                B : Rectangle renames Cases (N).Box;
                R : Result_Type renames Results (N);
            begin
                R.Changed := Dr.Clip_Box (B.X, B.Y, B.W, B.H, R.Got.X, R.Got.Y, R.Got.W, R.Got.H);
            end;
        end loop;
        Dr.Pop_Clip;
    end Measure;

    procedure Compare
           (Where   : in String;
            Results : in Result_Array) is
    begin
        for N in Cases'Range loop
            declare
                C : Case_Type renames Cases (N);
                R : Result_Type renames Results (N);
                Right : constant Boolean :=
                    (if C.Want.W = 0 then R.Got.W = 0 and R.Got.H = 0 else R.Got = C.Want);
            begin
                Check (Right, Where & ", " & Names (N).all & ": " & Image (R.Got)
                    & " for " & Image (C.Want));
                Check (R.Changed = C.Changed, Where & ", " & Names (N).all & ": changed is "
                    & Boolean'Image (R.Changed));
            end;
        end loop;
    end Compare;

    In_Window : Result_Array;
    Raised    : Text_Access := null;
    Draws     : Natural := 0;

    type Clip_Window is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Clip_Window);

    overriding procedure Draw
           (This : in out Clip_Window) is
    begin
        Draws := Draws + 1;
        if Draws = 1 then
            Measure (In_Window);
        end if;
    exception
    when Occurrence : others =>
        Raised := new String'(Ada.Exceptions.Exception_Information (Occurrence));
    end Draw;

    Window : Clip_Window := (Win.Forge.Create (0, 0, 100, 100, "Test_Clip_Box") with null record);

begin

    declare
        Surface : Img.Image_Surface := Img.Forge.Create (100, 100);
        Results : Result_Array;
    begin
        FLTK.Devices.Surface.Push_Current (Surface);
        Measure (Results);
        FLTK.Devices.Surface.Pop_Current;
        Compare ("an image surface", Results);
    end;

    Window.Show;
    for N in 1 .. 40 loop
        exit when Draws > 0 or else FLTK.Wait (0.05) < 0.0;
    end loop;
    Check (Draws > 0, "the window was drawn");
    Check (Raised = null, "nothing raised: " & (if Raised = null then "" else Raised.all));
    if Draws > 0 then
        Compare ("a window", In_Window);
    end if;
    Window.Hide;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Clip_Box;
