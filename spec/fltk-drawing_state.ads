

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  A log of the drawing state FLTKAda's calls push and pop: clips,
--  matrices, current surfaces, begun offscreens, started pages and
--  OpenGL.Start.  FLTK keeps drawing with that state after a hook
--  returns, so a hook whose code raised between a push and its pop would
--  leave FLTK drawing clipped, transformed, into the wrong surface or at
--  the wrong scale.  Each hook notes the log's length as it starts, and on
--  an exception undoes, latest first, every push recorded since then that
--  is still recorded (FLTK.Hook_Exceptions.Save).
--
--  The log holds at most Capacity entries.  A push made while it is full
--  is not recorded, and so is not undone.


with

    System;


private package FLTK.Drawing_State is


    --  Undoes the push recorded with Item, by calling the pop that goes
    --  with it.  That pop must Forget the entry.
    type Undo_Action is access procedure
           (Item : in System.Address);


    subtype Mark is Natural;


    Capacity : constant := 256;


    --  Records a push, to be undone by Undo (Item).
    procedure Remember
           (Undo : in Undo_Action;
            Item : in System.Address := System.Null_Address);

    --  Forgets the latest entry recorded with Undo, if there is one.
    procedure Forget
           (Undo : in Undo_Action);

    --  Forgets the latest entry recorded with Undo and Item, if there is one.
    procedure Forget
           (Undo : in Undo_Action;
            Item : in System.Address);

    --  Forgets every entry recorded with Item, which is being finalized.
    procedure Forget_All
           (Item : in System.Address);

    --  The log's length now.
    function Current
        return Mark;

    --  Undoes, latest first, every entry recorded after Level.  An exception
    --  an undo raises is dropped.
    procedure Undo_To
           (Level : in Mark);


end FLTK.Drawing_State;

