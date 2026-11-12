--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/radio.fl: each kind of button, with two groups of radio
--  buttons, and an output showing the label, value and changed flag of
--  the last button whose callback ran.  Ported from the C++ that FLUID
--  writes from it, guided by pofltk's Radio.Mod.


with

    Ada.Text_IO,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Light.Round,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Outputs.Multiline;

use type

    FLTK.Alignment;


function Radio
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Ent renames FLTK.Widgets.Buttons.Enter;
    package Lit renames FLTK.Widgets.Buttons.Light;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Rnd renames FLTK.Widgets.Buttons.Light.Round;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Grp renames FLTK.Widgets.Groups;
    package MO  renames FLTK.Widgets.Inputs.Text.Outputs.Multiline;


    W : Dbl.Double_Window := Dbl.Forge.Create (369, 214);

    A1 : Btn.Button := Btn.Forge.Create (W, 20, 10, 160, 30, "&Fl_Button A1");
    A2 : Btn.Button := Btn.Forge.Create (W, 20, 44, 160, 30, "Fl_Button &A2");
    B  : Ent.Enter_Button := Ent.Forge.Create (W, 20, 78, 160, 30, "Fl_Return_Button &B");
    C  : Lit.Light_Button := Lit.Forge.Create (W, 20, 113, 160, 30, "Fl_Light_Button &C");
    D  : Chk.Check_Button := Chk.Forge.Create (W, 20, 148, 160, 30, "Fl_Check_Button &D");
    E  : Rnd.Round_Button := Rnd.Forge.Create (W, 20, 178, 160, 30, "Fl_Round_Button &E");

    Rounds : Grp.Group := Grp.Forge.Create (W, 190, 10, 70, 120);
    R1 : Rnd.Round_Button := Rnd.Forge.Create (Rounds, 190, 10, 70, 30, "radio &1");
    R2 : Rnd.Round_Button := Rnd.Forge.Create (Rounds, 190, 40, 70, 30, "radio &2");
    R3 : Rnd.Round_Button := Rnd.Forge.Create (Rounds, 190, 70, 70, 30, "radio &3");
    R4 : Rnd.Round_Button := Rnd.Forge.Create (Rounds, 190, 100, 70, 30, "radio &4");

    Customs : Grp.Group := Grp.Forge.Create (W, 270, 10, 90, 120);
    C1 : Btn.Button := Btn.Forge.Create (Customs, 280, 20, 20, 20, "radio");
    C2 : Btn.Button := Btn.Forge.Create (Customs, 280, 45, 20, 20, "radio");
    C3 : Btn.Button := Btn.Forge.Create (Customs, 280, 70, 20, 20, "radio");
    C4 : Btn.Button := Btn.Forge.Create (Customs, 280, 95, 20, 20, "radio");

    Info : MO.Multiline_Output := MO.Forge.Create (W, 190, 148, 170, 62, "callback:");


    procedure Button_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        This    : Btn.Button'Class renames Btn.Button'Class (Item);
        --  FLTK's changed () is the flag's bit, FL_CHANGED, 128.
        Changed : constant Integer := (if This.Has_Changed then 128 else 0);
        Msg     : constant String :=
            "Label: '" & This.Get_Label & "'" & ASCII.LF &
            "Value:" & Integer'Image (Btn.State'Pos (This.Get_State)) & ASCII.LF &
            "Changed:" & Integer'Image (Changed);
    begin
        Info.Set_Value (Msg);
        Info.Redraw;
        Ada.Text_IO.Put_Line (Msg);
    end Button_Callback;


    procedure Normal
           (Item : in out Btn.Button'Class;
            Tip  : in     String) is
    begin
        Item.Set_Tooltip (Tip);
        Item.Set_Label_Size (13);
        Item.Set_Callback (Button_Callback'Unrestricted_Access);
    end Normal;

    procedure Round_Radio
           (Item : in out Rnd.Round_Button) is
    begin
        Item.Set_Tooltip
           ("Radio button, only one button is set at a time, in the corresponding group.");
        Item.Set_Kind (Btn.Radio_Kind);
        Item.Set_Down_Box (FLTK.Round_Down_Box);
        Item.Set_Callback (Button_Callback'Unrestricted_Access);
    end Round_Radio;

    procedure Custom_Radio
           (Item : in out Btn.Button) is
    begin
        Item.Set_Tooltip
           ("Custom look button, only one button is set at a time, in the corresponding group.");
        Item.Set_Kind (Btn.Radio_Kind);
        Item.Set_Selection_Color (1);
        Item.Set_Alignment (FLTK.Align_Right);
    end Custom_Radio;


begin

    Normal (A1, "Normal button (callback called only when released)");
    Normal (A2, "Normal button with callback called when changed (push and released)");
    A2.Set_When (FLTK.When_Changed);
    Normal (B, "Button with Return key as default shortcut");
    Normal (C, "Button with toggle state and a visual indicator of the current state");
    Normal (D, "Check button with toggle state");
    D.Set_Down_Box (FLTK.Down_Box);
    Normal (E, "Round Button with toggle state");
    E.Set_Down_Box (FLTK.Round_Down_Box);

    Rounds.Set_Box (FLTK.Thin_Up_Frame);
    Round_Radio (R1);
    Round_Radio (R2);
    Round_Radio (R3);
    Round_Radio (R4);

    Customs.Set_Box (FLTK.Thin_Up_Box);
    Custom_Radio (C1);
    Custom_Radio (C2);
    Custom_Radio (C3);
    Custom_Radio (C4);

    Info.Set_Text_Size (12);
    Info.Set_Alignment (FLTK.Align_Top + FLTK.Align_Left + FLTK.Align_Wrap);

    W.Show_With_Args;

    return FLTK.Run;

end Radio;
