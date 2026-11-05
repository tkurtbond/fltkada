


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  PLAN.md, Phase 13: Window_Of and Current_Window give an Ada object for
--  every GLUT window, FLTK's glut_window among them, where before a window
--  from FLTK.GLUT.Create_Window was only a number.  The object is Forge's
--  for a window Forge made, and otherwise one made the first time it is
--  asked for and the same after.  A window that has gone has none.
--  Valgrind checks that the ones made are freed.


with

    Checks,
    FLTK.GLUT,
    FLTK.Widgets.Groups.Windows.OpenGL.GLUT,
    System;

use

    Checks;

use type

    FLTK.GLUT.Menu_Number,
    FLTK.GLUT.Window_Number,
    System.Address;


procedure Test_GLUT_Window_Of is

    package Glt renames FLTK.GLUT;
    package GW  renames FLTK.Widgets.Groups.Windows.OpenGL.GLUT;

    procedure Pump is
    begin
        for N in 1 .. 5 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    procedure Chosen
           (Value : in Integer) is
    begin
        null;
    end Chosen;

    function Place_Of
           (Number : in Glt.Valid_Window_Number)
        return System.Address is (GW.Window_Of (Number).Data.all'Address);

    First, Sub, Second : Glt.Valid_Window_Number;
    Menu : Glt.Valid_Menu_Number;

    procedure Current is
        Ignore : constant System.Address := GW.Current_Window.Data.all'Address;
    begin
        null;
    end Current;

    procedure Of_First is
        Ignore : constant System.Address := Place_Of (First);
    begin
        null;
    end Of_First;

    procedure Of_Sub is
        Ignore : constant System.Address := Place_Of (Sub);
    begin
        null;
    end Of_Sub;

    procedure Of_Unmade is
        Ignore : constant System.Address := Place_Of (31);
    begin
        null;
    end Of_Unmade;

begin

    Glt.Init;
    Raises (Current'Unrestricted_Access, Constraint_Error'Identity,
        "Current_Window with no GLUT window raises Constraint_Error");
    Raises (Of_Unmade'Unrestricted_Access, Constraint_Error'Identity,
        "and Window_Of a number never made");

    --  A window FLTK.GLUT made.
    First := Glt.Create_Window ("first");
    declare
        W : GW.Glut_Window'Class renames GW.Window_Of (First).Data.all;
    begin
        Check (W.Get_Number = First,
            "Window_Of gives the window:" & First'Image & W.Get_Number'Image);
        Check (W.Get_Label = "first", "with its title: " & W.Get_Label);
        Check (Place_Of (First) = W'Address, "the same object each time");
        Check (GW.Current_Window.Data.all'Address = W'Address, "which Current_Window gives too");
        W.Set_Label ("renamed");
        Check (W.Get_Label = "renamed", "and which can change it");
        --  Its copy of an icon label is the wrapper's, to be let go
        --  without following the pointer once the window has gone.
        W.Set_Icon_Label ("first's icon");
        Check (W.Get_Icon_Label = "first's icon", "and give it an icon label");

        Menu := Glt.Create_Menu (Chosen'Unrestricted_Access);
        Glt.Add_Menu_Entry ("one", 1);
        Glt.Attach_Menu (Glt.Right);
        Check (W.Get_Menu (Glt.Right) = Menu, "its menu is GLUT's (glut_menu):" &
            W.Get_Menu (Glt.Right)'Image & Menu'Image);
    end;

    --  A sub-window, in it.
    Sub := Glt.Create_Sub_Window (First, 10, 10, 50, 50);
    Check (GW.Window_Of (Sub).Get_Number = Sub, "Window_Of a sub-window");
    Check (GW.Window_Of (Sub).Parent /= null
            and then GW.Window_Of (Sub).Parent.all'Address = Place_Of (First),
        "whose parent is its window's object");
    GW.Window_Of (Sub).Set_Icon_Label ("sub's icon");

    --  A window Forge made.
    declare
        Made : GW.Glut_Window := GW.Forge.Create (0, 0, 100, 100, "made");
        Number : constant Glt.Valid_Window_Number := Made.Get_Number;
    begin
        Check (Place_Of (Number) = Made'Address, "Window_Of a Forge window is its object");
        Glt.Set_Window (Number);
        Check (GW.Current_Window.Data.all'Address = Made'Address, "and so is Current_Window");
        Glt.Set_Window (First);
    end;

    --  Gone.
    Glt.Show_Window;
    Pump;
    Glt.Destroy_Window (First);
    Raises (Of_First'Unrestricted_Access, Constraint_Error'Identity,
        "Window_Of a destroyed window raises Constraint_Error");
    Raises (Of_Sub'Unrestricted_Access, Constraint_Error'Identity,
        "and of a sub-window in it");
    Pump;
    Raises (Of_First'Unrestricted_Access, Constraint_Error'Identity, "and after it has gone");

    Second := Glt.Create_Window ("second");
    Check (Second = First or Second = Sub, "a number is reused:" & Second'Image);
    Check (GW.Window_Of (Second).Get_Label = "second",
        "and the new window's object is its own: " & GW.Window_Of (Second).Get_Label);
    Check (GW.Window_Of (Second).Get_Number = Second, "with its number");
    Glt.Destroy_Window (Second);
    Pump;

    Summary;

end Test_GLUT_Window_Of;
