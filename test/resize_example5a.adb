--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/resize-example5a.cxx: a yellow group of three boxes, the
--  group's own resizable, shown at its first size and resized
--  horizontally.  All three boxes grow.  Guided by pofltk's
--  ResizeExample5a.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    Resize_Arrows;

use type

    FLTK.Alignment;


function Resize_Example5a
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Arw renames Resize_Arrows;

    --  window, simplex and arrow dimensions
    TLx : constant := 35; TRx : constant := 320; TLw : constant := 260; Ww : constant := 620;
    TLy : constant := 35; LGy : constant := 100; TLh : constant := 65; LGh : constant := 70;
    LAh : constant := 35; Wh  : constant := 175;


    --  A box of FL_UP_BOX.
    function Make
           (Parent     : in out Grp.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String)
        return Bx.Box is
    begin
        return Bx.Forge.Create (Parent, FLTK.Up_Box, X, Y, W, H, Text);
    end Make;


    --  FLTK's class Simplex.
    generic
        Parent     : in out Grp.Group;
        X, Y, W, H : in     Integer;
        Text       : in     String;
    package Simplex is
        Group   : Grp.Group := Grp.Forge.Create (Parent, X, Y, W, H, Text);
        Inner   : Grp.Group := Grp.Forge.Create (Group, X + 10, Y + 10, 240, 45);
        Box_A   : Bx.Box := Make (Inner, X + 20, Y + 20, 80, 25, "A");
        Box_B   : Bx.Box := Make (Inner, X + 110, Y + 20, 40, 25, "B");
        Box_C   : Bx.Box := Make (Inner, X + 160, Y + 20, 80, 25, "C");
    end Simplex;

    package body Simplex is
    begin
        Group.Set_Box (FLTK.Up_Box);
        Inner.Set_Box (FLTK.Up_Box);
        Inner.Set_Background_Color (FLTK.Yellow_Color);
        Group.Set_Resizable (Inner);
        Group.Set_Alignment (FLTK.Align_Top + FLTK.Align_Left);
    end Simplex;


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

        Window : Dbl.Double_Window := Dbl.Forge.Create (Ww, Wh, "resize-example5a");

        --  FLTK's class Resizables
        Resizables : Grp.Group := Grp.Forge.Create (Window, 0, 0, Ww, Wh);

        package TL is new Simplex (Resizables, TLx, TLy, TLw, TLh, "Original");
        package TR is new Simplex (Resizables, TRx, TLy, TLw, TLh, "Horizontally Resized");

        LG : Grp.Group := Grp.Forge.Create (Resizables, TLx, LGy, TLw, LGh);
        LA : constant Arw.Harrow := Arw.Forge.Create
            (LG, TL.Inner.Get_X, LG.Get_Y, TL.Inner.Get_W, LAh, "Initial" & ASCII.LF & "width");

        RG : Grp.Group := Grp.Forge.Create (Resizables, TRx, LGy, TLw, LGh);
        RA : constant Arw.Harrow := Arw.Forge.Create
            (RG, TR.Inner.Get_X, RG.Get_Y, TR.Inner.Get_W, LAh, "Resized" & ASCII.LF & "width");

    begin

        Window.Set_Background_Color (FLTK.White_Color);

        Set_Up (LG);
        LG.Set_Resizable (LA);
        Set_Up (RG);
        RG.Set_Resizable (RA);

        Resizables.Set_Resizable (TR.Group);

        Window.End_Current;
        Window.Set_Resizable (Resizables);
        Window.Set_Size_Range (Ww, Wh);
        Window.Show_With_Args;
        Window.Resize (Ww + 90, Wh);

        return FLTK.Run;

    end;

end Resize_Example5a;

