--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Draw,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups;


package body Unittests_Text is


    package Bx renames FLTK.Widgets.Boxes;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Grp renames FLTK.Widgets.Groups;

    use FLTK, FLTK.Draw, Unittests_Common;


    type Check_Access is access Chk.Check_Button;
    type Box_Access is access Bx.Box;


    procedure Base_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Item.Parent.Redraw;
    end Base_CB;


    type Text_Extents_Test is new Grp.Group with record
        Base_Bt : Check_Access;
    end record;

    overriding procedure Draw
           (This : in out Text_Extents_Test);

    type Text_Extents_Test_Access is access Text_Extents_Test;


    procedure Draw_Text_And_Boxes
           (This : in Text_Extents_Test;
            Txt  : in String;
            X, Y : in Integer)
    is
        WM, HM         : Natural;
        DX, DY, WT, HT : Integer;
        Desc           : Integer;
    begin
        --  measure text so we can draw the baseline first
        Measure (Txt, WM, HM, Symbols => False);
        Text_Extents (Txt, DX, DY, WT, HT);
        --  Draw a baseline before the boxes
        if This.Base_Bt.Is_On then
            Set_Color (Blue_Color);
            Line (X - 20, Y, X + WT + 20, Y);
        end if;
        --  draw fl_measure() typographical bounding box
        Desc := Font_Descent;
        Set_Color (Red_Color);
        Rect (X, Y - HM + Desc, WM, HM);
        --  draw fl_text_extents() glyph bounding box
        Set_Color (Green_Color);
        Rect (X + DX, Y + DY, WT, HT);
        --  Then we draw the text to show how it fits inside each of the two boxes
        Set_Color (Black_Color);
        Draw_Text (X, Y, Txt);
    end Draw_Text_And_Boxes;


    procedure Draw
           (This : in out Text_Extents_Test)
    is
        X0 : constant Integer := This.Get_X;
        Y0 : constant Integer := This.Get_Y;
        W0 : Natural := This.Get_W;
        H0 : Natural := This.Get_H;
        XX : Integer := X0 + 55;
        YY : Integer := Y0 + 40;
    begin
        Push_Clip (X0, Y0, W0, H0);
        --  set the background colour - slightly off-white to enhance the
        --  green bounding box
        Set_Color (Grey_Ramp (Greyscale'Val (Greyscale'Pos (Greyscale'Last) - 2)));
        Rect_Fill (X0, Y0, W0, H0);

        Grp.Group (This).Draw;

        Set_Font (Helvetica, 30);
        This.Draw_Text_And_Boxes ("!abcdeABCDE""#A", XX, YY);
        YY := YY + 50;
        This.Draw_Text_And_Boxes ("oacs", XX, YY);
        XX := XX + 100;
        This.Draw_Text_And_Boxes ("qjgIPT", XX, YY);
        YY := YY + 50;
        XX := XX - 100;
        This.Draw_Text_And_Boxes ("````````", XX, YY);
        YY := YY + 50;
        This.Draw_Text_And_Boxes ("--------", XX, YY);
        YY := YY + 50;
        This.Draw_Text_And_Boxes ("________", XX, YY);
        YY := YY + 50;

        Set_Font (Helvetica, 14);
        Set_Color (Red_Color);
        Draw_Text (XX, YY, "fl_measure bounding box in RED");
        YY := YY + 20;
        Set_Color (Green_Color);
        Draw_Text (XX, YY, "fl_text_extents bounding box in GREEN");
        Set_Color (Black_Color);
        XX := X0 + 10;
        YY := YY + 30;
        Draw_Text (XX, YY, "NOTE: On systems with text anti-aliasing (e.g. macOS Quartz)");
        Measure ("NOTE: ", W0, H0, Symbols => False);
        XX := XX + W0;
        YY := YY + H0;
        Draw_Text (XX, YY, "text may leak slightly outside the fl_text_extents()");
        Pop_Clip;
    end Draw;


    function Create
        return Widget_Access
    is
        X : constant Integer := Test_Area_X;
        Y : constant Integer := Test_Area_Y;
        W : constant Integer := Test_Area_W;
        H : constant Integer := Test_Area_H;
        Page : constant Text_Extents_Test_Access := new Text_Extents_Test'
           (Grp.Forge.Create (X, Y, W, H) with others => <>);
        Dummy : Box_Access;
    begin
        Page.Begin_Current;
        Page.Base_Bt := new Chk.Check_Button'
           (Chk.Forge.Create (X + W - 150, 50, 130, 20, "Show Baseline"));
        Page.Base_Bt.Set_Box (Flat_Box);
        Page.Base_Bt.Set_Down_Box (Down_Box);
        Page.Base_Bt.Set_Callback (Base_CB'Access);

        Dummy := new Bx.Box'(Bx.Forge.Create (X + W - 4, Y + H - 4, 2, 2));
        Page.Set_Resizable (Dummy.all);
        Page.End_Current;
        return Widget_Access (Page);
    end Create;


end Unittests_Text;
