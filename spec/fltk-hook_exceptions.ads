


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


with

    Ada.Exceptions;


private package FLTK.Hook_Exceptions is


    --  Keeps Occurrence, unless an exception is kept already.
    procedure Save
           (Occurrence : in Ada.Exceptions.Exception_Occurrence);

    --  Keeps a new occurrence of Id, with Message, unless an exception is
    --  kept already.
    procedure Save_New
           (Id      : in Ada.Exceptions.Exception_Id;
            Message : in String);

    --  If an exception is kept, forgets it and raises it.
    procedure Reraise;


end FLTK.Hook_Exceptions;


