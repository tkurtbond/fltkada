

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Devices is


    type Device is new Wrapper with private;

    type Device_Reference (Data : not null access Device'Class) is
        limited null record with Implicit_Dereference => Data;


private


    type Device is new Wrapper with null record;


end FLTK.Devices;

