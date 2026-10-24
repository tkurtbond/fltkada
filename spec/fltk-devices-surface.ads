

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


    pragma Inline (Get_Current);
    pragma Inline (Get_Original);

    pragma Inline (Has_Driver);
    pragma Inline (Get_Driver);


end FLTK.Devices.Surface;


