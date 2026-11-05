

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Menus.Choices.Schemes is


    --  A Choice preloaded with the available FLTK schemes, which switches the
    --  active scheme when an item is picked. Setting a callback replaces the
    --  built-in one that does the switching, just as in FLTK.
    type Scheme_Choice is new Choice with private;

    type Scheme_Choice_Reference (Data : not null access Scheme_Choice'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Scheme_Choice;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Scheme_Choice;

    end Forge;




    --  Selection  --

    --  Sets the chosen item to match the currently active scheme
    --  FLTK calls its own Init_Value from Handle, on a show, a push or the
    --  mouse coming in, so an Ada override of Init_Value is called only by
    --  Ada code; override Handle to change what those events do.
    procedure Init_Value
           (This : in out Scheme_Choice);

    --  Switches to the scheme chosen, as FLTK's own callback does, so that
    --  a callback set in its place can still switch.  With none chosen, it
    --  does nothing, where FLTK's callback reads before the menu
    --  (FLTK-issues.md F28).
    procedure Switch_Scheme
           (This : in out Scheme_Choice);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Scheme_Choice);

    function Handle
           (This  : in out Scheme_Choice;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Scheme_Choice is new Choice with null record;

    overriding procedure Initialize
           (This : in out Scheme_Choice);

    overriding procedure Finalize
           (This : in out Scheme_Choice);

    procedure Extra_Init
           (This       : in out Scheme_Choice;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Scheme_Choice)
    with Inline;


    pragma Inline (Init_Value);
    pragma Inline (Switch_Scheme);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Menus.Choices.Schemes;


