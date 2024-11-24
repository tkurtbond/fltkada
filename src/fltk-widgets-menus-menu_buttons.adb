

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Menus.Menu_Buttons is


    procedure menu_button_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, menu_button_set_draw_hook, "menu_button_set_draw_hook");
    pragma Inline (menu_button_set_draw_hook);

    procedure menu_button_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, menu_button_set_handle_hook, "menu_button_set_handle_hook");
    pragma Inline (menu_button_set_handle_hook);




    function new_fl_menu_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_menu_button, "new_fl_menu_button");
    pragma Inline (new_fl_menu_button);

    procedure free_fl_menu_button
           (M : in Storage.Integer_Address);
    pragma Import (C, free_fl_menu_button, "free_fl_menu_button");
    pragma Inline (free_fl_menu_button);




    procedure fl_menu_button_type
           (M : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_menu_button_type, "fl_menu_button_type");
    pragma Inline (fl_menu_button_type);

    function fl_menu_button_popup
           (M : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_button_popup, "fl_menu_button_popup");
    pragma Inline (fl_menu_button_popup);

    function fl_menu_find_index2
           (M, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_find_index2, "fl_menu_find_index2");
    pragma Inline (fl_menu_find_index2);




    procedure fl_menu_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_menu_button_draw, "fl_menu_button_draw");
    pragma Inline (fl_menu_button_draw);

    function fl_menu_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_button_handle, "fl_menu_button_handle");
    pragma Inline (fl_menu_button_handle);




    procedure Extra_Final
           (This : in out Menu_Button) is
    begin
        Extra_Final (Menu (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Menu_Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_menu_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Menu_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Menu (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Menu_Button is
        begin
            return This : Menu_Button do
                This.Void_Ptr := new_fl_menu_button
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                menu_button_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                menu_button_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Set_Popup_Kind
           (This : in out Menu_Button;
            Pop  : in     Popup_Buttons) is
    begin
        fl_menu_button_type (This.Void_Ptr, Popup_Buttons'Pos (Pop));
    end Set_Popup_Kind;


    function Popup
           (This : in out Menu_Button)
        return Extended_Index
    is
        use type Interfaces.C.int;
        Ptr : Storage.Integer_Address := fl_menu_button_popup (This.Void_Ptr);
    begin
        return Extended_Index (fl_menu_find_index2 (This.Void_Ptr, Ptr) + 1);
    end Popup;




    procedure Draw
           (This : in out Menu_Button) is
    begin
        fl_menu_button_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Menu_Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_menu_button_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Menus.Menu_Buttons;

