


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/device.cxx: a window of drawings with every kind of
--  primitive, and GO, which copies the window, a subwindow or a group to
--  an image surface, the clipboard, a printer or a file, captures it from
--  the screen, or shows it through a mask.  A window that shows a copy is
--  freed at the next GO, or when the program ends, after it is closed,
--  where FLTK deletes it from its callback.  FLTKAda's Printer raises
--  Page_Error whether the job failed or the user cancelled it, and doesn't
--  give FLTK's reason, so a failed print job isn't reported here, where
--  FLTK shows the reason in an alert (FLTKAda-BUGS.md 85).


with

    Ada.Containers.Doubly_Linked_Lists,
    Ada.Exceptions,
    Ada.Numerics.Long_Elementary_Functions,
    Ada.Strings.Unbounded,
    Ada.Unchecked_Deallocation,
    FLTK.Asks,
    FLTK.Devices.Surface.Copy,
    FLTK.Devices.Surface.Image,
    FLTK.Devices.Surface.Paged.PDF,
    FLTK.Devices.Surface.Paged.Postscript,
    FLTK.Devices.Surface.Paged.Printers,
    FLTK.Devices.Surface.SVG,
    FLTK.Draw,
    FLTK.Images.Bitmaps,
    FLTK.Images.Pixmaps,
    FLTK.Images.RGB,
    FLTK.Native_File_Choosers,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Light.Round.Radio,
    FLTK.Widgets.Clocks.Updated,
    FLTK.Widgets.Groups.Windows;


function Device
    return Integer
is


    package SU  renames Ada.Strings.Unbounded;
    package Srf renames FLTK.Devices.Surface;
    package Cps renames FLTK.Devices.Surface.Copy;
    package Ims renames FLTK.Devices.Surface.Image;
    package Pgd renames FLTK.Devices.Surface.Paged;
    package PDF renames FLTK.Devices.Surface.Paged.PDF;
    package PS  renames FLTK.Devices.Surface.Paged.Postscript;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;
    package SVG renames FLTK.Devices.Surface.SVG;
    package Drw renames FLTK.Draw;
    package Bmp renames FLTK.Images.Bitmaps;
    package Pix renames FLTK.Images.Pixmaps;
    package RGB renames FLTK.Images.RGB;
    package NFC renames FLTK.Native_File_Choosers;
    package Wdg renames FLTK.Widgets;
    package Box renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Ent renames FLTK.Widgets.Buttons.Enter;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Rnd renames FLTK.Widgets.Buttons.Light.Round;
    package Rad renames FLTK.Widgets.Buttons.Light.Round.Radio;
    package Clk renames FLTK.Widgets.Clocks.Updated;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Btn.State;
    use type FLTK.Box_Kind;
    use type FLTK.Size_Type;
    use type NFC.Chooser_Option;
    use type NFC.Show_Result;
    use type SU.Unbounded_String;

    function "+" (Str : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;

    LF : constant Character := ASCII.LF;




    --  The Drawings  --

    type Clipping is new Box.Box with null record;
    type Primitives is new Box.Box with null record;
    type Sub_Pixel is new Box.Box with null record;
    type Line_Styles is new Box.Box with null record;
    type Complex is new Box.Box with null record;

    --  FLTK's My_Button: a button with a white cross under its label.
    type Crossed_Button is new Btn.Button with null record;

    overriding procedure Draw
           (This : in out Clipping);

    overriding procedure Draw
           (This : in out Primitives);

    overriding procedure Draw
           (This : in out Sub_Pixel);

    overriding procedure Draw
           (This : in out Line_Styles);

    overriding procedure Draw
           (This : in out Complex);

    overriding procedure Draw
           (This : in out Crossed_Button);


    procedure Draw
           (This : in out Clipping)
    is
        X : constant Integer := This.Get_X;
        Y : constant Integer := This.Get_Y;
        W : constant Integer := This.Get_W;
        H : constant Integer := This.Get_H;
    begin
        Box.Box (This).Draw;
        Drw.Set_Color (FLTK.Red_Color);
        Drw.Rect_Fill (X + 5, Y + 5, W - 10, H - 10);
        Drw.Push_Clip (X + 6, Y + 6, W - 12, H - 12);
        Drw.Set_Color (FLTK.Dark_Green_Color);
        Drw.Rect_Fill (X + 5, Y + 5, W - 10, H - 10);
        Drw.Pop_Clip;
        Drw.Set_Color (FLTK.Yellow_Color);
        Drw.Rect_Fill (X + 7, Y + 7, W - 14, H - 14);
        Drw.Set_Color (FLTK.Blue_Color);

        Drw.Rect (X + 8, Y + 8, W - 16, H - 16);
        Drw.Push_Clip (X + 25, Y + 25, W - 50, H - 50);
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Rect (X + 24, Y + 24, W - 48, H - 48);
        Drw.Line (X + 27, Y + 27, X + W - 27, Y + H - 27);
        Drw.Line (X + 27, Y + H - 27, X + W - 27, Y + 27);
        Drw.Pop_Clip;
    end Draw;


    procedure Draw
           (This : in out Primitives)
    is
        X : constant Integer := This.Get_X;
        Y : constant Integer := This.Get_Y;
        D : Integer;
    begin
        Box.Box (This).Draw;
        D := Y + 5;
        while D < 48 + Y loop
            Drw.Ecks_Why_Line (X + 5, D, X + 48);
            D := D + 2;
        end loop;

        Drw.Push_Clip (X + 52, Y + 5, 45, 43);
        D := Y + 5;
        while D < 150 + Y loop
            Drw.Line (X + 52, D, X + 92, D - 40);
            D := D + 3;
        end loop;
        Drw.Pop_Clip;

        Drw.Set_Line_Style (Drw.Dash_Line);
        Drw.Ecks_Why_Line (X + 5, Y + 55, X + 48);
        Drw.Set_Line_Style (Drw.Dot_Line);
        Drw.Ecks_Why_Line (X + 5, Y + 58, X + 48);
        Drw.Set_Line_Style (Drw.Dashdot_Line);
        Drw.Ecks_Why_Line (X + 5, Y + 61, X + 48);
        Drw.Set_Line_Style (Drw.Dashdotdot_Line);
        Drw.Ecks_Why_Line (X + 5, Y + 64, X + 48);
        Drw.Set_Line_Style (Dashes => ((7, 3), (7, 2)));
        Drw.Ecks_Why_Line (X + 5, Y + 67, X + 48);

        Drw.Set_Line_Style;

        Drw.Line (X + 5, Y + 72, X + 25, Y + 95);
        Drw.Line (X + 8, Y + 72, X + 28, Y + 95, X + 31, Y + 72);

        Drw.Set_Color (FLTK.Yellow_Color);
        Drw.Polygon (X + 11, Y + 72, X + 27, Y + 91, X + 29, Y + 72);
        Drw.Set_Color (FLTK.Red_Color);
        Drw.Outline (X + 11, Y + 72, X + 27, Y + 91, X + 29, Y + 72);

        Drw.Set_Color (FLTK.Blue_Color);
        Drw.Set_Line_Style (Drw.Solid_Line, Width => 6);
        Drw.Outline (X + 31, Y + 12, X + 47, Y + 31, X + 49, Y + 12);
        Drw.Set_Line_Style;

        Drw.Set_Color (200, 0, 200);
        Drw.Polygon (X + 35, Y + 72, X + 33, Y + 95, X + 48, Y + 95, X + 43, Y + 72);
        Drw.Set_Color (FLTK.Green_Color);
        Drw.Outline (X + 35, Y + 72, X + 33, Y + 95, X + 48, Y + 95, X + 43, Y + 72);

        Drw.Set_Color (FLTK.Blue_Color);
        Drw.Why_Ecks_Line (X + 65, Y + 63, Y + 66);
        Drw.Set_Color (FLTK.Green_Color);
        Drw.Why_Ecks_Line (X + 66, Y + 66, Y + 63);

        Drw.Set_Color (FLTK.Blue_Color);
        Drw.Rect (X + 80, Y + 55, 5, 5);
        Drw.Set_Color (FLTK.Yellow_Color);
        Drw.Rect_Fill (X + 81, Y + 56, 3, 3);
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Point (X + 82, Y + 57);

        Drw.Set_Color (FLTK.Blue_Color);
        Drw.Rect (X + 56, Y + 79, 24, 17);
        Drw.Set_Color (FLTK.Cyan_Color);
        Drw.Rect_Fill (X + 57, Y + 80, 22, 15);
        Drw.Set_Color (FLTK.Red_Color);
        Drw.Arc (X + 57, Y + 80, 22, 15, 40.0, 270.0);
        Drw.Set_Color (FLTK.Yellow_Color);
        Drw.Pie (X + 58, Y + 81, 20, 13, 40.0, 270.0);

        Drw.Set_Line_Style;

        Drw.Set_Color (FLTK.Black_Color);
        Drw.Point (X + 58, Y + 58);
        Drw.Set_Color (FLTK.Red_Color);
        Drw.Why_Ecks_Line (X + 59, Y + 58, Y + 59);
        Drw.Set_Color (FLTK.Green_Color);
        Drw.Why_Ecks_Line (X + 60, Y + 59, Y + 58);
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Ecks_Why_Line (X + 61, Y + 58, X + 62);
        Drw.Set_Color (FLTK.Red_Color);
        Drw.Ecks_Why_Line (X + 62, Y + 59, X + 61);

        Drw.Set_Color (FLTK.Green_Color);
        Drw.Why_Ecks_Line (X + 57, Y + 58, Y + 59, X + 58);
        Drw.Set_Color (FLTK.Blue_Color);
        Drw.Ecks_Why_Line (X + 58, Y + 60, X + 56, Y + 58);
        Drw.Set_Color (FLTK.Red_Color);
        Drw.Ecks_Why_Line (X + 58, Y + 61, X + 56, Y + 63);
        Drw.Set_Color (FLTK.Green_Color);
        Drw.Why_Ecks_Line (X + 57, Y + 63, Y + 62, X + 58);

        Drw.Set_Color (FLTK.Blue_Color);
        Drw.Line (X + 58, Y + 63, X + 60, Y + 65);
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Line (X + 61, Y + 65, X + 59, Y + 63);

        Drw.Set_Color (FLTK.Black_Color);
    end Draw;


    procedure Draw
           (This : in out Sub_Pixel)
    is
        X : constant Long_Float := Long_Float (This.Get_X);
        Y : constant Long_Float := Long_Float (This.Get_Y);
        D : Long_Float;
    begin
        Box.Box (This).Draw;
        Drw.Push_Clip (This.Get_X + 5, This.Get_Y + 5, 45, 43);
        D := Y + 5.0;
        while D < 95.0 + Y loop
            Drw.Begin_Line;
            Drw.Vertex (X + 5.0, D);
            Drw.Vertex (X + 48.0, D);
            Drw.End_Line;
            D := D + 1.63;
        end loop;
        Drw.Pop_Clip;

        Drw.Push_Clip (This.Get_X + 52, This.Get_Y + 5, 45, 43);
        D := Y + 5.0;
        while D < 150.0 + Y loop
            Drw.Begin_Line;
            Drw.Vertex (X + 52.0, D);
            Drw.Vertex (X + 92.0, D - 43.0);
            Drw.End_Line;
            D := D + 2.3052;
        end loop;
        Drw.Pop_Clip;
    end Draw;


    procedure Draw
           (This : in out Line_Styles)
    is
        --  A line along the top from the left, then down, Width 5, in the
        --  style given; FLTK's lines are at Top 160, 150, .. 10.
        procedure Bent
               (Top    : in Long_Float;
                Line   : in Drw.Line_Kind      := Drw.Solid_Line;
                Cap    : in Drw.Cap_Kind       := Drw.Default_Cap;
                Join   : in Drw.Join_Kind      := Drw.Default_Join;
                Dashes : in Drw.Dash_Gap_Array := Drw.Empty_Dashes) is
        begin
            Drw.Set_Line_Style (Line, Cap, Join, 5, Dashes);
            Drw.Begin_Line;
            Drw.Vertex (10.0, Top);
            Drw.Vertex (200.0 - Top, Top);
            Drw.Vertex (200.0 - Top, 190.0);
            Drw.End_Line;
            Drw.Set_Line_Style;
        end Bent;
    begin
        Box.Box (This).Draw;
        Drw.Push_Matrix;
        Drw.Translate (Long_Float (This.Get_X), Long_Float (This.Get_Y));
        Drw.Scale (0.75, 0.75);

        --  The first in the colour Draw left, as in FLTK.
        Bent (160.0);
        Drw.Set_Color (FLTK.Red_Color);
        Bent (150.0, Cap => Drw.Flat_Cap, Join => Drw.Miter_Join);
        Drw.Set_Color (FLTK.Green_Color);
        Bent (140.0, Cap => Drw.Round_Cap, Join => Drw.Round_Join);
        Drw.Set_Color (FLTK.Blue_Color);
        Bent (130.0, Cap => Drw.Square_Cap, Join => Drw.Bevel_Join);

        Drw.Set_Color (FLTK.Black_Color);
        Bent (120.0, Drw.Dash_Line);
        Drw.Set_Color (FLTK.Red_Color);
        Bent (110.0, Drw.Dash_Line, Drw.Flat_Cap);
        Drw.Set_Color (FLTK.Green_Color);
        Bent (100.0, Drw.Dash_Line, Drw.Round_Cap);
        Drw.Set_Color (FLTK.Blue_Color);
        Bent (90.0, Drw.Dash_Line, Drw.Square_Cap);

        Drw.Set_Color (FLTK.Black_Color);
        Bent (80.0, Drw.Dot_Line);
        Drw.Set_Color (FLTK.Red_Color);
        Bent (70.0, Drw.Dot_Line, Drw.Flat_Cap);
        Drw.Set_Color (FLTK.Green_Color);
        Bent (60.0, Drw.Dot_Line, Drw.Round_Cap);
        Drw.Set_Color (FLTK.Blue_Color);
        Bent (50.0, Drw.Dot_Line, Drw.Square_Cap);

        Drw.Set_Color (FLTK.Black_Color);
        Bent (40.0, Drw.Dashdot_Line, Drw.Round_Cap, Drw.Round_Join);
        Drw.Set_Color (FLTK.Red_Color);
        Bent (30.0, Drw.Dashdotdot_Line, Drw.Square_Cap, Drw.Bevel_Join);
        Drw.Set_Color (FLTK.Green_Color);
        Bent (20.0, Drw.Dashdotdot_Line, Drw.Round_Cap, Drw.Round_Join);
        Drw.Set_Color (FLTK.Blue_Color);
        Bent (10.0, Dashes => ((10, 3), (4, 2), (2, 1)));

        Drw.Pop_Matrix;
        Drw.Set_Color (FLTK.Black_Color);
    end Draw;


    procedure Draw
           (This : in out Complex) is
    begin
        Box.Box (This).Draw;
        Drw.Push_Matrix;

        Drw.Translate (Long_Float (This.Get_X), Long_Float (This.Get_Y));
        Drw.Push_Matrix;
        Drw.Mult_Matrix (1.0, 3.0, 0.0, 1.0, 0.0, -20.0);
        Drw.Set_Color (FLTK.Green_Color);
        Drw.Begin_Polygon;
        Drw.Vertex (10.0, 10.0);
        Drw.Vertex (100.0, -80.0);
        Drw.Vertex (100.0, -190.0);
        Drw.End_Polygon;

        Drw.Set_Color (FLTK.Red_Color);
        Drw.Set_Line_Style (Drw.Dashdot_Line, Width => 7);
        Drw.Begin_Loop;
        Drw.Vertex (10.0, 10.0);
        Drw.Vertex (100.0, -80.0);
        Drw.Vertex (100.0, -190.0);
        Drw.End_Loop;
        Drw.Set_Line_Style;

        Drw.Set_Color (FLTK.Blue_Color);
        Drw.Set_Line_Style (Drw.Solid_Line, Width => 3);
        Drw.Begin_Loop;
        Drw.Circle (60.0, -50.0, 30.0);
        Drw.End_Loop;
        Drw.Set_Line_Style;

        Drw.Pop_Matrix;
        Drw.Scale (1.8, 1.0);

        Drw.Set_Color (FLTK.Yellow_Color);
        Drw.Begin_Polygon;
        Drw.Arc (30.0, 90.0, 20.0, -45.0, 200.0);
        Drw.End_Polygon;

        Drw.Set_Color (FLTK.Black_Color);
        Drw.Set_Line_Style (Drw.Dash_Line, Width => 3);
        Drw.Begin_Line;
        Drw.Arc (30.0, 90.0, 20.0, -45.0, 200.0);
        Drw.End_Line;
        Drw.Set_Line_Style;

        Drw.Translate (15.0, 0.0);
        Drw.Scale (1.5, 3.0);
        Drw.Begin_Complex_Polygon;
        Drw.Vertex (30.0, 70.0);
        Drw.Arc (45.0, 55.0, 10.0, 200.0, 90.0);
        Drw.Arc (55.0, 45.0, 8.0, -170.0, 20.0);
        Drw.Vertex (60.0, 40.0);
        Drw.Vertex (30.0, 20.0);
        Drw.Vertex (40.0, 5.0);
        Drw.Vertex (60.0, 25.0);
        Drw.Curve (35.0, 30.0, 30.0, 53.0, 0.0, 35.0, 65.0, 65.0);
        Drw.Gap;
        Drw.Vertex (50.0, 25.0);
        Drw.Vertex (40.0, 10.0);
        Drw.Vertex (35.0, 20.0);
        Drw.End_Complex_Polygon;

        Drw.Pop_Matrix;
    end Draw;


    procedure Draw
           (This : in out Crossed_Button)
    is
        Kind : FLTK.Box_Kind;
        Hue  : FLTK.Color;
        X    : constant Integer := This.Get_X;
        Y    : constant Integer := This.Get_Y;
        W    : constant Integer := This.Get_W;
        H    : constant Integer := This.Get_H;
    begin
        if This.Get_State = Btn.On then
            Kind := This.Get_Down_Box;
            if Kind = FLTK.No_Box then
                Kind := FLTK.Down (This.Get_Box);
            end if;
            Hue := This.Get_Selection_Color;
        else
            Kind := This.Get_Box;
            Hue := This.Get_Background_Color;
        end if;
        This.Draw_Box (Kind, Hue);
        Drw.Set_Color (FLTK.White_Color);
        Drw.Set_Line_Style (Drw.Solid_Line, Width => 5);
        Drw.Line (X + 15, Y + 10, X + W - 15, Y + H - 23);
        Drw.Line (X + W - 15, Y + 10, X + 15, Y + H - 23);
        Drw.Set_Line_Style;
        This.Draw_Label;
    end Draw;




    --  The Images  --

    Image_Side : constant := 80;

    --  Red in the upper left, green in the lower left, blue in the lower
    --  right, and clearer toward the middle.
    function Make_Image
        return FLTK.Color_Component_Array
    is
        use Ada.Numerics.Long_Elementary_Functions;
        Data  : FLTK.Color_Component_Array (1 .. 4 * Image_Side * Image_Side);
        P     : FLTK.Size_Type := Data'First;
        FX    : Long_Float;
        FY    : Long_Float;
        Alpha : Integer;
        procedure Put
               (Value : in Long_Float) is
        begin
            Data (P) := FLTK.Color_Component (Long_Float'Truncation (Value));
            P := P + 1;
        end Put;
    begin
        for Row in 0 .. Image_Side - 1 loop
            FY := Long_Float (Row) / Long_Float (Image_Side - 1);
            for Column in 0 .. Image_Side - 1 loop
                FX := Long_Float (Column) / Long_Float (Image_Side - 1);
                Put (255.0 * ((1.0 - FX) * (1.0 - FY)));
                Put (255.0 * ((1.0 - FX) * FY));
                Put (255.0 * (FX * FY));
                Alpha := Integer (Long_Float'Truncation
                    (350.0 * Sqrt ((FX - 0.5) ** 2 + (FY - 0.5) ** 2)));
                Put (Long_Float (Integer'Min (Alpha, 255)));
            end loop;
        end loop;
        return Data;
    end Make_Image;


    Sorceress_Width  : constant Integer := 75;
    Sorceress_Height : constant Integer := 75;


    --  It would be slightly more concise to write these numbers in base 10 here
    --  but it is vastly easier to use copy/replace on the 0x syntax
    Sorceress_Bits : constant FLTK.Color_Component_Array :=
    (16#fc#, 16#7e#, 16#40#, 16#20#, 16#90#, 16#00#, 16#07#, 16#80#, 16#23#, 16#00#, 16#00#, 16#c6#,
     16#c1#, 16#41#, 16#98#, 16#b8#, 16#01#, 16#07#, 16#66#, 16#00#, 16#15#, 16#9f#, 16#03#, 16#47#,
     16#8c#, 16#c6#, 16#dc#, 16#7b#, 16#cc#, 16#00#, 16#b0#, 16#71#, 16#0e#, 16#4d#, 16#06#, 16#66#,
     16#73#, 16#8e#, 16#8f#, 16#01#, 16#18#, 16#c4#, 16#39#, 16#4b#, 16#02#, 16#23#, 16#0c#, 16#04#,
     16#1e#, 16#03#, 16#0c#, 16#08#, 16#c7#, 16#ef#, 16#08#, 16#30#, 16#06#, 16#07#, 16#1c#, 16#02#,
     16#06#, 16#30#, 16#18#, 16#ae#, 16#c8#, 16#98#, 16#3f#, 16#78#, 16#20#, 16#06#, 16#02#, 16#20#,
     16#60#, 16#a0#, 16#c4#, 16#1d#, 16#c0#, 16#ff#, 16#41#, 16#04#, 16#fa#, 16#63#, 16#80#, 16#a1#,
     16#a4#, 16#3d#, 16#00#, 16#84#, 16#bf#, 16#04#, 16#0f#, 16#06#, 16#fc#, 16#a1#, 16#34#, 16#6b#,
     16#01#, 16#1c#, 16#c9#, 16#05#, 16#06#, 16#c7#, 16#06#, 16#be#, 16#11#, 16#1e#, 16#43#, 16#30#,
     16#91#, 16#05#, 16#c3#, 16#61#, 16#02#, 16#30#, 16#1b#, 16#30#, 16#cc#, 16#20#, 16#11#, 16#00#,
     16#c1#, 16#3c#, 16#03#, 16#20#, 16#0a#, 16#00#, 16#e8#, 16#60#, 16#21#, 16#00#, 16#61#, 16#1b#,
     16#c1#, 16#63#, 16#08#, 16#f0#, 16#c6#, 16#c7#, 16#21#, 16#03#, 16#f8#, 16#08#, 16#e1#, 16#cf#,
     16#0a#, 16#fc#, 16#4d#, 16#99#, 16#43#, 16#07#, 16#3c#, 16#0c#, 16#f1#, 16#9f#, 16#0b#, 16#fc#,
     16#5b#, 16#81#, 16#47#, 16#02#, 16#16#, 16#04#, 16#31#, 16#1c#, 16#0b#, 16#1f#, 16#17#, 16#89#,
     16#4d#, 16#06#, 16#1a#, 16#04#, 16#31#, 16#38#, 16#02#, 16#07#, 16#56#, 16#89#, 16#49#, 16#04#,
     16#0b#, 16#04#, 16#b1#, 16#72#, 16#82#, 16#a1#, 16#54#, 16#9a#, 16#49#, 16#04#, 16#1d#, 16#66#,
     16#50#, 16#e7#, 16#c2#, 16#f0#, 16#54#, 16#9a#, 16#58#, 16#04#, 16#0d#, 16#62#, 16#c1#, 16#1f#,
     16#44#, 16#fc#, 16#51#, 16#90#, 16#90#, 16#04#, 16#86#, 16#63#, 16#e0#, 16#74#, 16#04#, 16#ef#,
     16#31#, 16#1a#, 16#91#, 16#00#, 16#02#, 16#e2#, 16#c1#, 16#fd#, 16#84#, 16#f9#, 16#30#, 16#0a#,
     16#91#, 16#00#, 16#82#, 16#a9#, 16#c0#, 16#b9#, 16#84#, 16#f9#, 16#31#, 16#16#, 16#81#, 16#00#,
     16#42#, 16#a9#, 16#db#, 16#7f#, 16#0c#, 16#ff#, 16#1c#, 16#16#, 16#11#, 16#00#, 16#02#, 16#28#,
     16#0b#, 16#07#, 16#08#, 16#60#, 16#1c#, 16#02#, 16#91#, 16#00#, 16#46#, 16#29#, 16#0e#, 16#00#,
     16#00#, 16#00#, 16#10#, 16#16#, 16#11#, 16#02#, 16#06#, 16#29#, 16#04#, 16#00#, 16#00#, 16#00#,
     16#10#, 16#16#, 16#91#, 16#06#, 16#a6#, 16#2a#, 16#04#, 16#00#, 16#00#, 16#00#, 16#18#, 16#24#,
     16#91#, 16#04#, 16#86#, 16#2a#, 16#04#, 16#00#, 16#00#, 16#00#, 16#18#, 16#27#, 16#93#, 16#04#,
     16#96#, 16#4a#, 16#04#, 16#00#, 16#00#, 16#00#, 16#04#, 16#02#, 16#91#, 16#04#, 16#86#, 16#4a#,
     16#0c#, 16#00#, 16#00#, 16#00#, 16#1e#, 16#23#, 16#93#, 16#04#, 16#56#, 16#88#, 16#08#, 16#00#,
     16#00#, 16#00#, 16#90#, 16#21#, 16#93#, 16#04#, 16#52#, 16#0a#, 16#09#, 16#80#, 16#01#, 16#00#,
     16#d0#, 16#21#, 16#95#, 16#04#, 16#57#, 16#0a#, 16#0f#, 16#80#, 16#27#, 16#00#, 16#d8#, 16#20#,
     16#9d#, 16#04#, 16#5d#, 16#08#, 16#1c#, 16#80#, 16#67#, 16#00#, 16#e4#, 16#01#, 16#85#, 16#04#,
     16#79#, 16#8a#, 16#3f#, 16#00#, 16#00#, 16#00#, 16#f4#, 16#11#, 16#85#, 16#06#, 16#39#, 16#08#,
     16#7d#, 16#00#, 16#00#, 16#18#, 16#b7#, 16#10#, 16#81#, 16#03#, 16#29#, 16#12#, 16#cb#, 16#00#,
     16#7e#, 16#30#, 16#28#, 16#00#, 16#85#, 16#03#, 16#29#, 16#10#, 16#be#, 16#81#, 16#ff#, 16#27#,
     16#0c#, 16#10#, 16#85#, 16#03#, 16#29#, 16#32#, 16#fa#, 16#c1#, 16#ff#, 16#27#, 16#94#, 16#11#,
     16#85#, 16#03#, 16#28#, 16#20#, 16#6c#, 16#e1#, 16#ff#, 16#07#, 16#0c#, 16#01#, 16#85#, 16#01#,
     16#28#, 16#62#, 16#5c#, 16#e3#, 16#8f#, 16#03#, 16#4e#, 16#91#, 16#80#, 16#05#, 16#39#, 16#40#,
     16#f4#, 16#c2#, 16#ff#, 16#00#, 16#9f#, 16#91#, 16#84#, 16#05#, 16#31#, 16#c6#, 16#e8#, 16#07#,
     16#7f#, 16#80#, 16#cd#, 16#00#, 16#c4#, 16#04#, 16#31#, 16#06#, 16#c9#, 16#0e#, 16#00#, 16#c0#,
     16#48#, 16#88#, 16#e0#, 16#04#, 16#79#, 16#04#, 16#db#, 16#12#, 16#00#, 16#30#, 16#0c#, 16#c8#,
     16#e4#, 16#04#, 16#6d#, 16#06#, 16#b6#, 16#23#, 16#00#, 16#18#, 16#1c#, 16#c0#, 16#84#, 16#04#,
     16#25#, 16#0c#, 16#ff#, 16#c2#, 16#00#, 16#4e#, 16#06#, 16#b0#, 16#80#, 16#04#, 16#3f#, 16#8a#,
     16#b3#, 16#83#, 16#ff#, 16#c3#, 16#03#, 16#91#, 16#84#, 16#04#, 16#2e#, 16#d8#, 16#0f#, 16#3f#,
     16#00#, 16#00#, 16#5f#, 16#83#, 16#84#, 16#04#, 16#2a#, 16#70#, 16#fd#, 16#7f#, 16#00#, 16#00#,
     16#c8#, 16#c0#, 16#84#, 16#04#, 16#4b#, 16#e2#, 16#2f#, 16#01#, 16#00#, 16#08#, 16#58#, 16#60#,
     16#80#, 16#04#, 16#5b#, 16#82#, 16#ff#, 16#01#, 16#00#, 16#08#, 16#d0#, 16#a0#, 16#84#, 16#04#,
     16#72#, 16#80#, 16#e5#, 16#00#, 16#00#, 16#08#, 16#d2#, 16#20#, 16#44#, 16#04#, 16#ca#, 16#02#,
     16#ff#, 16#00#, 16#00#, 16#08#, 16#de#, 16#a0#, 16#44#, 16#04#, 16#82#, 16#02#, 16#6d#, 16#00#,
     16#00#, 16#08#, 16#f6#, 16#b0#, 16#40#, 16#02#, 16#82#, 16#07#, 16#3f#, 16#00#, 16#00#, 16#08#,
     16#44#, 16#58#, 16#44#, 16#02#, 16#93#, 16#3f#, 16#1f#, 16#00#, 16#00#, 16#30#, 16#88#, 16#4f#,
     16#44#, 16#03#, 16#83#, 16#23#, 16#3e#, 16#00#, 16#00#, 16#00#, 16#18#, 16#60#, 16#e0#, 16#07#,
     16#e3#, 16#0f#, 16#fe#, 16#00#, 16#00#, 16#00#, 16#70#, 16#70#, 16#e4#, 16#07#, 16#c7#, 16#1b#,
     16#fe#, 16#01#, 16#00#, 16#00#, 16#e0#, 16#3c#, 16#e4#, 16#07#, 16#c7#, 16#e3#, 16#fe#, 16#1f#,
     16#00#, 16#00#, 16#ff#, 16#1f#, 16#fc#, 16#07#, 16#c7#, 16#03#, 16#f8#, 16#33#, 16#00#, 16#c0#,
     16#f0#, 16#07#, 16#ff#, 16#07#, 16#87#, 16#02#, 16#fc#, 16#43#, 16#00#, 16#60#, 16#f0#, 16#ff#,
     16#ff#, 16#07#, 16#8f#, 16#06#, 16#be#, 16#87#, 16#00#, 16#30#, 16#f8#, 16#ff#, 16#ff#, 16#07#,
     16#8f#, 16#14#, 16#9c#, 16#8f#, 16#00#, 16#00#, 16#fc#, 16#ff#, 16#ff#, 16#07#, 16#9f#, 16#8d#,
     16#8a#, 16#0f#, 16#00#, 16#00#, 16#fe#, 16#ff#, 16#ff#, 16#07#, 16#bf#, 16#0b#, 16#80#, 16#1f#,
     16#00#, 16#00#, 16#ff#, 16#ff#, 16#ff#, 16#07#, 16#7f#, 16#3a#, 16#80#, 16#3f#, 16#00#, 16#80#,
     16#ff#, 16#ff#, 16#ff#, 16#07#, 16#ff#, 16#20#, 16#c0#, 16#3f#, 16#00#, 16#80#, 16#ff#, 16#ff#,
     16#ff#, 16#07#, 16#ff#, 16#01#, 16#e0#, 16#7f#, 16#00#, 16#c0#, 16#ff#, 16#ff#, 16#ff#, 16#07#,
     16#ff#, 16#0f#, 16#f8#, 16#ff#, 16#40#, 16#e0#, 16#ff#, 16#ff#, 16#ff#, 16#07#, 16#ff#, 16#ff#,
     16#ff#, 16#ff#, 16#40#, 16#f0#, 16#ff#, 16#ff#, 16#ff#, 16#07#, 16#ff#, 16#ff#, 16#ff#, 16#ff#,
     16#41#, 16#f0#, 16#ff#, 16#ff#, 16#ff#, 16#07#);


    Porsche_Header : constant Pix.Header := (64, 64, 4, 1);

    Porsche_Colors : constant Pix.Color_Definition_Array :=
       ((Name => +" ", Kind => Pix.Colorful, Value => +"#background"),
        (Name => +".", Kind => Pix.Colorful, Value => +"#000000000000"),
        (Name => +"X", Kind => Pix.Colorful, Value => +"#ffd100"),
        (Name => +"o", Kind => Pix.Colorful, Value => +"#FFFF00000000"));

    Porsche_Data : constant Pix.Pixmap_Data :=
       ("                                                                ",
        "                   ..........................                   ",
        "              .....................................             ",
        "        ............XXXXXXXXXXXXXXXXXXXXXXXX............        ",
        "        ......XXXXXXX...XX...XXXXXXXX...XXXXXXXXXX......        ",
        "        ..XXXXXXXXXX..X..XX..XXXX.XXXX..XXXXXXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..X..XX..XXX..XXXX..X...XXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..XXXXX..XX.....XX..XX.XXXXXXXXXXX..        ",
        "        ..XXXXXXXXX.....XXX..XXX..XXXX..X.XXXXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..XXXXX..XXX..XXXX....XXXXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..XXXXX..XXX..XXXX..X..XXXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..XXXXX..XXX..X.XX..XX..XXXXXXXXXX..        ",
        "        ..XXXXXXXXX....XXX....XXX..XX....XX..XXXXXXXXX..        ",
        "        ..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..        ",
        "        ..XXXXXXXXX..........................XXXXXXXXX..        ",
        "        ..XXX.......XXXXXXXXXXX...................XXXX..        ",
        "        ......XX.XXX.XXX..XXXXX.........................        ",
        "        ..XXXXX.XXX.XXX.XXXX.XX.........................        ",
        "        ..XXXX.XXX.XX.......XXX.........................        ",
        "        ..XXXX.......XXXXXX..XX..ooooooooooooooooooooo..        ",
        "        ..X.....XXXXXXXXXXXXXXX..ooooooooooooooooooooo..        ",
        "        ..X...XXXXXXXXXXXXXXXXX..ooooooooooooooooooooo..        ",
        "        ..X..XXXXXXX.XX.XXXXXXX..ooooooooooooooooooooo..        ",
        "        ..XXXXX.XXX.XX.XXXXXXXX..ooooooooooooooooooooo..        ",
        "        ..XXXX.XXX.XX.XX................................        ",
        "        ..XXXX.X.........X....X.X.X.....................        ",
        "        ..XXXX...XXXXXXX.X..X...X.X.X.X.................        ",
        "        ..X....XXXXXXXXXX.X...X.X.X.....................        ",
        "        ..X...XXXXXXXXXX.XXXXXXXXXXXXXX.................        ",
        "        ..X..XXXXXX.XX.X.XXX...XXXXXXXX.................        ",
        "        ..XXXXX.XX.XX.XX.XX.....XXXXXXX.oooooooooooooo..        ",
        "        ..XXXX.XX.XX.XX..XX.X...XXXXX.X.oooooooooooooo..        ",
        "        ..XXXX.X.......X.XXXX...XXXX..X.oooooooooooooo..        ",
        "        ..X......XXXXXX..XXXX...XXXX..X.oooooooooooooo..        ",
        "        ..X...XXXXXXXXXX.XXX.....XXX.XX.oooooooooooooo..        ",
        "        ..X..XXXXXXXXXXX.X...........XX.oooooooooooooo..        ",
        "        .................X.X.........XX.................        ",
        "        .................X.X.XXXX....XX.XXXXXXXXXXXXXX..        ",
        "        .................XXX.XXXXX.X.XX.XXX.XX.XXXXXXX..        ",
        "         ................XXXX.XXX..X..X.XX.XX.XXX.XXX..         ",
        "         ................XXXXXXXX.XX.XX.X.XX.XXX.XXXX..         ",
        "         .................XXXXXX.XX.XX.X..........XXX..         ",
        "          ..oooooooooooooo.XXXXXXXXXX....XXXXXXXX..X..          ",
        "          ..ooooooooooooooo.XXXXXXXX....XXXXXXXXXXXX..          ",
        "           ..ooooooooooooooo........XXXXXXX.XX.XXXX..           ",
        "           ..oooooooooooooooooo..XXXXX.XXX.XX.XX.XX..           ",
        "            ..ooooooooooooooooo..XXXX.XXX.XX.XX.XX..            ",
        "            ..ooooooooooooooooo..XXX.XX........XXX..            ",
        "             ....................XXX....XXXXXX..X..             ",
        "              ...................XX...XXXXXXXXXXX.              ",
        "              ...................X...XXXXXXXXXXX..              ",
        "               ..................X..XXXX.XXXXXX..               ",
        "                .................XXX.XX.XX.XXX..                ",
        "                 ................XX.XX.XX.XXX..                 ",
        "                  ..ooooooooooo..XX.......XX..                  ",
        "                   ..oooooooooo..X...XXXX.X..                   ",
        "                    ..ooooooooo..X..XXXXXX..                    ",
        "                     ...ooooooo..X..XXXX...                     ",
        "                      ....ooooo..XXXXX....                      ",
        "                        ....ooo..XXX....                        ",
        "                          ....o..X....                          ",
        "                            ........                            ",
        "                              ....                              ",
        "                                                                ");


    RGB_Picture     : RGB.RGB_Image := RGB.Forge.Create (Make_Image, Image_Side, Image_Side, 4);
    Porsche_Picture : Pix.Pixmap :=
        Pix.Forge.Create (Porsche_Header, Porsche_Colors, Porsche_Data);
    Sorceress_Picture : Bmp.Bitmap :=
        Bmp.Forge.Create (Sorceress_Bits, Sorceress_Width, Sorceress_Height);




    --  The Window  --

    The_Window : aliased Win.Window := Win.Forge.Create (500, 568, "Graphics test");

    C2 : Grp.Group := Grp.Forge.Create (The_Window, 3, 56, 494, 514);

    The_Clipping : Clipping :=
       (Box.Forge.Create (C2, 10, 140 + 16, 100, 100,
            "Clipping and rect(f):" & LF & "Yellow rect.framed" & LF &
            "by B-Y-G-R rect. 1 p." & LF & "thick. Your printer may " & LF &
            "render very thin lines" & LF & "surrounding ""X""") with null record);

    The_Primitives : Primitives :=
       (Box.Forge.Create (C2, 110, 80 + 16, 100, 100, "Integer primitives")
        with null record);

    The_Sub_Pixel : Sub_Pixel :=
       (Box.Forge.Create (C2, 220, 140 + 16, 100, 100,
            "Sub-pixel drawing of" & LF & "lines 1.63 points apart" & LF &
            "On the screen you" & LF & "can see aliasing, the" & LF &
            "printer should render" & LF & "them properly") with null record);

    The_Line_Styles : Line_Styles :=
       (Box.Forge.Create (C2, 330, 70 + 16 + 10, 150, 150, "Line styles") with null record);

    The_Complex : Complex :=
       (Box.Forge.Create (C2, 140, 270 + 16, 230, 250,
            "Complex (double) drawings:" & LF & "Blue ellipse may not be" & LF &
            "correctly transformed" & LF & "due to non-orthogonal" & LF &
            "transformation") with null record);

    B_RGB : Crossed_Button :=
       (Btn.Forge.Create (C2, 10, 245 + 16, 100, 100, "RGB with alpha") with null record);
    B_Pixmap : Crossed_Button :=
       (Btn.Forge.Create (C2, 10, 345 + 16, 100, 100, "Pixmap") with null record);
    B_Bitmap : Crossed_Button :=
       (Btn.Forge.Create (C2, 10, 445 + 16, 100, 100, "Bitmap") with null record);

    The_Clock : Clk.Updated_Clock := Clk.Forge.Create (C2, 360, 230 + 16, 120, 120);

    Ret  : Ent.Enter_Button := Ent.Forge.Create (C2, 360, 360 + 16, 120, 30, "Return");
    But1 : Btn.Button := Btn.Forge.Create (C2, 360, 390 + 16, 30, 30, "@->|");
    But2 : Btn.Button := Btn.Forge.Create (C2, 390, 390 + 16, 30, 30, "@UpArrow");
    But3 : Btn.Button := Btn.Forge.Create (C2, 420, 390 + 16, 30, 30, "@DnArrow");
    But4 : Btn.Button := Btn.Forge.Create (C2, 450, 390 + 16, 30, 30, "@+");
    But5 : Btn.Button := Btn.Forge.Create (C2, 360, 425 + 16, 120, 30, "Hello, World");
    But6 : Btn.Button := Btn.Forge.Create (C2, 360, 460 + 16, 120, 30, "Plastic");

    The_Group : aliased Grp.Group := Grp.Forge.Create (C2, 360, 495 + 16, 120, 40);
    Inner     : Grp.Group := Grp.Forge.Create (The_Group, 365, 500 + 16, 110, 30);
    Rad_Btn   : Rnd.Round_Button := Rnd.Forge.Create (Inner, 365, 500 + 16, 40, 30, "rad");
    Check_Btn : Chk.Check_Button := Chk.Forge.Create (Inner, 410, 500 + 16, 60, 30, "check");

    TX : Box.Box := Box.Forge.Create
       (C2, 120, 492 + 16, 230, 50,
        "Background is not printed because" & LF & "encapsulating group, which we are" & LF &
        " printing, has not set the box type");

    W3 : aliased Win.Window := Win.Forge.Create (The_Window, 2, 5, The_Window.Get_W - 10, 73);
    G1 : Grp.Group := Grp.Forge.Create (W3, 0, 0, W3.Get_W, W3.Get_H);

    Operation_Labels : constant array (1 .. 8) of SU.Unbounded_String :=
       (+"Fl_Image_Surface", +"Fl_Copy_Surface",
        +"Fl_Printer", +"Fl_PostScript_File_Device",
        +"Fl_PDF_File_Surface", +"Fl_SVG_File_Surface",
        +"fl_capture_window()", +"Fl_Image_Surface::mask()");

    type Radio_Access is access Rad.Radio_Round_Button;

    Operations : array (Operation_Labels'Range) of Radio_Access;

    procedure Free is new Ada.Unchecked_Deallocation (Rad.Radio_Round_Button, Radio_Access);

    G2 : Grp.Group := Grp.Forge.Create (W3, 0, 0, W3.Get_W, W3.Get_H);
    Target_Box : Box.Box := Box.Forge.Create (G2, 4, 55, 340, 16);
    T_Window : Rad.Radio_Round_Button :=
        Rad.Forge.Create (G2, 5, 57, 140, 12, "Decorated window");
    T_Sub    : Rad.Radio_Round_Button := Rad.Forge.Create (G2, 160, 57, 100, 12, "Sub-window");
    T_Group  : Rad.Radio_Round_Button := Rad.Forge.Create (G2, 275, 57, 60, 12, "Group");

    B4 : Btn.Button := Btn.Forge.Create (W3, 380, (W3.Get_H - 25) / 2, 100, 25, "GO");

    type Widget_Access is access all Wdg.Widget'Class;

    Target    : Widget_Access := The_Window'Access;
    Operation : SU.Unbounded_String := Operation_Labels (1);




    --  The Copies  --

    type Window_Access is access Win.Window;
    type Box_Access is access Box.Box;
    type Picture_Access is access RGB.RGB_Image;

    --  A window that shows a copy, and what it holds.
    type Shown is record
        Frame   : Window_Access;
        Holder  : Box_Access;
        Picture : Picture_Access;
    end record;

    package Shown_Lists is new Ada.Containers.Doubly_Linked_Lists (Shown);

    Copies : Shown_Lists.List;

    procedure Free is new Ada.Unchecked_Deallocation (Win.Window, Window_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Box.Box, Box_Access);
    procedure Free is new Ada.Unchecked_Deallocation (RGB.RGB_Image, Picture_Access);

    procedure Free
           (Item : in out Shown) is
    begin
        Free (Item.Holder);
        Free (Item.Frame);
        Free (Item.Picture);
    end Free;


    --  Frees the windows the user has closed, or all of them.
    procedure Free_Copies
           (All_Of_Them : in Boolean := False)
    is
        Place : Shown_Lists.Cursor := Copies.First;
        Next  : Shown_Lists.Cursor;
        Item  : Shown;
    begin
        while Shown_Lists.Has_Element (Place) loop
            Next := Shown_Lists.Next (Place);
            Item := Shown_Lists.Element (Place);
            if All_Of_Them or else not Item.Frame.Is_Shown then
                Free (Item);
                Copies.Delete (Place);
            end if;
            Place := Next;
        end loop;
    end Free_Copies;


    --  Shows Picture in a window of its own, with a yellow margin.
    procedure Show_Copy
           (Picture : in Picture_Access;
            Margin  : in Natural;
            Title   : in String)
    is
        Item : Shown;
    begin
        Item.Picture := Picture;
        Item.Frame := new Win.Window'(Win.Forge.Create
           (Picture.Get_W + 2 * Margin, Picture.Get_H + 2 * Margin, Title));
        Item.Frame.Set_Background_Color (FLTK.Yellow_Color);
        Item.Holder := new Box.Box'(Box.Forge.Create
           (Item.Frame.all, Margin, Margin, Picture.Get_W, Picture.Get_H));
        Item.Holder.Set_Box (FLTK.No_Box);
        Item.Holder.Set_Image (Picture.all);
        Copies.Append (Item);
        Item.Frame.Show;
    end Show_Copy;


    function Is_Window
        return Boolean is (Target.all in Win.Window'Class);

    --  A window with no parent, which has a frame drawn round it.
    function Is_Top
        return Boolean is (Is_Window and then Target.Parent = null);

    function Target_Window
        return access Win.Window'Class is (Win.Window'Class (Target.all)'Access);


    procedure To_Image_Surface
           (W, H : in Integer)
    is
        Surface : Ims.Image_Surface := Ims.Forge.Create (W, H, Highres => True);
        Picture : Picture_Access;
    begin
        Srf.Push_Current (Surface);
        Drw.Set_Color (FLTK.Yellow_Color);
        Drw.Rect_Fill (0, 0, W, H);
        if Is_Top then
            Surface.Draw_Decorated_Window (Target_Window.all);
        else
            Surface.Draw_Widget (Target.all);
        end if;
        Picture := new RGB.RGB_Image'(Surface.Get_Image);
        Srf.Pop_Current;
        Show_Copy (Picture, 5, "Fl_Image_Surface");
    end To_Image_Surface;


    --  Puts the target on the clipboard, as an image, for another program
    --  to paste.  Finalizing the surface does it, so nothing here shows.
    procedure To_Copy_Surface
           (W, H : in Integer)
    is
        Surface : Cps.Copy_Surface := Cps.Forge.Create (W, H);
    begin
        Srf.Push_Current (Surface);
        if Is_Top then
            Surface.Draw_Decorated_Window (Target_Window.all, 0, 0);
        else
            Drw.Set_Color (FLTK.Yellow_Color);
            Drw.Rect_Fill (0, 0, Surface.Get_W, Surface.Get_H);
            Surface.Draw_Widget (Target.all, 5, 10);
        end if;
        Srf.Pop_Current;
    end To_Copy_Surface;


    --  One page, of the target as large as fits, in the middle.
    procedure To_Page
           (Device : in out Pgd.Paged_Device'Class)
    is
        Target_W, Target_H : Integer;
        W, H               : Integer;
        S, S_Aux           : Float := 1.0;
    begin
        Device.Start_Page;
        if Is_Window then
            Target_W := Target_Window.Get_Decorated_W;
            Target_H := Target_Window.Get_Decorated_H;
        else
            Target_W := Target.Get_W;
            Target_H := Target.Get_H;
        end if;
        Device.Get_Printable_Rect (W, H);
        if Target_W > W then
            S_Aux := Float (W) / Float (Target_W);
        end if;
        if Target_H > H then
            S := Float (H) / Float (Target_H);
        end if;
        S := Float'Min (S, S_Aux);
        Device.Scale (S);
        Device.Get_Printable_Rect (W, H);
        Device.Set_Origin (W / 2, H / 2);
        if Is_Window then
            Device.Print_Window (Target_Window.all, -Target_W / 2, -Target_H / 2);
        else
            Device.Print_Widget (Target.all, -Target_W / 2, -Target_H / 2);
        end if;
        Device.End_Page;
        Device.End_Job;
    end To_Page;


    procedure To_Printer is
        Device : Prn.Printer := Prn.Forge.Create;
    begin
        Device.Start_Job (1);
        To_Page (Device);
    exception
        when Pgd.Page_Error =>
            --  Cancelled, or failed: FLTKAda can't tell which.
            null;
    end To_Printer;


    procedure Alert
           (Error : in Ada.Exceptions.Exception_Occurrence)
    is
        Message : constant String := Ada.Exceptions.Exception_Message (Error);
    begin
        if Message /= "" then
            FLTK.Asks.Alert (Message);
        end if;
    end Alert;


    procedure To_Postscript is
        Device : PS.Postscript_File_Device := PS.Forge.Create;
    begin
        Device.Start_Job (Count => 1, Format => Pgd.A4);
        To_Page (Device);
    exception
        when PS.User_Cancel_Error =>
            null;
        when Error : PS.File_Open_Error | PS.File_Write_Error =>
            Alert (Error);
    end To_Postscript;


    procedure To_PDF is
        Device : PDF.PDF_File_Surface := PDF.Forge.Create;
    begin
        Device.Start_Job ("FLTK.pdf");
        To_Page (Device);
    exception
        when PDF.User_Cancel_Error =>
            null;
        when Error : PDF.File_Open_Error | PDF.File_Write_Error =>
            Alert (Error);
    end To_PDF;


    procedure To_SVG is
        Chooser : NFC.Native_File_Chooser := NFC.Forge.Create (NFC.Browse_Save_File);
        W, H    : Integer;
    begin
        Chooser.Set_Title ("Save a .svg file");
        Chooser.Set_Filter ("SVG" & ASCII.HT & "*.svg" & LF);
        Chooser.Set_Options (NFC.Saveas_Confirm + NFC.Use_Filter_Ext);
        if Chooser.Show /= NFC.Picked then
            return;
        end if;
        if Is_Window then
            W := Target_Window.Get_Decorated_W;
            H := Target_Window.Get_Decorated_H;
        else
            W := Target.Get_W;
            H := Target.Get_H;
        end if;
        declare
            Surface : SVG.SVG_File_Surface := SVG.Forge.Create (Chooser.Get_Filename, W, H);
        begin
            if Is_Window then
                Surface.Draw_Decorated_Window (Target_Window.all);
            else
                Surface.Draw_Widget (Target.all);
            end if;
            Surface.Finish;
        exception
            when SVG.File_Write_Error =>
                FLTK.Asks.Message_Box
                   ("Error while writing to SVG file " & Chooser.Get_Filename);
        end;
    exception
        when SVG.File_Open_Error =>
            --  FLTK does nothing when fl_fopen fails.
            null;
    end To_SVG;


    procedure To_Capture is
        Picture : Picture_Access;
    begin
        if Is_Window then
            Picture := new RGB.RGB_Image'(Drw.Capture_Window
               (Target_Window.all, 0, 0, Target.Get_W, Target.Get_H));
        else
            Picture := new RGB.RGB_Image'(Drw.Capture_Window
               (Target.Nearest_Window.all,
                Target.Get_X, Target.Get_Y, Target.Get_W, Target.Get_H));
        end if;
        Show_Copy (Picture, 5, "fl_capture_window()");
    end To_Capture;


    --  The target through a white ellipse on yellow, and the window also
    --  through a ring with FLTK's name in it.
    procedure To_Mask is
        W       : constant Integer := Target.Get_W;
        H       : constant Integer := Target.Get_H;
        Surface : Ims.Image_Surface := Ims.Forge.Create (W, H, Highres => True);
        Mini    : Integer;
        DX, DY  : Integer;
        L, TH   : Integer;
        Picture : Picture_Access;
    begin
        Srf.Push_Current (Surface);
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Rect_Fill (0, 0, W, H);
        Drw.Set_Color (FLTK.White_Color);
        Drw.Pie (0, 0, W, H, 0.0, 360.0);
        if Is_Top then
            Drw.Set_Color (FLTK.Black_Color);
            Mini := Integer (Long_Float'Truncation (Long_Float (Integer'Min (W, H)) * 0.66));
            Drw.Pie (W / 2 - Mini / 2, H / 2 - Mini / 2, Mini, Mini, 0.0, 360.0);
            Drw.Set_Color (FLTK.White_Color);
            Drw.Set_Font (FLTK.Times_Bold, 120);
            Drw.Text_Extents ("FLTK", DX, DY, L, TH);
            Drw.Draw_Text (W / 2 - L / 2, H / 2 + TH / 2, "FLTK");
        end if;
        declare
            Mask : constant RGB.RGB_Image := Surface.Get_Image;
        begin
            Drw.Set_Color (FLTK.Yellow_Color);
            Drw.Rect_Fill (0, 0, W, H);
            Srf.Pop_Current;
            Surface.Mask (Mask);
        end;
        Srf.Push_Current (Surface);
        Surface.Draw_Widget (Target.all, 0, 0);
        Picture := new RGB.RGB_Image'(Surface.Get_Image);
        Srf.Pop_Current;
        Show_Copy (Picture, 0, SU.To_String (Operation));
    end To_Mask;


    procedure Copy_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Free_Copies;
        if Operation = "Fl_Image_Surface" then
            if Is_Top then
                To_Image_Surface (Target_Window.Get_Decorated_W, Target_Window.Get_Decorated_H);
            else
                To_Image_Surface (Target.Get_W, Target.Get_H);
            end if;
        elsif Operation = "Fl_Copy_Surface" then
            if Is_Top then
                To_Copy_Surface (Target_Window.Get_Decorated_W, Target_Window.Get_Decorated_H);
            else
                To_Copy_Surface (Target.Get_W + 10, Target.Get_H + 20);
            end if;
        elsif Operation = "Fl_Printer" then
            To_Printer;
        elsif Operation = "Fl_PostScript_File_Device" then
            To_Postscript;
        elsif Operation = "Fl_PDF_File_Surface" then
            To_PDF;
        elsif Operation = "Fl_SVG_File_Surface" then
            To_SVG;
        elsif Operation = "fl_capture_window()" then
            To_Capture;
        elsif Operation = "Fl_Image_Surface::mask()" then
            To_Mask;
        end if;
    end Copy_CB;


    procedure Operation_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Operation := +Item.Get_Label;
    end Operation_CB;


    procedure Target_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        if Item.Get_Label = "Decorated window" then
            Target := The_Window'Access;
        elsif Item.Get_Label = "Sub-window" then
            Target := W3'Access;
        else
            Target := The_Group'Access;
        end if;
    end Target_CB;


begin


    The_Clipping.Set_Alignment (FLTK.Align_Top);
    The_Clipping.Set_Label_Size (10);
    The_Primitives.Set_Label_Size (10);
    The_Primitives.Set_Alignment (FLTK.Align_Top);
    The_Sub_Pixel.Set_Label_Size (10);
    The_Sub_Pixel.Set_Alignment (FLTK.Align_Top);
    The_Line_Styles.Set_Label_Size (10);
    The_Line_Styles.Set_Alignment (FLTK.Align_Top);
    The_Complex.Set_Label_Size (10);
    The_Complex.Set_Alignment (FLTK.Align_Top);

    B_RGB.Set_Image (RGB_Picture);
    B_Pixmap.Set_Image (Porsche_Picture);
    B_Bitmap.Set_Label_Color (FLTK.Green_Color);
    B_Bitmap.Set_Image (Sorceress_Picture);

    Ret.Deactivate;
    But1.Set_Label_Color (FLTK.Dark3_Color);
    But2.Set_Label_Color (FLTK.Dark3_Color);
    But3.Set_Label_Color (FLTK.Dark3_Color);
    But4.Set_Label_Color (FLTK.Dark3_Color);
    But5.Set_Label_Font (FLTK.Helvetica_Bold_Italic);
    But5.Set_Label_Kind (FLTK.Shadow_Label);
    But5.Set_Box (FLTK.Round_Up_Box);
    But6.Set_Box (FLTK.Plastic_Up_Box);

    The_Group.Set_Box (FLTK.Up_Box);
    Inner.Set_Box (FLTK.Thin_Up_Frame);
    Rad_Btn.Set_State (Btn.On);
    Check_Btn.Set_State (Btn.On);
    The_Group.Deactivate;

    TX.Set_Box (FLTK.Shadow_Box);
    TX.Set_Label_Size (12);
    TX.Hide;

    W3.Set_Box (FLTK.Down_Box);
    for Index in Operations'Range loop
        Operations (Index) := new Rad.Radio_Round_Button'(Rad.Forge.Create
           (G1, (if Index mod 2 = 1 then 5 else 170), 4 + 13 * ((Index - 1) / 2), 150, 12,
            SU.To_String (Operation_Labels (Index))));
        Operations (Index).Set_Callback (Operation_CB'Unrestricted_Access);
        Operations (Index).Set_Label_Size (12);
    end loop;
    Operations (1).Set_State (Btn.On);

    Target_Box.Set_Box (FLTK.Border_Box);
    Target_Box.Set_Background_Color (FLTK.Light3_Color);
    T_Window.Set_Label_Size (12);
    T_Window.Set_State (Btn.On);
    T_Window.Set_Callback (Target_CB'Unrestricted_Access);
    T_Sub.Set_Label_Size (12);
    T_Sub.Set_Callback (Target_CB'Unrestricted_Access);
    T_Group.Set_Label_Size (12);
    T_Group.Set_Callback (Target_CB'Unrestricted_Access);

    B4.Set_Callback (Copy_CB'Unrestricted_Access);

    declare
        Icon : constant RGB.RGB_Image := RGB.Forge.Create (Porsche_Picture);
    begin
        Win.Set_Default_Icon (Icon);
    end;
    The_Window.Show_With_Args;

    return Result : constant Integer := FLTK.Run do
        Free_Copies (All_Of_Them => True);
        for Item of Operations loop
            Free (Item);
        end loop;
    end return;


end Device;


