--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Inputs.Text.Multiline,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

use type

    FLTK.Alignment;


package body Unittests_Unicode is


    package TB renames FLTK.Text_Buffers;
    package TD renames FLTK.Widgets.Groups.Text_Displays;
    package MLI renames FLTK.Widgets.Inputs.Text.Multiline;
    package Ch renames FLTK.Widgets.Menus.Choices;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;
    package Grp renames FLTK.Widgets.Groups;

    use FLTK, Unittests_Common;


    UTF8_Box_Test : constant String :=
       "╳╳ ██ ▏▏┏━━┓ ╔══╗ ╔═╦═╗ ██████" &
       ASCII.LF & "╳╳ ██ ▏▏┃  ┃ ║  ║ ╠═╬═╣ ██  ██" &
       ASCII.LF &
       "╳╳ ██ ▏▏┗━━┛ ╚══╝ ╚═╩═╝ ██████" &
       ASCII.LF & ASCII.LF & "underbar: ______" & ASCII.LF & " overbar: ‾‾‾‾‾‾" &
       ASCII.LF & ASCII.LF & "underbar/overbar alternate:" & ASCII.LF & ASCII.LF &
       "___‾‾‾___‾‾‾___‾‾‾___‾‾‾___" & ASCII.LF &
       "‾‾‾___‾‾‾___‾‾‾___‾‾‾___‾‾‾" & ASCII.LF;

    Help_Text : constant String :=
       "In this test, ideally the box's lines should all be touching without white space " &
       "between. Underbar and overbars should both be visible and not touching. All the " &
       "above should be unaffected by different font sizes and font settings.";


    type Group_Access is access Grp.Group;
    type Buffer_Access is access TB.Text_Buffer;
    type Display_Access is access TD.Text_Display;
    type Input_Access is access MLI.Multiline_Input;
    type Choice_Access is access Ch.Choice;
    type Slider_Access is access HVS.Horizontal_Value_Slider;

    Page             : Group_Access;
    Text_Buffer      : Buffer_Access;
    Text_Display     : Display_Access;
    Multiline_Input  : Input_Access;
    Font_Choice      : Choice_Access;
    Font_Size_Slider : Slider_Access;


    --  Font choice callback
    procedure Font_Choice_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        case Font_Choice.Chosen_Index is
            when 1 => Text_Display.Set_Text_Font (Courier);
            when 2 => Text_Display.Set_Text_Font (Monospace);
            when others => null;
        end case;
        Page.Parent.Redraw;
    end Font_Choice_CB;


    --  Slider callback - apply new font size to widgets
    procedure Font_Size_Slider_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Font_Size : constant FLTK.Font_Size :=
            FLTK.Font_Size (Long_Float'Truncation (Font_Size_Slider.Get_Value));
    begin
        Text_Display.Set_Text_Size (Font_Size);
        Multiline_Input.Set_Text_Size (Font_Size);
        Multiline_Input.Set_Position (0);   --  keep scrolled to top
        Page.Parent.Redraw;
    end Font_Size_Slider_CB;


    function Create
        return Widget_Access
    is
        X : constant Integer := Test_Area_X;
        Y : constant Integer := Test_Area_Y;
        W : constant Integer := Test_Area_W;
        H : constant Integer := Test_Area_H;
    begin
        Page := new Grp.Group'(Grp.Forge.Create (X, Y, W, H));
        Page.Begin_Current;

        --  Fl_Text_Display
        Text_Buffer := new TB.Text_Buffer'(TB.Forge.Create);
        Text_Buffer.Set_Entire_Text (UTF8_Box_Test);
        Text_Display := new TD.Text_Display'
           (TD.Forge.Create (X + 5, Y + 20, 250, 250, "Fl_Text_Display"));
        Text_Display.Set_Text_Font (Courier);
        Text_Display.Set_Buffer (Text_Buffer.all);
        Text_Display.Set_Tooltip (Help_Text);

        --  Fl_Multiline_Input
        Multiline_Input := new MLI.Multiline_Input'
           (MLI.Forge.Create (X + 250 + 15, Y + 20, 250, 250, "Fl_Multiline_Input"));
        Multiline_Input.Set_Alignment (Align_Center + Align_Top);
        Multiline_Input.Set_Text_Font (Courier);
        Multiline_Input.Set_Value (UTF8_Box_Test);
        Multiline_Input.Set_Tooltip (Help_Text);

        --  Font choice
        --  Fonts must be fixed width to work correctly..
        Font_Choice := new Ch.Choice'(Ch.Forge.Create (X + 150, Y + H - 80, 200, 25, "Font face"));
        Font_Choice.Add ("FL_COURIER");
        Font_Choice.Add ("FL_SCREEN");
        Font_Choice.Set_Chosen (Place => 1);
        Font_Choice.Set_Callback (Font_Choice_CB'Access);

        --  Font size slider
        Font_Size_Slider := new HVS.Horizontal_Value_Slider'
           (HVS.Forge.Create (X + 150, Y + H - 50, 200, 25, "Font size"));
        Font_Size_Slider.Set_Alignment (Align_Left);
        Font_Size_Slider.Set_Range (1.0, 50.0);
        Font_Size_Slider.Set_Step (1.0);
        Font_Size_Slider.Set_Value (14.0);
        Font_Size_Slider.Set_Callback (Font_Size_Slider_CB'Access);
        Page.End_Current;
        return Widget_Access (Page);
    end Create;


end Unittests_Unicode;
