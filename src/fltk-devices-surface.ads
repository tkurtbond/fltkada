

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Devices.Graphics;


package FLTK.Devices.Surface is


    pragma Elaborate_Body (FLTK.Devices.Surface);


    type Surface_Device is new Device with private;

    type Surface_Device_Reference (Data : not null access Surface_Device'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (Graphics : in FLTK.Devices.Graphics.Graphics_Driver)
            return Surface_Device;

    end Forge;




    function Get_Current
        return Surface_Device_Reference;

    procedure Set_Current
           (This : in out Surface_Device);

    function Get_Original
        return Surface_Device_Reference;




    function Has_Driver
           (This : in Surface_Device)
        return Boolean;

    function Get_Driver
           (This : in out Surface_Device)
        return FLTK.Devices.Graphics.Graphics_Driver_Reference;

    procedure Set_Driver
           (This   : in out Surface_Device;
            Driver : in     FLTK.Devices.Graphics.Graphics_Driver'Class);


private


    type Surface_Device is new Device with record
        My_Driver : aliased FLTK.Devices.Graphics.Graphics_Driver;
    end record;

    overriding procedure Initialize
           (This : in out Surface_Device);

    overriding procedure Finalize
           (This : in out Surface_Device);


    procedure Set_Current_Bookkeep
           (Surface : in Surface_Device'Class);


    pragma Inline (Get_Current);
    pragma Inline (Get_Original);

    pragma Inline (Has_Driver);
    pragma Inline (Get_Driver);


end FLTK.Devices.Surface;


