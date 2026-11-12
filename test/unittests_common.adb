--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Draw,
    FLTK.Widgets.Boxes;

use type

    FLTK.Alignment;


package body Unittests_Common is


    package FD renames FLTK.Draw;
    package Bx renames FLTK.Widgets.Boxes;


    procedure Draw_Alignment_Indicators
           (This : in out Main_Window)
    is
        Size : constant := 16;
        W    : constant Integer := This.Get_W;
        H    : constant Integer := This.Get_H;
    begin
        --  Top left corner.
        FD.Set_Color (FLTK.Green_Color);
        FD.Why_Ecks_Line (0, Size, 0, Size);
        FD.Set_Color (FLTK.Red_Color);
        FD.Why_Ecks_Line (-1, Size, -1, Size);
        FD.Set_Color (FLTK.White_Color);
        FD.Rect_Fill (3, 3, Size - 2, Size - 2);
        FD.Set_Color (FLTK.Black_Color);
        FD.Rect (3, 3, Size - 2, Size - 2);

        --  Bottom left corner.
        FD.Set_Color (FLTK.Green_Color);
        FD.Why_Ecks_Line (0, H - Size - 1, H - 1, Size);
        FD.Set_Color (FLTK.Red_Color);
        FD.Why_Ecks_Line (-1, H - Size - 1, H, Size);
        FD.Set_Color (FLTK.White_Color);
        FD.Rect_Fill (3, H - Size - 1, Size - 2, Size - 2);
        FD.Set_Color (FLTK.Black_Color);
        FD.Rect (3, H - Size - 1, Size - 2, Size - 2);

        --  Bottom right corner.
        FD.Set_Color (FLTK.Green_Color);
        FD.Why_Ecks_Line (W - 1, H - Size - 1, H - 1, W - Size - 1);
        FD.Set_Color (FLTK.Red_Color);
        FD.Why_Ecks_Line (W, H - Size - 1, H, W - Size - 1);
        FD.Set_Color (FLTK.White_Color);
        FD.Rect_Fill (W - Size - 1, H - Size - 1, Size - 2, Size - 2);
        FD.Set_Color (FLTK.Black_Color);
        FD.Rect (W - Size - 1, H - Size - 1, Size - 2, Size - 2);

        --  Top right corner.
        FD.Set_Color (FLTK.Green_Color);
        FD.Why_Ecks_Line (W - 1, Size, 0, W - Size - 1);
        FD.Set_Color (FLTK.Red_Color);
        FD.Why_Ecks_Line (W, Size, -1, W - Size - 1);
        FD.Set_Color (FLTK.White_Color);
        FD.Rect_Fill (W - Size - 1, 3, Size - 2, Size - 2);
        FD.Set_Color (FLTK.Black_Color);
        FD.Rect (W - Size - 1, 3, Size - 2, Size - 2);
    end Draw_Alignment_Indicators;


    procedure Draw
           (This : in out Main_Window) is
    begin
        FLTK.Widgets.Groups.Windows.Double.Double_Window (This).Draw;
        if This.Draw_Alignment_Test then
            Draw_Alignment_Indicators (This);
        end if;
    end Draw;


    procedure Test_Alignment
           (This : in out Main_Window;
            Show : in     Boolean) is
    begin
        This.Draw_Alignment_Test := Show;
        This.Redraw;
    end Test_Alignment;


    type Box_Access is access Bx.Box;


    procedure Add_Box
           (X, Y, W : in Integer;
            Label   : in String;
            Tooltip : in String)
    is
        T : constant Box_Access := new Bx.Box'(Bx.Forge.Create (X, Y, W, 18, Label));
    begin
        T.Set_Box (FLTK.Rounded_Box);
        T.Set_Background_Color (FLTK.Yellow_Color);
        T.Set_Tooltip (Tooltip);
    end Add_Box;


    procedure Add_Heading
           (X, Y  : in Integer;
            Label : in String)
    is
        T : constant Box_Access := new Bx.Box'(Bx.Forge.Create (X, Y, 80, 18, Label));
    begin
        T.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
    end Add_Heading;


end Unittests_Common;


