--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/keyboard.cxx and its FLUID-made keyboard_ui.cxx: a
--  picture of a keyboard whose keys light while they are held down, a
--  row of buttons that light with Ev.Last_Modifier's state and the mouse
--  buttons, the last key's FLTK name and text, and two dials the mouse
--  wheel turns.  The window ignores every event except the wheel, and an
--  event handler stops Escape closing it.  The buttons are made in
--  keyboard_ui.cxx's order, generated from it by a script.  Guided by
--  pofltk's Keyboard.Mod.


with

    Ada.Strings.Fixed,
    Ada.Strings.UTF_Encoding.Wide_Strings,
    Ada.Unchecked_Deallocation,
    FLTK.Events,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text.Outputs,
    FLTK.Widgets.Valuators.Dials;

use type

    FLTK.Alignment,
    FLTK.Event_Kind,
    FLTK.Keypress,
    FLTK.Widgets.Buttons.State;


function Keyboard
    return Integer
is

    package Ev   renames FLTK.Events;
    package Bx   renames FLTK.Widgets.Boxes;
    package Btn  renames FLTK.Widgets.Buttons;
    package Win  renames FLTK.Widgets.Groups.Windows;
    package Outp renames FLTK.Widgets.Inputs.Text.Outputs;
    package Dl   renames FLTK.Widgets.Valuators.Dials;


    type Output_Access is access Outp.Output;
    type Dial_Access is access Dl.Dial;
    type Box_Access is access Bx.Box;

    type Dial_Array is array (Positive range <>) of Dial_Access;

    procedure Free is new Ada.Unchecked_Deallocation (Outp.Output, Output_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Dl.Dial, Dial_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Bx.Box, Box_Access);

    Key_Output, Text_Output : Output_Access;
    Roller_X, Roller_Y      : Dial_Access;
    State_Label             : Box_Access;


    --  keyboard.h's MyWindow: the mouse wheel turns the dials, and no
    --  other event reaches the window or its children.
    type My_Window is new Win.Window with null record;

    overriding function Handle
           (This  : in out My_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    function Handle
           (This  : in out My_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        pragma Unreferenced (This);
    begin
        if Event = FLTK.Mouse_Wheel then
            Roller_X.Set_Value (Roller_X.Get_Value + Long_Float (Ev.Mouse_DX) * Roller_X.Get_Step);
            Roller_Y.Set_Value (Roller_Y.Get_Value + Long_Float (Ev.Mouse_DY) * Roller_Y.Get_Step);
            return FLTK.Handled;
        end if;
        return FLTK.Not_Handled;
    end Handle;


    --  Stops Escape closing the window; other shortcuts, such as the zoom
    --  keys, pass.
    function Handler
           (Event : in FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        if Event = FLTK.Shortcut and then Ev.Last_Key = FLTK.Escape_Key then
            return FLTK.Handled;
        end if;
        return FLTK.Not_Handled;
    end Handler;


    --  The tests for the state buttons, Fl::event_state (mask).
    type State_Test is access function return Boolean;

    function Shift return Boolean is (Ev.Last_Modifier (FLTK.Mod_Shift));
    function Caps_Lock return Boolean is (Ev.Last_Modifier (FLTK.Mod_Caps_Lock));
    function Ctrl return Boolean is (Ev.Last_Modifier (FLTK.Mod_Ctrl));
    function Alt return Boolean is (Ev.Last_Modifier (FLTK.Mod_Alt));
    function Num_Lock return Boolean is (Ev.Last_Modifier (FLTK.Mod_Num_Lock));
    function Meta return Boolean is (Ev.Last_Modifier (FLTK.Mod_Meta));
    function Scroll_Lock return Boolean is (Ev.Last_Modifier (FLTK.Mod_Scroll_Lock));
    function Button1 return Boolean is (Ev.Mouse_Left);
    function Button2 return Boolean is (Ev.Mouse_Middle);
    function Button3 return Boolean is (Ev.Mouse_Right);
    function Button4 return Boolean is (Ev.Mouse_Back);
    function Button5 return Boolean is (Ev.Mouse_Forward);

    --  The buttons marked "?" test bits 0x20, 0x2000, 0x4000 and 0x8000 of
    --  Fl::event_state, which FLTK's X11 driver never sets (Fl_x.cxx keeps
    --  only the modifier and button bits), so they never light in FLTK's
    --  build either.  FLTKAda's Modifier can't express them.
    function Never return Boolean is (False);


    --  keyboard.cxx tells its buttons apart by their callbacks, key_cb
    --  and shift_cb, and keeps the key or mask in the user data.
    type Key_Button is new Btn.Button with record
        Key  : FLTK.Keypress;
        Test : State_Test;  --  null for a key
    end record;

    type Key_Button_Access is access Key_Button;

    procedure Free is new Ada.Unchecked_Deallocation (Key_Button, Key_Button_Access);

    Buttons : array (1 .. 122) of Key_Button_Access;
    Count   : Natural := 0;


    Window : My_Window := (Win.Forge.Create (495, 215) with null record);


    procedure Add
           (X, Y, W, H : in Integer;
            Text       : in String;
            Key        : in FLTK.Keypress;
            Test       : in State_Test) is
    begin
        Count := Count + 1;
        Buttons (Count) := new Key_Button'
            (Btn.Forge.Create (Window, X, Y, W, H, Text) with Key => Key, Test => Test);
    end Add;

    procedure Add_Key
           (X, Y, W, H : in Integer;
            Text       : in String;
            Key        : in Natural) is
    begin
        Add (X, Y, W, H, Text, FLTK.Character_Key (Wide_Character'Val (Key)), null);
    end Add_Key;

    procedure Add_State
           (X, Y, W, H : in Integer;
            Text       : in String;
            Test       : in State_Test) is
    begin
        Add (X, Y, W, H, Text, FLTK.Character_Key (Wide_Character'Val (0)), Test);
    end Add_State;

    function Last
        return Key_Button_Access is (Buttons (Count));


    --  keyboard_ui.cxx's make_window.
    procedure Make_Window is
    begin
        Window.Set_Box (FLTK.Flat_Box);
        Window.Set_Background_Color (FLTK.Background_Color);
        Window.Set_Selection_Color (FLTK.Background_Color);
        Window.Set_Label_Kind (FLTK.No_Label);

        Key_Output := new Outp.Output'(Outp.Forge.Create
            (Window, 15, 20, 170, 30, "Fl::event_key():"));
        Key_Output.Set_Label_Size (9);
        Key_Output.Set_Alignment (FLTK.Align_Top_Left);
        Text_Output := new Outp.Output'(Outp.Forge.Create
            (Window, 195, 20, 190, 30, "Fl::event_text():"));
        Text_Output.Set_Label_Size (9);
        Text_Output.Set_Alignment (FLTK.Align_Top_Left);
        Add_Key (15, 70, 20, 20, "Esc ", 16#ff1b#);  --  FL_Escape
        Last.Set_Label_Size (8);
        Add_Key (50, 70, 20, 20, "F1", 16#ffbe#);  --  FL_F+1
        Last.Set_Label_Size (10);
        Add_Key (70, 70, 20, 20, "F2", 16#ffbf#);  --  FL_F+2
        Last.Set_Label_Size (10);
        Add_Key (90, 70, 20, 20, "F3", 16#ffc0#);  --  FL_F+3
        Last.Set_Label_Size (10);
        Add_Key (110, 70, 20, 20, "F4", 16#ffc1#);  --  FL_F+4
        Last.Set_Label_Size (10);
        Add_Key (140, 70, 20, 20, "F5", 16#ffc2#);  --  FL_F+5
        Last.Set_Label_Size (10);
        Add_Key (160, 70, 20, 20, "F6", 16#ffc3#);  --  FL_F+6
        Last.Set_Label_Size (10);
        Add_Key (180, 70, 20, 20, "F7", 16#ffc4#);  --  FL_F+7
        Last.Set_Label_Size (10);
        Add_Key (200, 70, 20, 20, "F8", 16#ffc5#);  --  FL_F+8
        Last.Set_Label_Size (10);
        Add_Key (230, 70, 20, 20, "F9", 16#ffc6#);  --  FL_F+9
        Last.Set_Label_Size (10);
        Add_Key (250, 70, 20, 20, "F10", 16#ffc7#);  --  FL_F+10
        Last.Set_Label_Size (10);
        Add_Key (270, 70, 20, 20, "F11", 16#ffc8#);  --  FL_F+11
        Last.Set_Label_Size (10);
        Add_Key (290, 70, 20, 20, "F12", 16#ffc9#);  --  FL_F+12
        Last.Set_Label_Size (10);
        Add_Key (325, 70, 20, 20, "Print ", 16#ff61#);  --  FL_Print
        Last.Set_Label_Size (8);
        Add_Key (345, 70, 20, 20, "Sclk ", 16#ff14#);  --  FL_Scroll_Lock
        Last.Set_Label_Size (8);
        Add_Key (365, 70, 20, 20, "Paus ", 16#ff13#);  --  FL_Pause
        Last.Set_Label_Size (8);
        Add_Key (400, 70, 20, 20, "Help", 16#ff68#);  --  FL_Help
        Last.Set_Label_Size (8);
        Add_Key (420, 70, 20, 20, "=", 16#ffbd#);  --  FL_KP+'='
        Last.Set_Label_Size (10);
        Roller_X := new Dl.Dial'(Dl.Forge.Create (Window, 440, 70, 20, 20, "x:"));
        Roller_Y := new Dl.Dial'(Dl.Forge.Create (Window, 460, 70, 20, 20, "y:"));
        for Roller of Dial_Array'(Roller_X, Roller_Y) loop
            Roller.Set_Box (FLTK.Round_Up_Box);
            Roller.Set_Selection_Color (FLTK.Background_Color);
            Roller.Set_Label_Size (9);
            Roller.Set_Step (0.1);
            Roller.Set_Alignment (FLTK.Align_Top_Left);
        end loop;
        Add_Key (15, 100, 20, 20, "`", 16#0060#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (35, 100, 20, 20, "1", 16#0031#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (55, 100, 20, 20, "2", 16#0032#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (75, 100, 20, 20, "3", 16#0033#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (95, 100, 20, 20, "4", 16#0034#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (115, 100, 20, 20, "5", 16#0035#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (135, 100, 20, 20, "6", 16#0036#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (155, 100, 20, 20, "7", 16#0037#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (175, 100, 20, 20, "8", 16#0038#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (195, 100, 20, 20, "9", 16#0039#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (215, 100, 20, 20, "0", 16#0030#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (235, 100, 20, 20, "-", 16#002d#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (255, 100, 20, 20, "=", 16#003d#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (275, 100, 35, 20, "Bksp", 16#ff08#);  --  FL_BackSpace
        Last.Set_Label_Kind (FLTK.Shadow_Label);
        Last.Set_Label_Size (8);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (325, 100, 20, 20, "Ins ", 16#ff63#);  --  FL_Insert
        Last.Set_Label_Size (8);
        Add_Key (345, 100, 20, 20, "Home", 16#ff50#);  --  FL_Home
        Last.Set_Label_Size (8);
        Add_Key (365, 100, 20, 20, "pgup ", 16#ff55#);  --  FL_Page_Up
        Last.Set_Label_Size (8);
        Add_Key (400, 100, 20, 20, "Num", 16#ff7f#);  --  FL_Num_Lock
        Last.Set_Label_Size (8);
        Add_Key (420, 100, 20, 20, "/", 16#ffaf#);  --  FL_KP+'/'
        Last.Set_Label_Size (10);
        Add_Key (440, 100, 20, 20, "*", 16#ffaa#);  --  FL_KP+'*'
        Last.Set_Label_Size (10);
        Add_Key (460, 100, 20, 20, "-", 16#ffad#);  --  FL_KP+'-'
        Last.Set_Label_Size (10);
        Add_Key (15, 120, 27, 20, "Tab", 16#ff09#);  --  FL_Tab
        Last.Set_Label_Size (8);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (42, 120, 20, 20, "Q", 16#0051#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (62, 120, 20, 20, "W", 16#0057#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (82, 120, 20, 20, "E", 16#0045#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (102, 120, 20, 20, "R", 16#0052#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (122, 120, 20, 20, "T", 16#0054#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (142, 120, 20, 20, "Y", 16#0059#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (162, 120, 20, 20, "U", 16#0055#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (182, 120, 20, 20, "I", 16#0049#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (202, 120, 20, 20, "O", 16#004f#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (222, 120, 20, 20, "P", 16#0050#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (242, 120, 20, 20, "[", 16#005b#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (262, 120, 20, 20, "]", 16#005d#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (282, 120, 28, 20, "\", 16#005c#);  --  label[0]
        Last.Set_Label_Size (10);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (325, 120, 20, 20, "Del ", 16#ffff#);  --  FL_Delete
        Last.Set_Label_Size (8);
        Add_Key (345, 120, 20, 20, "End ", 16#ff57#);  --  FL_End
        Last.Set_Label_Size (8);
        Add_Key (365, 120, 20, 20, "pgdn ", 16#ff56#);  --  FL_Page_Down
        Last.Set_Label_Size (8);
        Add_Key (400, 120, 20, 20, "7", 16#ffb7#);  --  FL_KP+'7'
        Last.Set_Label_Size (10);
        Add_Key (420, 120, 20, 20, "8", 16#ffb8#);  --  FL_KP+'8'
        Last.Set_Label_Size (10);
        Add_Key (440, 120, 20, 20, "9", 16#ffb9#);  --  FL_KP+'9'
        Last.Set_Label_Size (10);
        Add_Key (460, 120, 20, 40, "+", 16#ffab#);  --  FL_KP+'+'
        Last.Set_Label_Size (10);
        Last.Set_Alignment (FLTK.Align_Top + FLTK.Align_Inside);
        Add_Key (15, 140, 36, 20, "Lock", 16#ffe5#);  --  FL_Caps_Lock
        Last.Set_Label_Size (8);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (51, 140, 20, 20, "A", 16#0041#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (71, 140, 20, 20, "S", 16#0053#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (91, 140, 20, 20, "D", 16#0044#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (111, 140, 20, 20, "F", 16#0046#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (131, 140, 20, 20, "G", 16#0047#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (151, 140, 20, 20, "H", 16#0048#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (171, 140, 20, 20, "J", 16#004a#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (191, 140, 20, 20, "K", 16#004b#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (211, 140, 20, 20, "L", 16#004c#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (231, 140, 20, 20, ";", 16#003b#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (251, 140, 20, 20, "'", 16#0027#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (271, 140, 39, 20, "Enter", 16#ff0d#);  --  FL_Enter
        Last.Set_Label_Size (8);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (400, 140, 20, 20, "4", 16#ffb4#);  --  FL_KP+'4'
        Last.Set_Label_Size (10);
        Add_Key (420, 140, 20, 20, "5", 16#ffb5#);  --  FL_KP+'5'
        Last.Set_Label_Size (10);
        Add_Key (440, 140, 20, 20, "6", 16#ffb6#);  --  FL_KP+'6'
        Last.Set_Label_Size (10);
        Add_Key (15, 160, 45, 20, "Shift", 16#ffe1#);  --  FL_Shift_L
        Last.Set_Label_Size (8);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (60, 160, 20, 20, "Z", 16#005a#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (80, 160, 20, 20, "X", 16#0058#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (100, 160, 20, 20, "C", 16#0043#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (120, 160, 20, 20, "V", 16#0056#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (140, 160, 20, 20, "B", 16#0042#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (160, 160, 20, 20, "N", 16#004e#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (180, 160, 20, 20, "M", 16#004d#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (200, 160, 20, 20, ",", 16#002c#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (220, 160, 20, 20, ".", 16#002e#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (240, 160, 20, 20, "/", 16#002f#);  --  label[0]
        Last.Set_Label_Size (10);
        Add_Key (260, 160, 50, 20, "Shift", 16#ffe2#);  --  FL_Shift_R
        Last.Set_Label_Size (8);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (345, 160, 20, 20, "@8->", 16#ff52#);  --  FL_Up
        Last.Set_Label_Kind (FLTK.Shadow_Label);
        Last.Set_Label_Size (10);
        Last.Set_Label_Color (FLTK.Dark1_Color);
        Add_Key (400, 160, 20, 20, "1", 16#ffb1#);  --  FL_KP+'1'
        Last.Set_Label_Size (10);
        Add_Key (420, 160, 20, 20, "2", 16#ffb2#);  --  FL_KP+'2'
        Last.Set_Label_Size (10);
        Add_Key (440, 160, 20, 20, "3", 16#ffb3#);  --  FL_KP+'3'
        Last.Set_Label_Size (10);
        Add_Key (460, 160, 20, 40, "", 16#ff8d#);  --  FL_KP_Enter
        Add_Key (15, 180, 30, 20, "Ctrl", 16#ffe3#);  --  FL_Control_L
        Last.Set_Label_Size (8);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (45, 180, 30, 20, "Meta ", 16#ffe7#);  --  FL_Meta_L
        Last.Set_Label_Size (8);
        Add_Key (75, 180, 30, 20, "Alt ", 16#ffe9#);  --  FL_Alt_L
        Last.Set_Label_Size (8);
        Add_Key (105, 180, 85, 20, "", 16#0020#);  --  ' '
        Last.Set_Label_Size (10);
        Add_Key (190, 180, 30, 20, "Alt ", 16#ffea#);  --  FL_Alt_R
        Last.Set_Label_Size (8);
        Add_Key (220, 180, 30, 20, "Meta ", 16#ffe8#);  --  FL_Meta_R
        Last.Set_Label_Size (8);
        Add_Key (250, 180, 30, 20, "Menu ", 16#ff67#);  --  FL_Menu
        Last.Set_Label_Size (8);
        Add_Key (280, 180, 30, 20, "Ctrl", 16#ffe4#);  --  FL_Control_R
        Last.Set_Label_Size (8);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (325, 180, 20, 20, "@4->", 16#ff51#);  --  FL_Left
        Last.Set_Label_Kind (FLTK.Shadow_Label);
        Last.Set_Label_Size (10);
        Last.Set_Label_Color (FLTK.Dark1_Color);
        Add_Key (345, 180, 20, 20, "@2->", 16#ff54#);  --  FL_Down
        Last.Set_Label_Kind (FLTK.Shadow_Label);
        Last.Set_Label_Size (10);
        Last.Set_Label_Color (FLTK.Dark1_Color);
        Add_Key (365, 180, 20, 20, "@6->", 16#ff53#);  --  FL_Right
        Last.Set_Label_Kind (FLTK.Shadow_Label);
        Last.Set_Label_Size (10);
        Last.Set_Label_Color (FLTK.Dark1_Color);
        Add_Key (400, 180, 40, 20, "0", 16#ffb0#);  --  FL_KP+'0'
        Last.Set_Label_Size (10);
        Last.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
        Add_Key (440, 180, 20, 20, ".", 16#ffae#);  --  FL_KP+'.'
        Last.Set_Label_Size (10);
        State_Label := new Bx.Box'(Bx.Forge.Create
            (Window, FLTK.No_Box, 400, 15, 80, 0, "Fl::event_state():"));
        State_Label.Set_Label_Size (9);
        State_Label.Set_Alignment (FLTK.Align_Top_Left);
        Add_State (400, 15, 20, 10, "shift ", Shift'Access);  --  FL_SHIFT
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (420, 15, 20, 10, "lock ", Caps_Lock'Access);  --  FL_CAPS_LOCK
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (440, 15, 20, 10, "ctrl", Ctrl'Access);  --  FL_CTRL
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (460, 15, 20, 10, "alt", Alt'Access);  --  FL_ALT
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (400, 25, 20, 10, "num", Num_Lock'Access);  --  FL_NUM_LOCK
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (420, 25, 20, 10, "?", Never'Access);  --  0x20
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (440, 25, 20, 10, "meta ", Meta'Access);  --  FL_META
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (460, 25, 20, 10, "sclk", Scroll_Lock'Access);  --  FL_SCROLL_LOCK
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (400, 35, 20, 10, "b1", Button1'Access);  --  FL_BUTTON1
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (420, 35, 20, 10, "b2", Button2'Access);  --  FL_BUTTON2
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (440, 35, 20, 10, "b3", Button3'Access);  --  FL_BUTTON3
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (460, 35, 20, 10, "bck", Button4'Access);  --  FL_BUTTON4
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (400, 45, 20, 10, "fwd", Button5'Access);  --  FL_BUTTON5
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (420, 45, 20, 10, "?", Never'Access);  --  0x2000
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (440, 45, 20, 10, "?", Never'Access);  --  0x4000
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
        Add_State (460, 45, 20, 10, "?", Never'Access);  --  0x8000
        Last.Set_Box (FLTK.Thin_Up_Box);
        Last.Set_Selection_Color (3);
        Last.Set_Label_Size (8);
    end Make_Window;


    --  printf's "%0Nx", of Width digits or more.
    function Hex
           (Value : in Natural;
            Width : in Positive)
        return String
    is
        Digit  : constant String := "0123456789abcdef";
        Result : String (1 .. 8);
        First  : Positive := Result'Last + 1;
        V      : Natural := Value;
    begin
        loop
            First := First - 1;
            Result (First) := Digit (V mod 16 + 1);
            V := V / 16;
            exit when V = 0 and Result'Last - First + 1 >= Width;
        end loop;
        return Result (First .. Result'Last);
    end Hex;


    function Image
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Value'Image, Ada.Strings.Left);
    end Image;


    --  FLTK's numbers for the keys the name tests by range.
    FL_KP       : constant := 16#ff80#;
    FL_KP_Last  : constant := 16#ffbd#;
    FL_F        : constant := 16#ffbd#;
    FL_F_Last   : constant := 16#ffe0#;
    FL_Button   : constant := 16#fee8#;


    type Name_Access is access constant String;

    type Key_Name is record
        Key  : FLTK.Keypress;
        Name : Name_Access;
    end record;

    function "+" (Item : in String) return Name_Access is (new String'(Item));

    Key_Table : constant array (Positive range <>) of Key_Name :=
       ((FLTK.Escape_Key,        +"FL_Escape"),
        (FLTK.Backspace_Key,     +"FL_BackSpace"),
        (FLTK.Tab_Key,           +"FL_Tab"),
        (FLTK.ISO_Key,           +"FL_Iso_Key"),
        (FLTK.Enter_Key,         +"FL_Enter"),
        (FLTK.Print_Key,         +"FL_Print"),
        (FLTK.Scroll_Lock_Key,   +"FL_Scroll_Lock"),
        (FLTK.Pause_Key,         +"FL_Pause"),
        (FLTK.Insert_Key,        +"FL_Insert"),
        (FLTK.Home_Key,          +"FL_Home"),
        (FLTK.Page_Up_Key,       +"FL_Page_Up"),
        (FLTK.Delete_Key,        +"FL_Delete"),
        (FLTK.End_Key,           +"FL_End"),
        (FLTK.Page_Down_Key,     +"FL_Page_Down"),
        (FLTK.Left_Key,          +"FL_Left"),
        (FLTK.Up_Key,            +"FL_Up"),
        (FLTK.Right_Key,         +"FL_Right"),
        (FLTK.Down_Key,          +"FL_Down"),
        (FLTK.Left_Shift_Key,    +"FL_Shift_L"),
        (FLTK.Right_Shift_Key,   +"FL_Shift_R"),
        (FLTK.Left_Control_Key,  +"FL_Control_L"),
        (FLTK.Right_Control_Key, +"FL_Control_R"),
        (FLTK.Caps_Lock_Key,     +"FL_Caps_Lock"),
        (FLTK.Left_Alt_Key,      +"FL_Alt_L"),
        (FLTK.Right_Alt_Key,     +"FL_Alt_R"),
        (FLTK.Left_Meta_Key,     +"FL_Meta_L"),
        (FLTK.Right_Meta_Key,    +"FL_Meta_R"),
        (FLTK.Menu_Key,          +"FL_Menu"),
        (FLTK.Help_Key,          +"FL_Help"),
        (FLTK.Num_Lock_Key,      +"FL_Num_Lock"),
        (FLTK.Keypad_Enter_Key,  +"FL_KP_Enter"),
        (FLTK.Alt_Gr_Key,        +"FL_Alt_Gr"));


    --  The name main's loop gives the last key.
    function Key_Name_Of
           (K : in Natural)
        return String is
    begin
        if K = 0 then
            return "0";
        elsif K < 128 then
            return "'" & Character'Val (K) & "'";
        elsif K in 16#a0# .. 16#ff# then
            return "'" & Ada.Strings.UTF_Encoding.Wide_Strings.Encode
                ((1 => Wide_Character'Val (K))) & "'";
        elsif K > FL_F and K <= FL_F_Last then
            return "FL_F+" & Image (K - FL_F);
        elsif K in FL_KP .. FL_KP_Last then
            return "FL_KP+'" & Character'Val (K - FL_KP) & "'";
        elsif K in FL_Button .. FL_Button + 7 then
            return "FL_Button+" & Image (K - FL_Button);
        end if;
        for Item of Key_Table loop
            if FLTK.Key_Number (Item.Key) = K then
                return Item.Name.all;
            end if;
        end loop;
        return "0x" & Hex (K, 4);
    end Key_Name_Of;


    Lit : Boolean;

begin

    Ev.Add_Handler (Handler'Unrestricted_Access);
    Make_Window;
    Window.Show_With_Args;

    while FLTK.Wait /= 0 loop

        --  Update all the buttons with the current key and shift state.
        for Index in 1 .. Count loop
            if Buttons (Index).Test = null then
                Lit := Ev.Key_Now (Buttons (Index).Key);
            else
                Lit := Buttons (Index).Test.all;
            end if;
            if (Buttons (Index).Get_State = Btn.On) /= Lit then
                Buttons (Index).Set_State (if Lit then Btn.On else Btn.Off);
            end if;
        end loop;

        declare
            Name : constant String := Key_Name_Of (FLTK.Key_Number (Ev.Last_Key));
            Text : constant String := Ev.Text;
        begin
            if Key_Output.Get_Value /= Name then
                Key_Output.Set_Value (Name);
            end if;
            if Text_Output.Get_Value /= Text then
                Text_Output.Set_Value (Text);
            end if;
        end;

    end loop;

    for Index in 1 .. Count loop
        Free (Buttons (Index));
    end loop;
    Free (State_Label);
    Free (Roller_X);
    Free (Roller_Y);
    Free (Key_Output);
    Free (Text_Output);
    return 0;

end Keyboard;
