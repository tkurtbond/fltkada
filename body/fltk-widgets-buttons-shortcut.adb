

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Buttons.Shortcut is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_shortcut_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_shortcut_button, "new_fl_shortcut_button");
    pragma Inline (new_fl_shortcut_button);

    procedure free_fl_shortcut_button
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_shortcut_button, "free_fl_shortcut_button");
    pragma Inline (free_fl_shortcut_button);




    --  Value  --

    function fl_shortcut_button_get_value
           (B : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_shortcut_button_get_value, "fl_shortcut_button_get_value");
    pragma Inline (fl_shortcut_button_get_value);

    procedure fl_shortcut_button_set_value
           (B : in Storage.Integer_Address;
            S : in Interfaces.C.unsigned);
    pragma Import (C, fl_shortcut_button_set_value, "fl_shortcut_button_set_value");
    pragma Inline (fl_shortcut_button_set_value);




    --  Drawing, Events  --

    procedure fl_shortcut_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_shortcut_button_draw, "fl_shortcut_button_draw");
    pragma Inline (fl_shortcut_button_draw);

    function fl_shortcut_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_shortcut_button_handle, "fl_shortcut_button_handle");
    pragma Inline (fl_shortcut_button_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Shortcut_Button) is
    begin
        Extra_Final (Button (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Shortcut_Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_shortcut_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Shortcut_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Button (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Shortcut_Button) is
    begin
        This.Draw_Ptr := fl_shortcut_button_draw'Address;
        This.Handle_Ptr := fl_shortcut_button_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Shortcut_Button is
        begin
            return This : Shortcut_Button do
                This.Void_Ptr := new_fl_shortcut_button
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
            return Shortcut_Button is
        begin
            return This : Shortcut_Button := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Value  --

    function Get_Value
           (This : in Shortcut_Button)
        return Key_Combo is
    begin
        return To_Ada (fl_shortcut_button_get_value (This.Void_Ptr));
    end Get_Value;


    procedure Set_Value
           (This : in out Shortcut_Button;
            To   : in     Key_Combo) is
    begin
        fl_shortcut_button_set_value (This.Void_Ptr, To_C (To));
    end Set_Value;




    --  Events  --

    function Handle
           (This  : in out Shortcut_Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Button (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Buttons.Shortcut;


