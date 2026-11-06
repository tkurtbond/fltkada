--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/menubar.cxx: every kind of menu item, in a menu bar, a
--  menu button, a choice and a pop-up menu, with a terminal that the
--  callbacks print to.
--
--  The items are added one by one, not from a table.  A label added twice
--  at one place is the same item, so an item that shares its label with
--  another is added under a label of its own and then renamed.  Add can't
--  find a hidden item to add to, so the Invisible submenu is filled before
--  it is hidden.  FLTK's Huge submenu is a pointer to another table; here
--  it is an ordinary submenu.  The menus count their items from 1, so the
--  pop-up removes item 2, the File submenu, where the C++ removes item 1.
--  A menu given its items one by one has none chosen, where FLTK's table
--  gives it its first, so the menu button, the choice and the pop-up
--  choose theirs.  Quit hides the window, where the C++ calls exit.
--  FLTK's macOS system menu bar, and its About item, are left out: they
--  do nothing on other systems, as Fl_Sys_Menu_Bar::about does nothing
--  without a system menu bar driver, which only macOS has.


with

    Ada.Strings.UTF_Encoding.Wide_Strings,
    Ada.Text_IO,
    FLTK.Draw,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices.Schemes,
    FLTK.Widgets.Menus.Menu_Bars,
    FLTK.Widgets.Menus.Menu_Buttons,
    FLTK.Widgets.Valuators.Sliders.Value;

use

    FLTK;

use type

    FLTK.Key_Combo,
    FLTK.Menu_Flag,
    FLTK.Modifier;


function Menubar
    return Integer
is

    package Wdg renames FLTK.Widgets;
    package Box renames FLTK.Widgets.Boxes;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Mnu renames FLTK.Widgets.Menus;
    package Chc renames FLTK.Widgets.Menus.Choices;
    package Sch renames FLTK.Widgets.Menus.Choices.Schemes;
    package Bar renames FLTK.Widgets.Menus.Menu_Bars;
    package Btn renames FLTK.Widgets.Menus.Menu_Buttons;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package Vsl renames FLTK.Widgets.Valuators.Sliders.Value;

    Terminal_Height : constant := 120;
    Width           : constant := 700;

    --  The UTF-8 of the character with this code point.
    function U
           (Code : in Natural)
        return String is
    begin
        return Ada.Strings.UTF_Encoding.Wide_Strings.Encode ((1 => Wide_Character'Val (Code)));
    end U;

    function Key
           (Code : in Natural)
        return Keypress is
    begin
        return Character_Key (Wide_Character'Val (Code));
    end Key;

    Win    : Dbl.Double_Window := Dbl.Forge.Create (Width, 400 + Terminal_Height);
    Scheme : Sch.Scheme_Choice := Sch.Forge.Create (Win, 300, 50, 100, 25, "&scheme");
    TTY    : Trm.Terminal := Trm.Forge.Create (Win, 0, 400, Width, Terminal_Height);

    Menu_Bar : Bar.Menu_Bar := Bar.Forge.Create (Win, 0, 0, Width, 30);
    Button   : Btn.Menu_Button := Btn.Forge.Create (Win, 100, 100, 120, 25, "&menubutton");
    Choice   : Chc.Choice := Chc.Forge.Create (Win, 300, 100, 80, 25, "&choice:");
    Popup    : Btn.Menu_Button := Btn.Forge.Create (Win, 0, 0, Width, 400, "&popup");

    Note : Box.Box := Box.Forge.Create
        (Win, 200, 200, 200, 100, "Press right button" & ASCII.LF & "for a pop-up menu");

    Spacing : Vsl.Value_Slider := Vsl.Forge.Create
        (Win, 500, 150, 150, 20, "Fl::menu_linespacing()");

    pragma Unreferenced (Scheme, Note);

    procedure Window_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        --  The end of the program, so standard output, not the terminal.
        Ada.Text_IO.Put_Line ("window callback called");
        Item.Hide;
    end Window_CB;

    procedure Test_CB
           (Item : in out Wdg.Widget'Class)
    is
        This : Mnu.Menu'Class renames Mnu.Menu'Class (Item);
    begin
        if This.Chosen_Index = 0 then
            TTY.Print ("NULL" & ASCII.LF);
            return;
        end if;
        declare
            Keys : constant Key_Combo := This.Chosen.Data.Get_Shortcut;
        begin
            if Keys = No_Key then
                TTY.Print (This.Chosen_Label & ASCII.LF);
            else
                TTY.Print (This.Chosen_Label & " - " & Draw.Shortcut_Label (Keys) & ASCII.LF);
            end if;
        end;
    end Test_CB;

    procedure Quit_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Win.Hide;
    end Quit_CB;

    procedure Line_Spacing_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        --  Takes effect when a menu is next opened.
        Static.Set_Menu_Line_Spacing (Integer (Long_Float'Truncation (Spacing.Get_Value)));
    end Line_Spacing_CB;

    --  FLTK's menutable.
    procedure Add_Table
           (This : in out Mnu.Menu'Class)
    is
        Unique : Natural := 0;

        procedure Add
               (Text     : in String;
                Shortcut : in Key_Combo := No_Key;
                Flags    : in Menu_Flag := Flag_Normal) is
        begin
            This.Add (Text, Shortcut => Shortcut, Flags => Flags);
        end Add;

        --  An item labelled Label in the submenu at Path, which may have
        --  others with that label.
        procedure Same
               (Path     : in String;
                Label    : in String;
                Shortcut : in Key_Combo := No_Key;
                Flags    : in Menu_Flag := Flag_Normal)
        is
            Number : constant String := Natural'Image (Unique);
        begin
            Unique := Unique + 1;
            This.Set_Label
               (This.Add (Path & "/unique" & Number (Number'First + 1 .. Number'Last),
                    Shortcut => Shortcut, Flags => Flags),
                Label);
        end Same;

        procedure Styled
               (Text : in String;
                Kind : in Label_Kind;
                Font : in Font_Kind;
                Size : in Font_Size)
        is
            Place : constant Mnu.Index := This.Add (Text);
        begin
            This.Item (Place).Data.Set_Label_Kind (Kind);
            This.Item (Place).Data.Set_Label_Font (Font);
            This.Item (Place).Data.Set_Label_Size (Size);
        end Styled;

        procedure Shortcuts
               (Code    : in Keypress;
                Divider : in Menu_Flag) is
        begin
            Same ("&File", "shortcut", Press (Code));
            Same ("&File", "shortcut", Mod_Shift + Code);
            Same ("&File", "shortcut", Mod_Ctrl + Code);
            Same ("&File", "shortcut", Mod_Ctrl + Mod_Shift + Code);
            Same ("&File", "shortcut", Mod_Alt + Code);
            Same ("&File", "shortcut", Mod_Alt + Mod_Shift + Code);
            Same ("&File", "shortcut", Mod_Alt + Mod_Ctrl + Code);
            Same ("&File", "shortcut", Mod_Alt + Mod_Shift + Mod_Ctrl + Code, Divider);
        end Shortcuts;

        Place : Mnu.Index;

    begin
        Add ("foo", Flags => Flag_Inactive);

        Add ("&File/&Open", Mod_Alt + 'o', Flag_Inactive);
        Add ("&File/&Close");
        This.Add ("&File/&Quit", Quit_CB'Unrestricted_Access, Mod_Alt + 'q', Flag_Divider);
        Shortcuts (Press ('a'), Flag_Divider);
        Same ("&File", "shortcut", Press (Key (16#0D#)));
        Same ("&File", "shortcut", Mod_Ctrl + Enter_Key, Flag_Divider);
        Shortcuts (Function_Key (1), Flag_Divider);
        Add ("&File/&Submenus", Mod_Alt + 'S', Flag_Submenu);
        Add ("&File/&Submenus/A very long menu item");
        Add ("&File/&Submenus/&submenu", Mod_Ctrl + 'S', Flag_Submenu);
        for N in 1 .. 4 loop
            Add ("&File/&Submenus/&submenu/item" & Integer'Image (N));
        end loop;
        Add ("&File/&Submenus/after submenu");

        Add ("&Edit", Press (Function_Key (2)), Flag_Submenu);
        Add ("&Edit/Undo", Mod_Alt + 'z');
        Add ("&Edit/Redo", Mod_Alt + 'r', Flag_Divider);
        Add ("&Edit/Cut", Mod_Alt + 'x');
        Add ("&Edit/Copy", Mod_Alt + 'c');
        Add ("&Edit/Paste", Mod_Alt + 'v');
        Add ("&Edit/Inactive", Mod_Alt + 'd', Flag_Inactive);
        Add ("&Edit/Clear", Flags => Flag_Divider);
        Add ("&Edit/Invisible", Mod_Alt + 'e', Flag_Invisible);
        Add ("&Edit/Preferences");
        Add ("&Edit/Size");

        Add ("&Checkbox", Press (Function_Key (3)), Flag_Submenu);
        Add ("&Checkbox/&Alpha", Press (Function_Key (2)), Flag_Toggle);
        Add ("&Checkbox/&Beta", Flags => Flag_Toggle);
        Add ("&Checkbox/&Gamma", Flags => Flag_Toggle);
        Add ("&Checkbox/&Delta", Flags => Flag_Toggle + Flag_Value);
        Add ("&Checkbox/&Epsilon", Flags => Flag_Toggle);
        Add ("&Checkbox/&Pi", Flags => Flag_Toggle);
        Add ("&Checkbox/&Mu", Flags => Flag_Toggle + Flag_Divider);
        Place := This.Add ("&Checkbox/Red", Flags => Flag_Toggle);
        This.Item (Place).Data.Set_Label_Color (1);
        Add ("&Checkbox/Black", Flags => Flag_Toggle + Flag_Divider);
        Add ("&Checkbox/00", Flags => Flag_Toggle);
        Add ("&Checkbox/000", Flags => Flag_Toggle);

        Add ("&Radio/&Alpha", Flags => Flag_Radio);
        Add ("&Radio/&Beta", Flags => Flag_Radio);
        Add ("&Radio/&Gamma", Flags => Flag_Radio);
        Add ("&Radio/&Delta", Flags => Flag_Radio + Flag_Value);
        Add ("&Radio/&Epsilon", Flags => Flag_Radio);
        Add ("&Radio/&Pi", Flags => Flag_Radio);
        Add ("&Radio/&Mu", Flags => Flag_Radio + Flag_Divider);
        Add ("&Radio/Red", Flags => Flag_Radio);
        Add ("&Radio/Black", Flags => Flag_Radio + Flag_Divider);
        Add ("&Radio/00", Flags => Flag_Radio);
        Add ("&Radio/000", Flags => Flag_Radio);

        --  A size of 0 is the menu's text size.  FLTK's FL_SYMBOL_LABEL is
        --  FL_NORMAL_LABEL.
        Styled ("&Font/Normal", Normal_Label, Helvetica, 14);
        Styled ("&Font/Bold", Normal_Label, Helvetica_Bold, 14);
        Styled ("&Font/Italic", Normal_Label, Helvetica_Italic, 14);
        Styled ("&Font/BoldItalic", Normal_Label, Helvetica_Bold_Italic, 14);
        Styled ("&Font/Small", Normal_Label, Helvetica_Bold_Italic, 10);
        Styled ("&Font/Emboss", Embossed_Label, Helvetica, 0);
        Styled ("&Font/Engrave", Engraved_Label, Helvetica, 0);
        Styled ("&Font/Shadow", Shadow_Label, Helvetica, 0);
        Styled ("&Font/@->", Normal_Label, Helvetica, 0);

        Add ("&International/Sharp Ess", Press (Key (16#DF#)));
        Add ("&International/A Umlaut", Press (Key (16#C4#)));
        Add ("&International/a Umlaut", Press (Key (16#E4#)));
        Add ("&International/Euro currency", Mod_Command + Key (16#20AC#));
        Add ("&International/the &" & U (16#FC#) & " Umlaut");
        Add ("&International/the capital &" & U (16#DC#));
        Add ("&International/convert " & U (16#A5#) & " to &" & U (16#A3#));
        Add ("&International/convert " & U (16#A5#) & " to &" & U (16#20AC#));
        Add ("&International/Hangul character Sios &" & U (16#3145#));
        Add ("&International/Hangul character Cieuc", Press (Key (16#3148#)));

        Add ("E&mpty", Flags => Flag_Submenu);

        Add ("&Inactive", Flags => Flag_Inactive + Flag_Submenu);
        Same ("&Inactive", "A very long menu item");
        Same ("&Inactive", "A very long menu item");

        Place := This.Add ("Invisible", Flags => Flag_Submenu);
        Same ("Invisible", "A very long menu item");
        Same ("Invisible", "A very long menu item");
        This.Set_Flags (Place, Flag_Submenu + Flag_Invisible);

        for N in 0 .. 98 loop
            Add ("&Huge/item" & Integer'Image (N));
        end loop;

        Add ("button", Press (Function_Key (4)), Flag_Toggle);
    end Add_Table;

    --  FLTK's pulldown.
    procedure Add_Pulldown
           (This : in out Mnu.Menu'Class) is
    begin
        This.Add ("Red", Shortcut => Mod_Alt + 'r');
        This.Add ("Green", Shortcut => Mod_Alt + 'g');
        This.Add ("Blue", Shortcut => Mod_Alt + 'b');
        This.Add ("Strange", Shortcut => Mod_Alt + 's', Flags => Flag_Inactive);
        This.Add ("&Charm", Shortcut => Mod_Alt + 'c');
        This.Add ("Truth", Shortcut => Mod_Alt + 't');
        This.Add ("Beauty", Shortcut => Mod_Alt + 'b');
    end Add_Pulldown;

begin

    Win.Set_Callback (Window_CB'Unrestricted_Access);

    Add_Table (Menu_Bar);
    Menu_Bar.Set_Callback (Test_CB'Unrestricted_Access);

    Add_Pulldown (Button);
    Button.Set_Chosen (1);
    Button.Set_Tooltip ("this is a menu button");
    Button.Set_Callback (Test_CB'Unrestricted_Access);

    Add_Pulldown (Choice);
    Choice.Set_Chosen (1);
    Choice.Set_Tooltip ("this is a choice menu");
    Choice.Set_Callback (Test_CB'Unrestricted_Access);

    Popup.Set_Popup_Kind (Btn.Popup3);
    Add_Table (Popup);
    Popup.Remove (2);  --  the File submenu
    Popup.Set_Chosen (1);
    Popup.Set_Callback (Test_CB'Unrestricted_Access);

    Win.Set_Resizable (Popup);
    Win.Set_Size_Range (300, 400, 0, 400 + Terminal_Height);

    Spacing.Set_Tooltip ("Changes the line spacing between all menu items");
    Sld.Extra.Set_Kind (Sld.Slider (Spacing), Sld.Horizontal_Slider);
    Spacing.Set_Value (Long_Float (Static.Get_Menu_Line_Spacing));
    Spacing.Set_Background_Color (46);
    Spacing.Set_Selection_Color (1);
    Spacing.Set_Alignment (Align_Left);
    Spacing.Set_Range (0.1, 50.0);
    Spacing.Set_Step (1.0);
    Spacing.Set_Callback (Line_Spacing_CB'Unrestricted_Access);

    Win.Show_With_Args;
    return FLTK.Run;

end Menubar;
