

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Offscreens: pictures drawn once, away from the screen, and copied to
--  where they are wanted, as fl_create_offscreen, fl_begin_offscreen,
--  fl_end_offscreen, fl_copy_offscreen, fl_rescale_offscreen and
--  fl_delete_offscreen do.  An Offscreen is built on an Fl_Image_Surface,
--  as those are, but is freed when it is finalized, and its use is checked:
--  FLTK's own functions keep no record of which offscreen is begun, and
--  crash or read freed memory when used out of order (PLAN.md, Phase 9).


private with

    Ada.Finalization,
    FLTK.Devices.Surface.Image;


package FLTK.Draw.Offscreens is


    type Offscreen is tagged limited private;




    package Forge is

        --  An offscreen of W by H in FLTK units, as many pixels as that
        --  takes on the screen.  Raises Constraint_Error if W or H is below 1,
        --  which FLTK crashes on.
        function Create
               (W, H : in Integer)
            return Offscreen;

    end Forge;




    --  Whether This was made by Forge.Create.  Everything else raises
    --  Program_Error for one that wasn't.
    function Is_Valid
           (This : in Offscreen)
        return Boolean;

    function Get_W
           (This : in Offscreen)
        return Integer;

    function Get_H
           (This : in Offscreen)
        return Integer;




    --  Drawing  --

    --  Drawing goes to This until End_Drawing, and then to where it went
    --  before.  Offscreens can be begun one inside another, and with
    --  FLTK.Devices.Surface.Push_Current, 16 deep in all.  Raises
    --  Program_Error if This is begun already.
    procedure Begin_Drawing
           (This : in out Offscreen);

    --  Raises Program_Error unless This is begun and is the surface drawn on
    --  now: the last begun, or pushed, and not ended.
    procedure End_Drawing
           (This : in out Offscreen);

    function Is_Drawing
           (This : in Offscreen)
        return Boolean;

    --  Begin_Drawing (Target) as it's declared, and End_Drawing as it's
    --  finalized, if Target is still begun.  An exception from End_Drawing
    --  there is dropped.
    type Drawing_Guard
           (Target : not null access Offscreen) is tagged limited private;




    --  Copying  --

    --  Copies the W by H part of This at Source_X, Source_Y to X, Y of what
    --  is drawn on now.  Raises Program_Error if that is This itself, which
    --  Cairo leaves undefined.
    procedure Copy
           (This                 : in Offscreen;
            X, Y, W, H           : in Integer;
            Source_X, Source_Y   : in Integer := 0);

    --  Remakes This for the screen's scale now, keeping its picture.  Raises
    --  Program_Error if This is begun: FLTK frees what it would draw on.
    procedure Rescale
           (This : in out Offscreen);


private


    type Offscreen is new Ada.Finalization.Limited_Controlled with record
        Surface : FLTK.Devices.Surface.Image.Image_Surface;
        W, H    : Integer := 0;
        Begun   : Boolean := False;
    end record;

    overriding procedure Finalize
           (This : in out Offscreen);


    type Drawing_Guard
           (Target : not null access Offscreen)
    is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Initialize
           (This : in out Drawing_Guard);

    overriding procedure Finalize
           (This : in out Drawing_Guard);



    pragma Inline (Is_Valid);
    pragma Inline (Get_W);
    pragma Inline (Get_H);
    pragma Inline (Is_Drawing);


end FLTK.Draw.Offscreens;


