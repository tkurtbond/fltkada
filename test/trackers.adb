


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A callback that may free its own widget, after pofltk's
--  examples/Trackers.Mod.
--
--  Each click takes one from the count, and the last click frees the
--  button.  Inside a callback FLTK deletes the C++ widget only when events
--  are next handled:  here, by Check in the same callback.  The callback
--  uses a tracker to see whether its widget is still there.


with

    Ada.Strings.Fixed,
    Ada.Unchecked_Deallocation,
    FLTK.Widget_Trackers,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;


function Trackers
    return Integer
is


    package Trk renames FLTK.Widget_Trackers;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Button_Access is access Btn.Button;

    procedure Free is new Ada.Unchecked_Deallocation (Btn.Button, Button_Access);


    Window : Win.Window := Win.Forge.Create (200, 120, "Trackers");
    Button : Button_Access :=
        new Btn.Button'(Btn.Forge.Create (Window, 40, 20, 120, 30, "count down"));
    Left   : Bx.Box := Bx.Forge.Create (Window, 40, 60, 120, 30, "3");
    Count  : Natural := 3;


    procedure Count_Down
           (Item : in out Wdg.Widget'Class)
    is
        Tracker : constant Trk.Widget_Tracker := Trk.Forge.Create (Item);
    begin
        Count := Count - 1;
        if Count = 0 then
            --  Item is the button, and is gone from here on.
            Free (Button);
        end if;
        FLTK.Check;
        if Tracker.Exists then
            Item.Redraw;
        end if;
        Left.Set_Label (Ada.Strings.Fixed.Trim (Natural'Image (Count), Ada.Strings.Left));
    end Count_Down;


begin


    Button.Set_Callback (Count_Down'Unrestricted_Access);
    Window.Show;

    return FLTK.Run;


end Trackers;


