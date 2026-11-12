--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Draw,
    FLTK.Widgets;

use type

    FLTK.Alignment;


package body Unittests_Symbol is


    use FLTK, FLTK.Draw, Unittests_Common;


    --  Test symbol rendering
    type Symbol_Test is new FLTK.Widgets.Widget with null record;

    overriding procedure Draw
           (This : in out Symbol_Test);

    type Symbol_Test_Access is access Symbol_Test;


    procedure Draw_Text_And_Boxes
           (Txt  : in String;
            X, Y : in Integer)
    is
        WO, HO : Natural;
    begin
        Measure (Txt, WO, HO, Symbols => True);
        --  Draw fl_measure() rect
        Set_Color (Red_Color);
        Rect (X, Y, WO, HO);
        --  The C++ leaves out fl_text_extents(), which doesn't handle
        --  multiline strings yet.
        --  Draw text with symbols enabled
        Set_Color (Black_Color);
        Draw_Text (X, Y, 10, 10, Txt, Align_Inside + Align_Top + Align_Left, Symbols => True);
    end Draw_Text_And_Boxes;


    procedure Draw
           (This : in out Symbol_Test)
    is
        X0    : constant Integer := This.Get_X;
        Y0    : constant Integer := This.Get_Y;
        W0    : constant Integer := This.Get_W;
        H0    : constant Integer := This.Get_H;
        FSize : constant Integer := 25;
        XX    : Integer := X0 + 10;
        YY    : Integer := Y0 + 10;
        LF    : constant Character := ASCII.LF;
    begin
        Push_Clip (X0, Y0, W0, H0);
        --  set the background colour - slightly off-white to enhance the
        --  green bounding box
        Set_Color (Grey_Ramp (Greyscale'Val (Greyscale'Pos (Greyscale'Last) - 2)));
        Rect_Fill (X0, Y0, W0, H0);
        Set_Font (Helvetica, Font_Size (FSize));
        Draw_Text_And_Boxes ("Text", XX, YY);           --  check no symbols
        YY := YY + FSize + 10;
        Draw_Text_And_Boxes ("@->", XX, YY);            --  check symbol alone
        YY := YY + FSize + 10;
        Draw_Text_And_Boxes ("@-> ", XX, YY);           --  check symbol with trailing space
        YY := YY + FSize + 10;
        Draw_Text_And_Boxes ("@-> Rt Arrow", XX, YY);   --  check symbol at left edge
        YY := YY + FSize + 10;
        Draw_Text_And_Boxes ("Lt Arrow @<-", XX, YY);   --  check symbol at right edge
        YY := YY + FSize + 10;
        Draw_Text_And_Boxes ("@-> Rt/Lt @<-", XX, YY);  --  check symbol at lt+rt edges
        YY := YY + FSize + 10;
        Draw_Text_And_Boxes ("@@ At/Lt @<-", XX, YY);   --  check @@ at left, symbol at right
        YY := YY + FSize + 10;
        Draw_Text_And_Boxes ("@-> Lt/At @@", XX, YY);   --  check symbol at left, @@ at right
        YY := YY + FSize + 10;
        Draw_Text_And_Boxes ("@@ At/At @@", XX, YY);    --  check @@ at left+right
        XX := X0 + 200;
        YY := Y0 + 10;
        Draw_Text_And_Boxes ("Line1" & LF & "Line2", XX, YY);
        YY := YY + (FSize + 10) * 2;                     --  check 2 lines, no symbol
        Draw_Text_And_Boxes ("@-> Line1" & LF & "Line2 @<-", XX, YY);
        YY := YY + (FSize + 10) * 2;                     --  check 2 lines, lt+rt symbols
        Draw_Text_And_Boxes ("@-> Line1" & LF & "Line2" & LF & "Line3 @<-", XX, YY);
        YY := YY + (FSize + 10) * 3;                     --  check 3 lines, lt+rt symbols
        Draw_Text_And_Boxes ("@@@@", XX, YY);           --  check abutting @@'s
        YY := YY + (FSize + 10);
        Draw_Text_And_Boxes ("@@ @@", XX, YY);          --  check @@'s with space sep

        Set_Font (Helvetica, 14);
        Set_Color (Red_Color);
        Draw_Text (X0 + 10, Y0 + H0 - 20, "fl_measure bounding box in RED");
        Pop_Clip;
    end Draw;


    function Create
        return Widget_Access is
    begin
        return Widget_Access (Symbol_Test_Access'(new Symbol_Test'
           (FLTK.Widgets.Forge.Create (Test_Area_X, Test_Area_Y, Test_Area_W, Test_Area_H)
            with null record)));
    end Create;


end Unittests_Symbol;
