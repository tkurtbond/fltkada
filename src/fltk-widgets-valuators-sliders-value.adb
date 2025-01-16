

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Sliders.Value is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_value_slider
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_value_slider, "new_fl_value_slider");
    pragma Inline (new_fl_value_slider);

    procedure free_fl_value_slider
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_value_slider, "free_fl_value_slider");
    pragma Inline (free_fl_value_slider);




    function fl_value_slider_get_textcolor
           (S : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_value_slider_get_textcolor, "fl_value_slider_get_textcolor");
    pragma Inline (fl_value_slider_get_textcolor);

    procedure fl_value_slider_set_textcolor
           (S : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_value_slider_set_textcolor, "fl_value_slider_set_textcolor");
    pragma Inline (fl_value_slider_set_textcolor);

    function fl_value_slider_get_textfont
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_slider_get_textfont, "fl_value_slider_get_textfont");
    pragma Inline (fl_value_slider_get_textfont);

    procedure fl_value_slider_set_textfont
           (S : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_value_slider_set_textfont, "fl_value_slider_set_textfont");
    pragma Inline (fl_value_slider_set_textfont);

    function fl_value_slider_get_textsize
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_slider_get_textsize, "fl_value_slider_get_textsize");
    pragma Inline (fl_value_slider_get_textsize);

    procedure fl_value_slider_set_textsize
           (S : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_value_slider_set_textsize, "fl_value_slider_set_textsize");
    pragma Inline (fl_value_slider_set_textsize);




    procedure fl_value_slider_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_value_slider_draw, "fl_value_slider_draw");
    pragma Inline (fl_value_slider_draw);

    function fl_value_slider_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_value_slider_handle, "fl_value_slider_handle");
    pragma Inline (fl_value_slider_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Value_Slider) is
    begin
        Extra_Final (Slider (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Value_Slider) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_value_slider (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Value_Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Slider (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Value_Slider) is
    begin
        This.Draw_Ptr := fl_value_slider_draw'Address;
        This.Handle_Ptr := fl_value_slider_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Value_Slider is
        begin
            return This : Value_Slider do
                This.Void_Ptr := new_fl_value_slider
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
            return Value_Slider is
        begin
            return This : Value_Slider := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Get_Text_Color
           (This : in Value_Slider)
        return Color is
    begin
        return Color (fl_value_slider_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Value_Slider;
            To   : in     Color) is
    begin
        fl_value_slider_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Value_Slider)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_value_slider_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Value_Slider;
            To   : in     Font_Kind) is
    begin
        fl_value_slider_set_textfont (This.Void_Ptr, Font_Kind'Pos (To));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Value_Slider)
        return Font_Size is
    begin
        return Font_Size (fl_value_slider_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Value_Slider;
            To   : in     Font_Size) is
    begin
        fl_value_slider_set_textsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Text_Size;




    procedure Draw
           (This : in out Value_Slider) is
    begin
        Slider (This).Draw;
    end Draw;


    function Handle
           (This  : in out Value_Slider;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Slider (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Valuators.Sliders.Value;


