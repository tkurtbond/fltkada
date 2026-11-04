

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 9: offscreens, Image_Surface's Mask and Rescale, and
--  Capture_Window.  Ported from pofltk's TestDrawMore (TestOffscreen and
--  the capture checks), TestImages (Masks) and its Halt programs for
--  offscreen copies and masks, with checks of what FLTKAda refuses
--  besides: misuse that FLTK crashes on, or reads freed memory after.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Devices.Surface.Image,
    FLTK.Draw.Offscreens,
    FLTK.Images.RGB,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Offscreens is

    package Dr   renames FLTK.Draw;
    package Offs renames FLTK.Draw.Offscreens;
    package Surf renames FLTK.Devices.Surface;
    package Img  renames FLTK.Devices.Surface.Image;
    package RGB  renames FLTK.Images.RGB;
    package Win  renames FLTK.Widgets.Groups.Windows;

    subtype Pixel is Color_Component_Array (1 .. 3);

    Red   : constant Pixel := (255, 0, 0);
    Green : constant Pixel := (0, 255, 0);
    Blue  : constant Pixel := (0, 0, 255);
    White : constant Pixel := (255, 255, 255);

    function Image
           (Item : in Color_Component_Array)
        return String is
    begin
        return "(" & Color_Component'Image (Item (Item'First)) & ","
            & Color_Component'Image (Item (Item'First + 1)) & ","
            & Color_Component'Image (Item (Item'First + 2)) & " )";
    end Image;

    --  The pixel at X, Y of what is drawn on now.
    function Drawn
           (X, Y : in Integer)
        return Pixel is
    begin
        return Dr.Read_Image (X, Y, 1, 1);
    end Drawn;

    --  The pixel at X, Y of Item, 3 or 4 bytes a pixel.
    function Of_Image
           (Item : in RGB.RGB_Image;
            X, Y : in Integer)
        return Pixel
    is
        Place : constant Size_Type :=
            Size_Type ((Y * Item.Get_W + X) * Item.Get_D) + 1;
    begin
        return (Item.Get_Datum (Place), Item.Get_Datum (Place + 1),
            Item.Get_Datum (Place + 2));
    end Of_Image;

    procedure Check_Pixel
           (Got, Want : in Pixel;
            Message   : in String) is
    begin
        Check (Got = Want, Message & ": " & Image (Got)
            & (if Got = Want then "" else ", not " & Image (Want)));
    end Check_Pixel;

    --  An image W by H, 3 bytes a pixel, black where X is below Split and
    --  white elsewhere, or the other way round if Inverted.
    function Half_Mask
           (W, H     : in Positive;
            Split    : in Natural;
            Inverted : in Boolean := False)
        return RGB.RGB_Image
    is
        Data  : Color_Component_Array (1 .. Size_Type (W * H * 3));
        Value : Color_Component;
    begin
        for Y in 0 .. H - 1 loop
            for X in 0 .. W - 1 loop
                Value := (if (X < Split) = Inverted then 255 else 0);
                for C in Size_Type range 1 .. 3 loop
                    Data (Size_Type ((Y * W + X) * 3) + C) := Value;
                end loop;
            end loop;
        end loop;
        return RGB.Forge.Create (Data, W, H);
    end Half_Mask;

    Blank   : Offs.Offscreen;
    Off     : Offs.Offscreen := Offs.Forge.Create (20, 10);
    Inner   : Offs.Offscreen := Offs.Forge.Create (20, 10);
    Target  : Img.Image_Surface := Img.Forge.Create (30, 20);
    Masked  : Img.Image_Surface := Img.Forge.Create (40, 40);
    Never   : RGB.RGB_Image;
    Deep    : constant RGB.RGB_Image :=
        RGB.Forge.Create ((1 .. 64 => 255), 4, 4, Depth => 4);

    procedure Begin_Blank is
    begin
        Blank.Begin_Drawing;
    end Begin_Blank;

    procedure Create_Empty is
        Item : constant Offs.Offscreen := Offs.Forge.Create (0, 5);
    begin
        Check (Item.Is_Valid, "never reached");
    end Create_Empty;

    procedure Create_Negative is
        Item : constant Offs.Offscreen := Offs.Forge.Create (5, -3);
    begin
        Check (Item.Is_Valid, "never reached");
    end Create_Negative;

    procedure Create_Empty_Surface is
        Item : constant Img.Image_Surface := Img.Forge.Create (0, 5);
    begin
        Check (Item.Is_Highres, "never reached");
    end Create_Empty_Surface;

    procedure Begin_Off is
    begin
        Off.Begin_Drawing;
    end Begin_Off;

    procedure End_Off is
    begin
        Off.End_Drawing;
    end End_Off;

    procedure Rescale_Off is
    begin
        Off.Rescale;
    end Rescale_Off;

    procedure Copy_Off is
    begin
        Off.Copy (0, 0, 10, 10, 10, 0);
    end Copy_Off;

    procedure Rescale_Target is
    begin
        Target.Rescale;
    end Rescale_Target;

    procedure Mask_Deep is
    begin
        Masked.Mask (Deep);
    end Mask_Deep;

    procedure Mask_Never is
    begin
        Masked.Mask (Never);
    end Mask_Never;

    procedure Mask_Half is
    begin
        Masked.Mask (Half_Mask (40, 40, 20));
    end Mask_Half;

    --  Off's picture, copied to Target: Off's blue half at 5, 5.
    procedure Check_Copy
           (Message : in String) is
    begin
        Surf.Push_Current (Target);
        Dr.Rect_Fill (0, 0, 30, 20, 255, 255, 255);
        Off.Copy (5, 5, 10, 10, 10, 0);
        declare
            In_Copy  : constant Pixel := Drawn (10, 10);
            Right    : constant Pixel := Drawn (16, 10);
            Left     : constant Pixel := Drawn (4, 10);
        begin
            Surf.Pop_Current;
            Check_Pixel (In_Copy, Blue, Message & ", inside the copy");
            Check_Pixel (Right, White, Message & ", right of the copy");
            Check_Pixel (Left, White, Message & ", left of the copy");
        end;
    end Check_Copy;

    function Original_Is_Current
        return Boolean is
    begin
        return Surf.Get_Original.Data.Is_Current;
    end Original_Is_Current;

    Draws : Natural := 0;

    type Halves_Window is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Halves_Window);

    overriding procedure Draw
           (This : in out Halves_Window) is
    begin
        Draws := Draws + 1;
        Dr.Rect_Fill (0, 0, 50, 100, 255, 0, 0);
        Dr.Rect_Fill (50, 0, 50, 100, 0, 255, 0);
    end Draw;

    Window : Halves_Window :=
        (Win.Forge.Create (0, 0, 100, 100, "Test_Offscreens") with null record);
    Hidden : constant Win.Window := Win.Forge.Create (0, 0, 100, 100, "Hidden");

    type Rectangle is record
        X, Y, W, H : Integer;
    end record;

    Capture_At : Rectangle;

    procedure Capture is
        Got : constant RGB.RGB_Image :=
            Dr.Capture_Window (Window, Capture_At.X, Capture_At.Y, Capture_At.W, Capture_At.H);
    begin
        Check (Got.Get_W = 0, "never reached");
    end Capture;

    procedure Capture_Hidden is
        Got : constant RGB.RGB_Image := Dr.Capture_Window (Hidden, 0, 0, 10, 10);
    begin
        Check (Got.Get_W = 0, "never reached");
    end Capture_Hidden;

    type Offscreen_Access is access Offs.Offscreen;

    procedure Free is new Ada.Unchecked_Deallocation (Offs.Offscreen, Offscreen_Access);

begin

    --  Offscreens never made, or of no size.
    Check (not Blank.Is_Valid, "an offscreen not made by Forge.Create isn't valid");
    Raises (Begin_Blank'Access, Program_Error'Identity,
        "Begin_Drawing of one not made by Forge.Create raises Program_Error");
    Raises (Create_Empty'Access, Constraint_Error'Identity,
        "an offscreen of width 0 raises Constraint_Error");
    Raises (Create_Negative'Access, Constraint_Error'Identity,
        "an offscreen of height -3 raises Constraint_Error");
    Raises (Create_Empty_Surface'Access, Constraint_Error'Identity,
        "an image surface of width 0 raises Constraint_Error");
    Check (Off.Is_Valid and Off.Get_W = 20 and Off.Get_H = 10, "an offscreen 20 by 10");

    --  Drawing, and copying (pofltk TestOffscreen).
    Off.Begin_Drawing;
    Check (Off.Is_Drawing, "a begun offscreen is drawing");
    Raises (Begin_Off'Access, Program_Error'Identity,
        "Begin_Drawing twice raises Program_Error");
    Raises (Rescale_Off'Access, Program_Error'Identity,
        "Rescale of a begun offscreen raises Program_Error");
    Raises (Copy_Off'Access, Program_Error'Identity,
        "copying an offscreen onto itself raises Program_Error");
    Dr.Rect_Fill (0, 0, 10, 10, 255, 0, 0);
    Dr.Rect_Fill (10, 0, 10, 10, 0, 0, 255);
    declare
        Left  : constant Pixel := Drawn (5, 5);
        Right : constant Pixel := Drawn (15, 5);
    begin
        Check_Pixel (Left, Red, "the offscreen's left half");
        Check_Pixel (Right, Blue, "the offscreen's right half");
    end;

    --  One inside another.
    Inner.Begin_Drawing;
    Raises (End_Off'Access, Program_Error'Identity,
        "ending an offscreen out of order raises Program_Error");
    Check (Off.Is_Drawing and Inner.Is_Drawing, "both nested offscreens are drawing");
    Dr.Rect_Fill (0, 0, 20, 10, 255, 255, 255);
    Off.Copy (0, 0, 10, 10, 10, 0);
    declare
        Copied : constant Pixel := Drawn (5, 5);
        Beside : constant Pixel := Drawn (15, 5);
    begin
        Check_Pixel (Copied, Blue, "an offscreen copied into the one begun inside it");
        Check_Pixel (Beside, White, "beside that copy");
    end;
    Inner.End_Drawing;
    Off.End_Drawing;
    Check (not Off.Is_Drawing and not Inner.Is_Drawing, "ended offscreens aren't drawing");
    Raises (End_Off'Access, Program_Error'Identity,
        "End_Drawing when not begun raises Program_Error");
    Check (Original_Is_Current, "after both end, the original surface is current");

    Check_Copy ("an offscreen copied to an image surface");
    Off.Rescale;
    Check_Copy ("the same after Rescale");

    --  Freed while drawing.
    Surf.Push_Current (Target);
    declare
        Gone : Offs.Offscreen := Offs.Forge.Create (10, 10);
    begin
        Gone.Begin_Drawing;
    end;
    Check (Target.Is_Current, "an offscreen freed while begun gives back the surface before");
    Raises (Rescale_Target'Access, Program_Error'Identity,
        "Rescale of a pushed image surface raises Program_Error");
    Surf.Pop_Current;
    Check (Original_Is_Current, "then popping it gives back the original surface");

    declare
        Buried : Offscreen_Access := new Offs.Offscreen'(Offs.Forge.Create (10, 10));
    begin
        Buried.Begin_Drawing;
        Surf.Push_Current (Target);
        Free (Buried);
        Check (Target.Is_Current, "freeing an offscreen buried under another changes nothing");
        Surf.Pop_Current;
        Dr.Rect_Fill (0, 0, 10, 10, 0, 255, 0);
        Check_Pixel (Drawn (5, 5), Green, "the freed offscreen's stand-in is drawn on");
        Surf.Pop_Current;
        Check (Original_Is_Current, "popping the stand-in gives back the original surface");
    end;

    --  Masks (pofltk TestImages, Masks, and the Halt programs).
    Raises (Mask_Deep'Access, Unsupported_Error'Identity,
        "a mask of 4 bytes a pixel raises Unsupported_Error");
    Raises (Mask_Never'Access, FLTK.Images.No_Image_Error'Identity,
        "a mask never made raises No_Image_Error");
    Surf.Push_Current (Masked);
    Dr.Rect_Fill (0, 0, 40, 40, 255, 0, 0);
    Raises (Mask_Half'Access, Program_Error'Identity,
        "a mask of the current surface raises Program_Error");
    Surf.Pop_Current;
    Masked.Mask (Half_Mask (40, 40, 20));
    Raises (Mask_Half'Access, Program_Error'Identity,
        "a second mask before Get_Image raises Program_Error");
    Surf.Push_Current (Masked);
    Dr.Rect_Fill (0, 0, 40, 40, 0, 0, 255);
    Surf.Pop_Current;
    declare
        Got : constant RGB.RGB_Image := Masked.Get_Image;
    begin
        Check (Got.Get_W = 40 and Got.Get_H = 40, "the masked image is 40 by 40");
        Check_Pixel (Of_Image (Got, 5, 20), Red, "where the mask is black, the first drawing");
        Check_Pixel (Of_Image (Got, 35, 20), Blue, "where the mask is white, the second");
    end;
    Masked.Mask (Half_Mask (20, 20, 10, Inverted => True));
    Surf.Push_Current (Masked);
    Dr.Rect_Fill (0, 0, 40, 40, 0, 255, 0);
    Surf.Pop_Current;
    declare
        Got : constant RGB.RGB_Image := Masked.Get_Image;
    begin
        Check_Pixel (Of_Image (Got, 5, 20), Green, "a smaller mask, inverted, white side");
        Check_Pixel (Of_Image (Got, 35, 20), Blue, "a smaller mask, inverted, black side");
    end;
    --  A mask never used, freed with the surface at the end.
    Masked.Mask (Half_Mask (40, 40, 20));

    --  Capture_Window (pofltk TestDrawMore).
    Raises (Capture_Hidden'Access, Dr.Draw_Error'Identity,
        "capturing a window never shown raises Draw_Error");
    Window.Show;
    for N in 1 .. 40 loop
        exit when Draws > 0 or else FLTK.Wait (0.05) < 0.0;
    end loop;
    for N in 1 .. 4 loop
        exit when FLTK.Wait (0.05) < 0.0;
    end loop;
    Check (Draws > 0, "the window was drawn");
    declare
        Got : constant RGB.RGB_Image := Dr.Capture_Window (Window, 0, 0, 100, 100);
    begin
        Check (Got.Get_W = 100 and Got.Get_H = 100, "a whole window captured is 100 by 100");
        Check_Pixel (Of_Image (Got, 10, 50), Red, "its left half");
        Check_Pixel (Of_Image (Got, 90, 50), Green, "its right half");
    end;
    declare
        Got : constant RGB.RGB_Image := Dr.Capture_Window (Window, 90, 90, 50, 50);
    begin
        Check (Got.Get_W = 10 and Got.Get_H = 10, "past the right and bottom gives 10 by 10:"
            & Integer'Image (Got.Get_W) & Integer'Image (Got.Get_H));
        Check_Pixel (Of_Image (Got, 5, 5), Green, "and is of the right corner");
    end;
    declare
        Got : constant RGB.RGB_Image := Dr.Capture_Window (Window, -5, -6, 20, 20);
    begin
        Check (Got.Get_W = 15 and Got.Get_H = 14, "past the left and top gives 15 by 14:"
            & Integer'Image (Got.Get_W) & Integer'Image (Got.Get_H));
        Check_Pixel (Of_Image (Got, 0, 0), Red, "and starts at the window's corner");
    end;
    declare
        Got : constant RGB.RGB_Image :=
            Dr.Capture_Window (Window, 90, 90, Integer'Last, Integer'Last);
    begin
        Check (Got.Get_W = 10 and Got.Get_H = 10, "a size of Integer'Last gives 10 by 10:"
            & Integer'Image (Got.Get_W) & Integer'Image (Got.Get_H));
    end;
    declare
        Nothing : constant array (Positive range <>) of Rectangle :=
           ((100, 0, 5, 5), (0, -5, 5, 5), (0, 0, 0, 5), (0, 0, -3, 5), (0, 0, 5, 0));
    begin
        for R of Nothing loop
            Capture_At := R;
            Raises (Capture'Access, Dr.Draw_Error'Identity, "capturing nothing at"
                & Integer'Image (R.X) & Integer'Image (R.Y) & Integer'Image (R.W)
                & Integer'Image (R.H) & " raises Draw_Error");
        end loop;
    end;
    Window.Hide;
    Capture_At := (0, 0, 10, 10);
    Raises (Capture'Access, Dr.Draw_Error'Identity,
        "capturing a hidden window raises Draw_Error");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Offscreens;
