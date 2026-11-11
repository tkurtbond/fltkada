

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestDialogs: each FLTK.Asks dialog answered by
--  keys, as a user would.  A timeout waits for the dialog, notes its
--  title, types text into it a key at a time, and sends a last key.
--  Where the next dialog goes and its icon's text are
--  test_ask_placement's; FLTK's own file chooser is FLTK.File_Choosers's
--  tests'.  pofltk's native file chooser is test/desktop's, as a native
--  dialog can reach the desktop.  The color chooser widget, the
--  directory listing and the filename functions are left to the tests
--  of the other FLTKAda packages they are in.


with

    Ada.Directories,
    Ada.Strings.Unbounded,
    Checks,
    FLTK.Asks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes;

use

    Checks,
    FLTK;


procedure Test_Dialogs is

    package Ask renames FLTK.Asks;
    package Prb renames FLTK.Probe;
    package Sta renames FLTK.Static;
    package SU renames Ada.Strings.Unbounded;

    use type SU.Unbounded_String;

    use type Ask.Choice_Result;
    use type Ask.Extended_Choice_Result;
    use type Ask.Confirm_Result;


    --  Tries of 0.05 s, waiting for a dialog; generous, for valgrind.
    Tries : constant := 400;

    Text_Buffer  : String (1 .. 32);
    Text_Last    : Natural := 0;
    Key          : Keypress := Enter_Key;
    Key_Text     : String (1 .. 1) := (1 => ASCII.CR);
    Key_Has_Text : Boolean := True;
    Tried, Seen  : Natural := 0;
    Sent         : Boolean := False;
    Title        : String (1 .. 64);
    Title_Last   : Natural := 0;

    --  After the key, a timeout wakes the dialog's loop: FLTK runs
    --  timeouts and then waits for an event, so the loop ends only when
    --  one comes, and none comes under Xvfb.  It is a handler of its own,
    --  as one left over from the last dialog mustn't answer the next.
    procedure Wake is
    begin
        null;
    end Wake;

    procedure Answer is
        Ignore : Boolean;
    begin
        if not Prb.Modal then
            Tried := Tried + 1;
            if Tried < Tries then
                Sta.Repeat_Timeout (0.05, Answer'Unrestricted_Access);
            end if;
        elsif Seen < 2 then
            Seen := Seen + 1;
            Sta.Repeat_Timeout (0.05, Answer'Unrestricted_Access);
        else
            declare
                Shown : constant String := Prb.Modal_Title;
            begin
                Title_Last := Natural'Min (Shown'Length, Title'Length);
                Title (1 .. Title_Last) := Shown (Shown'First .. Shown'First + Title_Last - 1);
            end;
            for C of Text_Buffer (1 .. Text_Last) loop
                Ignore := Prb.Modal_Key (Press (C), Mod_None, (1 => C));
            end loop;
            if Key_Has_Text then
                Ignore := Prb.Modal_Key (Key, Mod_None, Key_Text);
            else
                Ignore := Prb.Modal_Key (Key);
            end if;
            Sent := True;
            Sta.Add_Timeout (0.01, Wake'Unrestricted_Access);
        end if;
    end Answer;

    --  Closes the dialog as its window's close button would.
    procedure Close is
        Ignore : Boolean;
    begin
        if Prb.Modal then
            Ignore := Prb.Close_Modal_Window;
            Sent := True;
            Sta.Add_Timeout (0.01, Wake'Unrestricted_Access);
        else
            Tried := Tried + 1;
            if Tried < Tries then
                Sta.Repeat_Timeout (0.05, Close'Unrestricted_Access);
            end if;
        end if;
    end Close;

    --  Answers the next dialog by typing Text and then Code.
    procedure Reply
           (Text : in String;
            Code : in Keypress;
            Echo : in Character)
    is
    begin
        Text_Last := Text'Length;
        Text_Buffer (1 .. Text_Last) := Text;
        Key := Code;
        Key_Text := (1 => Echo);
        Key_Has_Text := True;
        Tried := 0;
        Seen := 0;
        Sent := False;
        Title_Last := 0;
        Sta.Add_Timeout (0.05, Answer'Unrestricted_Access);
    end Reply;

    procedure Enter is
    begin
        Reply ("", Enter_Key, ASCII.CR);
    end Enter;

    procedure Escape is
    begin
        Reply ("", Escape_Key, ASCII.ESC);
    end Escape;

    procedure Close_Next is
    begin
        Tried := 0;
        Sent := False;
        Sta.Add_Timeout (0.05, Close'Unrestricted_Access);
    end Close_Next;

    function Answered
        return Boolean is
    begin
        return Sent and Tried < Tries;
    end Answered;

    function Title_Seen
        return String is
    begin
        return Title (1 .. Title_Last);
    end Title_Seen;

    function Ends
           (Text, Tail : in String)
        return Boolean is
    begin
        return Text'Length >= Tail'Length
            and then Text (Text'Last - Tail'Length + 1 .. Text'Last) = Tail;
    end Ends;


    Picked : String (1 .. 256);
    Picked_Last : Natural := 0;

    procedure Note_Picked
           (Item : in String) is
    begin
        Picked_Last := Natural'Min (Item'Length, Picked'Length);
        Picked (1 .. Picked_Last) := Item (Item'First .. Item'First + Picked_Last - 1);
    end Note_Picked;


    I : Ask.Choice_Result;
    E : Ask.Extended_Choice_Result;
    C : Ask.Confirm_Result;
    R, G, B : Ask.RGB_Int;

    Here : constant String := Ada.Directories.Current_Directory;

begin

    Check (Ask.Get_Message_Hotspot, "dialogs are shown under the mouse to start with");
    Ask.Set_Message_Hotspot (False);
    Check (not Ask.Get_Message_Hotspot, "Set_Message_Hotspot");
    Check (Ask.Get_Message_Font = Helvetica and Ask.Get_Message_Size = 14,
        "the message font is Helvetica 14 to start with");
    Ask.Set_Message_Font (Courier, 16);
    Check (Ask.Get_Message_Font = Courier and Ask.Get_Message_Size = 16,
        "Set_Message_Font, Get_Message_Font and Get_Message_Size");
    Ask.Set_Message_Font (Helvetica, 14);

    Enter;
    Ask.Message_Box ("100% done");
    Check (Answered, "Message_Box waits for the user; Enter closes it");
    Escape;
    Ask.Alert ("Careful");
    Check (Answered, "Alert; Escape closes it");

    Enter;
    I := Ask.Choice ("Save?", "No", "Yes", "Cancel");
    Check (I = Ask.Second, "Enter pushes Choice's second button");
    Escape;
    I := Ask.Choice ("Save?", "No", "Yes", "Cancel");
    Check (I = Ask.First, "Escape gives the first");
    Reply ("", Press ('n'), 'n');
    I := Ask.Choice ("Save?", "&No", "&Yes", "&Cancel");
    Check (I = Ask.First, "the first, by its shortcut");
    Reply ("", Press ('c'), 'c');
    I := Ask.Choice ("Save?", "&No", "&Yes", "&Cancel");
    Check (I = Ask.Third, "the third");
    Enter;
    I := Ask.Choice ("Go on?", "", "Go", "");
    Check (I = Ask.Second, "an empty label is no button");
    --  The first button's shortcut is Escape, and with no second, no
    --  button has the focus: Enter does nothing (Fl_Message.cxx).
    Escape;
    I := Ask.Choice ("Go on?", "Go");
    Check (I = Ask.First, "one button, which Escape pushes");

    Escape;
    E := Ask.Extended_Choice ("Save?", "No", "Yes", "Cancel");
    Check (E = Ask.Escaped, "Extended_Choice: Escape is Escaped");
    Close_Next;
    E := Ask.Extended_Choice ("Save?", "No", "Yes");
    Check (E = Ask.Closed, "the window closed is Closed");
    Reply ("", Press ('y'), 'y');
    E := Ask.Extended_Choice ("Save?", "&No", "&Yes", "&Cancel");
    Check (E = Ask.Second, "a button is its own");

    Reply ("xy", Enter_Key, ASCII.CR);
    declare
        Got : constant String := Ask.Text_Input ("Name:", "abc");
    begin
        Check (Got = "abcxy", "Text_Input starts with the default, the cursor after it: " & Got);
    end;
    Escape;
    Check (Ask.Text_Input ("Name:", "abc") = "", "cancelled, it gives """"");
    Reply ("secret", Enter_Key, ASCII.CR);
    Check (Ask.Password ("Password:") = "secret", "Password");
    declare
        Answer : SU.Unbounded_String := SU.To_Unbounded_String ("abc");
    begin
        Reply ("", Enter_Key, ASCII.CR);
        C := Ask.Text_Input ("Name:", Answer);
        Check (C = Ask.Confirm and Answer = "abc", "Text_Input with an Answer: OK on the default");
        Answer := SU.Null_Unbounded_String;
        Reply ("", Enter_Key, ASCII.CR);
        C := Ask.Text_Input ("Name:", Answer);
        Check (C = Ask.Confirm and Answer = "", "an empty answer is Confirm, not Cancel");
        Answer := SU.To_Unbounded_String ("kept");
        Escape;
        C := Ask.Text_Input ("Name:", Answer);
        Check (C = Ask.Cancel and Answer = "kept", "cancelled, Cancel, Answer unchanged");
        Answer := SU.Null_Unbounded_String;
        Reply ("pw", Enter_Key, ASCII.CR);
        C := Ask.Password ("Password:", Answer);
        Check (C = Ask.Confirm and Answer = "pw", "Password with an Answer");
        Escape;
        C := Ask.Password ("Password:", Answer);
        Check (C = Ask.Cancel and Answer = "pw", "cancelled, unchanged");
    end;

    --  With a maximum length (PLAN.md, Phase 20).
    Reply ("abcdef", Enter_Key, ASCII.CR);
    Check (Ask.Text_Input ("Name:", 3) = "abc", "Text_Input with a Max_Length stops the typing");
    Reply ("", Enter_Key, ASCII.CR);
    Check (Ask.Text_Input ("Name:", 3, "abcdef") = "abcdef",
        "a longer Default is shown whole (Fl_Message.cxx:471-474)");
    Reply ("xy", Enter_Key, ASCII.CR);
    Check (Ask.Text_Input ("Name:", 3, "ab") = "abx", "and typing after it stops at the limit");
    Reply ("secret", Enter_Key, ASCII.CR);
    Check (Ask.Password ("Password:", 4) = "secr", "Password with a Max_Length");
    declare
        Answer : SU.Unbounded_String := SU.Null_Unbounded_String;
    begin
        Reply ("abcdef", Enter_Key, ASCII.CR);
        C := Ask.Text_Input ("Name:", 2, Answer);
        Check (C = Ask.Confirm and Answer = "ab", "Text_Input with a Max_Length and an Answer");
        Escape;
        C := Ask.Text_Input ("Name:", 2, Answer);
        Check (C = Ask.Cancel and Answer = "ab", "cancelled, Cancel, Answer unchanged");
        Reply ("pqrs", Enter_Key, ASCII.CR);
        C := Ask.Password ("Password:", 3, Answer);
        Check (C = Ask.Confirm and Answer = "abp", "Password with a Max_Length and an Answer");
    end;
    Reply ("abcdef", Enter_Key, ASCII.CR);
    Check (Ask.Text_Input ("Name:") = "abcdef", "the next dialog has no limit");

    Ask.Set_Message_Title ("Once");
    Enter;
    Ask.Message_Box ("titled");
    Check (Title_Seen = "Once", "Set_Message_Title titles the next dialog: " & Title_Seen);
    Enter;
    Ask.Message_Box ("untitled");
    Check (Title_Seen = "", "and that one only: " & Title_Seen);
    Ask.Set_Message_Title_Default ("Always");
    Enter;
    Ask.Message_Box ("titled");
    Enter;
    Ask.Message_Box ("titled");
    Check (Title_Seen = "Always", "Set_Message_Title_Default titles every one");
    Ask.Set_Message_Title_Default ("");

    R := 10;
    G := 255;
    B := 0;
    Enter;
    C := Ask.Color_Chooser ("Color", R, G, B);
    Check (C = Ask.Confirm and Title_Seen = "Color" and R = 10 and G = 255 and B = 0,
        "Color_Chooser: OK gives the color");
    R := 1;
    G := 2;
    B := 3;
    Escape;
    C := Ask.Color_Chooser ("Color", R, G, B);
    Check (C = Ask.Cancel and R = 1 and G = 2 and B = 3, "cancelled, unchanged");

    Escape;
    Check (Ask.Show_Colormap (Red_Color) = Red_Color,
        "Show_Colormap gives back the old if none is picked");

    --  FLTK's own file chooser, which keys can answer.
    Ask.Set_File_Chooser_Callback (Note_Picked'Unrestricted_Access);
    Enter;
    declare
        Got : constant String := Ask.File_Chooser ("Open", "*.adb", "test_dialogs.adb", True);
    begin
        Check (Title_Seen = "Open" and Got = "test_dialogs.adb", "File_Chooser, relative: " & Got);
        Check (Ends (Picked (1 .. Picked_Last), "/test_dialogs.adb"),
            "Set_File_Chooser_Callback: " & Picked (1 .. Picked_Last));
    end;
    Ask.Set_File_Chooser_Callback (null);
    Picked_Last := 0;
    Enter;
    declare
        Got : constant String := Ask.File_Chooser ("Open", "*.adb", "test_dialogs.adb");
    begin
        Check (Got = Here & "/test_dialogs.adb", "and absolute: " & Got);
        Check (Picked_Last = 0, "Set_File_Chooser_Callback (null) stops it");
    end;
    Enter;
    Check (Ask.File_Chooser ("Save", "", "New.txt", True) = "New.txt",
        "a file that doesn't exist");
    Escape;
    Check (Ask.File_Chooser ("Save", "", "New.txt", True) = "", "cancelled, """"");
    declare
        Answer : SU.Unbounded_String := SU.To_Unbounded_String ("New.txt");
    begin
        Enter;
        C := Ask.File_Chooser ("Save", "", Answer, True);
        Check (C = Ask.Confirm and Answer = "New.txt", "File_Chooser with an Answer");
        Escape;
        C := Ask.File_Chooser ("Save", "", Answer, True);
        Check (C = Ask.Cancel and Answer = "New.txt", "cancelled, Cancel, Answer unchanged");
        Answer := SU.To_Unbounded_String ("..");
        Enter;
        C := Ask.Dir_Chooser ("Folder", Answer);
        Check (C = Ask.Confirm
                and SU.To_String (Answer) = Ada.Directories.Containing_Directory (Here) & "/",
            "Dir_Chooser with an Answer: " & SU.To_String (Answer));
        Escape;
        C := Ask.Dir_Chooser ("Folder", Answer);
        Check (C = Ask.Cancel
                and SU.To_String (Answer) = Ada.Directories.Containing_Directory (Here) & "/",
            "cancelled, unchanged");
    end;
    Enter;
    declare
        Got : constant String := Ask.Dir_Chooser ("Folder", "..");
    begin
        Check (Got = Ada.Directories.Containing_Directory (Here) & "/",
            "Dir_Chooser: the directory, absolute, with a slash: " & Got);
    end;

    declare
        Icon : constant FLTK.Widgets.Boxes.Box_Reference := Ask.Get_Message_Icon;
    begin
        Check (Icon.Data.Get_Box = Thin_Up_Box and Icon.Data.Get_Label_Font = Times_Bold
                and Icon.Data.Get_Label_Size = 34 and Icon.Data.Get_Background_Color = White_Color
                and Icon.Data.Get_Label_Color = Blue_Color,
            "Get_Message_Icon: FLTK's to start with");
    end;

    Summary;

end Test_Dialogs;
