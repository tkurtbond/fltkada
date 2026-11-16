--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  The bit records given to FLTK (FLTKAda-BUGS.md 141):  Menu_Flag,
--  Damage_Mask and the rest name some of the bits of the C value, and the
--  others are padding, which Ada needn't set.  A value whose padding holds
--  anything must reach FLTK as the bits it names and no others, or an item
--  added with Flag_Normal can turn into a pointer to a submenu.  The
--  padding is filled here by an unchecked conversion, as stale stack
--  memory filled it in ova_cg_ada.


with

    Ada.Unchecked_Conversion,
    Checks,
    Interfaces.C,
    FLTK.Menu_Items,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide;

use

    Checks;


procedure Test_Flag_Padding is

    package Chs renames FLTK.Widgets.Menus.Choices;
    package Sys renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;

    use type FLTK.Menu_Flag;
    use type FLTK.Damage_Mask;
    use type FLTK.Callback_Flag;

    function To_Flag is new Ada.Unchecked_Conversion (Interfaces.C.unsigned, FLTK.Menu_Flag);
    function To_Damage is new Ada.Unchecked_Conversion
        (Interfaces.C.unsigned_char, FLTK.Damage_Mask);

    --  Bit 5 is FL_SUBMENU_POINTER, which Menu_Flag leaves out; bits 8 on
    --  are FL_MENU_HORIZONTAL, FL_MENU_CHATTY and nothing.
    Dirty : constant FLTK.Menu_Flag := To_Flag (16#FFFF_FF20#);

    --  Bit 6, which Damage_Mask leaves out.
    Dirty_Damage : constant FLTK.Damage_Mask := To_Damage (16#40#);

    Menu : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Bar  : Sys.System_Menu_Bar := Sys.Forge.Create (0, 0, 100, 25);
    Box  : FLTK.Widgets.Boxes.Box := FLTK.Widgets.Boxes.Forge.Create (0, 0, 10, 10);

begin

    Check (Dirty = FLTK.Flag_Normal and Dirty_Damage = FLTK.Damage_None,
        "the dirty values name no bits");

    Menu.Add ("plain", Flags => Dirty);
    Menu.Add ("value", Flags => Dirty + FLTK.Flag_Value);
    Check (not Menu.Item (1).Is_Submenu and not Menu.Item (2).Is_Submenu,
        "an item added with padding set is no submenu");
    Check (Menu.Get_Flags (2) = FLTK.Flag_Value, "and has the flags it was given");

    Menu.Set_Flags (1, Dirty);
    Check (not Menu.Item (1).Is_Submenu, "nor after the menu's Set_Flags");

    declare
        Item : FLTK.Menu_Items.Menu_Item := FLTK.Menu_Items.Forge.Create ("alone", Flags => Dirty);
    begin
        Check (not Item.Is_Submenu, "nor is an item made alone");
        Item.Set_Flags (Dirty);
        Check (not Item.Is_Submenu, "nor after Set_Flags");
    end;

    Bar.Add ("File/Open", Flags => Dirty);
    Check (not Bar.Item (2).Is_Submenu, "nor an item in a System_Menu_Bar");

    Box.Clear_Damage;
    Box.Set_Damage (Dirty_Damage);
    Check (not Box.Is_Damaged, "damage with padding set is none");
    Box.Clear_Damage (Dirty_Damage);
    Check (not Box.Is_Damaged, "nor is it after Clear_Damage");

    Summary;

end Test_Flag_Padding;
