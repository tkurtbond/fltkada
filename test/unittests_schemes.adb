--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Text_Buffers,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Light.Round.Radio,
    FLTK.Widgets.Clocks.Updated,
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text.File,
    FLTK.Widgets.Inputs.Text.Outputs,
    FLTK.Widgets.Menus.Choices.Schemes,
    FLTK.Widgets.Progress_Bars,
    FLTK.Widgets.Valuators.Adjusters,
    FLTK.Widgets.Valuators.Counters,
    FLTK.Widgets.Valuators.Rollers,
    FLTK.Widgets.Valuators.Sliders.Scrollbars,
    FLTK.Widgets.Valuators.Sliders.Value,
    FLTK.Widgets.Valuators.Value_Inputs,
    FLTK.Widgets.Valuators.Value_Outputs;

use type

    FLTK.Alignment;


package body Unittests_Schemes is


    package Bx renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Lit renames FLTK.Widgets.Buttons.Light;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package RRB renames FLTK.Widgets.Buttons.Light.Round.Radio;
    package Clk renames FLTK.Widgets.Clocks.Updated;
    package Grp renames FLTK.Widgets.Groups;
    package Tabs renames FLTK.Widgets.Groups.Tabbed;
    package TD renames FLTK.Widgets.Groups.Text_Displays;
    package TE renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package TB renames FLTK.Text_Buffers;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package FIn renames FLTK.Widgets.Inputs.Text.File;
    package Otp renames FLTK.Widgets.Inputs.Text.Outputs;
    package SC renames FLTK.Widgets.Menus.Choices.Schemes;
    package PB renames FLTK.Widgets.Progress_Bars;
    package Adj renames FLTK.Widgets.Valuators.Adjusters;
    package Cnt renames FLTK.Widgets.Valuators.Counters;
    package Rol renames FLTK.Widgets.Valuators.Rollers;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package Scr renames FLTK.Widgets.Valuators.Sliders.Scrollbars;
    package VS renames FLTK.Widgets.Valuators.Sliders.Value;
    package VI renames FLTK.Widgets.Valuators.Value_Inputs;
    package VO renames FLTK.Widgets.Valuators.Value_Outputs;

    use FLTK, Unittests_Common;


    type Group_Access is access Grp.Group;
    type Scheme_Choice_Access is access SC.Scheme_Choice;
    type Light_Access is access Lit.Light_Button;
    type Window_Access is access Win.Window;
    type Button_Access is access Btn.Button;
    type Tabs_Access is access Tabs.Tabbed_Group;
    type Clock_Access is access Clk.Updated_Clock;
    type Progress_Access is access PB.Progress_Bar;
    type Slider_Access is access Sld.Slider;
    type Scrollbar_Access is access Scr.Scrollbar;
    type Value_Slider_Access is access VS.Value_Slider;
    type Value_Output_Access is access VO.Value_Output;
    type Adjuster_Access is access Adj.Adjuster;
    type Counter_Access is access Cnt.Counter;
    type Roller_Access is access Rol.Roller;
    type Value_Input_Access is access VI.Value_Input;
    type Input_Access is access Inp.Text_Input;
    type Output_Access is access Otp.Output;
    type Text_Editor_Access is access TE.Text_Editor;
    type Text_Display_Access is access TD.Text_Display;
    type Text_Buffer_Access is access TB.Text_Buffer;
    type File_Input_Access is access FIn.File_Input;
    type Radio_Round_Access is access RRB.Radio_Round_Button;
    type Box_Access is access Bx.Box;
    type Check_Access is access Chk.Check_Button;

    Subwin : Window_Access;


    procedure Activate_Subwin
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        B      : Lit.Light_Button renames Lit.Light_Button (Item);
        Active : constant Boolean := B.Is_On;
    begin
        if Active then
            B.Set_Label ("active");
        else
            B.Set_Label ("inactive");
        end if;
        --  Documentation of deactivate() states: "Currently you cannot
        --  deactivate Fl_Window widgets".  However, it seems to work in
        --  this case.  AlbrechtS, FLTK 1.4, July 2022
        if Active then
            Subwin.Activate;
        else
            Subwin.Deactivate;
        end if;
    end Activate_Subwin;


    function New_Buffer
           (Text : in String := "")
        return Text_Buffer_Access
    is
        B : constant Text_Buffer_Access := new TB.Text_Buffer'(TB.Forge.Create);
    begin
        if Text /= "" then
            B.Set_Entire_Text (Text);
        end if;
        return B;
    end New_Buffer;


    --  One of the labelled boxes, size 10, in the current group.  Their
    --  label colour is FL_FOREGROUND_COLOR unless the C++ sets another.
    procedure Make_Box
           (X, Y, W, H  : in Integer;
            Label       : in String;
            Kind        : in Box_Kind;
            Color       : in FLTK.Color;
            Label_Color : in FLTK.Color := Foreground_Color)
    is
        O : constant Box_Access := new Bx.Box'(Bx.Forge.Create (X, Y, W, H, Label));
    begin
        O.Set_Box (Kind);
        O.Set_Background_Color (Color);
        O.Set_Label_Color (Label_Color);
        O.Set_Label_Size (10);
    end Make_Box;


    procedure Make_Subwindow_Contents is
    begin
        --  Pasted from Edmanuel's gleam test app
        declare
            O : constant Button_Access := new Btn.Button'
               (Btn.Forge.Create (10, 9, 90, 25, "button"));
        begin
            O.Set_Box (Up_Box);
            O.Set_Background_Color (101);
            O.Set_Tooltip ("selection_color() = default");
            O.Set_Label_Font (5);
        end;
        declare
            O : constant Button_Access := new Btn.Button'
               (Btn.Forge.Create (10, 36, 90, 25, "button"));
        begin
            O.Set_Box (Up_Box);
            O.Set_Background_Color (179);
            O.Set_Selection_Color (O.Get_Background_Color);
            O.Set_Tooltip ("selection_color() = color()");
            O.Set_Label_Font (4);
            O.Set_Label_Color (Background2_Color);
        end;
        declare
            O : constant Button_Access := new Btn.Button'
               (Btn.Forge.Create (10, 63, 90, 25, "button"));
        begin
            O.Set_Box (Up_Box);
            O.Set_Background_Color (91);
            O.Set_Selection_Color (Lighter (O.Get_Background_Color));
            O.Set_Tooltip ("selection_color() = fl_lighter(color())");
        end;
        declare
            O : constant Button_Access := new Btn.Button'
               (Btn.Forge.Create (10, 90, 90, 25, "button"));
        begin
            O.Set_Box (Up_Box);
            O.Set_Background_Color (Inactive_Color);
            O.Set_Selection_Color (Darker (O.Get_Background_Color));
            O.Set_Tooltip ("selection_color() = fl_darker(color())");
            O.Set_Label_Color (Background2_Color);
        end;
        declare
            O : constant Tabs_Access := new Tabs.Tabbed_Group'
               (Tabs.Forge.Create (10, 120, 320, 215));
        begin
            O.Begin_Current;
            O.Set_Background_Color (Dark1_Color);
            O.Set_Selection_Color (Dark1_Color);
            declare
                O : constant Group_Access := new Grp.Group'
                   (Grp.Forge.Create (14, 141, 310, 190, "tab1"));
            begin
                O.Begin_Current;
                O.Set_Background_Color (Dark1_Color);
                O.Set_Selection_Color (23);
                O.Hide;
                declare
                    O : constant Clock_Access := new Clk.Updated_Clock'
                       (Clk.Forge.Create (24, 166, 130, 130));
                begin
                    O.Set_Box (Thin_Up_Box);
                    O.Set_Background_Color (12);
                    O.Set_Selection_Color (Background2_Color);
                    O.Set_Label_Color (Background2_Color);
                    O.Set_Tooltip ("Fl_Clock with thin up box");
                end;
                declare
                    O : constant Progress_Access := new PB.Progress_Bar'
                       (PB.Forge.Create (22, 306, 290, 20));
                    pragma Unreferenced (O);
                begin
                    null;
                end;
                declare
                    O : constant Clock_Access := new Clk.Updated_Clock'
                       (Clk.Forge.Create (179, 166, 130, 130));
                begin
                    O.Set_Box (Thin_Down_Box);
                    O.Set_Background_Color (26);
                    O.Set_Tooltip ("Fl_Clock with thin down box");
                end;
                O.End_Current;
            end;
            declare
                O : constant Group_Access := new Grp.Group'
                   (Grp.Forge.Create (15, 140, 310, 190, "tab2"));
            begin
                O.Begin_Current;
                O.Set_Background_Color (Dark1_Color);
                declare
                    O : constant Slider_Access := new Sld.Slider'
                       (Sld.Forge.Create (20, 161, 25, 155));
                begin
                    O.Set_Box (Down_Box);
                    O.Set_Tooltip ("Fl_Slider with down box");
                end;
                declare
                    O : constant Scrollbar_Access := new Scr.Scrollbar'
                       (Scr.Forge.Create (50, 161, 25, 155));
                begin
                    O.Set_All (0, 50, 1, 100);
                    O.Set_Box (Down_Box);
                    O.Set_Tooltip ("Fl_Scrollbar with down box");
                end;
                declare
                    O : constant Value_Slider_Access := new VS.Value_Slider'
                       (VS.Forge.Create (115, 161, 25, 155));
                begin
                    O.Set_Box (Down_Box);
                end;
                declare
                    O : constant Value_Output_Access := new VO.Value_Output'
                       (VO.Forge.Create (240, 265, 75, 25));
                begin
                    O.Set_Box (Down_Box);
                    O.Set_Tooltip ("Fl_Value_Output with down box");
                end;
                declare
                    O : constant Adjuster_Access := new Adj.Adjuster'
                       (Adj.Forge.Create (185, 210, 100, 25));
                begin
                    O.Set_Tooltip ("Fl_Adjuster");
                end;
                declare
                    O : constant Counter_Access := new Cnt.Counter'
                       (Cnt.Forge.Create (185, 180, 100, 25));
                begin
                    O.Set_Box (Down_Box);
                    O.Set_Tooltip ("Fl_Counter with down box");
                end;
                declare
                    O : constant Roller_Access := new Rol.Roller'
                       (Rol.Forge.Create (85, 161, 25, 155));
                begin
                    O.Set_Box (Up_Box);
                    O.Set_Tooltip ("Fl_Roller with up box");
                end;
                declare
                    O : constant Value_Input_Access := new VI.Value_Input'
                       (VI.Forge.Create (155, 265, 75, 25));
                begin
                    O.Set_Box (Down_Box);
                    O.Set_Tooltip ("Fl_Value_Input with down box");
                end;
                O.End_Current;
            end;
            declare
                O : constant Group_Access := new Grp.Group'
                   (Grp.Forge.Create (15, 140, 310, 190, "tab3"));
            begin
                O.Begin_Current;
                O.Set_Background_Color (Dark1_Color);
                O.Hide;
                declare
                    O : constant Input_Access := new Inp.Text_Input'
                       (Inp.Forge.Create (40, 230, 120, 25));
                begin
                    O.Set_Box (Down_Box);
                    O.Set_Tooltip ("Fl_Input with down box");
                end;
                declare
                    O : constant Output_Access := new Otp.Output'
                       (Otp.Forge.Create (40, 260, 120, 25));
                begin
                    O.Set_Box (Down_Box);
                    O.Set_Tooltip ("Fl_Output with down box");
                end;
                declare
                    O : constant Text_Editor_Access := new TE.Text_Editor'
                       (TE.Forge.Create (180, 160, 125, 55));
                begin
                    O.Set_Box (Down_Frame);
                    O.Set_Background_Color (80);
                    O.Set_Tooltip ("Fl_Text_Editor with down frame");
                    O.Set_Text_Size (8);
                    O.Set_Buffer (New_Buffer ("Text editor").all);
                end;
                declare
                    O : constant Text_Display_Access := new TD.Text_Display'
                       (TD.Forge.Create (180, 230, 125, 55));
                begin
                    O.Set_Box (Down_Frame);
                    O.Set_Background_Color (12);
                    O.Set_Tooltip ("Fl_Text_Display with down frame");
                    O.Set_Text_Size (8);
                    O.Set_Buffer (New_Buffer ("Text display").all);
                end;
                declare
                    O : constant File_Input_Access := new FIn.File_Input'
                       (FIn.Forge.Create (40, 290, 265, 30));
                begin
                    O.Set_Box (Down_Box);
                    O.Set_Tooltip ("Fl_File_Input with down box");
                end;
                O.End_Current;
            end;
            declare
                O : constant Group_Access := new Grp.Group'
                   (Grp.Forge.Create (15, 140, 310, 190, "tab4"));
            begin
                O.Begin_Current;
                O.Set_Background_Color (Dark1_Color);
                O.Hide;
                declare
                    O : constant Radio_Round_Access := new RRB.Radio_Round_Button'
                       (RRB.Forge.Create (40, 160, 120, 25, "Choice 1"));
                begin
                    O.Set_Tooltip ("Fl_Radio_Round_Button (default)");
                    --  don't set selection color (use default selection color)
                    O.Set_State (Btn.On);   --  selected
                end;
                declare
                    O : constant Radio_Round_Access := new RRB.Radio_Round_Button'
                       (RRB.Forge.Create (40, 190, 120, 25, "Choice 2"));
                begin
                    O.Set_Tooltip ("Fl_Radio_Round_Button (red)");
                    O.Set_Selection_Color (Red_Color);
                end;
                declare
                    O : constant Radio_Round_Access := new RRB.Radio_Round_Button'
                       (RRB.Forge.Create (40, 220, 120, 25, "Choice 3"));
                begin
                    O.Set_Tooltip ("Fl_Radio_Round_Button (green)");
                    O.Set_Selection_Color (Darker (Green_Color));
                end;
                declare
                    O : constant Radio_Round_Access := new RRB.Radio_Round_Button'
                       (RRB.Forge.Create (40, 250, 120, 25, "Choice 4"));
                begin
                    O.Set_Tooltip ("Fl_Radio_Round_Button (blue)");
                    O.Set_Selection_Color (Blue_Color);
                end;
                O.End_Current;
            end;
            O.End_Current;
        end;
        Make_Box (341, 10, 80, 50, "thin box" & ASCII.LF & "down1", Thin_Down_Box, 20);
        Make_Box (430, 10, 80, 50, "thin box" & ASCII.LF & "up1", Thin_Up_Box,
            Selection_Color, Label_Color => 6);
        Make_Box (341, 71, 80, 44, "thin box" & ASCII.LF & "down2", Thin_Down_Box, 190);
        Make_Box (430, 71, 80, 44, "thin box" & ASCII.LF & "up2", Thin_Up_Box, 96,
            Label_Color => Background2_Color);
        Make_Box (341, 127, 80, 50, "box down3", Down_Box, 3);
        Make_Box (430, 127, 80, 50, "box up3", Up_Box, 104, Label_Color => 3);
        Make_Box (341, 189, 80, 50, "box down4", Down_Box, 42, Label_Color => Dark_Red_Color);
        Make_Box (430, 189, 80, 50, "box up4", Up_Box, 30, Label_Color => 26);
        Make_Box (341, 251, 80, 82, "box down5", Down_Box, 19, Label_Color => 4);
        Make_Box (430, 251, 80, 82, "box up5", Up_Box, Foreground_Color,
            Label_Color => Background2_Color);
        declare
            O : constant Light_Access := new Lit.Light_Button'
               (Lit.Forge.Create (110, 10, 105, 25, "Light"));
        begin
            O.Set_Box (Down_Box);
            O.Set_Background_Color (Background2_Color);
            O.Set_Selection_Color (30);
            O.Set_Selection_Color (Red_Color);
            O.Set_Tooltip ("Fl_Light_Button with down box");
        end;
        declare
            O : constant Check_Access := new Chk.Check_Button'
               (Chk.Forge.Create (110, 37, 105, 25, "Check"));
        begin
            O.Set_Box (Down_Frame);
            O.Set_Down_Box (Down_Box);
            O.Set_Background_Color (Dark1_Color);
            O.Set_Selection_Color (Darker (Green_Color));
            O.Set_Tooltip ("Fl_Check_Button with down frame");
        end;
        declare
            O : constant Input_Access := new Inp.Text_Input'
               (Inp.Forge.Create (220, 10, 100, 25));
        begin
            O.Set_Box (Down_Box);
            O.Set_Background_Color (23);
            O.Set_Tooltip ("Fl_Input with down box");
        end;
        declare
            O : constant Adjuster_Access := new Adj.Adjuster'
               (Adj.Forge.Create (110, 65, 80, 43));
        begin
            O.Set_Box (Up_Box);
            O.Set_Background_Color (Inactive_Color);
            O.Set_Selection_Color (Background2_Color);
            O.Set_Label_Color (55);
            O.Set_Tooltip ("Fl_Adjuster with up box");
        end;
        declare
            O : constant Text_Editor_Access := new TE.Text_Editor'
               (TE.Forge.Create (220, 40, 100, 25));
        begin
            O.Set_Box (Down_Frame);
            O.Set_Background_Color (19);
            O.Set_Selection_Color (Dark1_Color);
            O.Set_Buffer (New_Buffer.all);
            O.Set_Tooltip ("Fl_Text_Editor with down frame");
        end;
        declare
            O : constant Text_Editor_Access := new TE.Text_Editor'
               (TE.Forge.Create (220, 70, 100, 25));
        begin
            O.Set_Box (Up_Frame);
            O.Set_Background_Color (19);
            O.Set_Selection_Color (Dark1_Color);
            O.Set_Buffer (New_Buffer.all);
            O.Set_Tooltip ("Fl_Text_Editor with up frame");
        end;
    end Make_Subwindow_Contents;


    function Create
        return Widget_Access
    is
        X : constant Integer := Test_Area_X;
        Y : constant Integer := Test_Area_Y;
        W : constant Integer := Test_Area_W;
        H : constant Integer := Test_Area_H;
        Page          : constant Group_Access := new Grp.Group'(Grp.Forge.Create (X, Y, W, H));
        Scheme_Choice : Scheme_Choice_Access;
        Active        : Light_Access;
    begin
        Page.Begin_Current;
        Scheme_Choice := new SC.Scheme_Choice'
           (SC.Forge.Create (X + 125, Y, 140, 25, "FLTK Scheme"));
        Active := new Lit.Light_Button'(Lit.Forge.Create (X + 300, Y, 100, 25, "active"));
        Scheme_Choice.Set_Label_Font (Helvetica_Bold);

        Active.Set_State (Btn.On);
        Active.Set_Selection_Color (Red_Color);
        Active.Set_Alignment (Align_Center);
        Subwin := new Win.Window'(Win.Forge.Create (X, Y + 30, W, H - 30));
        Active.Set_Callback (Activate_Subwin'Access);
        Subwin.Begin_Current;
        Make_Subwindow_Contents;
        Subwin.End_Current;
        Subwin.Set_Resizable (Subwin.all);
        Subwin.Show;
        Page.End_Current;
        return Widget_Access (Page);
    end Create;


end Unittests_Schemes;
