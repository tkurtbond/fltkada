--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A widget's image fitted to its box (PLAN.md, Phase 30):  with
--  Set_Image_Fit, the image and inactive image are scaled to the box's
--  inside as the widget is drawn, in proportion, growing only when Expand
--  is asked, and their own sizes are put back after.  After pofltk's
--  TestImages.Mod.  Pixels are read away from the image's edges and
--  middle, where a scaling filter blends.


with

    Checks,
    FLTK.Images.RGB,
    FLTK.Probe,
    FLTK.Widgets.Boxes;

use

    Checks,
    FLTK;


procedure Test_Image_Fit is

    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package Bxs renames FLTK.Widgets.Boxes;

    use type Prb.RGB;

    Red   : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Blue  : constant Prb.RGB := Prb.To_RGB (0, 0, 255);
    White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);

    --  W by H pixels, the left half red and the right half blue.
    function Red_Blue
           (W, H : in Positive)
        return Color_Component_Array
    is
        Data : Color_Component_Array (1 .. Size_Type (W * H * 3)) := (others => 0);
        At_P : Size_Type;
    begin
        for Y in 0 .. H - 1 loop
            for X in 0 .. W - 1 loop
                At_P := Size_Type ((Y * W + X) * 3 + 1);
                if X < W / 2 then
                    Data (At_P) := 255;
                else
                    Data (At_P + 2) := 255;
                end if;
            end loop;
        end loop;
        return Data;
    end Red_Blue;

    --  A box that notes its image's width as its Draw runs.
    type Noting_Box is new Bxs.Box with record
        Seen : Integer := -1;
    end record;

    overriding procedure Draw
           (This : in out Noting_Box);

    overriding procedure Draw
           (This : in out Noting_Box) is
    begin
        This.Seen := This.Get_Image.Get_W;
        Bxs.Box (This).Draw;
    end Draw;

    Box : Noting_Box := (Bxs.Forge.Create (20, 0, 20, 20) with Seen => -1);

    Small : RGB.RGB_Image := RGB.Forge.Create (Red_Blue (4, 2), 4, 2);
    Large : RGB.RGB_Image := RGB.Forge.Create (Red_Blue (40, 20), 40, 20);
    Dim   : RGB.RGB_Image := RGB.Forge.Create (Red_Blue (4, 2), 4, 2);

    Captured : Boolean;

begin

    Box.Set_Box (Flat_Box);
    Box.Set_Background_Color (White_Color);
    Box.Set_Image (Small);

    Check (not Box.Is_Image_Fitted and not Box.Is_Image_Expanding,
        "not fitted to start with");
    Check (Prb.Capture (Box) and then Prb.Pixel (8, 9) = Red and then Prb.Pixel (11, 9) = Blue,
        "unfitted, a 4x2 image is drawn at its own size");
    Prb.Release;

    Box.Set_Image_Fit (True);
    Check (Box.Is_Image_Fitted and not Box.Is_Image_Expanding, "Set_Image_Fit");
    Check (Prb.Capture (Box) and then Prb.Pixel (8, 9) = Red
            and then Prb.Pixel (11, 9) = Blue and then Prb.Pixel (3, 9) = White,
        "a smaller image isn't grown");
    Prb.Release;

    Box.Set_Image_Fit (True, Expand => True);
    Check (Box.Is_Image_Fitted and Box.Is_Image_Expanding, "Set_Image_Fit with Expand");
    Check (Prb.Capture (Box) and then Prb.Pixel (3, 9) = Red
            and then Prb.Pixel (16, 9) = Blue and then Prb.Pixel (10, 3) = White
            and then Prb.Pixel (10, 16) = White,
        "unless Expand: grown, in proportion");
    Prb.Release;
    Check (Box.Seen = 20, "the Ada Draw sees the fitted size:" & Box.Seen'Image);
    Check (Small.Get_W = 4 and Small.Get_H = 2,
        "and the size is put back after:" & Small.Get_W'Image & Small.Get_H'Image);

    Box.Resize (20, 0, 40, 20);
    Check (Prb.Capture (Box) and then Prb.Pixel (5, 3) = Red and then Prb.Pixel (34, 16) = Blue,
        "and follows its box");
    Prb.Release;
    Box.Resize (20, 0, 20, 20);

    Box.Set_Image (Large);
    Box.Set_Image_Fit (True);
    Check (Prb.Capture (Box) and then Prb.Pixel (3, 9) = Red
            and then Prb.Pixel (16, 9) = Blue and then Prb.Pixel (10, 3) = White,
        "a larger image is shrunk");
    Prb.Release;
    Check (Large.Get_W = 40 and Large.Get_H = 20, "and put back:" & Large.Get_W'Image);

    Box.Set_Box (Down_Box);
    Check (Prb.Capture (Box) and then Prb.Pixel (4, 9) = Red
            and then Prb.Pixel (15, 9) = Blue and then Prb.Pixel (8, 4) = White,
        "inside its box's frame");
    Prb.Release;

    --  Above the image is the box, greyed as inactive.
    Box.Set_Inactive_Image (Dim);
    Box.Set_Image_Fit (True, Expand => True);
    Box.Deactivate;
    Captured := Prb.Capture (Box);
    Check (Captured and then Prb.Pixel (4, 9) = Red
            and then Prb.Pixel (15, 9) = Blue and then Prb.Pixel (8, 4) /= Red,
        "the inactive image too");
    Prb.Release;
    Check (Dim.Get_W = 4 and Large.Get_W = 40, "both put back");
    Box.Activate;

    Box.Set_Image_Fit (False);
    Check (not Box.Is_Image_Fitted and not Box.Is_Image_Expanding,
        "Set_Image_Fit False");
    Check (Prb.Capture (Box) and then Prb.Pixel (6, 4) = Red and then Prb.Pixel (14, 4) = Blue,
        "drawn at its own size again");
    Prb.Release;

    Summary;

end Test_Image_Fit;


