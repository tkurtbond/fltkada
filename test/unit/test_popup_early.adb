

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 3: a menu popped up just after its window's Show, before
--  the window is on the screen (pofltk 28).  Under Wayland FLTK 1.4.5 makes
--  the pop-up against a parent surface not yet configured, and the
--  compositor ends the program: "Fatal error no 1 in Wayland protocol".
--  Each popup here comes straight after Show, on a window of its own.  On
--  X11 a timeout closes the menu; on Wayland it closes at once (pofltk 29).


with

    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Buttons;

use

    Checks;


procedure Test_Popup_Early is

    package Win renames FLTK.Widgets.Groups.Windows;
    package Mnu renames FLTK.Widgets.Menus;
    package Mnb renames FLTK.Widgets.Menus.Menu_Buttons;

    First  : aliased Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Popup_Early 1");
    Button : Mnb.Menu_Button := Mnb.Forge.Create (First, 100, 60, 80, 30, "Menu");

    Second : aliased Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Popup_Early 2");
    Menu   : Mnb.Menu_Button := Mnb.Forge.Create (Second, 100, 60, 80, 30, "Menu");

    Target : access Win.Window := First'Access;

    --  Prb.Grabbed: the grab is the menu's own window (test_exceptions.adb).
    procedure Close_Menu is
        Ignore : Boolean;
    begin
        if FLTK.Probe.Grabbed then
            Ignore := FLTK.Probe.Handle_Key (Target.all, FLTK.Keydown, FLTK.Escape_Key);
        end if;
    end Close_Menu;

    Picked : Mnu.Extended_Index;

begin

    Button.Add (Text => "one", Action => null);
    Button.Add (Text => "two", Action => null);
    Menu.Add (Text => "one", Action => null);
    Menu.Add (Text => "two", Action => null);

    First.Show;
    FLTK.Static.Add_Timeout (0.3, Close_Menu'Unrestricted_Access);
    Picked := Button.Popup;
    Check (Picked = Mnu.No_Index, "Menu_Button Popup straight after Show picks nothing:"
        & Mnu.Extended_Index'Image (Picked));

    Target := Second'Access;
    Second.Show;
    FLTK.Static.Add_Timeout (0.3, Close_Menu'Unrestricted_Access);
    Picked := Menu.Popup (100, 100);
    Check (Picked = Mnu.No_Index, "Menu Popup straight after Show picks nothing:"
        & Mnu.Extended_Index'Image (Picked));

    Summary;

end Test_Popup_Early;


