--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/handle_keys.cxx: every keyboard event the window sees,
--  one line each in a terminal, with its number, its key and that key's
--  name, the modifier flags, and its text as characters, code point and
--  bytes.  Check buttons choose which of Keydown, Keyup and Shortcut are
--  shown, and turn GUI scaling's shortcuts on and off.  The terminal
--  passes keyboard events on, so the window hears them.  Guided by
--  pofltk's HandleKeys.Mod.


with

    Ada.Strings.Fixed,
    Ada.Strings.UTF_Encoding.Wide_Wide_Strings,
    FLTK.Events,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment,
    FLTK.Event_Kind,
    FLTK.Keypress,
    FLTK.Widgets.Buttons.State;


function Handle_Keys
    return Integer
is

    package Ev  renames FLTK.Events;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    LF : constant Character := ASCII.LF;

    --  Text in the headline and after clearing the terminal buffer.
    Headline_Text : constant String :=
        "[nnn] Event           Key     Name,  Flags: C A S M N L  Text  Unicode   UTF-8/hex";

    Lkn : constant := 14;  --  length of key name field

    --  Tooltip for headline and terminal widgets
    TT : constant String :=
        "Flags:" & LF &
        "C=Ctrl, A=Alt, S=Shift, M=Meta" & LF &
        "N=NumLock, L=CapsLock";


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


    --  printf's "%Ns" (Width > 0) and "%-Ns" (Width < 0).
    function Pad
           (Text  : in String;
            Width : in Integer)
        return String is
    begin
        if Text'Length >= abs Width then
            return Text;
        elsif Width > 0 then
            return (1 .. Width - Text'Length => ' ') & Text;
        else
            return Text & (1 .. -Width - Text'Length => ' ');
        end if;
    end Pad;


    --  FLTK's numbers for the keys get_keyname tests by range.
    FL_KP       : constant := 16#ff80#;
    FL_KP_Last  : constant := 16#ffbd#;
    FL_F        : constant := 16#ffbd#;
    FL_F_Last   : constant := 16#ffe0#;
    FL_Button   : constant := 16#fee8#;

    type Key_Name is record
        Key  : FLTK.Keypress;
        Text : access constant String;
    end record;

    Escape_Name     : aliased constant String := "FL_Escape";
    Backspace_Name  : aliased constant String := "FL_BackSpace";
    Tab_Name        : aliased constant String := "FL_Tab";
    ISO_Name        : aliased constant String := "FL_Iso_Key";
    Enter_Name      : aliased constant String := "FL_Enter";
    Print_Name      : aliased constant String := "FL_Print";
    Scroll_Name     : aliased constant String := "FL_Scroll_Lock";
    Pause_Name      : aliased constant String := "FL_Pause";
    Insert_Name     : aliased constant String := "FL_Insert";
    Home_Name       : aliased constant String := "FL_Home";
    Page_Up_Name    : aliased constant String := "FL_Page_Up";
    Delete_Name     : aliased constant String := "FL_Delete";
    End_Name        : aliased constant String := "FL_End";
    Page_Down_Name  : aliased constant String := "FL_Page_Down";
    Left_Name       : aliased constant String := "FL_Left";
    Up_Name         : aliased constant String := "FL_Up";
    Right_Name      : aliased constant String := "FL_Right";
    Down_Name       : aliased constant String := "FL_Down";
    Shift_L_Name    : aliased constant String := "FL_Shift_L";
    Shift_R_Name    : aliased constant String := "FL_Shift_R";
    Control_L_Name  : aliased constant String := "FL_Control_L";
    Control_R_Name  : aliased constant String := "FL_Control_R";
    Caps_Lock_Name  : aliased constant String := "FL_Caps_Lock";
    Alt_L_Name      : aliased constant String := "FL_Alt_L";
    Alt_R_Name      : aliased constant String := "FL_Alt_R";
    Meta_L_Name     : aliased constant String := "FL_Meta_L";
    Meta_R_Name     : aliased constant String := "FL_Meta_R";
    Menu_Name       : aliased constant String := "FL_Menu";
    Help_Name       : aliased constant String := "FL_Help";
    Num_Lock_Name   : aliased constant String := "FL_Num_Lock";
    KP_Enter_Name   : aliased constant String := "FL_KP_Enter";
    Alt_Gr_Name     : aliased constant String := "FL_Alt_Gr";

    --  This table is a duplicate of the table in test/keyboard.cxx.
    Key_Table : constant array (Positive range <>) of Key_Name :=
       ((FLTK.Escape_Key,        Escape_Name'Access),
        (FLTK.Backspace_Key,     Backspace_Name'Access),
        (FLTK.Tab_Key,           Tab_Name'Access),
        (FLTK.ISO_Key,           ISO_Name'Access),
        (FLTK.Enter_Key,         Enter_Name'Access),
        (FLTK.Print_Key,         Print_Name'Access),
        (FLTK.Scroll_Lock_Key,   Scroll_Name'Access),
        (FLTK.Pause_Key,         Pause_Name'Access),
        (FLTK.Insert_Key,        Insert_Name'Access),
        (FLTK.Home_Key,          Home_Name'Access),
        (FLTK.Page_Up_Key,       Page_Up_Name'Access),
        (FLTK.Delete_Key,        Delete_Name'Access),
        (FLTK.End_Key,           End_Name'Access),
        (FLTK.Page_Down_Key,     Page_Down_Name'Access),
        (FLTK.Left_Key,          Left_Name'Access),
        (FLTK.Up_Key,            Up_Name'Access),
        (FLTK.Right_Key,         Right_Name'Access),
        (FLTK.Down_Key,          Down_Name'Access),
        (FLTK.Left_Shift_Key,    Shift_L_Name'Access),
        (FLTK.Right_Shift_Key,   Shift_R_Name'Access),
        (FLTK.Left_Control_Key,  Control_L_Name'Access),
        (FLTK.Right_Control_Key, Control_R_Name'Access),
        (FLTK.Caps_Lock_Key,     Caps_Lock_Name'Access),
        (FLTK.Left_Alt_Key,      Alt_L_Name'Access),
        (FLTK.Right_Alt_Key,     Alt_R_Name'Access),
        (FLTK.Left_Meta_Key,     Meta_L_Name'Access),
        (FLTK.Right_Meta_Key,    Meta_R_Name'Access),
        (FLTK.Menu_Key,          Menu_Name'Access),
        (FLTK.Help_Key,          Help_Name'Access),
        (FLTK.Num_Lock_Key,      Num_Lock_Name'Access),
        (FLTK.Keypad_Enter_Key,  KP_Enter_Name'Access),
        (FLTK.Alt_Gr_Key,        Alt_Gr_Name'Access));


    --  The name of key K.  Its length in bytes, which is what FLTK's
    --  snprintf counts, aligns the columns.
    function Get_Keyname
           (K : in Natural)
        return String is
    begin
        if K = 0 then
            return "0";
        elsif K < 32 then  --  control character
            return "^" & Character'Val (K + 64);
        elsif K < 128 then  --  ASCII
            return "'" & Character'Val (K) & "'";
        elsif K in 16#a0# .. 16#ff# then  --  ISO-8859-1 (international keyboards)
            return "'" & Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode
                ((1 => Wide_Wide_Character'Val (K))) & "'";
        elsif K > FL_F and K <= FL_F_Last then
            return "FL_F+" & Image (K - FL_F);
        elsif K >= FL_KP and K <= FL_KP_Last then
            if K = FLTK.Key_Number (FLTK.Keypad_Enter_Key) then
                return "FL_KP_Enter";
            else
                return "FL_KP+'" & Character'Val (K - FL_KP) & "'";
            end if;
        elsif K >= FL_Button and K <= FL_Button + 7 then
            return "FL_Button+" & Image (K - FL_Button);
        else
            for Entry_Item of Key_Table loop
                if FLTK.Key_Number (Entry_Item.Key) = K then
                    return Entry_Item.Text.all;
                end if;
            end loop;
            return "0x" & Hex (K, 4);
        end if;
    end Get_Keyname;


    --  fl_utf8decode of Text's first character: an invalid sequence gives
    --  its first byte.
    function Decode
           (Text : in String)
        return Natural is
    begin
        return Wide_Wide_Character'Pos
           (Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode (Text) (1));
    exception
        when others =>
            return Character'Pos (Text (Text'First));
    end Decode;


    type Key_Terminal is new Trm.Terminal with null record;

    overriding function Handle
           (This  : in out Key_Terminal;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    --  Class to handle events
    type App is new Dbl.Double_Window with record
        Eventnum : Natural := 0;
    end record;

    overriding function Handle
           (This  : in out App;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    WW : constant := 700;
    WH : constant := 400;

    Win : App := (Dbl.Forge.Create (0, 0, WW, WH) with Eventnum => 0);

    Headline : Bx.Box := Bx.Forge.Create (Win, 2, 0, WW - 4, 25);
    TTY      : Key_Terminal := (Trm.Forge.Create (Win, 0, 25, WW, WH - 100) with null record);

    Grid : Grd.Grid := Grd.Forge.Create (Win, 0, WH - 75, WW, 75);

    Keydown   : Chk.Check_Button := Chk.Forge.Create (Grid, 0, 0, 80, 30, "Keydown");
    Keyup     : Chk.Check_Button := Chk.Forge.Create (Grid, 0, 0, 80, 30, "Keyup");
    Shortcut  : Chk.Check_Button := Chk.Forge.Create (Grid, 0, 0, 80, 30, "Shortcut");
    Scaling   : Chk.Check_Button := Chk.Forge.Create (Grid, 0, 0, 80, 30, "GUI scaling");
    Clear     : Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "Clear");
    Copy      : Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "Copy");
    Quit      : Btn.Button := Btn.Forge.Create (Grid, WW - 70, WH - 50, 80, 30, "Quit");


    function Handle
           (This  : in out Key_Terminal;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        case Event is
            when FLTK.Keydown | FLTK.Keyup | FLTK.Shortcut =>
                return FLTK.Not_Handled;
            when others =>
                return Trm.Terminal (This).Handle (Event);
        end case;
    end Handle;


    --  Counts and prints the current event.  Returns True if printed
    --  (used), False if suppressed.  The event counter is incremented only
    --  if the event is printed and wraps at 1000.
    function Print_Event
           (This  : in out App;
            Event : in     FLTK.Event_Kind)
        return Boolean is
    begin
        case Event is
            when FLTK.Keydown =>
                if not Keydown.Is_On then
                    return False;
                end if;
                TTY.Set_Text_Fore_Color (FLTK.Black_Color);
            when FLTK.Keyup =>
                if not Keyup.Is_On then
                    return False;
                end if;
                TTY.Set_Text_Fore_Color (FLTK.Blue_Color);
            when FLTK.Shortcut =>
                if not Shortcut.Is_On then
                    return False;
                end if;
                TTY.Set_Text_Fore_Color (16#00aa0000#);  --  dark green
            when others =>
                return False;
        end case;
        This.Eventnum := (This.Eventnum + 1) mod 1000;
        TTY.Print ("[" & Pad (Image (This.Eventnum), 3) & "] " &
            Pad (FLTK.Event_Name (Event), -12));
        return True;
    end Print_Event;


    --  Event handling
    function Handle
           (This  : in out App;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        Result : constant FLTK.Event_Outcome := Dbl.Double_Window (This).Handle (Event);
    begin
        --  filter and output keyboard events only
        if not Print_Event (This, Event) then
            return Result;
        end if;
        declare
            Etxt  : constant String := Ev.Text;
            Ekey  : constant Natural := FLTK.Key_Number (Ev.Last_Key);
            Elen  : constant Natural := Ev.Text_Length;

            function Flag
                   (Mask : in FLTK.Modifier;
                    Name : in Character)
                return Character is
            begin
                return (if Ev.Last_Modifier (Mask) then Name else '.');
            end Flag;

            Ctrl   : constant Character := Flag (FLTK.Mod_Ctrl, 'C');
            Alt    : constant Character := Flag (FLTK.Mod_Alt, 'A');
            Shift  : constant Character := Flag (FLTK.Mod_Shift, 'S');
            Meta   : constant Character := Flag (FLTK.Mod_Meta, 'M');
            Numlk  : constant Character := Flag (FLTK.Mod_Num_Lock, 'N');
            Capslk : constant Character := Flag (FLTK.Mod_Caps_Lock, 'L');

            Name : constant String := Get_Keyname (Ekey);
        begin
            TTY.Print (Pad ("0x" & Hex (Ekey, 4), 10) & "  ");  --  event key number (hex)
            TTY.Print (Name);
            if Name'Length < Lkn then
                for I in 1 .. Lkn - Name'Length loop
                    TTY.Append_ASCII (" ");
                end loop;
            end if;
            TTY.Print (Ctrl & ' ' & Alt & ' ' & Shift & ' ' & Meta & ' ' &
                Numlk & ' ' & Capslk & "  ");
            if Elen > 0 then
                declare
                    First : constant Natural := Character'Pos (Etxt (Etxt'First));
                begin
                    --  C++ compares a signed char: bytes from 128 are negative.
                    if Elen = 1 and (First < 32 or First >= 128) then  --  control character
                        TTY.Print ("'^" & Character'Val ((First + 64) mod 256) & "' ");
                    else
                        TTY.Print ("'" & Etxt & "'  ");
                    end if;
                end;
                TTY.Print (" U+" & Hex (Decode (Etxt), 4) & "   ");
                for C of Etxt loop
                    TTY.Print (" " & Hex (Character'Pos (C), 2));
                end loop;
            else
                TTY.Print ("'' ");
            end if;
            TTY.Set_Text_Fore_Color (FLTK.Black_Color);
            TTY.Print ((1 => LF));
        end;
        return Result;
    end Handle;


    procedure Focus_Terminal is
        Took : constant Boolean := TTY.Take_Focus;
        pragma Unreferenced (Took);
    begin
        null;
    end Focus_Terminal;


    --  Quit button callback: closes the window
    procedure Quit_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Win.Hide;
    end Quit_CB;


    --  Clear button callback: clears the terminal widget
    procedure Clear_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        TTY.Clear_Screen_Home;
        TTY.Clear_History;
        TTY.Print (Headline_Text & LF);  --  helpful if copied to the clipboard
        TTY.Redraw;
        Focus_Terminal;
    end Clear_CB;


    --  Copy button callback: copies the selected text to the clipboard
    procedure Copy_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Selected : constant Boolean := TTY.Selection_Text_Length > 0;
        Text     : constant String :=
            (if Selected then TTY.Selection_Text else TTY.Get_Text);
    begin
        FLTK.Static.Copy (Text, FLTK.Static.Clipboard);
        TTY.Print ("[" & (if Selected then "Selected" else "Full") &
            " text copied to clipboard, length = " & Image (Text'Length) & "]" & LF);
        Focus_Terminal;
    end Copy_CB;


    --  Callback for all (light) buttons
    procedure Toggle_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Focus_Terminal;
    end Toggle_CB;


    --  Toggle recognition of GUI scaling shortcuts
    procedure Toggle_Scaling
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Toggle : constant Boolean := Chk.Check_Button (Item).Is_On;
    begin
        FLTK.Screen.Set_Keyboard_Scaling (Toggle);
        if Toggle then
            TTY.Print ("GUI-Scaling = ON, OPTION_SIMPLE_ZOOM_SHORTCUT = " &
                (if FLTK.Static.Get_Option (FLTK.Static.Simple_Zoom_Shortcut)
                 then "ON" else "OFF") & LF);
        end if;
        Toggle_CB (Item);  --  give focus to 'app'
    end Toggle_Scaling;


    --  Window close callback (Esc does not close the window)
    procedure Close_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Ev.Last = FLTK.Shortcut then
            return;
        end if;
        Item.Hide;
    end Close_CB;

begin

    Headline.Set_Background_Color (FLTK.Light2_Color);
    Headline.Set_Box (FLTK.Flat_Box);
    Headline.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside);
    Headline.Set_Label_Font (FLTK.Courier);
    Headline.Set_Label_Size (12);
    Headline.Set_Label (Headline_Text);
    Headline.Set_Tooltip (TT);

    TTY.Set_Background_Color (FLTK.White_Color);
    TTY.Set_Text_Fore_Color (FLTK.Darker (FLTK.Blue_Color));
    TTY.Set_Selection_Back_Color (FLTK.Blue_Color);
    TTY.Set_Selection_Fore_Color (FLTK.White_Color);
    TTY.Set_Text_Font (FLTK.Courier);
    TTY.Set_Text_Size (12);
    TTY.Set_Tooltip (TT);

    TTY.Set_Box (FLTK.Down_Box);
    TTY.Set_Show_Unknown (True);
    TTY.Set_Text_Fore_Color (FLTK.Black_Color);
    TTY.Print ("Please press any key ..." & LF);

    Grid.Set_Layout (2, 5, 5, 5);

    Grid.Set_Widget (Keydown, 1, 1);
    Keydown.Set_State (Btn.On);
    Keydown.Set_Callback (Toggle_CB'Unrestricted_Access);
    Keydown.Set_Tooltip ("Show FL_KEYDOWN aka FL_KEYBOARD events");

    Grid.Set_Widget (Keyup, 1, 2);
    Keyup.Set_State (Btn.Off);
    Keyup.Set_Callback (Toggle_CB'Unrestricted_Access);
    Keyup.Set_Tooltip ("Show FL_KEYUP events");

    Grid.Set_Widget (Shortcut, 1, 3);
    Shortcut.Set_State (Btn.Off);
    Shortcut.Set_Callback (Toggle_CB'Unrestricted_Access);
    Shortcut.Set_Tooltip ("Show FL_SHORTCUT events");

    Grid.Set_Widget (Scaling, 1, 4);
    Scaling.Set_State (Btn.Off);
    Scaling.Set_Callback (Toggle_Scaling'Unrestricted_Access);
    Scaling.Set_Tooltip ("Use GUI scaling shortcuts");
    Toggle_Scaling (Scaling);

    Grid.Set_Widget (Clear, 2, 1);
    Clear.Set_Callback (Clear_CB'Unrestricted_Access);
    Clear.Set_Tooltip ("Clear the display");

    Grid.Set_Widget (Copy, 2, 2);
    Copy.Set_Callback (Copy_CB'Unrestricted_Access);
    Copy.Set_Tooltip ("Copy terminal contents to clipboard");

    Grid.Set_Widget (Quit, 2, 5);
    Quit.Set_Box (FLTK.Thin_Up_Box);
    Quit.Set_Callback (Quit_CB'Unrestricted_Access);
    Quit.Set_Tooltip ("Exit the program");

    Grid.End_Current;
    Win.End_Current;
    Win.Set_Callback (Close_CB'Unrestricted_Access);
    Win.Set_Resizable (TTY);
    Win.Set_Size_Range (660, 300);
    Win.Show_With_Args;

    return FLTK.Run;

end Handle_Keys;
