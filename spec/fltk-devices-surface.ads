

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Devices.Graphics;


package FLTK.Devices.Surface is


    type Surface_Device is new Device with private;

    type Surface_Device_Reference (Data : not null access Surface_Device'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (Graphics : in out FLTK.Devices.Graphics.Graphics_Driver)
            return Surface_Device;

    end Forge;




    --  Surfaces  --

    function Get_Current
        return Surface_Device_Reference;

    procedure Set_Current
           (This : in out Surface_Device);

    function Get_Original
        return Surface_Device_Reference;

    --  Makes This the current surface, remembering the previous one so a
    --  matching Pop_Current can restore it.  At most 16 can be remembered.
    procedure Push_Current
           (This : in out Surface_Device'Class);

    procedure Pop_Current;

    --  Whether This is the surface drawn on now.
    function Is_Current
           (This : in Surface_Device)
        return Boolean;




    --  Drivers  --

    function Has_Driver
           (This : in Surface_Device)
        return Boolean;

    function Get_Driver
           (This : in out Surface_Device)
        return FLTK.Devices.Graphics.Graphics_Driver_Reference;

    procedure Set_Driver
           (This   : in out Surface_Device;
            Driver : in out FLTK.Devices.Graphics.Graphics_Driver'Class);


private


    type Surface_Device is new Device with record
        My_Driver : access FLTK.Devices.Graphics.Graphics_Driver'Class;
    end record;

    overriding procedure Finalize
           (This : in out Surface_Device);


    procedure Set_Current_Bookkeep
           (Surface : in out Surface_Device'Class)
    with Inline;

    --  Whether This is current or remembered by Push_Current.
    function Is_Remembered
           (This : in Surface_Device'Class)
        return Boolean;

    --  Called by Finalize before This's FLTK object is freed.  FLTK keeps
    --  the current surface and the ones Push_Current remembers, and draws on
    --  or makes current what it keeps after it is freed.  So This is popped
    --  while it is current from a Push_Current, and the original surface is
    --  made current if This still is.  If This is still remembered below
    --  another, the result is False, and its FLTK object must not be freed:
    --  the stack then remembers a stand-in with the same FLTK object.  The
    --  stand-in owns that object, and both are freed once the stack has
    --  forgotten the stand-in, the next time a surface is made current or
    --  popped.
    function Release_Current
           (This : in out Surface_Device'Class)
        return Boolean;


    pragma Inline (Get_Current);
    pragma Inline (Get_Original);
    pragma Inline (Is_Current);

    pragma Inline (Has_Driver);
    pragma Inline (Get_Driver);


end FLTK.Devices.Surface;


