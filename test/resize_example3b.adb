--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/resize-example3b.cxx: resize-example3a's dialog of an
--  icon, a message and a button, with the message its resizable.  The
--  message grows, and the button is pushed out of the dialog, as the
--  button is in line with it.  Guided by pofltk's ResizeExample3b.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double,
    Resize_Arrows;

use type

    FLTK.Alignment;


function Resize_Example3b
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Arw renames Resize_Arrows;

    --  resize dialog and arrow dimensions
    TLx : constant := 35; TRx : constant := 270; TGx : constant := 470;
    TLw : constant := 200; TGw : constant := 120; TAw : constant := 35;
    TLy : constant := 35; BLy : constant := 160; LGy : constant := 250;
    TLh : constant := 90; LGh : constant := 90; LAh : constant := 35;

    --  window dimensions
    Ww : constant := 590;
    Wh : constant := 340;


    --  FLTK's class ResizeDialog.
    generic
        Parent     : in out Grp.Group;
        X, Y, W, H : in     Integer;
        Text       : in     String;
    package Resize_Dialog is
        Group   : Grp.Group := Grp.Forge.Create (Parent, X, Y, W, H, Text);
        Icon    : Bx.Box := Bx.Forge.Create (Group, X + 10, Y + 10, 30, 30, "!");
        Message : Bx.Box := Bx.Forge.Create (Group, X + 50, Y + 10, 140, 30, "Out of Memory");
        Button  : Btn.Button := Btn.Forge.Create (Group, X + 140, Y + 50, 50, 30, "Darn!");
    end Resize_Dialog;

    package body Resize_Dialog is
    begin
        Group.Set_Alignment (FLTK.Align_Top + FLTK.Align_Left);
        Group.Set_Box (FLTK.Up_Box);
        Icon.Set_Box (FLTK.Down_Box);
        Message.Set_Box (FLTK.Down_Box);
        Message.Set_Background_Color (FLTK.Yellow_Color);
        Group.Set_Resizable (Message);
    end Resize_Dialog;


    --  A group of no box for an arrow.
    procedure Set_Up
           (Item : in out Grp.Group) is
    begin
        Item.Set_Box (FLTK.No_Box);
        Item.Set_Background_Color (FLTK.White_Color);
    end Set_Up;

begin

    FLTK.Static.Parse_Args;

    declare

        Window : Dbl.Double_Window := Dbl.Forge.Create (Ww, Wh, "resize-example3b");

        --  FLTK's class Resizables
        Resizables : Grp.Group := Grp.Forge.Create (Window, 0, 0, Ww, Wh);

        package TL is new Resize_Dialog (Resizables, TLx, TLy, TLw, TLh, "Original Size");
        package TR is new Resize_Dialog (Resizables, TRx, TLy, TLw, TLh, "Horizontally Resized");
        package BL is new Resize_Dialog (Resizables, TLx, BLy, TLw, TLh, "Vertically Resized");
        package BR is new Resize_Dialog
            (Resizables, TRx, BLy, TLw, TLh, "Horizontally and Vertically Resized");

        LG : Grp.Group := Grp.Forge.Create (Resizables, TLx, LGy, TLw, LGh);
        LA : constant Arw.Harrow := Arw.Forge.Create
            (LG, BL.Message.Get_X, LG.Get_Y, BL.Message.Get_W, LAh, "Initial" & ASCII.LF & "width");

        RG : Grp.Group := Grp.Forge.Create (Resizables, TRx, LGy, TLw, LGh);
        RA : constant Arw.Harrow := Arw.Forge.Create
            (RG, BR.Message.Get_X, LG.Get_Y, BL.Message.Get_W, LAh, "Resized" & ASCII.LF & "width");

        TG : Grp.Group := Grp.Forge.Create (Resizables, TGx, TLy, TGw, TLh);
        TA : constant Arw.Varrow := Arw.Forge.Create
            (TG, TG.Get_X, TR.Message.Get_Y, TAw, TR.Message.Get_H,
             "Initial" & ASCII.LF & "height");

        BG : Grp.Group := Grp.Forge.Create (Resizables, TGx, BLy, TGw, TLh);
        BA : constant Arw.Varrow := Arw.Forge.Create
            (BG, BG.Get_X, BR.Message.Get_Y, TAw, BR.Message.Get_H,
             "Resized" & ASCII.LF & "height");

    begin

        Window.Set_Background_Color (FLTK.White_Color);

        Resizables.Set_Box (FLTK.Up_Box);
        Resizables.Set_Background_Color (FLTK.White_Color);
        TL.Group.Clear_Resizable;

        Set_Up (LG);
        LG.Set_Resizable (LA);
        Set_Up (RG);
        RG.Set_Resizable (RA);
        Set_Up (TG);
        TG.Set_Resizable (TA);
        Set_Up (BG);
        BG.Set_Resizable (BA);

        Resizables.Set_Resizable (BR.Group);

        Window.End_Current;
        Window.Set_Resizable (Resizables);
        Window.Set_Size_Range (Ww, Wh);
        Window.Show_With_Args;
        Window.Resize (Ww + 50, Wh + 35);

        --  suppress focus box
        FLTK.Static.Set_Option (FLTK.Static.Visible_Focus, False);

        return FLTK.Run;

    end;

end Resize_Example3b;

