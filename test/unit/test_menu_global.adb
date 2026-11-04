


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 27: Fl_Menu_::global keeps the menu in a
--  static pointer that nothing clears, and its handler uses it for every
--  shortcut no window takes (Fl_Menu_global.cxx:23-28).  A global menu
--  finalized, then its shortcut typed, reads the freed menu.


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Bars;

use

    Checks,
    FLTK;


procedure Test_Menu_Global is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Bar renames FLTK.Widgets.Menus.Menu_Bars;

    Picks : Natural := 0;

    procedure Count
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Picks := Picks + 1;
    end Count;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Menu_Global");

    Box : constant FLTK.Widgets.Boxes.Box :=
        FLTK.Widgets.Boxes.Forge.Create (Window, 10, 10, 100, 25, "box");

    function Type_Key
           (Key : in Character)
        return Boolean is
    begin
        return Prb.Handle_Key (Window, Shortcut, Press (Key), Mod_Ctrl);
    end Type_Key;

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;

    --  A global menu in no window: its shortcut works in this one.
    declare
        Menu : Bar.Menu_Bar := Bar.Forge.Create (0, 0, 100, 25);
    begin
        Menu.Add ("first", Count'Unrestricted_Access, Mod_Ctrl + 'g');
        Menu.Make_Global;
        Check (Type_Key ('g') and then Picks = 1, "the global menu's shortcut is used");
    end;

    --  It is gone, so its shortcut does nothing.
    Check (not Type_Key ('g'), "a finalized global menu's shortcut is not handled");
    Check (Picks = 1, "a finalized global menu's item is not picked");

    --  A second global menu replaces the first, which then goes first.
    declare
        Second : Bar.Menu_Bar := Bar.Forge.Create (0, 0, 100, 25);
    begin
        Second.Add ("second", Count'Unrestricted_Access, Mod_Ctrl + 'h');
        declare
            Third : Bar.Menu_Bar := Bar.Forge.Create (0, 0, 100, 25);
        begin
            Third.Add ("third", Count'Unrestricted_Access, Mod_Ctrl + 'j');
            Third.Make_Global;
            Second.Make_Global;
        end;
        Check (Type_Key ('h') and then Picks = 2,
            "the global menu set last still works after the one it replaced goes");
        Check (not Type_Key ('j'), "the replaced menu's shortcut is not handled");
    end;
    Check (not Type_Key ('h'), "the last global menu, finalized, is not used");

    Summary;

end Test_Menu_Global;


