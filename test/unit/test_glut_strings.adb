

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 37 (FLTKAda-BUGS.md): the strings GLUT keeps.  GLUT keeps a menu
--  item's text as given (i->text = label, glut_compatibility.cxx:350, 358,
--  367, 376) and a window's icon title (Fl_Window::label, Fl_Window.cxx:545),
--  and never frees them.  So FLTKAda keeps the copies, and frees each once
--  GLUT has let go of it: after the item is changed or removed, the menu
--  destroyed, the title replaced or the window destroyed.  This is checked by
--  valgrind: an FLTKAda leak, or a read of a freed text, fails vg-check.sh.
--  GLUT has no way to read a menu's texts back.


with

    Checks,
    FLTK.GLUT;

use

    Checks;

use type

    FLTK.GLUT.Menu_Number,
    FLTK.GLUT.Window_Number;


procedure Test_GLUT_Strings is

    package Glt renames FLTK.GLUT;

    Serial : Natural := 0;

    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

    procedure On_Menu
           (Value : in Integer) is
    begin
        pragma Unreferenced (Value);
    end On_Menu;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Sub, Main : Glt.Valid_Menu_Number;

    Window : Glt.Valid_Window_Number;

begin

    Glt.Init;

    Sub := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    Glt.Add_Menu_Entry (Fresh ("sub entry"), 1);

    Main := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    Glt.Add_Menu_Entry (Fresh ("entry"), 1);
    Glt.Add_Menu_Entry (Fresh ("entry"), 2);
    Glt.Add_Sub_Menu (Fresh ("submenu"), Sub);
    Glt.Add_Menu_Entry (Fresh ("entry"), 3);
    Glt.Change_To_Menu_Entry (1, Fresh ("changed entry"), 10);
    Glt.Change_To_Sub_Menu (2, Fresh ("changed submenu"), Sub);
    Glt.Change_To_Menu_Entry (2, Fresh ("changed back"), 20);
    Glt.Remove_Menu_Item (3);
    Glt.Add_Menu_Entry (Fresh ("after removal"), 4);
    Check (Glt.Get_Menu = Main, "the main menu is current");

    Window := Glt.Create_Window (Fresh ("window"));
    Glt.Set_Icon_Title (Fresh ("icon"));
    Glt.Set_Icon_Title (Fresh ("icon"));
    Glt.Set_Window (Window);
    Glt.Attach_Menu (Glt.Right);
    Glt.Show_Window;
    Pump (10);
    Glt.Set_Icon_Title (Fresh ("icon"));
    Pump (5);
    Check (Glt.Get_Window = Window, "the window is current");

    Glt.Destroy_Window (Window);
    Pump (5);
    Glt.Destroy_Menu (Main);
    Glt.Set_Menu (Sub);
    Glt.Change_To_Menu_Entry (1, Fresh ("changed sub entry"), 2);
    Glt.Destroy_Menu (Sub);
    Check (True, "the menu and window changes ran (checked by valgrind)");
    Summary;

end Test_GLUT_Strings;

