

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Interfaces.C;


package body FLTK.Draw.Offscreens is


    ------------------------
    --  Functions From C  --
    ------------------------

    procedure fl_image_surface_copy_offscreen
           (S                  : in Storage.Integer_Address;
            X, Y, W, H, SX, SY : in Interfaces.C.int);
    pragma Import (C, fl_image_surface_copy_offscreen, "fl_image_surface_copy_offscreen");
    pragma Inline (fl_image_surface_copy_offscreen);




    -------------------
    --  Auxiliaries  --
    -------------------

    procedure Check_Made
           (This : in Offscreen) is
    begin
        if not This.Surface.Is_Valid then
            raise Program_Error with "Offscreen not made by Forge.Create";
        end if;
    end Check_Made;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (W, H : in Integer)
            return Offscreen is
        begin
            if W < 1 or H < 1 then
                raise Constraint_Error with "Offscreen of a size below 1";
            end if;
            return
               (Surface => FLTK.Devices.Surface.Image.Forge.Create (W, H, Highres => True),
                W       => W,
                H       => H,
                Begun   => False);
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Is_Valid
           (This : in Offscreen)
        return Boolean is
    begin
        return This.Surface.Is_Valid;
    end Is_Valid;


    function Get_W
           (This : in Offscreen)
        return Integer is
    begin
        return This.W;
    end Get_W;


    function Get_H
           (This : in Offscreen)
        return Integer is
    begin
        return This.H;
    end Get_H;




    --  Drawing  --

    procedure Begin_Drawing
           (This : in out Offscreen) is
    begin
        Check_Made (This);
        if This.Begun then
            raise Program_Error with "Begin_Drawing of an Offscreen begun already";
        end if;
        FLTK.Devices.Surface.Push_Current (This.Surface);
        This.Begun := True;
    end Begin_Drawing;


    procedure End_Drawing
           (This : in out Offscreen) is
    begin
        Check_Made (This);
        if not This.Begun or else not This.Surface.Is_Current then
            raise Program_Error with "End_Drawing of an Offscreen not the one drawn on";
        end if;
        FLTK.Devices.Surface.Pop_Current;
        This.Begun := False;
    end End_Drawing;


    function Is_Drawing
           (This : in Offscreen)
        return Boolean is
    begin
        return This.Begun;
    end Is_Drawing;




    --  Copying  --

    procedure Copy
           (This                 : in Offscreen;
            X, Y, W, H           : in Integer;
            Source_X, Source_Y   : in Integer := 0) is
    begin
        Check_Made (This);
        if This.Surface.Is_Current then
            raise Program_Error with "Copy of an Offscreen onto itself";
        end if;
        fl_image_surface_copy_offscreen
           (Wrapper (This.Surface).Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Source_X),
            Interfaces.C.int (Source_Y));
    end Copy;


    procedure Rescale
           (This : in out Offscreen) is
    begin
        Check_Made (This);
        if This.Begun then
            raise Program_Error with "Rescale of an Offscreen begun";
        end if;
        This.Surface.Rescale;
    end Rescale;


end FLTK.Draw.Offscreens;


