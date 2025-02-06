

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Buttons is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

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




    --  State  --

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




    --  Settings  --

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




    --  Drawing, Events  --

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




    --  Miscellaneous  --

    procedure fl_button_simulate_key_action
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_button_simulate_key_action, "fl_button_simulate_key_action");
    pragma Inline (fl_button_simulate_key_action);




    -------------------
    --  Destructors  --
    -------------------

    --  Clipper route successfully navigated
    procedure button_extra_final_hook
           (Ada_Obj : in Storage.Integer_Address);
    pragma Export (C, button_extra_final_hook, "button_extra_final_hook");

    procedure button_extra_final_hook
           (Ada_Obj : in Storage.Integer_Address)
    is
        My_Button : Button;
        for My_Button'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Button);
    begin
        Extra_Final (My_Button);
    end button_extra_final_hook;


    procedure Extra_Final
           (This : in out Button) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Mobius strip traversal complete
    procedure button_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr);
    pragma Export (C, button_extra_init_hook, "button_extra_init_hook");

    procedure button_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr)
    is
        My_Button : Button;
        for My_Button'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Button);
    begin
        Extra_Init
           (My_Button,
            Integer (X), Integer (Y),
            Integer (W), Integer (H),
            Interfaces.C.Strings.Value (C_Str));
    end button_extra_init_hook;


    procedure Extra_Init
           (This       : in out Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Button) is
    begin
        This.Draw_Ptr   := fl_button_draw'Address;
        This.Handle_Ptr := fl_button_handle'Address;
    end Initialize;


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
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Button is
        begin
            return This : Button := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  State  --

    function Is_On
           (This : in Button)
        return Boolean is
    begin
        return This.Get_State = On;
    end Is_On;


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




    --  Settings  --

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
        return To_Ada (fl_button_get_shortcut (This.Void_Ptr));
    end Get_Shortcut;


    procedure Set_Shortcut
           (This : in out Button;
            Key  : in     Key_Combo) is
    begin
        fl_button_set_shortcut (This.Void_Ptr, Interfaces.C.int (To_C (Key)));
    end Set_Shortcut;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Button) is
    begin
        Widget (This).Draw;
    end Draw;


    function Handle
           (This  : in out Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;




    --  Miscellaneous  --

    procedure Simulate_Key_Action
           (This : in out Button) is
    begin
        fl_button_simulate_key_action (This.Void_Ptr);
    end Simulate_Key_Action;


end FLTK.Widgets.Buttons;


