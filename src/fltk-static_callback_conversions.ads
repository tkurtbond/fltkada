

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Static;


private package FLTK.Static_Callback_Conversions is


    function To_Awake_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.Awake_Handler;

    function To_Address
           (Call : in FLTK.Static.Awake_Handler)
        return Storage.Integer_Address;

    function To_Timeout_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.Timeout_Handler;

    function To_Address
           (Call : in FLTK.Static.Timeout_Handler)
        return Storage.Integer_Address;

    function To_Idle_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.Idle_Handler;

    function To_Address
           (Call : in FLTK.Static.Idle_Handler)
        return Storage.Integer_Address;

    function To_Clipboard_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.Clipboard_Notify_Handler;

    function To_Address
           (Call : in FLTK.Static.Clipboard_Notify_Handler)
        return Storage.Integer_Address;

    function To_File_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.File_Handler;

    function To_Address
           (Call : in FLTK.Static.File_Handler)
        return Storage.Integer_Address;


end FLTK.Static_Callback_Conversions;


