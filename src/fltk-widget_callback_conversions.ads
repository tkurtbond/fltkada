

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets;


private package FLTK.Widget_Callback_Conversions is


    function To_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Widgets.Widget_Callback;

    function To_Address
           (Call : in FLTK.Widgets.Widget_Callback)
        return Storage.Integer_Address;


end FLTK.Widget_Callback_Conversions;


