--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/input.cxx: one of each kind of text input, buttons that
--  set their when (), print the ones that changed, and change the
--  colours, and a terminal where their callbacks print.  Guided by
--  pofltk's Input.Mod.


with

    Ada.Strings.UTF_Encoding.Wide_Wide_Strings,
    FLTK.Asks,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Buttons.Light,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text.Floating_Point,
    FLTK.Widgets.Inputs.Text.Multiline,
    FLTK.Widgets.Inputs.Text.Secret,
    FLTK.Widgets.Inputs.Text.Whole_Number;

use type

    FLTK.Asks.Confirm_Result,
    FLTK.Callback_Flag;


function Input
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Lgt renames FLTK.Widgets.Buttons.Light;
    package Tgl renames FLTK.Widgets.Buttons.Toggle;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Inp renames FLTK.Widgets.Inputs;
    package Txt renames FLTK.Widgets.Inputs.Text;
    package Flt renames FLTK.Widgets.Inputs.Text.Floating_Point;
    package Mul renames FLTK.Widgets.Inputs.Text.Multiline;
    package Sec renames FLTK.Widgets.Inputs.Text.Secret;
    package Int renames FLTK.Widgets.Inputs.Text.Whole_Number;

    Terminal_Height : constant := 120;

begin

    --  the following two lines set the correct color scheme, so that
    --  Contrast below will return good results
    FLTK.Static.Parse_Args;
    FLTK.Static.System_Colors;

    declare

        Window : Win.Window := Win.Forge.Create (400, 420 + Terminal_Height);
        G_TTY  : Trm.Terminal := Trm.Forge.Create (Window, 0, 420, 400, Terminal_Height);

        Normal    : aliased Txt.Text_Input := Txt.Forge.Create
            (Window, 70, 10, 300, 30, "Normal:");
        Float     : aliased Flt.Float_Input := Flt.Forge.Create
            (Window, 70, 45, 300, 30, "Float:");
        Whole     : aliased Int.Integer_Input := Int.Forge.Create
            (Window, 70, 80, 300, 30, "Int:");
        Secret    : aliased Sec.Secret_Input := Sec.Forge.Create
            (Window, 70, 115, 300, 30, "&Secret:");
        Multiline : aliased Mul.Multiline_Input := Mul.Forge.Create
            (Window, 70, 150, 300, 100, "&Multiline:");

        type Input_Access is access all Inp.Input'Class;

        Inputs : constant array (0 .. 4) of Input_Access :=
           (Normal'Access, Float'Access, Whole'Access, Secret'Access, Multiline'Access);

        Y  : constant := 255;
        Y1 : constant := Y;

        When_Changed_Button     : Tgl.Toggle_Button := Tgl.Forge.Create
            (Window, 10, Y, 200, 25, "FL_WHEN_CHANGED");
        When_Release_Button     : Tgl.Toggle_Button := Tgl.Forge.Create
            (Window, 10, Y + 25, 200, 25, "FL_WHEN_RELEASE");
        When_Enter_Key_Button   : Tgl.Toggle_Button := Tgl.Forge.Create
            (Window, 10, Y + 50, 200, 25, "FL_WHEN_ENTER_KEY");
        When_Not_Changed_Button : Tgl.Toggle_Button := Tgl.Forge.Create
            (Window, 10, Y + 75, 200, 25, "FL_WHEN_NOT_CHANGED");
        Print_Button            : Btn.Button := Btn.Forge.Create
            (Window, 10, Y + 105, 200, 25, "&print changed()");
        Tab_Nav_Button          : Lgt.Light_Button := Lgt.Forge.Create
            (Window, 10, Y + 130, 100, 25, " Tab Nav");
        Arrow_Nav_Button        : Lgt.Light_Button := Lgt.Forge.Create
            (Window, 110, Y + 130, 100, 25, " Arrow Nav");

        Color_Button     : Btn.Button := Btn.Forge.Create (Window, 220, Y1, 120, 25, "color");
        Selection_Button : Btn.Button := Btn.Forge.Create
            (Window, 220, Y1 + 25, 120, 25, "selection_color");
        Text_Button      : Btn.Button := Btn.Forge.Create
            (Window, 220, Y1 + 50, 120, 25, "textcolor");

        When_Now : FLTK.Callback_Flag := FLTK.Call_Never;


        procedure CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            G_TTY.Print
               ("Callback for " & Item.Get_Label & " '" & Inp.Input'Class (Item).Get_Value &
                "'" & ASCII.LF);
        end CB;


        --  FLTK's toggle_cb, with the flag it is passed a formal.
        generic
            Flag : FLTK.Callback_Flag;
        procedure Toggle_CB
               (Item : in out FLTK.Widgets.Widget'Class);

        procedure Toggle_CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            if Btn.Button'Class (Item).Is_On then
                When_Now := When_Now + Flag;
            else
                When_Now := When_Now - Flag;
            end if;
            for I of Inputs loop
                I.Set_When (When_Now);
            end loop;
        end Toggle_CB;

        procedure Toggle_Changed     is new Toggle_CB (FLTK.When_Changed);
        procedure Toggle_Release     is new Toggle_CB (FLTK.When_Release);
        procedure Toggle_Enter_Key   is new Toggle_CB (FLTK.When_Enter_Key);
        procedure Toggle_Not_Changed is new Toggle_CB (FLTK.When_Interact);


        procedure Test
               (I : in out Inp.Input'Class) is
        begin
            if I.Has_Changed then
                I.Clear_Changed;
                G_TTY.Print (I.Get_Label & " '" & I.Get_Value & "'" & ASCII.LF);
                declare
                    C : constant Wide_Wide_Character := I.Wide_Wide_Index (I.Get_Position);
                begin
                    --  fl_utf8encode puts NUL at the text's end, which ends
                    --  FLTK's string.
                    G_TTY.Print
                       ("Symbol at cursor position: " &
                        (if C = Wide_Wide_Character'Val (0) then ""
                         else Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode ((1 => C))) &
                        ASCII.LF);
                end;
            end if;
        end Test;


        procedure Button_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            for I of Inputs loop
                Test (I.all);
            end loop;
        end Button_CB;


        --  FLTK's color_cb, with the colour it changes a formal.
        generic
            Target : FLTK.Color;
        procedure Color_CB
               (Item : in out FLTK.Widgets.Widget'Class);

        procedure Color_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            R, G, B : FLTK.Asks.RGB_Int;
        begin
            FLTK.Static.Get_Color (Target, R, G, B);
            if FLTK.Asks.Color_Chooser ("", R, G, B) = FLTK.Asks.Confirm then
                FLTK.Static.Set_Color (Target, R, G, B);
                FLTK.Screen.Redraw;
                Item.Set_Label_Color (FLTK.Contrast (FLTK.Black_Color, Target));
                Item.Redraw;
            end if;
        end Color_CB;

        procedure Color_Background  is new Color_CB (FLTK.Background2_Color);
        procedure Color_Selection   is new Color_CB (FLTK.Selection_Color);
        procedure Color_Foreground  is new Color_CB (FLTK.Foreground_Color);


        procedure Tab_Nav_CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            Multiline.Set_Tab_Nav (Btn.Button'Class (Item).Is_On);
        end Tab_Nav_CB;


        procedure Arrow_Nav_CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            FLTK.Static.Set_Option (FLTK.Static.Arrow_Focus, Btn.Button'Class (Item).Is_On);
        end Arrow_Nav_CB;

    begin

        Normal.Set_Tooltip ("Normal input field");
        Float.Set_Tooltip ("Input field for floating-point number (F1)");
        Float.Set_Shortcut (FLTK.Press (FLTK.Function_Key (1)));
        Whole.Set_Tooltip ("Input field for integer number (F2)");
        Whole.Set_Shortcut (FLTK.Press (FLTK.Function_Key (2)));
        Secret.Set_Tooltip ("Input field for password (Alt-S)");
        Multiline.Set_Tooltip ("Input field for short text with newlines (Alt-M)");
        Multiline.Set_Wrap (True);

        for I in 0 .. 3 loop
            Inputs (I).Set_When (FLTK.Call_Never);
            Inputs (I).Set_Callback (CB'Unrestricted_Access);
        end loop;

        When_Changed_Button.Set_Callback (Toggle_Changed'Unrestricted_Access);
        When_Changed_Button.Set_Tooltip ("Do callback each time the text changes");
        When_Release_Button.Set_Callback (Toggle_Release'Unrestricted_Access);
        When_Release_Button.Set_Tooltip ("Do callback when widget loses focus");
        When_Enter_Key_Button.Set_Callback (Toggle_Enter_Key'Unrestricted_Access);
        When_Enter_Key_Button.Set_Tooltip ("Do callback when user hits Enter key");
        When_Not_Changed_Button.Set_Callback (Toggle_Not_Changed'Unrestricted_Access);
        When_Not_Changed_Button.Set_Tooltip ("Do callback even if the text is not changed");

        Print_Button.Set_Callback (Button_CB'Unrestricted_Access);
        Print_Button.Set_Tooltip ("Print widgets that have changed() flag set");

        Tab_Nav_Button.Set_Tooltip ("Control tab navigation for the multiline input field");
        Tab_Nav_Button.Set_Callback (Tab_Nav_CB'Unrestricted_Access);
        Tab_Nav_Button.Set_State (Btn.State'Val (Boolean'Pos (Multiline.Is_Tab_Nav)));

        Arrow_Nav_Button.Set_Tooltip
           ("Control horizontal arrow key focus navigation behavior." & ASCII.LF &
            "e.g. Fl::OPTION_ARROW_FOCUS");
        Arrow_Nav_Button.Set_Callback (Arrow_Nav_CB'Unrestricted_Access);
        Arrow_Nav_Button.Set_State
           (Btn.State'Val (Boolean'Pos (FLTK.Static.Get_Option (FLTK.Static.Arrow_Focus))));

        Color_Button.Set_Background_Color (Normal.Get_Background_Color);
        Color_Button.Set_Callback (Color_Background'Unrestricted_Access);
        Color_Button.Set_Tooltip ("Color behind the text");

        Selection_Button.Set_Background_Color (Normal.Get_Selection_Color);
        Selection_Button.Set_Callback (Color_Selection'Unrestricted_Access);
        Selection_Button.Set_Label_Color
           (FLTK.Contrast (FLTK.Black_Color, Selection_Button.Get_Background_Color));
        Selection_Button.Set_Tooltip ("Color behind selected text");

        Text_Button.Set_Background_Color (Normal.Get_Text_Color);
        Text_Button.Set_Callback (Color_Foreground'Unrestricted_Access);
        Text_Button.Set_Label_Color
           (FLTK.Contrast (FLTK.Black_Color, Text_Button.Get_Background_Color));
        Text_Button.Set_Tooltip ("Color of the text");

        Window.End_Current;
        Window.Set_Resizable (G_TTY);
        Window.Show_With_Args;

        return FLTK.Run;

    end;

end Input;
