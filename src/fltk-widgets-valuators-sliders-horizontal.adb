

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Sliders.Horizontal is


    procedure horizontal_slider_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, horizontal_slider_set_draw_hook, "horizontal_slider_set_draw_hook");
    pragma Inline (horizontal_slider_set_draw_hook);

    procedure horizontal_slider_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, horizontal_slider_set_handle_hook, "horizontal_slider_set_handle_hook");
    pragma Inline (horizontal_slider_set_handle_hook);




    function new_fl_horizontal_slider
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_horizontal_slider, "new_fl_horizontal_slider");
    pragma Inline (new_fl_horizontal_slider);

    procedure free_fl_horizontal_slider
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_horizontal_slider, "free_fl_horizontal_slider");
    pragma Inline (free_fl_horizontal_slider);




    procedure fl_horizontal_slider_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_horizontal_slider_draw, "fl_horizontal_slider_draw");
    pragma Inline (fl_horizontal_slider_draw);

    function fl_horizontal_slider_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_horizontal_slider_handle, "fl_horizontal_slider_handle");
    pragma Inline (fl_horizontal_slider_handle);




    procedure Extra_Final
           (This : in out Horizontal_Slider) is
    begin
        Extra_Final (Slider (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Horizontal_Slider) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_horizontal_slider (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Horizontal_Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Slider (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Horizontal_Slider is
        begin
            return This : Horizontal_Slider do
                This.Void_Ptr := new_fl_horizontal_slider
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                horizontal_slider_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                horizontal_slider_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Horizontal_Slider) is
    begin
        fl_horizontal_slider_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Horizontal_Slider;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_horizontal_slider_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Valuators.Sliders.Horizontal;

