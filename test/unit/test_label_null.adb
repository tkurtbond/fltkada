--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 98: Forge.Create with the label "" leaves the widget's
--  label null, but Set_Label ("") gave it an empty string.  FLTK counts an
--  empty string as a line of text and null as none (fl_draw.cxx:254-263),
--  so an image with an empty label sits lower (fl_draw.cxx:290).
--  Set_Label ("") now leaves the label null too.


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.RGB,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks;

use type

    FLTK.Alignment,
    FLTK.Size_Type;


procedure Test_Label_Null is

    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    --  10 by 10 pixels of red.
    function Red
        return FLTK.Color_Component_Array
    is
        Data : FLTK.Color_Component_Array (1 .. 10 * 10 * 3) := (others => 0);
    begin
        for I in 0 .. 10 * 10 - 1 loop
            Data (Data'First + 3 * FLTK.Size_Type (I)) := 255;
        end loop;
        return Data;
    end Red;

    Window  : Win.Window := Win.Forge.Create (300, 100);
    Created : Bx.Box := Bx.Forge.Create (Window, 0, 0, 100, 100, "");
    Set     : Bx.Box := Bx.Forge.Create (Window, 100, 0, 100, 100, "label");
    Cleared : Bx.Box := Bx.Forge.Create (Window, 200, 0, 100, 100, "label");
    Picture : RGB.RGB_Image := RGB.Forge.Create (Red, 10, 10);

    --  The first row of Item with a red pixel in its middle column, or -1.
    function Top_Of_Red
           (Item : in Bx.Box)
        return Integer
    is
        Row : Integer := -1;
    begin
        if Prb.Capture (Item) then
            for Y in 0 .. Item.Get_H - 1 loop
                if Prb.Pixel (Item.Get_W / 2, Y) = Prb.To_RGB (255, 0, 0) then
                    Row := Y;
                    exit;
                end if;
            end loop;
        end if;
        Prb.Release;
        return Row;
    end Top_Of_Red;

begin

    Created.Set_Image (Picture);
    Set.Set_Image (Picture);
    Cleared.Set_Image (Picture);
    Set.Set_Label ("");
    Cleared.Set_Label ("");
    Cleared.Set_Label ("x");
    Cleared.Set_Label ("");
    Created.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);
    Set.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);
    Cleared.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);

    Check (Top_Of_Red (Created) = 45,
        "an image with no label sits in the middle," & Integer'Image (Top_Of_Red (Created)));
    Check (Top_Of_Red (Set) = Top_Of_Red (Created),
        "Set_Label ("""") puts the image where Create with """" does,"
        & Integer'Image (Top_Of_Red (Set)) & " and" & Integer'Image (Top_Of_Red (Created)));
    Check (Top_Of_Red (Cleared) = Top_Of_Red (Created),
        "after another label too," & Integer'Image (Top_Of_Red (Cleared)));
    Check (Set.Get_Label = "" and Cleared.Get_Label = "", "Get_Label gives """"");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Label_Null;
