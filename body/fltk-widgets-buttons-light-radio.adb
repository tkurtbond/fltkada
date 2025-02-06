

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Buttons.Light.Radio is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_radio_light_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_radio_light_button, "new_fl_radio_light_button");
    pragma Inline (new_fl_radio_light_button);

    procedure free_fl_radio_light_button
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_radio_light_button, "free_fl_radio_light_button");
    pragma Inline (free_fl_radio_light_button);




    --  Drawing, Events  --

    procedure fl_radio_light_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_radio_light_button_draw, "fl_radio_light_button_draw");
    pragma Inline (fl_radio_light_button_draw);

    function fl_radio_light_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_radio_light_button_handle, "fl_radio_light_button_handle");
    pragma Inline (fl_radio_light_button_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Radio_Light_Button) is
    begin
        Extra_Final (Light_Button (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Radio_Light_Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_radio_light_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Radio_Light_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Light_Button (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Radio_Light_Button) is
    begin
        This.Draw_Ptr   := fl_radio_light_button_draw'Address;
        This.Handle_Ptr := fl_radio_light_button_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Radio_Light_Button is
        begin
            return This : Radio_Light_Button do
                This.Void_Ptr := new_fl_radio_light_button
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
            return Radio_Light_Button is
        begin
            return This : Radio_Light_Button := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;


end FLTK.Widgets.Buttons.Light.Radio;


