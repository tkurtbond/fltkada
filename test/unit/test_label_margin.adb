--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 20, after pofltk's Margins in test/TestWidget.Mod and
--  HaltLabelMargin:  the label's margins and image spacing read back at
--  their limits, a horizontal margin moves a label aligned left by its
--  pixels, and a margin past a byte raises.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Label_Margin is

    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type FLTK.Alignment;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Label_Margin");
    Item   : FLTK.Widgets.Boxes.Box :=
        FLTK.Widgets.Boxes.Forge.Create (Window, 0, 0, 100, 20, "X");
    X0     : Integer;

    --  The first column of Item's capture, from the left, with a pixel
    --  not white:  where its black label starts.
    function Left_Ink
        return Integer is
    begin
        Check (Prb.Capture (Item), "the box draws");
        for X in 0 .. Item.Get_W - 1 loop
            for Y in 0 .. Item.Get_H - 1 loop
                if Prb.Pixel (X, Y) /= Prb.To_RGB (255, 255, 255) then
                    Prb.Release;
                    return X;
                end if;
            end loop;
        end loop;
        Prb.Release;
        return Item.Get_W;
    end Left_Ink;

    --  From 'Value, so the compiler can't see they are out of range.
    Too_Far : constant Integer := Integer'Value ("128");
    Too_Low : constant Integer := Integer'Value ("-1");

    procedure Horizontal_Too_Far is
    begin
        Item.Set_Horizontal_Label_Margin (Too_Far);
    end Horizontal_Too_Far;

    procedure Vertical_Too_Far is
    begin
        Item.Set_Vertical_Label_Margin (-Too_Far - 1);
    end Vertical_Too_Far;

    procedure Spacing_Too_Low is
    begin
        Item.Set_Label_Image_Spacing (Too_Low);
    end Spacing_Too_Low;

begin

    Check (Item.Get_Horizontal_Label_Margin = 0 and Item.Get_Vertical_Label_Margin = 0
        and Item.Get_Label_Image_Spacing = 0, "label margins and image spacing start at 0");
    Item.Set_Horizontal_Label_Margin (-128);
    Item.Set_Vertical_Label_Margin (127);
    Item.Set_Label_Image_Spacing (255);
    Check (Item.Get_Horizontal_Label_Margin = -128 and Item.Get_Vertical_Label_Margin = 127
        and Item.Get_Label_Image_Spacing = 255,
        "label margins and image spacing read back at their limits");

    Raises (Horizontal_Too_Far'Access, Constraint_Error'Identity,
        "a horizontal margin of 128 raises (HaltLabelMargin)");
    Raises (Vertical_Too_Far'Access, Constraint_Error'Identity,
        "a vertical margin of -129 raises");
    Raises (Spacing_Too_Low'Access, Constraint_Error'Identity,
        "an image spacing of -1 raises");
    Check (Item.Get_Horizontal_Label_Margin = -128 and Item.Get_Vertical_Label_Margin = 127,
        "and leaves the margins as they were");

    Item.Set_Horizontal_Label_Margin (0);
    Item.Set_Vertical_Label_Margin (0);
    Item.Set_Box (FLTK.Flat_Box);
    Item.Set_Background_Color (FLTK.White_Color);
    Item.Set_Label_Color (FLTK.Black_Color);
    Item.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
    X0 := Left_Ink;
    Item.Set_Horizontal_Label_Margin (20);
    Check (Left_Ink = X0 + 20, "a horizontal label margin moves a label aligned left");
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Label_Margin;
