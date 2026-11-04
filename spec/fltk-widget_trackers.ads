--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    FLTK.Widgets;


package FLTK.Widget_Trackers is


    --  Says whether a widget still exists, across a call that may free it:
    --  a callback that may free its own widget, say.  A widget stops
    --  existing when its Ada object is finalized, even inside a callback,
    --  where FLTK deletes the C++ widget only later; and when FLTK deletes
    --  the C++ widget itself, as a group does a child with no Ada object.
    type Widget_Tracker is new Wrapper with private;




    package Forge is

        --  A tracker tracking nothing.
        function Create
            return Widget_Tracker;

        function Create
               (Item : in out FLTK.Widgets.Widget'Class)
            return Widget_Tracker;

    end Forge;




    --  Tracks Item instead of whatever was tracked before.  Raises
    --  Program_Error if Item has no FLTK widget.
    procedure Track
           (This : in out Widget_Tracker;
            Item : in out FLTK.Widgets.Widget'Class);

    function Exists
           (This : in Widget_Tracker)
        return Boolean;

    function Deleted
           (This : in Widget_Tracker)
        return Boolean;

    --  The widget, or null if it was deleted or none is tracked.
    function Item
           (This : in Widget_Tracker)
        return access FLTK.Widgets.Widget'Class;


private


    type Widget_Tracker is new Wrapper with record
        Watched : access FLTK.Widgets.Widget'Class;
    end record;

    overriding procedure Finalize
           (This : in out Widget_Tracker);


    pragma Inline (Deleted);


end FLTK.Widget_Trackers;

