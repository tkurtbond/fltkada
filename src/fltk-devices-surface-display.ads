

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Devices.Graphics;


package FLTK.Devices.Surface.Display is


    type Display_Device is new Surface_Device with private;

    type Display_Device_Reference (Data : not null access Display_Device'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        --  Docs say you shouldn't ever need to use this, but it's here anyway.
        function Create
               (Graphics : in out FLTK.Devices.Graphics.Graphics_Driver)
            return Display_Device;

    end Forge;




    function Get_Platform_Display
        return Display_Device_Reference;


private


    type Display_Device is new Surface_Device with null record;

    overriding procedure Finalize
           (This : in out Display_Device);


    pragma Inline (Get_Platform_Display);


end FLTK.Devices.Surface.Display;


