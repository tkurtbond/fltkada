--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/resize-example1.cxx: a group of fifteen boxes, itself its
--  resizable, shown at its first size and resized horizontally,
--  vertically and both ways, with arrows showing the widths and heights
--  before and after:  every box grows.  The window starts larger than it
--  was made, so the copies are already resized.  Guided by pofltk's
--  ResizeExample1.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    Resize_Arrows;

use type

    FLTK.Alignment;


function Resize_Example1
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Arw renames Resize_Arrows;

    --  inner box dimensions
    Ax : constant := 0;   Bx_X : constant := 35;  Cx : constant := 70;  Dx : constant := 105;
    Nx : constant := 140; Aw   : constant := 35;  Rw : constant := 70;  Mw : constant := 140;
    Ay : constant := 0;   Ey   : constant := 35;  Gy : constant := 70;  Iy : constant := 105;
    My : constant := 140; Ah   : constant := 35;  Rh : constant := 70;  Nh : constant := 175;

    --  resize box and arrow group dimensions
    TLx : constant := 35; TRx : constant := 245; TGx : constant := 420;
    TLw : constant := 175; TGw : constant := 140; TAw : constant := 35;
    TLy : constant := 35; BLy : constant := 245; LGy : constant := 420;
    TLh : constant := 175; LGh : constant := 105; LAh : constant := 35;

    --  window dimensions
    Ww : constant := 560;
    Wh : constant := 525;


    --  FLTK's FL_FRAME_BOX is FL_ENGRAVED_BOX.
    function Make
           (Parent     : in out Grp.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String;
            Hue        : in     FLTK.Color)
        return Bx.Box is
    begin
        return This : Bx.Box := Bx.Forge.Create (Parent, FLTK.Engraved_Box, X, Y, W, H, Text) do
            This.Set_Background_Color (Hue);
        end return;
    end Make;


    --  FLTK's class Resizebox:  the group and its boxes, in FLTK's order.
    generic
        Parent     : in out Grp.Group;
        X, Y, W, H : in     Integer;
        Text       : in     String;
    package Resize_Box is
        Group : Grp.Group := Grp.Forge.Create (Parent, X, Y, W, H, Text);
        A : Bx.Box := Make (Group, X + Ax,   Y + Ay, Aw, Ah, "A", 14);
        B : Bx.Box := Make (Group, X + Bx_X, Y + Ay, Aw, Ah, "B", 9);
        C : Bx.Box := Make (Group, X + Cx,   Y + Ay, Aw, Ah, "C", 10);
        D : Bx.Box := Make (Group, X + Dx,   Y + Ay, Aw, Ah, "D", 11);
        E : Bx.Box := Make (Group, X + Ax,   Y + Ey, Aw, Ah, "E", 9);
        R : Bx.Box := Make (Group, X + Bx_X, Y + Ey, Rw, Rh, " ", 8);
        F : Bx.Box := Make (Group, X + Dx,   Y + Ey, Aw, Ah, "F", 12);
        G : Bx.Box := Make (Group, X + Ax,   Y + Gy, Aw, Ah, "G", 10);
        H_Box : Bx.Box := Make (Group, X + Dx, Y + Gy, Aw, Ah, "H", 13);
        I : Bx.Box := Make (Group, X + Ax,   Y + Iy, Aw, Ah, "I", 11);
        J : Bx.Box := Make (Group, X + Bx_X, Y + Iy, Aw, Ah, "J", 12);
        K : Bx.Box := Make (Group, X + Cx,   Y + Iy, Aw, Ah, "K", 13);
        L : Bx.Box := Make (Group, X + Dx,   Y + Iy, Aw, Ah, "L", 14);
        M : Bx.Box := Make (Group, X + Ax,   Y + My, Mw, Ah, "M", 12);
        N : Bx.Box := Make (Group, X + Nx,   Y + Ay, Aw, Nh, "N", 13);
    end Resize_Box;

    package body Resize_Box is
    begin
        Group.Set_Alignment (FLTK.Align_Top + FLTK.Align_Left);
        Group.Set_Box (FLTK.Up_Box);
        Group.Set_Resizable (Group);
    end Resize_Box;


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

        Window : Dbl.Double_Window := Dbl.Forge.Create (Ww, Wh, "resize-example1");

        --  FLTK's class Resizables
        Resizables : Grp.Group := Grp.Forge.Create (Window, 0, 0, Ww, Wh);

        package TL is new Resize_Box (Resizables, TLx, TLy, TLw, TLh, "Original Size");
        package TR is new Resize_Box (Resizables, TRx, TLy, TLw, TLh, "Horizontally Resized");
        package BL is new Resize_Box (Resizables, TLx, BLy, TLw, TLh, "Vertically Resized");
        package BR is new Resize_Box
            (Resizables, TRx, BLy, TLw, TLh, "Horizontally and Vertically Resized");

        LG : Grp.Group := Grp.Forge.Create (Resizables, TLx, LGy, TLw, LGh);
        LA : constant Arw.Harrow := Arw.Forge.Create
            (LG, LG.Get_X, LG.Get_Y, LG.Get_W, LAh, "Initial" & ASCII.LF & "width");

        RG : Grp.Group := Grp.Forge.Create (Resizables, TRx, LGy, TLw, LGh);
        RA : constant Arw.Harrow := Arw.Forge.Create
            (RG, RG.Get_X, RG.Get_Y, RG.Get_W, LAh, "Resized" & ASCII.LF & "width");

        TG : Grp.Group := Grp.Forge.Create (Resizables, TGx, TLy, TGw, TLh);
        TA : constant Arw.Varrow := Arw.Forge.Create
            (TG, TGx, TLy, TAw, TLh, "Initial" & ASCII.LF & "height");

        BG : Grp.Group := Grp.Forge.Create (Resizables, TGx, BLy, TGw, TLh);
        BA : constant Arw.Varrow := Arw.Forge.Create
            (BG, TGx, BLy, TAw, TLh, "Resized" & ASCII.LF & "height");

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
        Window.Resize (Ww + 140, Wh + 35);

        return FLTK.Run;

    end;

end Resize_Example1;

