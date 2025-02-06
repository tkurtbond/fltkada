

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Buttons.Repeat is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_repeat_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_repeat_button, "new_fl_repeat_button");
    pragma Inline (new_fl_repeat_button);

    procedure free_fl_repeat_button
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_repeat_button, "free_fl_repeat_button");
    pragma Inline (free_fl_repeat_button);




    --  Activity  --

    procedure fl_repeat_button_deactivate
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_repeat_button_deactivate, "fl_repeat_button_deactivate");
    pragma Inline (fl_repeat_button_deactivate);




    --  Drawing, Events  --

    procedure fl_repeat_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_repeat_button_draw, "fl_repeat_button_draw");
    pragma Inline (fl_repeat_button_draw);

    function fl_repeat_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_repeat_button_handle, "fl_repeat_button_handle");
    pragma Inline (fl_repeat_button_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Repeat_Button) is
    begin
        Extra_Final (Button (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Repeat_Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_repeat_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Repeat_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Button (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Repeat_Button) is
    begin
        This.Draw_Ptr := fl_repeat_button_draw'Address;
        This.Handle_Ptr := fl_repeat_button_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Repeat_Button is
        begin
            return This : Repeat_Button do
                This.Void_Ptr := new_fl_repeat_button
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
            return Repeat_Button is
        begin
            return This : Repeat_Button := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Activity  --

    procedure Deactivate
           (This : in out Repeat_Button) is
    begin
        fl_repeat_button_deactivate (This.Void_Ptr);
    end Deactivate;




    --  Events  --

    function Handle
           (This  : in out Repeat_Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Button (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Buttons.Repeat;


