


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Inputs:  text in and out, typing, editing, numbers, file inputs and
--  input choices, after pofltk's test/TestInputs.Mod.  Keys are sent as
--  from the window system (FLTK.Probe) to the focus, in a window shown
--  only for the file input's click.  Undo and redo are test_undo_redo's.


with

    Ada.Exceptions,
    Checks,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Widgets.Groups.Input_Choices,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text.File,
    FLTK.Widgets.Inputs.Text.Floating_Point,
    FLTK.Widgets.Inputs.Text.Multiline,
    FLTK.Widgets.Inputs.Text.Outputs.Multiline,
    FLTK.Widgets.Inputs.Text.Secret,
    FLTK.Widgets.Inputs.Text.Whole_Number,
    System;

use

    Checks,
    FLTK;

use type

    System.Address;


procedure Test_Input is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Txt renames FLTK.Widgets.Inputs.Text;
    package Fil renames FLTK.Widgets.Inputs.Text.File;
    package Flt renames FLTK.Widgets.Inputs.Text.Floating_Point;
    package Mul renames FLTK.Widgets.Inputs.Text.Multiline;
    package Otp renames FLTK.Widgets.Inputs.Text.Outputs;
    package MOt renames FLTK.Widgets.Inputs.Text.Outputs.Multiline;
    package Sec renames FLTK.Widgets.Inputs.Text.Secret;
    package Int renames FLTK.Widgets.Inputs.Text.Whole_Number;
    package ICh renames FLTK.Widgets.Groups.Input_Choices;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window  : Win.Window := Win.Forge.Create (0, 0, 400, 300, "Test_Input");
    Line    : Txt.Text_Input := Txt.Forge.Create (Window, 60, 10, 300, 25, "in");
    Whole   : Int.Integer_Input := Int.Forge.Create (Window, 60, 40, 100, 25, "int");
    Real    : Flt.Float_Input := Flt.Forge.Create (Window, 200, 40, 100, 25, "float");
    Multi   : Mul.Multiline_Input := Mul.Forge.Create (Window, 60, 70, 300, 60, "multi");
    Secret  : Sec.Secret_Input := Sec.Forge.Create (Window, 60, 140, 100, 25, "secret");
    Shown   : Otp.Output := Otp.Forge.Create (Window, 200, 140, 100, 25, "out");
    MShown  : constant MOt.Multiline_Output :=
        MOt.Forge.Create (Window, 60, 170, 300, 25, "mout");
    Path    : Fil.File_Input := Fil.Forge.Create (Window, 60, 200, 300, 40, "file");
    Choice  : ICh.Input_Choice := ICh.Forge.Create (Window, 60, 250, 120, 25, "choice");

    Calls : Natural := 0;
    Ok    : Boolean;

    procedure Count
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Calls := Calls + 1;
    end Count;

    --  Types each character of Keys into the focus.
    procedure Type_Keys
           (Keys : in String) is
    begin
        for C of Keys loop
            Ok := Prb.Key (Keydown, Press (C), Mod_None, (1 => C));
        end loop;
    end Type_Keys;

    --  With the text the window system gives it:  under Wayland, FLTK takes
    --  a key with no text as composed text.
    procedure Enter is
    begin
        Ok := Prb.Key (Keydown, Enter_Key, Mod_None, (1 => ASCII.CR));
    end Enter;

    function Has_Focus
           (Item : in Wdg.Widget'Class)
        return Boolean is
    begin
        return FLTK.Events.Get_Focus /= null
            and then FLTK.Events.Get_Focus.all'Address = Item'Address;
    end Has_Focus;

    procedure Click
           (X, Y : in Integer) is
    begin
        Ok := Prb.Mouse (Window, Push, X, Y);
        Ok := Prb.Mouse (Window, Release, X, Y);
    end Click;

begin

    --  The text, from the program.
    Check (Line.Get_Value = "" and Line.Size = 0, "an input starts empty");
    Line.Set_Value ("hello, world");
    Check (Line.Get_Value = "hello, world" and Line.Size = 12 and Line.Get_Position = 12,
        "Set_Value sets the text, with the cursor at its end");

    --  Typing.
    Line.Set_Value ("");
    Line.Set_Callback (Count'Unrestricted_Access);
    Line.Set_When (When_Changed);
    Check (Line.Take_Focus and Has_Focus (Line), "an input takes the focus");
    Type_Keys ("abc");
    Check (Line.Get_Value = "abc" and Calls = 3,
        "typed keys go in, with a callback each (When_Changed)");
    Ok := Prb.Key (Keydown, Backspace_Key, Mod_None, (1 => ASCII.BS));
    Check (Ok and Line.Get_Value = "ab", "BackSpace deletes");
    Line.Set_When (When_Enter_Key);
    Calls := 0;
    Enter;
    Check (Calls = 0, "Enter doesn't call back (When_Enter_Key) if nothing changed");
    Check (Line.Get_Position = 2 and Line.Get_Mark = 0, "but selects all the text");
    Line.Set_Position_Mark (2, 2);
    Type_Keys ("c");
    Enter;
    Check (Calls = 1 and Line.Get_Value = "abc",
        "Enter calls back once something has changed, typing nothing");
    Line.Set_Maximum_Size (4);
    Line.Set_Position_Mark (3, 3);
    Type_Keys ("xyz");
    Check (Line.Get_Value = "abcx" and Line.Get_Maximum_Size = 4,
        "typing stops at the maximum size");
    Line.Set_Maximum_Size (32767);

    --  Editing.
    Line.Set_Value ("hello, world");
    Line.Set_Position_Mark (0, 5);
    Check (Line.Get_Position = 0 and Line.Get_Mark = 5,
        "Set_Position_Mark sets the cursor and mark");
    Check (Line.Insert ("goodbye"), "Insert replaces the selection");
    Check (Line.Get_Value = "goodbye, world", "with its text");
    Check (Line.Replace (9, 14, "moon"), "Replace a range");
    Check (Line.Get_Value = "goodbye, moon", "with its text");
    Check (Line.Cut (0, 9), "Cut a range");
    Check (Line.Get_Value = "moon", "deletes the range");
    Check (Line.Undo, "Undo");
    Check (Line.Get_Value = "goodbye, moon", "restores it");
    Line.Set_Position_Mark (0, 8);
    Check (Line.Cut, "Cut");
    Check (Line.Get_Value = " moon", "deletes the selection");
    Check (Line.Index (1) = 'm', "Index");

    --  pofltk 155 and FLTKAda-BUGS 125, after TestInputs and HaltInputIndex.
    --  Index decodes the UTF-8 character at a byte; a byte inside one is
    --  read alone, as Latin-1.
    declare
        CE : constant Ada.Exceptions.Exception_Id := Constraint_Error'Identity;
        C  : Character with Unreferenced;
        W  : Wide_Wide_Character with Unreferenced;
        procedure Before is
        begin
            C := Line.Index (-1);
        end Before;
        procedure Past is
        begin
            C := Line.Index (4);
        end Past;
        procedure Wide_Past is
        begin
            W := Line.Wide_Wide_Index (4);
        end Wide_Past;
        procedure Euro is
        begin
            C := Line.Index (0);
        end Euro;
    begin
        Line.Set_Value ("a" & Character'Val (16#C3#) & Character'Val (16#A9#));
        Check (Line.Index (0) = 'a' and Line.Index (1) = Character'Val (16#E9#)
                and Line.Index (3) = Character'Val (0),
            "Index is the character at a byte, NUL at the end");
        Check (Line.Index (2) = Character'Val (16#A9#),
            "and a byte that isn't a character's first is read as Latin-1");
        Check (Line.Wide_Wide_Index (1) = Wide_Wide_Character'Val (16#E9#)
                and Line.Wide_Wide_Index (3) = Wide_Wide_Character'Val (0),
            "Wide_Wide_Index too");
        Raises (Before'Access, CE, "Index before the text raises Constraint_Error");
        Line.Set_Value ("ab");
        Raises (Past'Access, CE, "Index past the text's end raises Constraint_Error");
        Raises (Wide_Past'Access, CE, "so does Wide_Wide_Index");
        Line.Set_Value (Character'Val (16#E2#) & Character'Val (16#82#) & Character'Val (16#AC#));
        Check (Line.Wide_Wide_Index (0) = Wide_Wide_Character'Val (16#20AC#),
            "Wide_Wide_Index gives a character past U+00FF");
        Raises (Euro'Access, CE, "where Index raises Constraint_Error");
    end;

    --  Numbers.
    Check (Whole.Take_Focus, "focus to the integer input");
    Type_Keys ("1x2-");
    Check (Whole.Get_Value = "12" and Long_Integer'(Whole.Get_Value) = 12,
        "an integer input takes only digits where they fit");
    Whole.Set_Value ("-345");
    Check (Long_Integer'(Whole.Get_Value) = -345, "its value as an integer");
    Check (Real.Take_Focus, "focus to the float input");
    Type_Keys ("2.5x");
    Check (Real.Get_Value = "2.5" and Long_Float'(Real.Get_Value) = 2.5,
        "a float input takes a real number");

    --  Many lines.
    Check (Multi.Take_Focus, "focus to the multiline input");
    Type_Keys ("a");
    Enter;
    Type_Keys ("b");
    Check (Multi.Get_Value = "a" & ASCII.LF & "b", "Enter types a new line in a multiline input");
    Multi.Set_Wrap (True);
    Multi.Set_Tab_Nav (False);
    Check (Multi.Is_Wrap and not Multi.Is_Tab_Nav, "Wrap and Tab_Nav read back");

    --  Secrets and outputs.
    Check (Secret.Take_Focus, "focus to the secret input");
    Type_Keys ("pw");
    Check (Secret.Get_Value = "pw", "a secret input's value is the text typed");
    Check (Shown.Is_Readonly and MShown.Is_Readonly and not Line.Is_Readonly,
        "outputs are read-only, inputs not");
    Shown.Set_Value ("shown");
    Check (Shown.Take_Focus, "an output takes the focus, for selecting");
    Type_Keys ("x");
    Check (Shown.Get_Value = "shown", "but typing doesn't change it");
    Line.Set_Readonly (True);
    Check (Line.Is_Readonly, "Set_Readonly");

    --  The text's look.
    Line.Set_Text_Font (Courier);
    Line.Set_Text_Size (18);
    Line.Set_Text_Color (Blue_Color);
    Line.Set_Cursor_Color (Red_Color);
    Check (Line.Get_Text_Font = Courier and Line.Get_Text_Size = 18
            and Line.Get_Text_Color = Blue_Color and Line.Get_Cursor_Color = Red_Color,
        "text font, size and color, and cursor color, read back");

    --  An input choice.
    Choice.Set_Callback (Count'Unrestricted_Access);
    Calls := 0;
    Check (Choice.Button_Menu.Number_Of_Items = 0 and not Choice.Has_Item (1),
        "an input choice starts with no items");
    Choice.Button_Menu.Add ("one");
    Choice.Button_Menu.Add ("two");
    Choice.Button_Menu.Add ("three");
    Check (Choice.Has_Item (3) and not Choice.Has_Item (4), "its menu's items are its items");
    Check (Choice.Item (3).Get_Label = "three", "Item");
    Choice.Set_Item (2);
    Check (Choice.Get_Input = "two" and Choice.Button_Menu.Chosen_Index = 2 and Calls = 0,
        "Set_Item chooses an item and sets the text, without a callback");
    Choice.Set_Input ("four");
    Check (not Choice.Update_Menu_Button and Choice.Button_Menu.Chosen_Index = 2,
        "Update_Menu_Button: no item is ""four"", so it leaves the menu as it was");
    Choice.Set_Input ("three");
    Check (Choice.Update_Menu_Button and Choice.Button_Menu.Chosen_Index = 3
            and Calls = 0,
        "an item that is the input's text is chosen, with no callback");
    Choice.Set_Input ("four");
    Check (Choice.Get_Input = "four" and Choice.Button_Menu.Chosen_Index = 3,
        "Set_Input leaves the menu alone");
    Choice.Set_Changed (True);
    Check (Choice.Has_Changed, "Set_Changed reaches the input");
    Choice.Clear_Changed;
    Check (not Choice.Has_Changed, "and Clear_Changed clears it");
    Choice.Set_Down_Box (Flat_Box);
    Choice.Set_Text_Size (18);
    Choice.Set_Text_Color (Blue_Color);
    Choice.Set_Text_Font (Courier);
    Check (Choice.Get_Down_Box = Flat_Box and Choice.Get_Text_Size = 18
            and Choice.Get_Text_Color = Blue_Color and Choice.Get_Text_Font = Courier,
        "the box and text settings read back");
    Choice.Set_Input ("");
    Click (70, 260);
    Type_Keys ("x");
    Check (Calls = 1 and Choice.Get_Input = "x", "typing in it calls back");
    Choice.Clear;
    Check (Choice.Button_Menu.Number_Of_Items = 0, "Clear");

    --  A file input:  a click on a directory in the bar above the text cuts
    --  the path back to it.  The bar is laid out as it draws, so the window
    --  is shown.
    Path.Set_Callback (Count'Unrestricted_Access);
    Calls := 0;
    Path.Set_Value ("/usr/share/doc/x");
    Check (Path.Get_Value = "/usr/share/doc/x", "a file input's value reads back");
    Path.Set_Down_Box (Flat_Box);
    Check (Path.Get_Down_Box = Flat_Box, "its down box reads back");
    Path.Set_Down_Box (Up_Box);
    Window.Show;
    Window.Wait_For_Expose;
    Ok := Prb.Capture (Path);
    Prb.Release;
    Ok := Prb.Mouse (Window, Push, 66, 203);
    Ok := Prb.Mouse (Window, Release, 66, 203);
    Check (Path.Get_Value = "/" and Calls = 1,
        "a click on its first directory cuts the path to it, and calls back: '"
            & Path.Get_Value & "'");
    Window.Hide;

    --  The right-button menu's texts, from pofltk's TestInputs.  FLTK keeps
    --  the pointer, so the text must outlast the String it came from.
    Check (Txt.Get_Cut_Menu_Text = "Cut" and Txt.Get_Copy_Menu_Text = "Copy"
            and Txt.Get_Paste_Menu_Text = "Paste",
        "the menu texts start as FLTK's");
    declare
        Cut   : constant String := "Ausschneiden";
        Copy  : constant String := "Kopieren";
        Paste : constant String := "Einfuegen";
    begin
        Txt.Set_Cut_Menu_Text (Cut);
        Txt.Set_Copy_Menu_Text (Copy);
        Txt.Set_Paste_Menu_Text (Paste);
    end;
    Check (Txt.Get_Cut_Menu_Text = "Ausschneiden" and Txt.Get_Copy_Menu_Text = "Kopieren"
            and Txt.Get_Paste_Menu_Text = "Einfuegen",
        "Set_Cut_Menu_Text and the others, kept as copies");
    Txt.Set_Cut_Menu_Text ("Cut");
    Txt.Set_Copy_Menu_Text ("Copy");
    Txt.Set_Paste_Menu_Text ("Paste");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Input;



