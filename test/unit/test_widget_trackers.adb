--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK.Widget_Trackers (Fl_Widget_Tracker): whether a widget still exists.
--  Mirrors pofltk's TestTracker.  A widget stops existing when its Ada
--  object is freed, even inside a callback, where FLTK deletes the C++
--  widget only later.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widget_Trackers,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    System;

use type

    System.Address;

use

    Checks,
    FLTK;


procedure Test_Widget_Trackers is

    package Trk renames FLTK.Widget_Trackers;
    package Prb renames FLTK.Probe;
    package Wd  renames FLTK.Widgets;
    package Bxs renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Box_Access is access Bxs.Box;
    type Group_Access is access Grp.Group;
    type Button_Access is access Btn.Button;

    procedure Free is new Ada.Unchecked_Deallocation (Bxs.Box, Box_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Grp.Group, Group_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Btn.Button, Button_Access);

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 200, "Test_Widget_Trackers");

    Tracker : Trk.Widget_Tracker := Trk.Forge.Create;

    function Is_Item
           (Item : in Wd.Widget'Class)
        return Boolean is
    begin
        return Tracker.Item /= null and then Tracker.Item.all'Address = Item'Address;
    end Is_Item;

    --  A button that frees itself in its callback, and asks the tracker
    --  just after.
    Selfish        : Button_Access;
    Exists_After   : Boolean := True;
    Callback_Ran   : Boolean := False;

    procedure Free_Self
           (Item : in out Wd.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Callback_Ran := True;
        Free (Selfish);
        Exists_After := Tracker.Exists;
    end Free_Self;

    --  A box freed by a timeout, inside Wait, where FLTK deletes the C++
    --  widget only after the timeout returns.
    Timed           : Box_Access;
    Timed_Tracker   : Trk.Widget_Tracker := Trk.Forge.Create;
    Timeout_Ran     : Boolean := False;
    Exists_In_Timer : Boolean := True;

    procedure Free_Timed is
    begin
        Timeout_Ran := True;
        Free (Timed);
        Exists_In_Timer := Timed_Tracker.Exists;
    end Free_Timed;

    procedure Track_Blank is
        Blank : Bxs.Box;
    begin
        Tracker.Track (Blank);
    end Track_Blank;

    --  Finalizing it used to read through a null pointer (FLTKAda-BUGS.md 68).
    procedure Leave_Blank is
        Blank : Bxs.Box;
        pragma Unreferenced (Blank);
    begin
        null;
    end Leave_Blank;

    B, Child : Box_Access;
    G        : Group_Access;
    Waited   : Long_Float;
    pragma Unreferenced (Waited);

begin

    Check (not Tracker.Exists and Tracker.Deleted and Tracker.Item = null,
        "a tracker tracking nothing");

    Window.End_Current;
    B := new Bxs.Box'(Bxs.Forge.Create (Window, 0, 0, 10, 10));
    Tracker.Track (B.all);
    Check (Tracker.Exists and not Tracker.Deleted and Is_Item (B.all), "a widget exists");
    Free (B);
    Check (not Tracker.Exists and Tracker.Deleted and Tracker.Item = null,
        "and doesn't once freed");

    G := new Grp.Group'(Grp.Forge.Create (Window, 0, 20, 100, 100));
    Child := new Bxs.Box'(Bxs.Forge.Create (G.all, 0, 20, 10, 10));
    Tracker.Track (Child.all);
    Free (G);
    Check (Tracker.Exists and Is_Item (Child.all),
        "a child with its own Ada object outlives its group");
    Free (Child);
    Check (Tracker.Deleted, "until it is freed");

    declare
        Local : Bxs.Box := Bxs.Forge.Create (Window, 0, 0, 10, 10);
    begin
        Tracker.Track (Local);
        Check (Tracker.Exists, "a local widget exists");
    end;
    Check (Tracker.Deleted, "and doesn't once out of scope");

    Tracker.Track (Window);
    Check (Tracker.Exists and Is_Item (Window), "a tracker can move to another widget");

    declare
        Other : constant Trk.Widget_Tracker := Trk.Forge.Create (Window);
    begin
        Check (Other.Exists and Other.Item.all'Address = Window'Address,
            "Forge.Create tracks its widget");
    end;
    Check (Tracker.Exists, "a tracker gone leaves the others");

    No_Raise (Leave_Blank'Unrestricted_Access, "a widget with no FLTK widget finalizes");
    Raises (Track_Blank'Unrestricted_Access, Program_Error'Identity,
        "tracking a widget with no FLTK widget raises");

    --  The case a tracker is for: a callback that frees its own widget.

    Selfish := new Btn.Button'(Btn.Forge.Create (Window, 0, 150, 50, 25, "go"));
    Selfish.Set_Callback (Free_Self'Unrestricted_Access);
    Tracker.Track (Selfish.all);
    Window.Show;
    while not Window.Is_Shown loop
        Waited := FLTK.Wait (0.02);
    end loop;
    if Prb.Mouse (Window, Push, 10, 160) then
        null;
    end if;
    if Prb.Mouse (Window, Release, 10, 160) then
        null;
    end if;
    Check (Callback_Ran, "a click runs the callback");
    Check (not Exists_After and Tracker.Deleted,
        "a widget freed in its own callback is deleted at once");

    Timed := new Bxs.Box'(Bxs.Forge.Create (Window, 100, 0, 10, 10));
    Timed_Tracker.Track (Timed.all);
    FLTK.Static.Add_Timeout (0.0, Free_Timed'Unrestricted_Access);
    for I in 1 .. 100 loop
        exit when Timeout_Ran;
        Waited := FLTK.Wait (0.01);
    end loop;
    Check (Timeout_Ran and not Exists_In_Timer,
        "a widget freed inside Wait is deleted at once, before FLTK deletes it");
    for I in 1 .. 5 loop
        Waited := FLTK.Wait (0.01);
    end loop;
    Check (Timed_Tracker.Deleted, "and stays deleted once FLTK has");

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, "unexpected " & Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Widget_Trackers;
