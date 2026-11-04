--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 10, pofltk 55: Fl_Multi_Label::label (Fl_Widget *)
--  calls o->label (FL_MULTI_LABEL, this), which keeps a copied label's
--  COPIED_LABEL flag, so FLTK later free()s the multi-label.  And once a
--  label is a pointer (a multi-label, an icon or an image), Get_Label
--  read the pointer as text, and Set_Label_Kind could make FLTK read
--  text as a pointer.


with

    Ada.Exceptions,
    Checks,
    FLTK.Multi_Labels,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Widget_Multi_Label is

    package ML  renames FLTK.Multi_Labels;
    package Prb renames FLTK.Probe;
    package Box renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    --  Declared first, so it outlives the widgets that show it.
    Multi : ML.Multi_Label := ML.Forge.Create;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Start");
    Shown  : Box.Box := Box.Forge.Create (Window, 10, 10, 100, 40, "copied");
    Blank  : constant Box.Box := Box.Forge.Create (Window, 10, 60, 100, 40);
    Plain  : constant Box.Box := Box.Forge.Create (Window, 10, 110, 100, 40, "plain");
    Text   : Box.Box := Box.Forge.Create (Window, 150, 10, 100, 40, "text");

    --  A checksum of the pixels of a capture of Item.
    function Signature
           (Item : in FLTK.Widgets.Widget'Class)
        return Long_Long_Integer
    is
        Sum : Long_Long_Integer := 0;
    begin
        if not Prb.Capture (Item) then
            return -1;
        end if;
        for Y in 0 .. Item.Get_H - 1 loop
            for X in 0 .. Item.Get_W - 1 loop
                Sum := (Sum * 31 + Long_Long_Integer (Prb.Pixel (X, Y))) mod 16#7FFF_FFFF#;
            end loop;
        end loop;
        Prb.Release;
        return Sum;
    end Signature;

begin

    Window.End_Current;
    Multi.Set_First ("A");
    Multi.Set_Second ("B");

    --  A copied label replaced by a multi-label.
    ML.Set_Multi_Label (Shown, Multi);
    Check (Shown.Get_Label_Kind = Multi_Label, "the widget shows a multi-label");
    Check (Shown.Get_Label = "", "Get_Label is """" for a multi-label");
    Check (Signature (Shown) /= Signature (Blank), "the multi-label is drawn");

    Shown.Set_Label_Kind (Shadow_Label);
    Check (Shown.Get_Label_Kind = Multi_Label,
        "Set_Label_Kind leaves a multi-label a multi-label");

    --  Text replaces it as a normal label.
    Shown.Set_Label ("plain");
    Check (Shown.Get_Label_Kind = Normal_Label, "Set_Label makes the label normal");
    Check (Shown.Get_Label = "plain", "and sets its text");
    Check (Signature (Shown) = Signature (Plain), "and it is drawn as text");

    --  Text never becomes a pointer label.
    for Kind in reverse Label_Kind range Multi_Label .. Image_Label loop
        Text.Set_Label_Kind (Kind);
        Check (Text.Get_Label_Kind = Normal_Label,
            "text is not made a " & Label_Kind'Image (Kind));
    end loop;
    Check (Text.Get_Label = "text", "and keeps its text");
    Check (Signature (Text) /= Signature (Blank), "and is drawn");

    --  A window's title replaces its multi-label.
    ML.Set_Multi_Label (Window, Multi);
    Check (Window.Get_Label = "", "a window's multi-label has no text");
    Window.Set_Label ("title");
    Check (Window.Get_Label = "title", "Set_Label gives the window a title again");
    Check (Window.Get_Label_Kind = Normal_Label, "as a normal label");

    --  The last widget shows the multi-label when they are finalized.
    ML.Set_Multi_Label (Shown, Multi);

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Widget_Multi_Label;
