


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  An Ada exception raised in a hook FLTK calls (a callback, an overridden
--  Draw or Handle, a timeout, ...) must not unwind through FLTK's frames:
--  FLTK keeps state across those calls that only a normal return restores
--  (PLAN.md N12, FLTK-issues.md F3).  So each hook catches every exception
--  and keeps it here, and returns normally.  Once control is back in Ada,
--  the binding raises the kept exception again: in Wait, Check, Run,
--  Do_Callback, Popup, the dialogs and the other calls that run hooks.
--
--  Only the first exception is kept.  Any raised before it is raised again
--  are dropped.
--
--  A hook also takes a Mark as it starts, and passes it to Save, which
--  first undoes the clips, matrices, current surfaces, offscreens, pages
--  and OpenGL.Start the hook's code pushed and didn't pop
--  (FLTK.Drawing_State).


with

    Ada.Exceptions,
    FLTK.Drawing_State;


private package FLTK.Hook_Exceptions is


    subtype Mark is FLTK.Drawing_State.Mark;

    --  The mark a hook takes as it starts.
    function Entry_Mark
        return Mark
    renames FLTK.Drawing_State.Current;

    --  Keeps Occurrence, unless an exception is kept already.
    procedure Save
           (Occurrence : in Ada.Exceptions.Exception_Occurrence);

    --  Undoes the drawing state pushed since Since, and keeps Occurrence,
    --  unless an exception is kept already.
    procedure Save
           (Occurrence : in Ada.Exceptions.Exception_Occurrence;
            Since      : in Mark);

    --  Keeps a new occurrence of Id, with Message, unless an exception is
    --  kept already.
    procedure Save_New
           (Id      : in Ada.Exceptions.Exception_Id;
            Message : in String);

    --  If an exception is kept, forgets it and raises it.
    procedure Reraise;


end FLTK.Hook_Exceptions;


