--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 8: FL_ROUND_UP_BOX, FL_SHADOW_LABEL and others
--  are macros that call fl_define_FL_ROUND_UP_BOX () and so on, which put
--  the type's drawing code in FLTK's tables.  Until then the tables hold a
--  stand-in: an up box, a border box or a flat box
--  (fl_boxtype.cxx:297-360), and a normal label (fl_labeltype.cxx:58-69).
--  Each type, set by its plain value as FLTKAda does, must draw unlike its
--  stand-in.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Widgets.Boxes;

use

    Checks,
    FLTK;


procedure Test_Defined_Types is

    package Prb renames FLTK.Probe;
    package Bxs renames FLTK.Widgets.Boxes;

    Width  : constant := 60;
    Height : constant := 40;

    type Picture is array (0 .. Width - 1, 0 .. Height - 1) of Prb.RGB;

    function Taken
           (Item : in out Bxs.Box)
        return Picture
    is
        Result : Picture := (others => (others => -1));
    begin
        if Prb.Capture (Item) then
            for X in Result'Range (1) loop
                for Y in Result'Range (2) loop
                    Result (X, Y) := Prb.Pixel (X, Y);
                end loop;
            end loop;
        end if;
        Prb.Release;
        return Result;
    end Taken;

    function Of_Box
           (Kind : in Box_Kind)
        return Picture
    is
        Item : Bxs.Box := Bxs.Forge.Create (Kind, 0, 0, Width, Height);
    begin
        Item.Set_Background_Color (RGB_Red_Color);
        return Taken (Item);
    end Of_Box;

    function Of_Label
           (Kind : in Label_Kind)
        return Picture
    is
        Item : Bxs.Box := Bxs.Forge.Create (Flat_Box, 0, 0, Width, Height, "Ag");
    begin
        Item.Set_Background_Color (White_Color);
        Item.Set_Label_Color (RGB_Red_Color);
        Item.Set_Label_Size (24);
        Item.Set_Label_Kind (Kind);
        return Taken (Item);
    end Of_Label;

    type Box_Case is record
        Kind, Stand_In : Box_Kind;
    end record;

    --  One type for each fl_define_FL_* function, with its stand-in.
    Boxes : constant array (Positive range <>) of Box_Case :=
       ((Shadow_Box, Border_Box),
        (Rounded_Box, Border_Box),
        (RShadow_Box, Border_Box),
        (RFlat_Box, Flat_Box),
        (Round_Up_Box, Up_Box),
        (Diamond_Up_Box, Up_Box),
        (Oval_Box, Border_Box),
        (Plastic_Up_Box, Up_Box),
        (Gtk_Up_Box, Up_Box),
        (Gleam_Up_Box, Up_Box),
        (Oxy_Up_Box, Up_Box));

    Labels : constant array (Positive range <>) of Label_Kind :=
       (Shadow_Label, Engraved_Label, Embossed_Label);

begin

    for C of Boxes loop
        Check (Of_Box (C.Kind) /= Of_Box (C.Stand_In), Box_Kind'Image (C.Kind)
            & " draws unlike " & Box_Kind'Image (C.Stand_In));
    end loop;

    for Kind of Labels loop
        Check (Of_Label (Kind) /= Of_Label (Normal_Label), Label_Kind'Image (Kind)
            & " draws unlike a normal label");
    end loop;

    --  The pictures are real: a box and a label draw something.
    Check (Of_Box (Up_Box) /= Of_Box (No_Box), "an up box draws");
    Check (Of_Label (Normal_Label) /= Of_Label (No_Label), "a normal label draws");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Defined_Types;
