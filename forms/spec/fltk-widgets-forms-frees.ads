

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Fl_Free:  a widget whose events, drawing and steps all go to one
--  function, Handle_Free, which a type derived from Free overrides.  It
--  comes from Forms, where a free object had a handler function and not a
--  class of its own.


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Forms.Frees is


    type Free is new Widget with private;

    type Free_Reference (Data : not null access Free'Class) is limited null record
        with Implicit_Dereference => Data;

    --  A sleeping free is inactive to start with.  An input free, and an
    --  all free, can take the focus.  A continuous free, and an all free,
    --  get a step every hundredth of a second.
    type Free_Kind is (Normal_Free, Sleeping_Free, Input_Free, Continuous_Free, All_Free);

    --  What Handle_Free is called for: an event, a Draw or a step.
    type Free_Event_Kind is (FLTK_Event, Draw_Event, Step_Event);




    package Forge is

        function Create
               (Kind       : in Free_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Free;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                Kind       : in     Free_Kind;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Free;

    end Forge;




    --  Handling  --

    --  Called with Kind FLTK_Event for each event Handle passes on, but a
    --  Shortcut, or a Focus to a free that isn't an input or all free; with
    --  Draw_Event to draw it; and with Step_Event for each step.  Event is
    --  the event, or No_Event for the other two.  X and Y are the event's,
    --  or 0 for the other two.  The key and the mouse button are
    --  FLTK.Events', not the char FLTK's Forms handler gets.  The result
    --  says whether to do the callback.  This one draws nothing and does no
    --  callback.
    function Handle_Free
           (This  : in out Free;
            Kind  : in     Free_Event_Kind;
            Event : in     Event_Kind;
            X, Y  : in     Integer)
        return Boolean;




    --  Drawing, Events  --

    --  Draw calls Handle_Free with Draw_Event.
    procedure Draw
           (This : in out Free);

    --  Handle calls Handle_Free with FLTK_Event, but for a Shortcut, and a
    --  Focus to a free that can't take it, and is handled but for those.
    function Handle
           (This  : in out Free;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    for Free_Kind use
       (Normal_Free     => 1,
        Sleeping_Free   => 2,
        Input_Free      => 3,
        Continuous_Free => 4,
        All_Free        => 5);


    type Free is new Widget with null record;

    overriding procedure Initialize
           (This : in out Free);

    overriding procedure Finalize
           (This : in out Free);

    procedure Extra_Init
           (This       : in out Free;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Free)
    with Inline;


    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Forms.Frees;


