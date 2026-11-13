


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 44: FLTK.Events.Get_Grab, Get_Pushed, Get_Below_Mouse
--  and Get_Focus, for a window or widget FLTK made itself.  With no Ada
--  object to give, they gave null in a release build and raised
--  Internal_FLTK_Error in a debug build, and a program couldn't tell an
--  open pop-up menu from no grab at all.  Now they give null in any build,
--  and Has_Grab, Has_Pushed, Has_Below_Mouse and Has_Focus say whether
--  there is one, whoever made it.
--
--  FLTK.Probe makes the foreign window and button.  A pop-up menu, whose
--  window FLTK makes, is the real case; it is checked on X11 only, since
--  on Wayland a pop-up menu closes at once without a seat.


with

    Ada.Exceptions,
    Checks,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Buttons;

use

    Checks,
    FLTK;


procedure Test_Foreign_Widgets is

    package Evt renames FLTK.Events;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Mnb renames FLTK.Widgets.Menus.Menu_Buttons;

    use type Prb.Foreign_Kind;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Foreign_Widgets");
    Menu   : Mnb.Menu_Button := Mnb.Forge.Create (Window, 100, 60, 80, 30, "Menu");

    --  Whether the getter for What gives null, and doesn't raise.
    function Gives_Null
           (What : in Prb.Foreign_Kind)
        return Boolean is
    begin
        case What is
            when Prb.Foreign_Grab        => return Evt.Get_Grab = null;
            when Prb.Foreign_Pushed      => return Evt.Get_Pushed = null;
            when Prb.Foreign_Below_Mouse => return Evt.Get_Below_Mouse = null;
            when Prb.Foreign_Focus       => return Evt.Get_Focus = null;
        end case;
    end Gives_Null;

    function Has
           (What : in Prb.Foreign_Kind)
        return Boolean is
    begin
        case What is
            when Prb.Foreign_Grab        => return Evt.Has_Grab;
            when Prb.Foreign_Pushed      => return Evt.Has_Pushed;
            when Prb.Foreign_Below_Mouse => return Evt.Has_Below_Mouse;
            when Prb.Foreign_Focus       => return Evt.Has_Focus;
        end case;
    end Has;

    procedure Foreign
           (What : in Prb.Foreign_Kind)
    is
        Name : constant String := Prb.Foreign_Kind'Image (What);
    begin
        Prb.Release_Foreign;
        Check (not Has (What) and Gives_Null (What), Name & ": none to start with");
        Prb.Take_Foreign (What);
        Check (Has (What), Name & ": Has_ says there is one");
        begin
            Check (Gives_Null (What), Name & ": Get_ gives null for FLTK's own");
        exception
            when Occurrence : others =>
                Check (False, Name & ": Get_ gives null for FLTK's own, not " &
                    Ada.Exceptions.Exception_Information (Occurrence));
        end;
        Prb.Release_Foreign;
        Check (not Has (What), Name & ": and none once released");
    end Foreign;

    --  Seen while the pop-up menu is up.
    Menu_Has_Grab   : Boolean := False;
    Menu_Grab_Null  : Boolean := False;
    Menu_Grab_Error : Boolean := False;

    procedure Look_At_Menu is
        Ignore : Boolean;
    begin
        Menu_Has_Grab := Evt.Has_Grab;
        begin
            Menu_Grab_Null := Evt.Get_Grab = null;
        exception
            when others =>
                Menu_Grab_Error := True;
        end;
        if Prb.Grabbed then
            Ignore := Prb.Handle_Key (Window, Keydown, Escape_Key);
        end if;
    end Look_At_Menu;

begin

    Menu.Add (Text => "one", Action => null);
    Menu.Add (Text => "two", Action => null);
    Window.Show;
    Window.Wait_For_Expose;

    --  An Ada window's grab: Get_Grab gives it.
    Evt.Set_Grab (Window);
    Check (Evt.Has_Grab and then Evt.Get_Grab /= null
            and then Evt.Get_Grab.Get_Label = "Test_Foreign_Widgets",
        "an Ada window's grab: Has_Grab, and Get_Grab gives the window");
    Evt.Release_Grab;
    Check (not Evt.Has_Grab and Evt.Get_Grab = null, "no grab once released");

    Prb.Show_Foreign;
    for What in Prb.Foreign_Kind loop
        Foreign (What);
    end loop;
    Prb.Delete_Foreign;

    if Prb.On_Wayland then
        Skip ("a pop-up menu's grab: menus close at once on Wayland");
    else
        FLTK.Static.Add_Timeout (0.2, Look_At_Menu'Unrestricted_Access);
        declare
            Ignore : constant FLTK.Widgets.Menus.Extended_Index := Menu.Popup;
        begin
            null;
        end;
        Check (Menu_Has_Grab, "a pop-up menu up: Has_Grab");
        Check (Menu_Grab_Null and not Menu_Grab_Error,
            "and Get_Grab gives null for its window, without raising");
    end if;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Foreign_Widgets;
