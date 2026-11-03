

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 16 (FLTKAda-BUGS.md): strings FLTK keeps without copying them.  Each
--  string is built at run time, passed, and then the secondary stack is
--  scribbled over, so a binding that passed a temporary would hand FLTK
--  'X's, or worse.  The test then reads the value back from FLTK.
--
--  The tooltip can't be read back, since FLTK's tooltip window is private.
--  That case shows the tip and relies on valgrind and on FLTK's source
--  (Fl_Tooltip.cxx:301).  The ask choosers' title can only be read while
--  the dialog is up, when the caller's temporary is still alive; FLTK keeps
--  it after the dialog closes, in the hidden chooser (fl_file_dir.cxx:116,
--  200), so that case too rests on the source.


with

    Checks,
    FLTK.Asks,
    FLTK.Draw,
    FLTK.File_Choosers,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Tooltips,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Browsers.Textline.File,
    FLTK.Widgets.Groups.Windows,
    Symbol_Counts;

use

    Checks,
    FLTK;


procedure Test_Kept_Strings is

    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Bx  renames FLTK.Widgets.Boxes;
    package FB  renames FLTK.Widgets.Groups.Browsers.Textline.File;
    package FC  renames FLTK.File_Choosers;

    Serial : Natural := 0;

    --  A new string each call, made at run time on the secondary stack.
    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

    function Expected
           (Base : in String)
        return String is
    begin
        return Base & Integer'Image (Serial);
    end Expected;

    --  Integer'Image's space becomes _, since a label's symbol name can't hold one.
    function Underscored
           (Text : in String)
        return String
    is
        Result : String := Text;
    begin
        for C of Result loop
            if C = ' ' then
                C := '_';
            end if;
        end loop;
        return Result;
    end Underscored;

    function Filler
           (Length : in Positive)
        return String is
    begin
        return (1 .. Length => 'X');
    end Filler;

    --  Overwrites what the last calls left on the stacks.
    procedure Scribble is
        Count : Natural := 0;
    begin
        for N in 1 .. 8 loop
            declare
                Junk : constant String := Filler (4096 * N);
            begin
                Count := Count + Junk'Length;
            end;
        end loop;
        pragma Assert (Count > 0);
    end Scribble;

    Ignore_Done : Boolean;

    Ignore_Count : Natural;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;


    --  Symbols  --

    Refused_Name : String (1 .. 8) := (others => ' ');
    Refused_Last : Natural := 0;

    procedure Add_Refused is
    begin
        FLTK.Draw.Add_Symbol
           (Refused_Name (1 .. Refused_Last), Symbol_Counts.Draw'Access, True);
    end Add_Refused;

    procedure Refuse
           (Name  : in String;
            Label : in String) is
    begin
        Refused_Name (1 .. Name'Length) := Name;
        Refused_Last := Name'Length;
        Raises (Add_Refused'Unrestricted_Access, FLTK.Draw.Draw_Error'Identity,
            "Add_Symbol refuses " & Label);
    end Refuse;

    procedure Draw_Non_ASCII is
    begin
        FLTK.Draw.Draw_Symbol (0, 0, 20, 20, "@" & Character'Val (16#C3#)
            & Character'Val (16#A9#), Black_Color);
    end Draw_Non_ASCII;


    --  Ask choosers  --

    Seen_Title : String (1 .. 64) := (others => ' ');
    Seen_Last  : Natural := 0;

    procedure Note_Title_And_Close is
        Title  : constant String := Prb.Modal_Title;
        Ignore : Boolean;
    begin
        Seen_Last := Natural'Min (Title'Length, Seen_Title'Length);
        Seen_Title (1 .. Seen_Last) := Title (Title'First .. Title'First + Seen_Last - 1);
        Ignore := Prb.Close_Modal;
    end Note_Title_And_Close;



    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Kept_Strings");

    Symbol_Box : Bx.Box := Bx.Forge.Create (Window, Flat_Box, 10, 10, 40, 40);

    Browser : FB.File_Browser := FB.Forge.Create (Window, 60, 10, 200, 150);

begin

    --  Window icon label, from Set_Icon_Label and from Set_Labels.
    Window.Set_Icon_Label (Fresh ("icon"));
    Scribble;
    Check (Window.Get_Icon_Label = Expected ("icon"), "Set_Icon_Label's text is kept: "
        & Window.Get_Icon_Label);

    Window.Set_Labels ("label", Fresh ("both"));
    Scribble;
    Check (Window.Get_Icon_Label = Expected ("both"), "Set_Labels's icon text is kept: "
        & Window.Get_Icon_Label);

    --  Replacing the icon label frees the old copy, and the new one stands.
    Window.Set_Icon_Label (Fresh ("again"));
    Scribble;
    Check (Window.Get_Icon_Label = Expected ("again"), "a second icon label is kept: "
        & Window.Get_Icon_Label);


    --  File_Browser filter; Load reads it.
    Browser.Set_Filter (Fresh ("*.no-such-ext"));
    Scribble;
    Check (Browser.Get_Filter = Expected ("*.no-such-ext"), "Set_Filter's pattern is kept: "
        & Browser.Get_Filter);
    Ignore_Count := Browser.Load (Dir => ".");


    --  File_Chooser title.
    declare
        Chooser : constant FC.File_Chooser := FC.Forge.Create (Fresh ("chooser"), "*", ".");
        Title   : constant String := Expected ("chooser");
    begin
        Scribble;
        Check (Chooser.Get_Label = Title, "File_Chooser's title is kept: " & Chooser.Get_Label);
    end;


    --  Symbols: a kept name a label can use, and the names refused.
    FLTK.Draw.Add_Symbol (Underscored (Fresh ("kept")), Symbol_Counts.Draw'Access, True);
    Scribble;
    Symbol_Box.Set_Label ("@" & Underscored (Expected ("kept")));

    Refuse ("", "an empty name");
    Refuse ("a@b", "a name holding @");
    Refuse ("#x", "a name starting #");
    Refuse ("$x", "a name starting $");
    Refuse ("%x", "a name starting %");
    Refuse ("7x", "a name starting with a digit");
    Refuse ("-3x", "a name starting -3");
    Refuse ("+3x", "a name starting +3");
    Refuse ("x" & Character'Val (16#C3#) & Character'Val (16#A9#), "a name outside ASCII");
    Raises (Draw_Non_ASCII'Unrestricted_Access, FLTK.Draw.Draw_Error'Identity,
        "Draw_Symbol refuses a name outside ASCII");

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump (10);
    Check (Symbol_Counts.Draws > 0,
        "a label draws the kept symbol:" & Natural'Image (Symbol_Counts.Draws));


    --  Tooltip: shown at once, from a temporary.
    FLTK.Tooltips.Set_Enabled (True);
    FLTK.Tooltips.Set_Delay (0.0);
    FLTK.Tooltips.Enter_Area (Symbol_Box, 0, 0, 40, 40, Fresh ("tip"));
    Scribble;
    Pump (10);
    FLTK.Tooltips.Enter_Area (Symbol_Box, 0, 0, 40, 40, Expected ("tip"));
    Pump (5);
    FLTK.Tooltips.Enter_Area (Symbol_Box, 0, 0, 40, 40, Fresh ("other tip"));
    Scribble;
    Pump (5);
    --  FLTK still holds the last text after an empty one (pofltk's shim freed it
    --  here, and the dir chooser below read it), and after a text given while
    --  tooltips are disabled.
    FLTK.Tooltips.Enter_Area (Symbol_Box, 0, 0, 40, 40, "");
    Pump (5);
    FLTK.Tooltips.Enter_Area (Symbol_Box, 0, 0, 40, 40, Fresh ("tip"));
    Pump (5);
    FLTK.Tooltips.Disable;
    FLTK.Tooltips.Enter_Area (Symbol_Box, 0, 0, 40, 40, Fresh ("disabled tip"));
    Scribble;
    FLTK.Tooltips.Set_Enabled (True);
    Pump (5);
    Check (True, "the tooltip cases ran (checked by valgrind, not by value)");


    --  Ask choosers: the title, read while the dialog is up.
    declare
        Ignore : Boolean;
    begin
        FLTK.Static.Add_Timeout (0.2, Note_Title_And_Close'Unrestricted_Access);
        declare
            Result : constant String := FLTK.Asks.Dir_Chooser (Fresh ("dir title"), ".");
        begin
            Ignore := Result'Length > 0;
        end;
        Check (Seen_Title (1 .. Seen_Last) = Expected ("dir title"),
            "Dir_Chooser's title is kept: " & Seen_Title (1 .. Seen_Last));

        Seen_Last := 0;
        FLTK.Static.Add_Timeout (0.2, Note_Title_And_Close'Unrestricted_Access);
        declare
            Result : constant String := FLTK.Asks.File_Chooser (Fresh ("file title"), "*", "");
        begin
            Ignore := Result'Length > 0;
        end;
        Check (Seen_Title (1 .. Seen_Last) = Expected ("file title"),
            "File_Chooser's title is kept: " & Seen_Title (1 .. Seen_Last));
    end;

    Window.Hide;
    Summary;

end Test_Kept_Strings;

