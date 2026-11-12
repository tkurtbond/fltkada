--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/ask.cxx: the common dialogs, nested.  Each button renames
--  itself with what is typed into a dialog, closing the window asks
--  first, and every 5 seconds, up to 10 times, a question pops up over
--  whatever is open.  The password is limited to 20 characters, as
--  FLTK's program is when FLTK uses std::string, and as its dialog says.
--  Quit hides the window, where the C++ calls exit.


with

    Ada.Characters.Latin_1,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    FLTK.Asks,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Asks.Choice_Result,
    FLTK.Asks.Confirm_Result,
    FLTK.Color;


function Ask
    return Integer
is

    package Latin renames Ada.Characters.Latin_1;
    package SU    renames Ada.Strings.Unbounded;

    package AK  renames FLTK.Asks;
    package Stc renames FLTK.Static;
    package BX  renames FLTK.Widgets.Boxes;
    package BTN renames FLTK.Widgets.Buttons;
    package ENT renames FLTK.Widgets.Buttons.Enter;
    package WD  renames FLTK.Widgets.Groups.Windows.Double;


    --  "§" and "€" in UTF-8.
    Section : constant String := Character'Val (16#C2#) & Character'Val (16#A7#);
    Euro    : constant String :=
        Character'Val (16#E2#) & Character'Val (16#82#) & Character'Val (16#AC#);


    procedure Rename_Input
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Answer : SU.Unbounded_String := SU.To_Unbounded_String (Item.Get_Label);
    begin
        AK.Set_Message_Icon_Label (Section);
        if AK.Text_Input ("Input (no size limit, use ctrl/j for newline):", Answer) =
            AK.Confirm
        then
            Item.Set_Label (SU.To_String (Answer));
            Item.Redraw;
        end if;
    end Rename_Input;


    procedure Rename_Password
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Answer : SU.Unbounded_String := SU.To_Unbounded_String (Item.Get_Label);
    begin
        AK.Set_Message_Icon_Label (Euro);
        if AK.Password ("Enter password (max. 20 characters):", 20, Answer) = AK.Confirm then
            Item.Set_Label (SU.To_String (Answer));
            Item.Redraw;
        end if;
    end Rename_Password;


    procedure Window_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Hotspot : constant Boolean := AK.Get_Message_Hotspot;
        Reply   : AK.Choice_Result;
    begin
        AK.Set_Message_Hotspot (False);
        AK.Set_Message_Title ("note: no hotspot set for this dialog");
        Reply := AK.Choice ("Are you sure you want to quit?", "Cancel", "Quit", "Dunno");
        AK.Set_Message_Hotspot (Hotspot);
        if Reply = AK.Second then
            Item.Hide;
        elsif Reply = AK.Third then
            AK.Set_Message_Position_Over (Item);
            AK.Set_Message_Title ("This dialog must be centered over the main window");
            AK.Message_Box ("Well, maybe you should know before we quit.");
        end if;
    end Window_Callback;


    --  Shows a question, nested in any dialog already open, until stopped
    --  by its button or the Enter key, or 10 have been shown.  Closing it,
    --  or Escape, just closes it.
    Stop  : Boolean := False;
    Count : Natural := 0;

    Delta_Time : constant := 5.0;
    Most       : constant := 10;

    procedure Timer_Callback is
        Message_Icon : constant BX.Box_Reference := AK.Get_Message_Icon;
        My_Color     : FLTK.Color;
    begin
        Count := Count + 1;
        if Count >= Most then
            Stop := True;
        end if;
        if Stop then
            Message_Icon.Set_Background_Color (FLTK.White_Color);
            return;
        end if;

        Stc.Repeat_Timeout (Delta_Time, Timer_Callback'Unrestricted_Access);

        My_Color := (Message_Icon.Get_Background_Color + 1) mod 32;
        if My_Color = Message_Icon.Get_Label_Color then
            My_Color := My_Color + 1;
        end if;
        Message_Icon.Set_Background_Color (My_Color);

        AK.Set_Message_Title
           ("Message #" & Ada.Strings.Fixed.Trim (Natural'Image (Count), Ada.Strings.Left));

        if AK.Choice
           ("Timeout. Click the 'Close' button or press Escape." & Latin.LF &
            "Note: this message had been blocked in FLTK 1.3" & Latin.LF &
            "and earlier if another message window was open." & Latin.LF &
            "This message should pop up every 5 seconds (max. 10 times)" & Latin.LF &
            "in FLTK 1.4 and later until stopped by clicking the button" & Latin.LF &
            "below or by pressing the Enter (Return) key." & Latin.LF,
            "Close", "Stop these funny popups") = AK.Second
        then
            Stop := True;
        end if;
    end Timer_Callback;


    The_Window : WD.Double_Window := WD.Forge.Create (200, 105);

    Button_One : ENT.Enter_Button := ENT.Forge.Create (The_Window, 20, 10, 160, 35, "Test text");
    Button_Two : BTN.Button       := BTN.Forge.Create (The_Window, 20, 50, 160, 35, "MyPassword");


begin


    Button_One.Set_Callback (Rename_Input'Unrestricted_Access);
    Button_Two.Set_Callback (Rename_Password'Unrestricted_Access);

    The_Window.Set_Resizable (Button_One);
    The_Window.Show_With_Args;
    The_Window.Set_Callback (Window_Callback'Unrestricted_Access);

    Stc.Add_Timeout (5.0, Timer_Callback'Unrestricted_Access);

    return FLTK.Run;


end Ask;
