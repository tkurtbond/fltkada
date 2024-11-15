

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Buttons is


    procedure button_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, button_set_draw_hook, "button_set_draw_hook");
    pragma Inline (button_set_draw_hook);

    procedure button_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, button_set_handle_hook, "button_set_handle_hook");
    pragma Inline (button_set_handle_hook);




    function new_fl_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_button, "new_fl_button");
    pragma Inline (new_fl_button);

    procedure free_fl_button
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_button, "free_fl_button");
    pragma Inline (free_fl_button);




    function fl_button_get_state
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_button_get_state, "fl_button_get_state");
    pragma Inline (fl_button_get_state);

    procedure fl_button_set_state
           (B : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_button_set_state, "fl_button_set_state");
    pragma Inline (fl_button_set_state);

    procedure fl_button_set_only
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_button_set_only, "fl_button_set_only");
    pragma Inline (fl_button_set_only);




    function fl_button_get_down_box
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_button_get_down_box, "fl_button_get_down_box");
    pragma Inline (fl_button_get_down_box);

    procedure fl_button_set_down_box
           (B : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_button_set_down_box, "fl_button_set_down_box");
    pragma Inline (fl_button_set_down_box);

    function fl_button_get_shortcut
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_button_get_shortcut, "fl_button_get_shortcut");
    pragma Inline (fl_button_get_shortcut);

    procedure fl_button_set_shortcut
           (B : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_button_set_shortcut, "fl_button_set_shortcut");
    pragma Inline (fl_button_set_shortcut);




    procedure fl_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_button_draw, "fl_button_draw");
    pragma Inline (fl_button_draw);

    function fl_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_button_handle, "fl_button_handle");
    pragma Inline (fl_button_handle);




    procedure Finalize
           (This : in out Button) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Button'Class
        then
            free_fl_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Widget (This));
    end Finalize;




    procedure Extra_Init
           (This       : in out Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Button is
        begin
            return This : Button do
                This.Void_Ptr := new_fl_button
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                button_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                button_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    function Get_State
           (This : in Button)
        return State is
    begin
        return State'Val (fl_button_get_state (This.Void_Ptr));
    end Get_State;


    procedure Set_State
           (This : in out Button;
            St   : in     State) is
    begin
        fl_button_set_state (This.Void_Ptr, State'Pos (St));
    end Set_State;


    procedure Set_Only
           (This : in out Button) is
    begin
        fl_button_set_only (This.Void_Ptr);
    end Set_Only;




    function Get_Down_Box
           (This : in Button)
        return Box_Kind is
    begin
        return Box_Kind'Val (fl_button_get_down_box (This.Void_Ptr));
    end Get_Down_Box;


    procedure Set_Down_Box
           (This : in out Button;
            To   : in     Box_Kind) is
    begin
        fl_button_set_down_box (This.Void_Ptr, Box_Kind'Pos (To));
    end Set_Down_Box;


    function Get_Shortcut
           (This : in Button)
        return Key_Combo is
    begin
        return To_Ada (Interfaces.C.unsigned_long (fl_button_get_shortcut (This.Void_Ptr)));
    end Get_Shortcut;


    procedure Set_Shortcut
           (This : in out Button;
            Key  : in     Key_Combo) is
    begin
        fl_button_set_shortcut (This.Void_Ptr, Interfaces.C.int (To_C (Key)));
    end Set_Shortcut;




    procedure Draw
           (This : in out Button) is
    begin
        fl_button_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_button_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Buttons;

