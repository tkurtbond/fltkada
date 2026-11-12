--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda bug 130: Callback_Flag had no FL_WHEN_CLOSED, so no child of a
--  Tabbed_Group could have a close button.  FLTK draws one at the left of
--  the tab of a child whose when () has FL_WHEN_CLOSED, and a click on
--  it calls that child's callback with FL_REASON_CLOSED instead of
--  selecting it (Fl_Tabs.cxx, handle and hit_close).  FLTK's test/tabs
--  removes the child in that callback.


with

    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Closable_Tab is

    package Grp renames FLTK.Widgets.Groups;
    package Prb renames FLTK.Probe;
    package Tab renames FLTK.Widgets.Groups.Tabbed;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (300, 200, "Closable");
    Tabs   : Tab.Tabbed_Group := Tab.Forge.Create (Window, 10, 10, 280, 180);
    One    : Grp.Group := Grp.Forge.Create (Tabs, 10, 35, 280, 155, "one");
    Two    : Grp.Group := Grp.Forge.Create (Tabs, 10, 35, 280, 155, "two");

    Calls  : Natural := 0;
    Reason : Callback_Reason := Reason_Unknown;

    procedure Close
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Calls  := Calls + 1;
        Reason := FLTK.Static.Get_Callback_Reason;
        if Reason = Reason_Closed then
            Tabs.Remove (Item);
        end if;
    end Close;

    procedure Click
           (X, Y : in Integer)
    is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Push, X, Y);
        Ignore := Prb.Mouse (Window, Release, X, Y);
    end Click;

    Ignore : Boolean;

begin

    Window.End_Current;
    Two.Hide;
    One.Set_When (When_Closed);
    One.Set_Callback (Close'Unrestricted_Access);
    Two.Set_Callback (Close'Unrestricted_Access);
    Check (One.Get_When = When_Closed, "Get_When gives back When_Closed");

    Window.Show;
    while not Window.Is_Shown loop
        Ignore := FLTK.Wait (0.02) = 0.0;
    end loop;

    --  The close button is the first 13 pixels of the tab,
    --  (labelsize + EXTRASPACE + EXTRAGAP) / 2.
    Click (15, 20);
    Check (Calls = 1, "a click on the close button calls the callback:" & Calls'Image);
    Check (Reason = Reason_Closed, "with the reason Reason_Closed: " & Reason_Name (Reason));
    Check (Tabs.Number_Of_Children = 1, "and the callback removed the tab");
    Check (Tabs.Child (1).Data.Get_Label = "two", "leaving the other");

    --  Two has no When_Closed: a click on the same place only selects it.
    Reason := Reason_Unknown;
    Click (15, 20);
    Check (Tabs.Number_Of_Children = 1, "a tab without When_Closed isn't closed");
    Check (Calls = 1, "its callback isn't called to close it:" & Calls'Image);

    Window.Hide;
    Summary;

end Test_Closable_Tab;
