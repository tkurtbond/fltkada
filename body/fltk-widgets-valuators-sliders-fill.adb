

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Sliders.Fill is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_fill_slider
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_fill_slider, "new_fl_fill_slider");
    pragma Inline (new_fl_fill_slider);

    procedure free_fl_fill_slider
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_fill_slider, "free_fl_fill_slider");
    pragma Inline (free_fl_fill_slider);




    procedure fl_fill_slider_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_fill_slider_draw, "fl_fill_slider_draw");
    pragma Inline (fl_fill_slider_draw);

    function fl_fill_slider_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_fill_slider_handle, "fl_fill_slider_handle");
    pragma Inline (fl_fill_slider_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Fill_Slider) is
    begin
        Extra_Final (Slider (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Fill_Slider) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_fill_slider (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Fill_Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Slider (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Fill_Slider) is
    begin
        This.Draw_Ptr   := fl_fill_slider_draw'Address;
        This.Handle_Ptr := fl_fill_slider_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Fill_Slider is
        begin
            return This : Fill_Slider do
                This.Void_Ptr := new_fl_fill_slider
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
            return Fill_Slider is
        begin
            return This : Fill_Slider := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;


end FLTK.Widgets.Valuators.Sliders.Fill;


