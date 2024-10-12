

with

    Ada.Unchecked_Conversion,
    FLTK.Widgets;

use type

    FLTK.Widgets.Widget_Callback;


package body FLTK.Widget_Callback_Conversions is


    function To_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Widgets.Widget_Callback
    is
        function Raw is new Ada.Unchecked_Conversion
            (Storage.Integer_Address, FLTK.Widgets.Widget_Callback);
    begin
        if Addy = Null_Pointer then
            return null;
        else
            return Raw (Addy);
        end if;
    end To_Access;


    function To_Address
           (Call : in FLTK.Widgets.Widget_Callback)
        return Storage.Integer_Address
    is
        function Raw is new Ada.Unchecked_Conversion
            (FLTK.Widgets.Widget_Callback, Storage.Integer_Address);
    begin
        if Call = null then
            return Null_Pointer;
        else
            return Raw (Call);
        end if;
    end To_Address;


end FLTK.Widget_Callback_Conversions;


