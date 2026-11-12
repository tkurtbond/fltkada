--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/resize.fl: buttons that move the window 50 pixels each way,
--  and grow and shrink it by 20.  Ported from the C++ that FLUID writes
--  from it, guided by pofltk's Resize.Mod.


with

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment;


function Resize
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;


    W : Dbl.Double_Window := Dbl.Forge.Create (366, 261);

    Left   : Btn.Button := Btn.Forge.Create (W, 20, 40, 40, 40, "@<-");
    Down   : Btn.Button := Btn.Forge.Create (W, 60, 80, 40, 40, "@2->");
    Right  : Btn.Button := Btn.Forge.Create (W, 100, 40, 40, 40, "@->");
    Up     : Btn.Button := Btn.Forge.Create (W, 60, 0, 40, 40, "@8->");
    Grow   : Btn.Button := Btn.Forge.Create (W, 30, 130, 110, 40, "grow");
    Shrink : Btn.Button := Btn.Forge.Create (W, 30, 190, 110, 40, "shrink");

    Text : Bx.Box := Bx.Forge.Create
       (W, 150, 10, 160, 220,
        "This is a test of program-generated resize() of a window.  The window should " &
        "move or resize once when each button is clicked.  The program and window manag" &
        "er should not go into fits echoing resizes back and forth!");


    procedure Move
           (DX, DY : in Integer) is
    begin
        W.Reposition (W.Get_X + DX, W.Get_Y + DY);
    end Move;

    procedure Left_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Move (-50, 0);
    end Left_Callback;

    procedure Down_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Move (0, 50);
    end Down_Callback;

    procedure Right_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Move (50, 0);
    end Right_Callback;

    procedure Up_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Move (0, -50);
    end Up_Callback;

    procedure Grow_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        W.Resize (W.Get_W + 20, W.Get_H + 20);
    end Grow_Callback;

    procedure Shrink_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        W.Resize (W.Get_W - 20, W.Get_H - 20);
    end Shrink_Callback;


begin

    Left.Set_Callback (Left_Callback'Unrestricted_Access);
    Down.Set_Callback (Down_Callback'Unrestricted_Access);
    Right.Set_Callback (Right_Callback'Unrestricted_Access);
    Up.Set_Callback (Up_Callback'Unrestricted_Access);

    Grow.Set_Label_Font (FLTK.Helvetica_Bold);
    Grow.Set_Label_Size (18);
    Grow.Set_Callback (Grow_Callback'Unrestricted_Access);
    Shrink.Set_Label_Font (FLTK.Helvetica_Bold);
    Shrink.Set_Label_Size (18);
    Shrink.Set_Callback (Shrink_Callback'Unrestricted_Access);

    Text.Set_Box (FLTK.Border_Box);
    Text.Set_Alignment (FLTK.Align_Wrap + FLTK.Align_Left + FLTK.Align_Inside);

    W.Set_Resizable (W);
    W.Show_With_Args;

    return FLTK.Run;

end Resize;
