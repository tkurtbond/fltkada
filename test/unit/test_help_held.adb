

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 89: Fl_Help_View::handle keeps the link a push
--  was on till the release, which follows it (Fl_Help_View.cxx:3150, 3190,
--  3218-3220).  Setting the page frees the links (:2554-2560), so a page
--  set with the mouse held on a link had the release follow it from freed
--  memory.  A resize lays the page out again, and the link held may be
--  another by then.  A link held while the page changes is not followed.
--  Run from test/unit, which holds the pages.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Widgets.Groups.Help_Views,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Help_Held is

    package Prb renames FLTK.Probe;
    package HV  renames FLTK.Widgets.Groups.Help_Views;
    package Win renames FLTK.Widgets.Groups.Windows;

    Page_Asks : Natural := 0;

    function Link
           (Item : in out HV.Help_View'Class;
            URI  : in     String)
        return String
    is
        pragma Unreferenced (Item);
    begin
        Page_Asks := Page_Asks + 1;
        return URI;
    end Link;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Help_Held");

    View : HV.Help_View := HV.Forge.Create (Window, 0, 0, 300, 200);

    Linked : constant String := "<p><a href=""help_two.html"">Two</a></p><p>And more.</p>";

    Ignore : Boolean;

    procedure Show_Linked is
    begin
        View.Set_Content (Linked);
        Ignore := Prb.Capture (View);
        Prb.Release;
    end Show_Linked;

    --  Where a click follows the link, or 0.
    function Link_Y
        return Natural
    is
        Before : constant Natural := Page_Asks;
        Y      : Natural := 3;
    begin
        while Y < 40 loop
            Ignore := Prb.Mouse (Window, Push, 15, Y);
            Ignore := Prb.Mouse (Window, Release, 15, Y, Clicks => 1);
            if Page_Asks /= Before then
                return Y;
            end if;
            Y := Y + 3;
        end loop;
        return 0;
    end Link_Y;

    Y : Natural;

begin

    View.Set_Link_Callback (Link'Unrestricted_Access);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;

    Show_Linked;
    Y := Link_Y;
    Check (Y /= 0 and then View.Document_Title = "Help Two", "a click follows a link");

    --  pofltk 89: the page set while the link is held.
    Show_Linked;
    declare
        Before : constant Natural := Page_Asks;
    begin
        Ignore := Prb.Mouse (Window, Push, 15, Y);
        View.Set_Content ("<p>Replaced, and a good deal longer than it was before it was"
            & " replaced, so the links it had are gone</p>");
        Ignore := Prb.Capture (View);
        Prb.Release;
        Ignore := Prb.Mouse (Window, Release, 15, Y, Clicks => 1);
        Check (Page_Asks = Before and then View.Document_Title /= "Help Two",
            "a link held while the page is set is not followed:"
            & Natural'Image (Page_Asks - Before) & " """ & View.Document_Title & """");
    end;

    --  A page loaded while the link is held.
    Show_Linked;
    declare
        Before : Natural;
    begin
        Ignore := Prb.Mouse (Window, Push, 15, Y);
        View.Load ("help_one.html");
        Before := Page_Asks;
        Ignore := Prb.Mouse (Window, Release, 15, Y, Clicks => 1);
        Check (Page_Asks = Before and then View.Document_Title = "Help One",
            "a link held while a page loads is not followed: """
            & View.Document_Title & """");
    end;

    --  A resize while the link is held.
    Show_Linked;
    declare
        Before : constant Natural := Page_Asks;
    begin
        Ignore := Prb.Mouse (Window, Push, 15, Y);
        View.Resize (0, 0, 200, 200);
        Ignore := Prb.Capture (View);
        Prb.Release;
        Ignore := Prb.Mouse (Window, Release, 15, Y, Clicks => 1);
        Check (Page_Asks = Before, "a link held while the view is resized is not followed:"
            & Natural'Image (Page_Asks - Before));
        View.Resize (0, 0, 300, 200);
    end;

    --  A click after is followed again.
    Show_Linked;
    Check (Link_Y = Y and then View.Document_Title = "Help Two", "a later click follows a link");

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Help_Held;
