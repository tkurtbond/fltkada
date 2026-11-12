--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/resize-example4b.cxx: resize-example4a's row of buttons
--  and inputs split into two groups, each with its input as its
--  resizable, in a group that is its own resizable.  Both inputs grow.
--  Guided by pofltk's ResizeExample4b.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    Resize_Arrows;

use type

    FLTK.Alignment;


function Resize_Example4b
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Arw renames Resize_Arrows;

    --  window, complex and arrow dimensions
    TLx : constant := 35; TRx : constant := 320; TLw : constant := 260; Ww : constant := 620;
    TLy : constant := 35; LGy : constant := 100; TLh : constant := 65; LGh : constant := 80;
    LAh : constant := 35; Wh  : constant := 200;


    --  A box of FL_UP_BOX.
    function Make
           (Parent     : in out Grp.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String)
        return Bx.Box is
    begin
        return Bx.Forge.Create (Parent, FLTK.Up_Box, X, Y, W, H, Text);
    end Make;


    --  FLTK's class Complex.
    generic
        Parent     : in out Grp.Group;
        X, Y, W, H : in     Integer;
        Text       : in     String;
    package Complex is
        Group   : Grp.Group := Grp.Forge.Create (Parent, X, Y, W, H, Text);
        Left    : Grp.Group := Grp.Forge.Create (Group, X + 10, Y + 10, 120, 45);
        Button1 : Bx.Box := Make (Left, X + 20, Y + 20, 40, 25, "btn");
        Input1  : Bx.Box := Make (Left, X + 70, Y + 20, 50, 25, "input");
        Right   : Grp.Group := Grp.Forge.Create (Group, X + 130, Y + 10, 120, 45);
        Button2 : Bx.Box := Make (Right, X + 140, Y + 20, 40, 25, "btn");
        Input2  : Bx.Box := Make (Right, X + 190, Y + 20, 50, 25, "input");
    end Complex;

    package body Complex is
    begin
        Group.Set_Box (FLTK.Up_Box);
        Left.Set_Box (FLTK.Up_Box);
        Input1.Set_Background_Color (FLTK.Yellow_Color);
        Left.Set_Resizable (Input1);
        Right.Set_Box (FLTK.Up_Box);
        Input2.Set_Background_Color (FLTK.Yellow_Color);
        Right.Set_Resizable (Input2);
        Group.Set_Alignment (FLTK.Align_Top + FLTK.Align_Left);
    end Complex;


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

        Window : Dbl.Double_Window := Dbl.Forge.Create (Ww, Wh, "resize-example4b");

        --  FLTK's class Resizables
        Resizables : Grp.Group := Grp.Forge.Create (Window, 0, 0, Ww, Wh);

        package TL is new Complex (Resizables, TLx, TLy, TLw, TLh, "Original");
        --  FLTK's typo
        package TR is new Complex (Resizables, TRx, TLy, TLw, TLh, "Horizonally Resized");

        LG : Grp.Group := Grp.Forge.Create (Resizables, TLx, LGy, TLw, LGh);
        LA : constant Arw.Harrow := Arw.Forge.Create
            (LG, TL.Input2.Get_X, LG.Get_Y, TL.Input2.Get_W, LAh, "Initial" & ASCII.LF & "width");

        RG  : Grp.Group := Grp.Forge.Create (Resizables, TRx, LGy, TLw, LGh);
        RG0 : Grp.Group := Grp.Forge.Create (RG, TRx, LGy, TLw / 2, LGh);
        RG1 : Grp.Group := Grp.Forge.Create (RG, TRx + TLw / 2, LGy, TLw / 2, LGh);
        RA  : constant Arw.Harrow := Arw.Forge.Create
            (RG1, TR.Input2.Get_X, RG1.Get_Y, TR.Input2.Get_W, LAh, "Resized" & ASCII.LF & "width");

    begin

        Window.Set_Background_Color (FLTK.White_Color);

        Set_Up (LG);
        LG.Set_Resizable (LA);
        Set_Up (RG);
        Set_Up (RG0);
        Set_Up (RG1);
        RG1.Set_Resizable (RA);

        Resizables.Set_Resizable (TR.Group);

        Window.End_Current;
        Window.Set_Resizable (Resizables);
        Window.Set_Size_Range (Ww, Wh);
        Window.Show_With_Args;
        Window.Resize (Ww + 90, Wh);

        return FLTK.Run;

    end;

end Resize_Example4b;

