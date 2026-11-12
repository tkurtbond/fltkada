--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/label.cxx: a label's alignments, fonts, sizes and types,
--  with and without an image, and its margins and the gap between image
--  and text; each control changes the frame's label at once.  FLTK's
--  static_value becomes Set_Value, which copies the text; the input looks
--  the same.  FL_SYMBOL_LABEL is FL_NORMAL_LABEL.  Guided by pofltk's
--  Label.Mod.


with

    Ada.Strings.Unbounded,
    FLTK.Images.Pixmaps,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

use type

    FLTK.Alignment;


function Label
    return Integer
is

    package SU  renames Ada.Strings.Unbounded;
    package Pix renames FLTK.Images.Pixmaps;
    package Bx  renames FLTK.Widgets.Boxes;
    package Tgl renames FLTK.Widgets.Buttons.Toggle;
    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package Chc renames FLTK.Widgets.Menus.Choices;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    function "+" (Str : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;


    --  test/pixmaps/blast.xpm

    type Blast_Pixel_Rows is array (1 .. 32) of String (1 .. 32);

    function To_Data
           (Rows : in Blast_Pixel_Rows)
        return Pix.Pixmap_Data
    is
        Data : Pix.Pixmap_Data (Rows'Range, Rows (Rows'First)'Range);
    begin
        for R in Data'Range (1) loop
            for C in Data'Range (2) loop
                Data (R, C) := Rows (R) (C);
            end loop;
        end loop;
        return Data;
    end To_Data;

    Blast_Header : constant Pix.Header := (32, 32, 32, 1);
    Blast_Colors : constant Pix.Color_Definition_Array :=
       ((+" ", Pix.Colorful, +"#905518"), (+".", Pix.Colorful, +"#9F580E"),
        (+"+", Pix.Colorful, +"#A36526"), (+"@", Pix.Colorful, +"#AF6519"),
        (+"#", Pix.Colorful, +"#BF7429"), (+"$", Pix.Colorful, +"#C77622"),
        (+"%", Pix.Colorful, +"#B67B3C"), (+"&", Pix.Colorful, +"#D07518"),
        (+"*", Pix.Colorful, +"#D88836"), (+"=", Pix.Colorful, +"#E48628"),
        (+"-", Pix.Colorful, +"#F28514"), (+";", Pix.Colorful, +"#FF951C"),
        (+">", Pix.Colorful, +"#FA9835"), (+",", Pix.Colorful, +"#FF982A"),
        (+"'", Pix.Colorful, +"#F49F48"), (+")", Pix.Colorful, +"#FFA82D"),
        (+"!", Pix.Colorful, +"#FFA93F"), (+"~", Pix.Colorful, +"#FFBA1C"),
        (+"{", Pix.Colorful, +"#FFB936"), (+"]", Pix.Colorful, +"#FFBA4C"),
        (+"^", Pix.Colorful, +"#FFCA42"), (+"/", Pix.Colorful, +"#FFD329"),
        (+"(", Pix.Colorful, +"#FFCF5E"), (+"_", Pix.Colorful, +"#FFD94C"),
        (+":", Pix.Colorful, +"#FFE946"), (+"<", Pix.Colorful, +"#FFFB3E"),
        (+"[", Pix.Colorful, +"#FFFB55"), (+"}", Pix.Colorful, +"#FEFC69"),
        (+"|", Pix.Colorful, +"#FFFE82"), (+"1", Pix.Colorful, +"#FFFFA3"),
        (+"2", Pix.Colorful, +"#FEFFCB"), (+"3", Pix.Colorful, +"#FEFFFC"));
    Blast_Rows : constant Blast_Pixel_Rows :=
       ("     % .  ....@@@#@@.+.+++%     ",
        "  %%++++.....@######@@@@.++ %   ",
        " %%% %++@@.@@@#$$#######@++++%% ",
        " %%+%+####@@$&&=*=&&$$####@++%%+",
        "+%+%#####&&&&&==='===*$$###%%%%+",
        "%+%%%%**=*&&&&>,>,>-=>==*$*##%%%",
        "  %#****'=>---,))!),>>>==***#%#+",
        "  @%*'''>>>>;;,{{{))))>>>''**#%+",
        " ..@#*'!]]]{)){^__^^{]!!!'''###+",
        " ..@$=']]((^^~~:::/__^{((!>**##@",
        "....&&=>(_|[::/<}[<[::_((!>==###",
        "....&&--!_}|}[<[}[}}}||_]!>>**##",
        "@@$$&&--;{:|1|[<|}|}||}_^]>>=*##",
        "##$$=-,;)~~<121<2|121}}:^])>=*$#",
        "#*'''!]{^_<<<1313332|}}}^{!>>*##",
        "%*'']((|}}||||<333321|[[_^]>==*#",
        "*''''((||112333333321|}[_^]!>=*#",
        "%%*''!]^_[[[}<13332}<[<:_])>>*$#",
        "##*==,,)~_:<[|212311}[</{),,=*$#",
        "#@$$==,;)~/<|1<2|<1}|[:^{)-=&&$@",
        ".@@$&&-;)~:|}<<1}[|}[[:^{,-=&$@@",
        "..@@&&-;)(}[/<[|[<<}<:_^{),=&$@.",
        "...@&&=,{_(~~:[[<</[[^~]!>>=&$@@",
        " .@@$&'!({;;{/}::/~/_^)),>=*$#@+",
        " ..@$=''>,-;)^__~^{)^]),,==*$#@@",
        ". @##*'==&--){({));;,{>>==$$#@++",
        "%++#%**$&&--,!));;;-->>=&$$##@+%",
        " +%%##@@@@&=>>>>>>=-==='$$#@@+++",
        " %%+@@..&.$&='==-&&&&&$*$#@@.+% ",
        " %%+ ....@$$*==&$&&&@$$##@@+ %  ",
        "   %  ....@#*#$$$#@@@@@##+@++   ",
        "        ..@####@@@@@..+@++%     ");


    Img : Pix.Pixmap := Pix.Forge.Create (Blast_Header, Blast_Colors, To_Data (Blast_Rows));

    Window : Dbl.Double_Window := Dbl.Forge.Create (440, 495);

    Input : Inp.Text_Input := Inp.Forge.Create
        (Window, 70, 435, 350, 25, "Label:");
    Sizes : HVS.Horizontal_Value_Slider := HVS.Forge.Create
        (Window, 70, 350, 350, 25, "Size:");
    Fonts : HVS.Horizontal_Value_Slider := HVS.Forge.Create
        (Window, 70, 325, 350, 25, "Font:");
    Margin : Bx.Box := Bx.Forge.Create (Window, 0, 380, 70, 25, "Margins");
    H_Margin : HVS.Horizontal_Value_Slider := HVS.Forge.Create
        (Window, 70 + 50, 380, 125, 25, "Hor:");
    V_Margin : HVS.Horizontal_Value_Slider := HVS.Forge.Create
        (Window, 70 + 175 + 50, 380, 125, 25, "Vert:");
    Img_Spacing : HVS.Horizontal_Value_Slider := HVS.Forge.Create
        (Window, 70 + 50, 405, 125, 25, "Image:");

    G : Grp.Group := Grp.Forge.Create (Window, 70, 275, 350, 50);
    Imageb           : Tgl.Toggle_Button := Tgl.Forge.Create (G, 70, 275, 50, 25, "image");
    Imageovertextb   : Tgl.Toggle_Button := Tgl.Forge.Create (G, 120, 275, 50, 25, "T o I");
    Imagenexttotextb : Tgl.Toggle_Button := Tgl.Forge.Create (G, 170, 275, 50, 25, "I | T");
    Imagebackdropb   : Tgl.Toggle_Button := Tgl.Forge.Create (G, 220, 275, 50, 25, "back");
    Leftb   : Tgl.Toggle_Button := Tgl.Forge.Create (G, 70, 300, 50, 25, "left");
    Rightb  : Tgl.Toggle_Button := Tgl.Forge.Create (G, 120, 300, 50, 25, "right");
    Topb    : Tgl.Toggle_Button := Tgl.Forge.Create (G, 170, 300, 50, 25, "top");
    Bottomb : Tgl.Toggle_Button := Tgl.Forge.Create (G, 220, 300, 50, 25, "bottom");
    Insideb : Tgl.Toggle_Button := Tgl.Forge.Create (G, 270, 300, 50, 25, "inside");
    Wrapb   : Tgl.Toggle_Button := Tgl.Forge.Create (G, 320, 300, 50, 25, "wrap");
    Clipb   : Tgl.Toggle_Button := Tgl.Forge.Create (G, 370, 300, 50, 25, "clip");

    --  created in the window, after the group is ended
    C    : Chc.Choice := Chc.Forge.Create (Window, 70, 250, 200, 25);
    Text : Bx.Box := Bx.Forge.Create
        (Window, FLTK.Engraved_Box, 120, 75, 200, 100);


    procedure Button_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        I : FLTK.Alignment := FLTK.Align_Center;
    begin
        if Leftb.Is_On then I := I + FLTK.Align_Left; end if;
        if Rightb.Is_On then I := I + FLTK.Align_Right; end if;
        if Topb.Is_On then I := I + FLTK.Align_Top; end if;
        if Bottomb.Is_On then I := I + FLTK.Align_Bottom; end if;
        if Insideb.Is_On then I := I + FLTK.Align_Inside; end if;
        if Clipb.Is_On then I := I + FLTK.Align_Clip; end if;
        if Wrapb.Is_On then I := I + FLTK.Align_Wrap; end if;
        if Imageovertextb.Is_On then I := I + FLTK.Align_Text_Over_Image; end if;
        if Imagenexttotextb.Is_On then I := I + FLTK.Align_Image_Next_To_Text; end if;
        if Imagebackdropb.Is_On then I := I + FLTK.Align_Image_Backdrop; end if;
        Text.Set_Alignment (I);
        Window.Redraw;
    end Button_CB;


    procedure Image_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Imageb.Is_On then
            Text.Set_Image (Img);
        else
            Text.Clear_Image;
        end if;
        Window.Redraw;
    end Image_CB;


    procedure Font_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Set_Label_Font (FLTK.Font_Kind (Integer (Fonts.Get_Value)));
        Window.Redraw;
    end Font_CB;


    procedure H_Margin_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Set_Horizontal_Label_Margin (Integer (H_Margin.Get_Value));
        Window.Redraw;
    end H_Margin_CB;


    procedure V_Margin_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Set_Vertical_Label_Margin (Integer (V_Margin.Get_Value));
        Window.Redraw;
    end V_Margin_CB;


    procedure Spacing_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Set_Label_Image_Spacing (Integer (Img_Spacing.Get_Value));
        Window.Redraw;
    end Spacing_CB;


    procedure Size_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Set_Label_Size (FLTK.Font_Size (Integer (Sizes.Get_Value)));
        Window.Redraw;
    end Size_CB;


    procedure Input_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Text.Set_Label (Input.Get_Value);
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


    --  FL_SYMBOL_LABEL is FL_NORMAL_LABEL.
    procedure Symbol_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Value : constant String := Input.Get_Value;
    begin
        Text.Set_Label_Kind (FLTK.Normal_Label);
        if Value'Length = 0 or else Value (Value'First) /= '@' then
            Input.Set_Value ("@->");
            Text.Set_Label ("@->");
        end if;
        Window.Redraw;
    end Symbol_CB;


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
           (Item    : in out Tgl.Toggle_Button;
            Tooltip : in     String) is
    begin
        Item.Set_Callback (Button_CB'Unrestricted_Access);
        Item.Set_Tooltip (Tooltip);
    end Setup;


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

    Input.Set_Value ("The quick brown fox jumped over the lazy dog.");
    Input.Set_When (FLTK.When_Changed);
    Input.Set_Callback (Input_CB'Unrestricted_Access);
    Input.Set_Tooltip ("label text");

    Setup (Sizes, 1.0, 64.0, 14.0, Size_CB'Unrestricted_Access);
    Setup (Fonts, 0.0, 15.0, 0.0, Font_CB'Unrestricted_Access);

    Margin.Set_Box (FLTK.Flat_Box);
    Margin.Set_Alignment (FLTK.Align_Right + FLTK.Align_Inside);

    Setup (H_Margin, -25.0, 25.0, 0.0, H_Margin_CB'Unrestricted_Access);
    Setup (V_Margin, -25.0, 25.0, 0.0, V_Margin_CB'Unrestricted_Access);
    Setup (Img_Spacing, 0.0, 50.0, 0.0, Spacing_CB'Unrestricted_Access);

    Imageb.Set_Callback (Image_CB'Unrestricted_Access);
    Imageb.Set_Tooltip ("show image");
    Setup (Imageovertextb, "FL_ALIGN_TEXT_OVER_IMAGE");
    Setup (Imagenexttotextb, "FL_ALIGN_IMAGE_NEXT_TO_TEXT");
    Setup (Imagebackdropb, "FL_ALIGN_IMAGE_BACKDROP");
    Setup (Leftb, "FL_ALIGN_LEFT");
    Setup (Rightb, "FL_ALIGN_RIGHT");
    Setup (Topb, "FL_ALIGN_TOP");
    Setup (Bottomb, "FL_ALIGN_BOTTOM");
    Setup (Insideb, "FL_ALIGN_INSIDE");
    Setup (Wrapb, "FL_ALIGN_WRAP");
    Setup (Clipb, "FL_ALIGN_CLIP");

    G.Set_Resizable (Insideb);
    G.End_Current;

    C.Add ("FL_NORMAL_LABEL", Normal_CB'Unrestricted_Access);
    C.Add ("FL_SYMBOL_LABEL", Symbol_CB'Unrestricted_Access);
    C.Add ("FL_SHADOW_LABEL", Shadow_CB'Unrestricted_Access);
    C.Add ("FL_ENGRAVED_LABEL", Engraved_CB'Unrestricted_Access);
    C.Add ("FL_EMBOSSED_LABEL", Embossed_CB'Unrestricted_Access);
    --  menu (choices) selects the first item; Add does not
    C.Set_Chosen (1);

    Text.Set_Label (Input.Get_Value);
    Text.Set_Alignment (FLTK.Align_Center);

    Window.Set_Resizable (Text);
    Window.End_Current;
    Window.Show_With_Args;

    return FLTK.Run;

end Label;
