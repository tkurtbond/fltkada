--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/output.cxx: an Fl_Output and an Fl_Multiline_Output that
--  show what is typed in an input, in the font and size two sliders
--  choose.  Guided by pofltk's Output.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Outputs.Multiline,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


function Output
    return Integer
is

    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Txt renames FLTK.Widgets.Inputs.Text;
    package Otp renames FLTK.Widgets.Inputs.Text.Outputs;
    package Mul renames FLTK.Widgets.Inputs.Text.Outputs.Multiline;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

begin

    FLTK.Static.Parse_Args;

    declare

        Window : Dbl.Double_Window := Dbl.Forge.Create (400, 400);

        Input : Txt.Text_Input := Txt.Forge.Create (Window, 50, 375, 350, 25);
        Sizes : HVS.Horizontal_Value_Slider := HVS.Forge.Create
            (Window, 50, 350, 350, 25, "Size");
        Fonts : HVS.Horizontal_Value_Slider := HVS.Forge.Create
            (Window, 50, 325, 350, 25, "Font");
        Text2 : Mul.Multiline_Output := Mul.Forge.Create
            (Window, 100, 150, 200, 100, "Fl_Multiline_Output");
        Text  : Otp.Output := Otp.Forge.Create (Window, 100, 90, 200, 30, "Fl_Output");


        procedure Font_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            Text.Set_Text_Font (FLTK.Font_Kind (Long_Float'Truncation (Fonts.Get_Value)));
            Text.Redraw;
            Text2.Set_Text_Font (FLTK.Font_Kind (Long_Float'Truncation (Fonts.Get_Value)));
            Text2.Redraw;
        end Font_CB;


        procedure Size_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            Text.Set_Text_Size (FLTK.Font_Size (Long_Float'Truncation (Sizes.Get_Value)));
            Text.Redraw;
            Text2.Set_Text_Size (FLTK.Font_Size (Long_Float'Truncation (Sizes.Get_Value)));
            Text2.Redraw;
        end Size_CB;


        procedure Input_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            Text.Set_Value (Input.Get_Value);
            Text2.Set_Value (Input.Get_Value);
        end Input_CB;

    begin

        --  FLTK's static_value; Set_Value copies, which looks the same.
        Input.Set_Value ("The quick brown fox" & ASCII.LF & "jumped over" & ASCII.LF &
            "the lazy dog.");
        Input.Set_When (FLTK.When_Changed);
        Input.Set_Callback (Input_CB'Unrestricted_Access);

        Sizes.Set_Alignment (FLTK.Align_Left);
        Sizes.Set_Bounds (1.0, 64.0);
        Sizes.Set_Step (1);
        Sizes.Set_Value (14.0);
        Sizes.Set_Callback (Size_CB'Unrestricted_Access);

        Fonts.Set_Alignment (FLTK.Align_Left);
        Fonts.Set_Bounds (0.0, 15.0);
        Fonts.Set_Step (1);
        Fonts.Set_Value (0.0);
        Fonts.Set_Callback (Font_CB'Unrestricted_Access);

        Text2.Set_Value (Input.Get_Value);
        Text2.Set_Alignment (FLTK.Align_Bottom);
        Text2.Set_Tooltip ("This is an Fl_Multiline_Output widget.");
        Window.Set_Resizable (Text2);

        Text.Set_Value (Input.Get_Value);
        Text.Set_Alignment (FLTK.Align_Bottom);
        Text.Set_Tooltip ("This is an Fl_Output widget.");

        Window.End_Current;
        Window.Show_With_Args;

        return FLTK.Run;

    end;

end Output;
