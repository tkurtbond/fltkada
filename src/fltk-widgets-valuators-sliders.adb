

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Sliders is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_slider
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_slider, "new_fl_slider");
    pragma Inline (new_fl_slider);

    function new_fl_slider2
           (K          : in Interfaces.C.unsigned_char;
            X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_slider2, "new_fl_slider2");
    pragma Inline (new_fl_slider2);

    procedure free_fl_slider
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_slider, "free_fl_slider");
    pragma Inline (free_fl_slider);




    procedure fl_slider_set_bounds
           (S    : in Storage.Integer_Address;
            A, B : in Interfaces.C.double);
    pragma Import (C, fl_slider_set_bounds, "fl_slider_set_bounds");
    pragma Inline (fl_slider_set_bounds);

    function fl_slider_get_slider
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_slider_get_slider, "fl_slider_get_slider");
    pragma Inline (fl_slider_get_slider);

    procedure fl_slider_set_slider
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_slider_set_slider, "fl_slider_set_slider");
    pragma Inline (fl_slider_set_slider);

    function fl_slider_get_slider_size
           (S : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_slider_get_slider_size, "fl_slider_get_slider_size");
    pragma Inline (fl_slider_get_slider_size);

    procedure fl_slider_set_slider_size
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.double);
    pragma Import (C, fl_slider_set_slider_size, "fl_slider_set_slider_size");
    pragma Inline (fl_slider_set_slider_size);

    function fl_slider_scrollvalue
           (S          : in Storage.Integer_Address;
            P, Z, F, T : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_slider_scrollvalue, "fl_slider_scrollvalue");
    pragma Inline (fl_slider_scrollvalue);




    procedure fl_slider_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_slider_draw, "fl_slider_draw");
    pragma Inline (fl_slider_draw);

    procedure fl_slider_draw2
           (S          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_slider_draw2, "fl_slider_draw2");
    pragma Inline (fl_slider_draw2);

    function fl_slider_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_slider_handle, "fl_slider_handle");
    pragma Inline (fl_slider_handle);

    function fl_slider_handle2
           (S             : in Storage.Integer_Address;
            E, X, Y, W, H : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_slider_handle2, "fl_slider_handle2");
    pragma Inline (fl_slider_handle2);




    function fl_widget_get_type
           (S : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_widget_get_type, "fl_widget_get_type");
    pragma Inline (fl_widget_get_type);

    procedure fl_widget_set_type
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_set_type, "fl_widget_set_type");
    pragma Inline (fl_widget_set_type);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Slider) is
    begin
        Extra_Final (Valuator (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Slider) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_slider (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Valuator (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Slider) is
    begin
        This.Draw_Ptr   := fl_slider_draw'Address;
        This.Handle_Ptr := fl_slider_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Slider is
        begin
            return This : Slider do
                This.Void_Ptr := new_fl_slider
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Kind       : in Slider_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Slider is
        begin
            return This : Slider do
                This.Void_Ptr := new_fl_slider2
                   (Slider_Kind'Pos (Kind),
                    Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    procedure Set_Bounds
           (This     : in out Slider;
            Min, Max : in     Long_Float) is
    begin
        fl_slider_set_bounds
           (This.Void_Ptr,
            Interfaces.C.double (Min),
            Interfaces.C.double (Max));
    end Set_Bounds;


    function Get_Box
           (This : in Slider)
        return Box_Kind is
    begin
        return Box_Kind'Val (fl_slider_get_slider (This.Void_Ptr));
    end Get_Box;


    procedure Set_Box
           (This : in out Slider;
            To   : in     Box_Kind) is
    begin
        fl_slider_set_slider (This.Void_Ptr, Box_Kind'Pos (To));
    end Set_Box;


    function Get_Slide_Size
           (This : in Slider)
        return Float is
    begin
        return Float (fl_slider_get_slider_size (This.Void_Ptr));
    end Get_Slide_Size;


    procedure Set_Slide_Size
           (This : in out Slider;
            To   : in     Long_Float) is
    begin
        fl_slider_set_slider_size (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Slide_Size;


    procedure Set_Scrollvalue
           (This            : in out Slider;
            Pos_First_Line  : in     Natural;
            Lines_In_Window : in     Natural;
            First_Line_Num  : in     Natural;
            Total_Lines     : in     Natural)
    is
        Ignore_Me : Interfaces.C.int;
    begin
        Ignore_Me := fl_slider_scrollvalue
           (This.Void_Ptr,
            Interfaces.C.int (Pos_First_Line),
            Interfaces.C.int (Lines_In_Window),
            Interfaces.C.int (First_Line_Num),
            Interfaces.C.int (Total_Lines));
    end Set_Scrollvalue;




    procedure Draw
           (This : in out Slider) is
    begin
        Valuator (This).Draw;
    end Draw;


    procedure Draw
           (This       : in out Slider;
            X, Y, W, H : in     Integer) is
    begin
        fl_slider_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Draw;


    function Handle
           (This  : in out Slider;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Valuator (This).Handle (Event);
    end Handle;


    function Handle
           (This       : in out Slider;
            Event      : in     Event_Kind;
            X, Y, W, H : in     Integer)
        return Event_Outcome is
    begin
        return Event_Outcome'Val (fl_slider_handle2
           (This.Void_Ptr,
            Event_Kind'Pos (Event),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H)));
    end Handle;




    function Get_Slider_Type
           (This : in Slider)
        return Slider_Kind is
    begin
        return Slider_Kind'Val (fl_widget_get_type (This.Void_Ptr));
    exception
    when Constraint_Error => raise Internal_FLTK_Error;
    end Get_Slider_Type;


    package body Extra is

        procedure Set_Slider_Type
               (This : in out Slider;
                To   : in     Slider_Kind) is
        begin
            fl_widget_set_type (This.Void_Ptr, Slider_Kind'Pos (To));
        end Set_Slider_Type;

        pragma Inline (Set_Slider_Type);

    end Extra;


end FLTK.Widgets.Valuators.Sliders;


