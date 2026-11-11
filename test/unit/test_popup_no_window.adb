


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 150, after pofltk's test/HaltPopup.Mod:  a menu in no window,
--  popped up with no window shown, has nothing to pop up over.  FLTK then
--  calls screen_num() through a null window (Fl_Menu.cxx:1000).  Popup,
--  Pulldown and a Menu_Button's Popup raise Program_Error instead.
--  test_menu pops up a menu in a window that is shown.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Menus.Menu_Buttons;

use

    Checks;


procedure Test_Popup_No_Window is

    package Mnu renames FLTK.Widgets.Menus;
    package MBt renames FLTK.Widgets.Menus.Menu_Buttons;

    PE : constant Ada.Exceptions.Exception_Id := Program_Error'Identity;

    Button : MBt.Menu_Button := MBt.Forge.Create (0, 0, 100, 25, "Pop");
    Picked : Mnu.Extended_Index with Unreferenced;

    procedure Button_Popup is
    begin
        Picked := Button.Popup;
    end Button_Popup;

    procedure Menu_Popup is
    begin
        Picked := Mnu.Menu (Button).Popup (10, 10);
    end Menu_Popup;

    procedure Menu_Pulldown is
    begin
        Picked := Mnu.Menu (Button).Pulldown (10, 10, 100, 25);
    end Menu_Pulldown;

begin

    Button.Add ("One");
    Button.Add ("Two");

    Raises (Button_Popup'Access, PE,
        "Menu_Button Popup in no window, none shown, raises Program_Error");
    Raises (Menu_Popup'Access, PE,
        "Menu Popup in no window, none shown, raises Program_Error");
    Raises (Menu_Pulldown'Access, PE,
        "Menu Pulldown in no window, none shown, raises Program_Error");

    Summary;

end Test_Popup_No_Window;


