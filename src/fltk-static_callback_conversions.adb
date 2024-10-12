

with

    Ada.Unchecked_Conversion,
    FLTK.Static;

use type

    FLTK.Static.Awake_Handler,
    FLTK.Static.Timeout_Handler,
    FLTK.Static.Idle_Handler,
    FLTK.Static.Clipboard_Notify_Handler,
    FLTK.Static.File_Handler;


package body FLTK.Static_Callback_Conversions is


    function To_Awake_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.Awake_Handler
    is
        function Raw is new Ada.Unchecked_Conversion
            (Storage.Integer_Address, FLTK.Static.Awake_Handler);
    begin
        if Addy = Null_Pointer then
            return null;
        else
            return Raw (Addy);
        end if;
    end To_Awake_Access;


    function To_Address
           (Call : in FLTK.Static.Awake_Handler)
        return Storage.Integer_Address
    is
        function Raw is new Ada.Unchecked_Conversion
            (FLTK.Static.Awake_Handler, Storage.Integer_Address);
    begin
        if Call = null then
            return Null_Pointer;
        else
            return Raw (Call);
        end if;
    end To_Address;


    function To_Timeout_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.Timeout_Handler
    is
        function Raw is new Ada.Unchecked_Conversion
            (Storage.Integer_Address, FLTK.Static.Timeout_Handler);
    begin
        if Addy = Null_Pointer then
            return null;
        else
            return Raw (Addy);
        end if;
    end To_Timeout_Access;


    function To_Address
           (Call : in FLTK.Static.Timeout_Handler)
        return Storage.Integer_Address
    is
        function Raw is new Ada.Unchecked_Conversion
            (FLTK.Static.Timeout_Handler, Storage.Integer_Address);
    begin
        if Call = null then
            return Null_Pointer;
        else
            return Raw (Call);
        end if;
    end To_Address;


    function To_Idle_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.Idle_Handler
    is
        function Raw is new Ada.Unchecked_Conversion
            (Storage.Integer_Address, FLTK.Static.Idle_Handler);
    begin
        if Addy = Null_Pointer then
            return null;
        else
            return Raw (Addy);
        end if;
    end To_Idle_Access;


    function To_Address
           (Call : in FLTK.Static.Idle_Handler)
        return Storage.Integer_Address
    is
        function Raw is new Ada.Unchecked_Conversion
            (FLTK.Static.Idle_Handler, Storage.Integer_Address);
    begin
        if Call = null then
            return Null_Pointer;
        else
            return Raw (Call);
        end if;
    end To_Address;


    function To_Clipboard_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.Clipboard_Notify_Handler
    is
        function Raw is new Ada.Unchecked_Conversion
            (Storage.Integer_Address, FLTK.Static.Clipboard_Notify_Handler);
    begin
        if Addy = Null_Pointer then
            return null;
        else
            return Raw (Addy);
        end if;
    end To_Clipboard_Access;


    function To_Address
           (Call : in FLTK.Static.Clipboard_Notify_Handler)
        return Storage.Integer_Address
    is
        function Raw is new Ada.Unchecked_Conversion
            (FLTK.Static.Clipboard_Notify_Handler, Storage.Integer_Address);
    begin
        if Call = null then
            return Null_Pointer;
        else
            return Raw (Call);
        end if;
    end To_Address;


    function To_File_Access
           (Addy : in Storage.Integer_Address)
        return FLTK.Static.File_Handler
    is
        function Raw is new Ada.Unchecked_Conversion
            (Storage.Integer_Address, FLTK.Static.File_Handler);
    begin
        if Addy = Null_Pointer then
            return null;
        else
            return Raw (Addy);
        end if;
    end To_File_Access;


    function To_Address
           (Call : in FLTK.Static.File_Handler)
        return Storage.Integer_Address
    is
        function Raw is new Ada.Unchecked_Conversion
            (FLTK.Static.File_Handler, Storage.Integer_Address);
    begin
        if Call = null then
            return Null_Pointer;
        else
            return Raw (Call);
        end if;
    end To_Address;


end FLTK.Static_Callback_Conversions;


