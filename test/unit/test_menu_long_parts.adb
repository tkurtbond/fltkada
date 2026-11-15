--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 172: Fl_Menu_Item::insert copies each part of a label, between
--  '/'s, into a 1024-byte buffer on the stack with no bound
--  (Fl_Menu_add.cxx:147,163), so a 3000-byte label aborted the program with
--  "stack smashing detected".  Add and Insert now cut each part to 1023
--  bytes, counting a '\' escape as the one byte it becomes, where a UTF-8
--  character starts.  A part starting with '/' is taken whole and never
--  copied, so it is kept whole.


with

    Checks,
    FLTK.Menu_Items,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide;

use

    Checks;


procedure Test_Menu_Long_Parts is

    package Chs renames FLTK.Widgets.Menus.Choices;
    package Sys renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;

    function Label
           (Menu  : in FLTK.Widgets.Menus.Menu'Class;
            Place : in Positive)
        return String is
    begin
        return FLTK.Menu_Items.Get_Label (Menu.Item (Place).Data.all);
    end Label;

    function Escaped
           (Count : in Natural)
        return String
    is
        Result : String (1 .. 2 * Count);
    begin
        for I in 1 .. Count loop
            Result (2 * I - 1 .. 2 * I) := "\a";
        end loop;
        return Result;
    end Escaped;

    E_Acute : constant String := Character'Val (16#C3#) & Character'Val (16#A9#);

    Plain   : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Sub     : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Escapes : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    UTF8    : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Slashed : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Inserts : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Bar     : Sys.System_Menu_Bar := Sys.Forge.Create (0, 0, 100, 25);

begin

    Plain.Add ((1 .. 3000 => 'x'));
    Check (Label (Plain, 1) = (1 .. 1023 => 'x'),
        "Add cuts a 3000-byte label to 1023 bytes:" &
        Natural'Image (Label (Plain, 1)'Length));

    Plain.Add ((1 .. 1023 => 'y'));
    Check (Label (Plain, 2) = (1 .. 1023 => 'y'),
        "and keeps a label of 1023 bytes whole:" &
        Natural'Image (Label (Plain, 2)'Length));

    Sub.Add ((1 .. 1500 => 's') & "/In");
    Check (Label (Sub, 1) = (1 .. 1023 => 's') and then Label (Sub, 2) = "In",
        "a submenu's title is cut the same: " &
        Natural'Image (Label (Sub, 1)'Length) & " " & Label (Sub, 2));

    Escapes.Add (Escaped (1000) & (1 .. 100 => 'b'));
    Check (Label (Escapes, 1) = (1 .. 1000 => 'a') & (1 .. 23 => 'b'),
        "an escape counts as the one byte it becomes:" &
        Natural'Image (Label (Escapes, 1)'Length));

    UTF8.Add ((1 .. 1022 => 'x') & E_Acute & "yy");
    Check (Label (UTF8, 1) = (1 .. 1022 => 'x'),
        "the cut falls where a UTF-8 character starts:" &
        Natural'Image (Label (UTF8, 1)'Length));

    Slashed.Add ('/' & (1 .. 1500 => 'f'));
    Check (Label (Slashed, 1) = '/' & (1 .. 1500 => 'f'),
        "a label starting with '/' is kept whole:" &
        Natural'Image (Label (Slashed, 1)'Length));

    Inserts.Add ("Last");
    Inserts.Insert (1, (1 .. 3000 => 'z'));
    Check (Label (Inserts, 1) = (1 .. 1023 => 'z') and then Label (Inserts, 2) = "Last",
        "Insert cuts a 3000-byte label to 1023 bytes:" &
        Natural'Image (Label (Inserts, 1)'Length));

    Bar.Add ((1 .. 3000 => 'm'), Shortcut => "");
    Bar.Insert (1, (1 .. 3000 => 'n'));
    Check (Label (Bar, 1) = (1 .. 1023 => 'n') and then Label (Bar, 2) = (1 .. 1023 => 'm'),
        "System_Menu_Bar's Add and Insert cut it too:" &
        Natural'Image (Label (Bar, 1)'Length) & Natural'Image (Label (Bar, 2)'Length));

    Summary;

end Test_Menu_Long_Parts;
