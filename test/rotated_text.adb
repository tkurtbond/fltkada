--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/rotated_text.cxx: a widget drawing the input's text at
--  the angle the slider sets, in the font, size and label type chosen,
--  centred, from the left or from the right, and clipped or not.  FLTK's
--  static_value becomes Set_Value, which copies the text; the input looks
--  the same.  Guided by pofltk's RotatedText.Mod.


with

    Ada.Numerics.Long_Elementary_Functions,
    Ada.Strings.Unbounded,
    FLTK.Draw,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

use type

    FLTK.Alignment,
    FLTK.Label_Kind;


function Rotated_Text
    return Integer
is

    package LEF renames Ada.Numerics.Long_Elementary_Functions;
    package SU  renames Ada.Strings.Unbounded;
    package FDR renames FLTK.Draw;
    package Tgl renames FLTK.Widgets.Buttons.Toggle;
    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package Chc renames FLTK.Widgets.Menus.Choices;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    Pi : constant := Ada.Numerics.Pi;


    --  C's conversion of a double to an int.
    function Trunc
           (Value : in Long_Float)
        return Integer is
    begin
        return Integer (Long_Float'Truncation (Value));
    end Trunc;


    --  An offset and colour of a label type's copies of the text; the
    --  last is drawn in the label colour.
    type Copy is record
        DX, DY : Integer;
        Hue    : FLTK.Color;
    end record;

    type Copy_Array is array (Positive range <>) of Copy;

    Shadow : constant Copy_Array :=
       ((2, 2, FLTK.Dark3_Color), (0, 0, 0));
    Engraved : constant Copy_Array :=
       ((1, 0, FLTK.Light3_Color), (1, 1, FLTK.Light3_Color), (0, 1, FLTK.Light3_Color),
        (-1, 0, FLTK.Dark3_Color), (-1, -1, FLTK.Dark3_Color), (0, -1, FLTK.Dark3_Color),
        (0, 0, 0));
    Embossed : constant Copy_Array :=
       ((-1, 0, FLTK.Light3_Color), (-1, -1, FLTK.Light3_Color), (0, -1, FLTK.Light3_Color),
        (1, 0, FLTK.Dark3_Color), (1, 1, FLTK.Dark3_Color), (0, 1, FLTK.Dark3_Color),
        (0, 0, 0));


    --  code taken from fl_engraved_label.cxx
    type Rotated_Label_Box is new FLTK.Widgets.Widget with record
        Angle : Integer := 0;
        Text  : SU.Unbounded_String;
        Align : FLTK.Alignment := FLTK.Align_Center;
    end record;

    overriding procedure Draw
           (This : in out Rotated_Label_Box);


    procedure Innards
           (This   : in Rotated_Label_Box;
            X, Y   : in Integer;
            Copies : in Copy_Array) is
    begin
        for I in Copies'Range loop
            FDR.Set_Color
               (if I < Copies'Last then Copies (I).Hue else This.Get_Label_Color);
            FDR.Draw_Text
               (X + Copies (I).DX, Y + Copies (I).DY, SU.To_String (This.Text), This.Angle);
        end loop;
    end Innards;


    procedure Draw
           (This : in out Rotated_Label_Box)
    is
        Text     : constant String := SU.To_String (This.Text);
        DX, DY   : Natural;
        X, Y     : Integer;
        Radians  : Long_Float;
    begin
        This.Draw_Box;
        FDR.Set_Font (This.Get_Label_Font, This.Get_Label_Size);
        FDR.Set_Color (This.Get_Label_Color);

        if This.Align - FLTK.Align_Clip /= This.Align then  --  Align_Clip is set
            FDR.Push_Clip (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        else
            FDR.Push_No_Clip;
        end if;
        FDR.Measure (Text, DX, DY);
        if This.Align - FLTK.Align_Left /= This.Align then
            X := 0;
            Y := 0;
        elsif This.Align - FLTK.Align_Right /= This.Align then
            Radians := Pi * Long_Float (This.Angle + 180) / 180.0;
            Y := Trunc (-LEF.Sin (Radians) * Long_Float (DX));
            X := Trunc (LEF.Cos (Radians) * Long_Float (DX));
        else
            Radians := Pi * Long_Float (This.Angle) / 180.0;
            Y := Trunc (LEF.Sin (Radians) * Long_Float (DX));
            X := Trunc (-LEF.Cos (Radians) * Long_Float (DX));
            X := X / 2;
            Y := Y / 2;
        end if;
        X := This.Get_X + This.Get_W / 2 + X;
        Y := This.Get_Y + This.Get_H / 2 + Y;

        case This.Get_Label_Kind is
            when FLTK.Shadow_Label   => Innards (This, X, Y, Shadow);
            when FLTK.Engraved_Label => Innards (This, X, Y, Engraved);
            when FLTK.Embossed_Label => Innards (This, X, Y, Embossed);
            when others              => FDR.Draw_Text (X, Y, Text, This.Angle);
        end case;
        FDR.Pop_Clip;
        This.Draw_Label;
    end Draw;


    Window : Dbl.Double_Window := Dbl.Forge.Create (400, 425);

    Angles : HVS.Horizontal_Value_Slider := HVS.Forge.Create (Window, 50, 400, 350, 25, "Angle:");
    Input  : Inp.Text_Input := Inp.Forge.Create (Window, 50, 375, 350, 25);
    Sizes  : HVS.Horizontal_Value_Slider := HVS.Forge.Create (Window, 50, 350, 350, 25, "Size:");
    Fonts  : HVS.Horizontal_Value_Slider := HVS.Forge.Create (Window, 50, 325, 350, 25, "Font:");

    G      : Grp.Group := Grp.Forge.Create (Window, 50, 300, 350, 25);
    Leftb  : Tgl.Toggle_Button := Tgl.Forge.Create (G, 50, 300, 50, 25, "left");
    Rightb : Tgl.Toggle_Button := Tgl.Forge.Create (G, 100, 300, 50, 25, "right");
    Clipb  : Tgl.Toggle_Button := Tgl.Forge.Create (G, 350, 300, 50, 25, "clip");

    --  created in the window, after the group is ended
    C    : Chc.Choice := Chc.Forge.Create (Window, 50, 275, 200, 25);
    Text : Rotated_Label_Box :=
       (FLTK.Widgets.Forge.Create (Window, 100, 75, 200, 100, "Widget with rotated text")
        with others => <>);


    procedure Button_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        I : FLTK.Alignment := FLTK.Align_Center;
    begin
        if Leftb.Is_On then I := I + FLTK.Align_Left; end if;
        if Rightb.Is_On then I := I + FLTK.Align_Right; end if;
        if Clipb.Is_On then I := I + FLTK.Align_Clip; end if;
        Text.Align := I;
        Window.Redraw;
    end Button_CB;


    procedure Font_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Set_Label_Font (FLTK.Font_Kind (Integer (Fonts.Get_Value)));
        Window.Redraw;
    end Font_CB;


    procedure Size_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Set_Label_Size (FLTK.Font_Size (Integer (Sizes.Get_Value)));
        Window.Redraw;
    end Size_CB;


    procedure Angle_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Angle := Integer (Angles.Get_Value);
        Window.Redraw;
    end Angle_CB;


    procedure Input_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Text := SU.To_Unbounded_String (Input.Get_Value);
        Window.Redraw;
    end Input_CB;


    procedure Set_Kind
           (Kind : in FLTK.Label_Kind) is
    begin
        Text.Set_Label_Kind (Kind);
        Window.Redraw;
    end Set_Kind;


    procedure Normal_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Set_Kind (FLTK.Normal_Label);
    end Normal_CB;


    procedure Shadow_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Set_Kind (FLTK.Shadow_Label);
    end Shadow_CB;


    procedure Embossed_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Set_Kind (FLTK.Embossed_Label);
    end Embossed_CB;


    procedure Engraved_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Set_Kind (FLTK.Engraved_Label);
    end Engraved_CB;


    procedure Setup
           (Item     : in out HVS.Horizontal_Value_Slider;
            Min, Max : in     Long_Float;
            Value    : in     Long_Float;
            Callback : in     FLTK.Widgets.Widget_Callback) is
    begin
        Item.Set_Alignment (FLTK.Align_Left);
        Item.Set_Bounds (Min, Max);
        Item.Set_Step (1);
        Item.Set_Value (Value);
        Item.Set_Callback (Callback);
    end Setup;

begin

    Setup (Angles, -360.0, 360.0, 0.0, Angle_CB'Unrestricted_Access);

    Input.Set_Value ("Rotate Me!!!");
    Input.Set_When (FLTK.When_Changed);
    Input.Set_Callback (Input_CB'Unrestricted_Access);

    Setup (Sizes, 1.0, 64.0, 14.0, Size_CB'Unrestricted_Access);
    Setup (Fonts, 0.0, 15.0, 0.0, Font_CB'Unrestricted_Access);

    Leftb.Set_Callback (Button_CB'Unrestricted_Access);
    Rightb.Set_Callback (Button_CB'Unrestricted_Access);
    Clipb.Set_Callback (Button_CB'Unrestricted_Access);
    G.Set_Resizable (Rightb);
    G.End_Current;

    C.Add ("FL_NORMAL_LABEL", Normal_CB'Unrestricted_Access);
    C.Add ("FL_SHADOW_LABEL", Shadow_CB'Unrestricted_Access);
    C.Add ("FL_ENGRAVED_LABEL", Engraved_CB'Unrestricted_Access);
    C.Add ("FL_EMBOSSED_LABEL", Embossed_CB'Unrestricted_Access);
    --  menu (choices) selects the first item; Add does not
    C.Set_Chosen (1);

    Text.Text := SU.To_Unbounded_String (Input.Get_Value);
    Text.Set_Box (FLTK.Engraved_Box);
    Text.Set_Alignment (FLTK.Align_Bottom);
    Window.Set_Resizable (Text);
    Window.End_Current;
    Window.Show_With_Args;

    return FLTK.Run;

end Rotated_Text;
