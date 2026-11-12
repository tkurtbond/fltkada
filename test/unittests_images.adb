--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Draw,
    FLTK.Images.RGB,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Radio,
    FLTK.Widgets.Groups;

use type

    FLTK.Alignment,
    FLTK.Widgets.Buttons.State;


package body Unittests_Images is


    package RGB renames FLTK.Images.RGB;
    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Rad renames FLTK.Widgets.Buttons.Radio;
    package Grp renames FLTK.Widgets.Groups;

    use FLTK, FLTK.Draw, Unittests_Common;


    --  Parameters for fine tuning for developers.
    --  Default values: CB=1, DX=0, IMG=1, LX=0, FLIPH=0

    --  True to show the checker board background for alpha images
    CB : Boolean := True;
    --  additional (undefined (0)) pixels per line, must be >= 0, ignored
    --  (irrelevant), if LX = 0 (see below)
    DX : constant Natural := 0;
    --  True to use an RGB_Image for drawing images with transparency,
    --  False to use Draw_Image instead, which ignores the alpha channel.
    Img : Boolean := True;
    --  0 for default: the line size defaults (internally) to width * depth
    --  +1: line size = (width + DX) * depth
    --  -1 to flip image vertically: line size = - ((width + DX) * depth)
    LX : Integer := 0;
    --  True = Flip image horizontally (only if Img is False)
    Flip_H : Boolean := False;

    subtype Gray_Data is Color_Component_Array (1 .. Size_Type ((128 + DX) * 128 * 1));
    subtype Gray_A_Data is Color_Component_Array (1 .. Size_Type ((128 + DX) * 128 * 2));
    subtype RGB_Data is Color_Component_Array (1 .. Size_Type ((128 + DX) * 128 * 3));
    subtype RGBA_Data is Color_Component_Array (1 .. Size_Type ((128 + DX) * 128 * 4));

    Img_Gray   : Gray_Data;
    Img_Gray_A : Gray_A_Data;
    Img_RGB    : RGB_Data;
    Img_RGBA   : RGBA_Data;

    type RGB_Image_Access is access RGB.RGB_Image;

    I_G, I_GA, I_RGB, I_RGBA : RGB_Image_Access;


    --  The C++ points its RGB images at the last line, with a negative
    --  line size, when LX is -1.  An RGB_Image's Line_Size can't be
    --  negative, so the images get the lines in reverse order instead,
    --  which draws the same.
    function Reversed
           (Data  : in Color_Component_Array;
            Depth : in Positive)
        return Color_Component_Array
    is
        Line   : constant Size_Type := Size_Type ((128 + DX) * Depth);
        Result : Color_Component_Array (Data'Range);
    begin
        for Row in 0 .. Size_Type (127) loop
            Result (Data'First + Row * Line .. Data'First + Row * Line + Line - 1) :=
                Data (Data'First + (127 - Row) * Line
                      .. Data'First + (127 - Row) * Line + Line - 1);
        end loop;
        return Result;
    end Reversed;


    procedure Build_Images
    is
        DG, DGA, DRGB, DRGBA : Size_Type := 1;
        V : Color_Component;
    begin
        for Y in 0 .. 127 loop
            for X in 0 .. 127 loop
                V := Color_Component ((Y * 2) mod 256);
                Img_Gray (DG) := V;
                Img_Gray_A (DGA) := V;
                Img_RGB (DRGB) := V;
                Img_RGBA (DRGBA) := V;
                V := Color_Component ((X * 2) mod 256);
                Img_RGB (DRGB + 1) := V;
                Img_RGBA (DRGBA + 1) := V;
                V := Color_Component (((127 - X) * 2) mod 256);
                Img_RGB (DRGB + 2) := V;
                Img_RGBA (DRGBA + 2) := V;
                V := Color_Component ((X + Y) mod 256);
                Img_Gray_A (DGA + 1) := V;
                Img_RGBA (DRGBA + 3) := V;
                DG := DG + 1;
                DGA := DGA + 2;
                DRGB := DRGB + 3;
                DRGBA := DRGBA + 4;
            end loop;
            --  The C++ zeroes DX padding bytes at the end of each line here
            --  when LX /= 0; DX is 0, and the arrays have no padding.
        end loop;
        declare
            Line : constant Natural := (if LX = 0 then 0 else 128 + DX);
        begin
            if LX < 0 then
                I_G := new RGB.RGB_Image'(RGB.Forge.Create
                   (Reversed (Img_Gray, 1), 128, 128, 1, Line * 1));
                I_GA := new RGB.RGB_Image'(RGB.Forge.Create
                   (Reversed (Img_Gray_A, 2), 128, 128, 2, Line * 2));
                I_RGB := new RGB.RGB_Image'(RGB.Forge.Create
                   (Reversed (Img_RGB, 3), 128, 128, 3, Line * 3));
                I_RGBA := new RGB.RGB_Image'(RGB.Forge.Create
                   (Reversed (Img_RGBA, 4), 128, 128, 4, Line * 4));
            else
                I_G := new RGB.RGB_Image'(RGB.Forge.Create (Img_Gray, 128, 128, 1, Line * 1));
                I_GA := new RGB.RGB_Image'(RGB.Forge.Create (Img_Gray_A, 128, 128, 2, Line * 2));
                I_RGB := new RGB.RGB_Image'(RGB.Forge.Create (Img_RGB, 128, 128, 3, Line * 3));
                I_RGBA := new RGB.RGB_Image'(RGB.Forge.Create (Img_RGBA, 128, 128, 4, Line * 4));
            end if;
        end;
    end Build_Images;


    procedure Free_Images is
    begin
        --  The images are controlled; dropping them leaks only the access
        --  values' storage, which a test program can afford.
        I_G := null;
        I_GA := null;
        I_RGB := null;
        I_RGBA := null;
    end Free_Images;


    type Check_Access is access Chk.Check_Button;
    type Radio_Access is access Rad.Radio_Button;
    type Group_Access is access Grp.Group;

    type Image_Test is new Grp.Group with record
        Ctr_Grp  : Group_Access;
        Ck_CB    : Check_Access;
        Ck_Img   : Check_Access;
        Ck_FlipH : Check_Access;
        Rb_LXm1  : Radio_Access;
        Rb_LX0   : Radio_Access;
        Rb_LXp1  : Radio_Access;
    end record;

    overriding procedure Draw
           (This : in out Image_Test);

    type Image_Test_Access is access Image_Test;

    The_Test : Image_Test_Access;


    procedure Refresh_Images_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        It : Image_Test renames The_Test.all;
    begin
        Free_Images;   --  release the previous images
        --  determine the state for the next images
        CB := It.Ck_CB.Is_On;
        Img := It.Ck_Img.Is_On;
        Flip_H := It.Ck_FlipH.Is_On;
        --  read the LX state radio buttons
        if It.Rb_LXp1.Is_On then
            LX := 1;
        elsif It.Rb_LXm1.Is_On then
            LX := -1;
        else
            LX := 0;
        end if;
        --  construct the next images
        Build_Images;
        It.Redraw;
    end Refresh_Images_CB;


    procedure Draw_Raw
           (Data     : in Color_Component_Array;
            XX, YY   : in Integer;
            Depth    : in Positive) is
    begin
        Draw_Image (XX + 1, YY + 1, 128, 128, Data, Depth,
            Line_Size       => (if LX = 0 then 0 else (128 + DX) * Depth),
            Flip_Horizontal => Flip_H,
            Flip_Vertical   => LX < 0);
    end Draw_Raw;


    procedure Draw
           (This : in out Image_Test)
    is
        XX : Integer := This.Get_X + 10;
        YY : Integer := This.Get_Y + 10;
    begin
        Grp.Group (This).Draw;

        --  top left: RGB
        Set_Color (Black_Color);
        Rect (XX, YY, 130, 130);
        if Img then
            I_RGB.Draw (XX + 1, YY + 1);
        else
            Draw_Raw (Img_RGB, XX, YY, 3);
        end if;
        Draw_Text (XX + 134, YY + 64, "RGB");

        --  bottom left: RGBA
        XX := This.Get_X + 10;
        YY := This.Get_Y + 10 + 134;
        Set_Color (Black_Color);
        Rect (XX, YY, 130, 130);                --  black frame
        Set_Color (White_Color);
        Rect_Fill (XX + 1, YY + 1, 128, 128);   --  white background
        if CB then   --  checker board
            Set_Color (Black_Color);
            Rect_Fill (XX + 65, YY + 1, 64, 64);
            Set_Color (Black_Color);
            Rect_Fill (XX + 1, YY + 65, 64, 64);
        end if;
        if Img then
            I_RGBA.Draw (XX + 1, YY + 1);
        else
            Draw_Raw (Img_RGBA, XX, YY, 4);
        end if;
        Set_Color (Black_Color);
        Draw_Text (XX + 134, YY + 64, "RGBA");

        --  top right: Gray
        XX := This.Get_X + 10 + 200;
        YY := This.Get_Y + 10;
        Set_Color (Black_Color);
        Rect (XX, YY, 130, 130);
        if Img then
            I_G.Draw (XX + 1, YY + 1);
        else
            Draw_Raw (Img_Gray, XX, YY, 1);
        end if;
        Draw_Text (XX + 134, YY + 64, "Gray");

        --  bottom right: Gray+Alpha
        XX := This.Get_X + 10 + 200;
        YY := This.Get_Y + 10 + 134;
        Set_Color (Black_Color);
        Rect (XX, YY, 130, 130);                --  black frame
        Set_Color (White_Color);
        Rect_Fill (XX + 1, YY + 1, 128, 128);   --  white background
        if CB then   --  checker board
            Set_Color (Black_Color);
            Rect_Fill (XX + 65, YY + 1, 64, 64);
            Set_Color (Black_Color);
            Rect_Fill (XX + 1, YY + 65, 64, 64);
        end if;
        if Img then
            I_GA.Draw (XX + 1, YY + 1);
        else
            Draw_Raw (Img_Gray_A, XX, YY, 2);
        end if;
        Set_Color (Black_Color);
        Draw_Text (XX + 134, YY + 64, "Gray+Alpha");
    end Draw;


    function To_State
           (On : in Boolean)
        return Btn.State is
    begin
        return (if On then Btn.On else Btn.Off);
    end To_State;


    function Create
        return Widget_Access
    is
        X  : constant Integer := Test_Area_X;
        Y  : constant Integer := Test_Area_Y;
        W  : constant Integer := Test_Area_W;
        H  : constant Integer := Test_Area_H;
        CW : constant Integer := 90;
        CH : constant Integer := 200;
        CX : constant Integer := X + W - CW - 5;
        CY : constant Integer := Y + 10;
        Rd_Grp : Group_Access;
    begin
        Build_Images;
        The_Test := new Image_Test'(Grp.Forge.Create (X, Y, W, H) with others => <>);
        The_Test.Begin_Current;
        declare
            It : Image_Test renames The_Test.all;
        begin
            It.Set_Label
               ("Testing Image Drawing" & ASCII.LF & ASCII.LF &
                "This test renders four images, two of them with a checker board" & ASCII.LF &
                "visible through the graphics. Color and gray gradients should be" & ASCII.LF &
                "visible. This does not test any image formats such as JPEG.");
            It.Set_Alignment (Align_Inside + Align_Bottom + Align_Left + Align_Wrap);
            It.Set_Box (Border_Box);
            It.Ctr_Grp := new Grp.Group'(Grp.Forge.Create (CX, CY, CW, CH));
            It.Ctr_Grp.Begin_Current;

            It.Ck_CB := new Chk.Check_Button'
               (Chk.Forge.Create (CX + 10, CY + 10, CW - 20, 30, "CB"));
            It.Ck_CB.Set_Callback (Refresh_Images_CB'Access);
            It.Ck_CB.Set_State (To_State (CB));
            It.Ck_CB.Set_Tooltip
               ("1 to show the checker board background for alpha images," & ASCII.LF &
                "0 otherwise");

            It.Ck_Img := new Chk.Check_Button'
               (Chk.Forge.Create (CX + 10, CY + 40, CW - 20, 30, "IMG"));
            It.Ck_Img.Set_Callback (Refresh_Images_CB'Access);
            It.Ck_Img.Set_State (To_State (Img));
            It.Ck_Img.Set_Tooltip
               ("1 to use Fl_RGB_Image for drawing images with transparency," & ASCII.LF &
                "0 to use fl_draw_image() instead.");

            It.Ck_FlipH := new Chk.Check_Button'
               (Chk.Forge.Create (CX + 10, CY + 70, CW - 20, 30, "FLIPH"));
            It.Ck_FlipH.Set_Callback (Refresh_Images_CB'Access);
            It.Ck_FlipH.Set_State (To_State (Flip_H));
            It.Ck_FlipH.Set_Tooltip
               ("1 = Flip image horizontally (only if IMG == 0)" & ASCII.LF &
                "0 = Draw image normal, w/o horizontal flipping");

            Rd_Grp := new Grp.Group'(Grp.Forge.Create (CX + 10, CY + 100, CW - 20, 90, "LX"));
            Rd_Grp.Begin_Current;

            It.Rb_LXp1 := new Rad.Radio_Button'
               (Rad.Forge.Create (CX + 15, CY + 105, CW - 30, 20, "+1"));
            It.Rb_LXp1.Set_Callback (Refresh_Images_CB'Access);
            It.Rb_LX0 := new Rad.Radio_Button'
               (Rad.Forge.Create (CX + 15, CY + 125, CW - 30, 20, "0"));
            It.Rb_LX0.Set_Callback (Refresh_Images_CB'Access);
            It.Rb_LX0.Set_Tooltip
               ("0 for default: ld() = 0, i.e. ld() defaults (internally) to w()*d()" & ASCII.LF &
                "+1: ld() = (w() + DX) * d()" & ASCII.LF &
                "-1 to flip image vertically: ld() = - ((w() + DX) * d())");
            It.Rb_LXm1 := new Rad.Radio_Button'
               (Rad.Forge.Create (CX + 15, CY + 145, CW - 30, 20, "-1"));
            It.Rb_LXm1.Set_Callback (Refresh_Images_CB'Access);
            It.Rb_LX0.Set_State (Btn.On);

            Rd_Grp.Set_Box (Border_Box);
            Rd_Grp.Set_Alignment (Align_Inside + Align_Bottom + Align_Center);
            Rd_Grp.End_Current;

            It.Ctr_Grp.Set_Box (Border_Box);
            It.Ctr_Grp.End_Current;
            It.End_Current;   --  make sure this Image_Test group is closed
        end;
        return Widget_Access (The_Test);
    end Create;


end Unittests_Images;
