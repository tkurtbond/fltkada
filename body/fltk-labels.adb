

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Registry,
    Interfaces.C.Strings;

use type

    Interfaces.C.Strings.chars_ptr;


package body FLTK.Labels is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_label
           (V : in Interfaces.C.Strings.chars_ptr;
            F : in Interfaces.C.int;
            S : in Interfaces.C.int;
            H : in Interfaces.C.unsigned;
            K : in Interfaces.C.int;
            P : in Interfaces.C.unsigned)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_label, "new_fl_label");
    pragma Inline (new_fl_label);

    procedure free_fl_label
           (L : in Storage.Integer_Address);
    pragma Import (C, free_fl_label, "free_fl_label");
    pragma Inline (free_fl_label);




    --  Attributes  --

    function fl_label_get_value
           (L : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_label_get_value, "fl_label_get_value");
    pragma Inline (fl_label_get_value);

    procedure fl_label_set_value
           (L : in Storage.Integer_Address;
            V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_label_set_value, "fl_label_set_value");
    pragma Inline (fl_label_set_value);

    function fl_label_get_font
           (L : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_label_get_font, "fl_label_get_font");
    pragma Inline (fl_label_get_font);

    procedure fl_label_set_font
           (L : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_label_set_font, "fl_label_set_font");
    pragma Inline (fl_label_set_font);

    function fl_label_get_size
           (L : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_label_get_size, "fl_label_get_size");
    pragma Inline (fl_label_get_size);

    procedure fl_label_set_size
           (L : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_label_set_size, "fl_label_set_size");
    pragma Inline (fl_label_set_size);

    function fl_label_get_color
           (L : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_label_get_color, "fl_label_get_color");
    pragma Inline (fl_label_get_color);

    procedure fl_label_set_color
           (L : in Storage.Integer_Address;
            H : in Interfaces.C.unsigned);
    pragma Import (C, fl_label_set_color, "fl_label_set_color");
    pragma Inline (fl_label_set_color);

    function fl_label_get_type
           (L : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_label_get_type, "fl_label_get_type");
    pragma Inline (fl_label_get_type);

    procedure fl_label_set_type
           (L : in Storage.Integer_Address;
            K : in Interfaces.C.int);
    pragma Import (C, fl_label_set_type, "fl_label_set_type");
    pragma Inline (fl_label_set_type);

    function fl_label_get_align
           (L : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_label_get_align, "fl_label_get_align");
    pragma Inline (fl_label_get_align);

    procedure fl_label_set_align
           (L : in Storage.Integer_Address;
            P : in Interfaces.C.unsigned);
    pragma Import (C, fl_label_set_align, "fl_label_set_align");
    pragma Inline (fl_label_set_align);

    procedure fl_label_set_image
           (L, I : in Storage.Integer_Address);
    pragma Import (C, fl_label_set_image, "fl_label_set_image");
    pragma Inline (fl_label_set_image);

    procedure fl_label_set_deimage
           (L, I : in Storage.Integer_Address);
    pragma Import (C, fl_label_set_deimage, "fl_label_set_deimage");
    pragma Inline (fl_label_set_deimage);




    --  Drawing  --

    procedure fl_label_draw
           (L          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            P          : in Interfaces.C.unsigned);
    pragma Import (C, fl_label_draw, "fl_label_draw");
    pragma Inline (fl_label_draw);

    procedure fl_label_measure
           (L    : in     Storage.Integer_Address;
            W, H : in out Interfaces.C.int);
    pragma Import (C, fl_label_measure, "fl_label_measure");
    pragma Inline (fl_label_measure);




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Label) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            FLTK.Registry.Label_Store.Delete (This.Void_Ptr);
            free_fl_label (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Interfaces.C.Strings.Free (This.My_Text);
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Value    : in     String;
                Font     : in     Font_Kind               := Helvetica;
                Size     : in     Font_Size               := Get_Normal_Size;
                Hue      : in     Color                   := Foreground_Color;
                Kind     : in     Label_Kind              := Normal_Label;
                Place    : in     Alignment               := Align_Center;
                Active   : access FLTK.Images.Image'Class := null;
                Inactive : access FLTK.Images.Image'Class := null)
            return Label is
        begin
            return This : Label do
                This.My_Text := Interfaces.C.Strings.New_String (Value);
                This.Void_Ptr := new_fl_label
                   (This.My_Text,           --  Interfaces.C.Strings.chars_ptr
                    To_C (Font),   --  Interfaces.C.int
                    Interfaces.C.int (Size),
                    Interfaces.C.unsigned (Hue),
                    Label_Kind'Pos (Kind),  --  Interfaces.C.int
                    Interfaces.C.unsigned (Place));
                This.Set_Active (Active);
                This.Set_Inactive (Inactive);
                FLTK.Registry.Label_Store.Insert (This.Void_Ptr, This'Unchecked_Access);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Attributes  --

    function Get_Value
           (This : in Label)
        return String
    is
        Text : constant Interfaces.C.Strings.chars_ptr := fl_label_get_value (This.Void_Ptr);
    begin
        if Text = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Text);
        end if;
    end Get_Value;


    procedure Set_Value
           (This : in out Label;
            Text : in     String) is
    begin
        Interfaces.C.Strings.Free (This.My_Text);
        This.My_Text := Interfaces.C.Strings.New_String (Text);
        fl_label_set_value (This.Void_Ptr, This.My_Text);
    end Set_Value;


    function Get_Font
           (This : in Label)
        return Font_Kind is
    begin
        return Font_Kind (fl_label_get_font (This.Void_Ptr));
    end Get_Font;


    procedure Set_Font
           (This : in out Label;
            Font : in     Font_Kind) is
    begin
        fl_label_set_font (This.Void_Ptr, To_C (Font));
    end Set_Font;


    function Get_Size
           (This : in Label)
        return Font_Size is
    begin
        return Font_Size (fl_label_get_size (This.Void_Ptr));
    end Get_Size;


    procedure Set_Size
           (This : in out Label;
            Size : in     Font_Size) is
    begin
        fl_label_set_size (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Size;


    function Get_Color
           (This : in Label)
        return Color is
    begin
        return Color (fl_label_get_color (This.Void_Ptr));
    end Get_Color;


    procedure Set_Color
           (This : in out Label;
            Hue  : in     Color) is
    begin
        fl_label_set_color (This.Void_Ptr, Interfaces.C.unsigned (Hue));
    end Set_Color;


    function Get_Kind
           (This : in Label)
        return Label_Kind is
    begin
        return Label_Kind'Val (fl_label_get_type (This.Void_Ptr));
    end Get_Kind;


    procedure Set_Kind
           (This : in out Label;
            Kind : in     Label_Kind) is
    begin
        fl_label_set_type (This.Void_Ptr, Label_Kind'Pos (Kind));
    end Set_Kind;


    function Get_Alignment
           (This : in Label)
        return Alignment is
    begin
        return Alignment (fl_label_get_align (This.Void_Ptr));
    end Get_Alignment;


    procedure Set_Alignment
           (This  : in out Label;
            Place : in     Alignment) is
    begin
        fl_label_set_align (This.Void_Ptr, Interfaces.C.unsigned (Place));
    end Set_Alignment;


    function Get_Active
           (This : in Label)
        return access FLTK.Images.Image'Class is
    begin
        return This.My_Active;
    end Get_Active;


    procedure Set_Active
           (This : in out Label;
            Pic  : access FLTK.Images.Image'Class) is
    begin
        if Pic /= null then
            fl_label_set_image (This.Void_Ptr, Wrapper (Pic.all).Void_Ptr);
        else
            fl_label_set_image (This.Void_Ptr, Null_Pointer);
        end if;
        This.My_Active := Pic;
    end Set_Active;


    function Get_Inactive
           (This : in Label)
        return access FLTK.Images.Image'Class is
    begin
        return This.My_Inactive;
    end Get_Inactive;


    procedure Set_Inactive
           (This : in out Label;
            Pic  : access FLTK.Images.Image'Class) is
    begin
        if Pic /= null then
            fl_label_set_deimage (This.Void_Ptr, Wrapper (Pic.all).Void_Ptr);
        else
            fl_label_set_deimage (This.Void_Ptr, Null_Pointer);
        end if;
        This.My_Inactive := Pic;
    end Set_Inactive;




    --  Drawing  --

    procedure Draw
           (This       : in out Label;
            X, Y, W, H : in     Integer;
            Place      : in     Alignment) is
    begin
        fl_label_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Place));
    end Draw;


    --  FLTK reads W as the width to wrap the text at, 0 for none
    --  (fl_draw.cxx:520-521), so it is given 0, not what W held.
    procedure Measure
           (This : in     Label;
            W, H :    out Integer)
    is
        Result_W, Result_H : Interfaces.C.int := 0;
    begin
        fl_label_measure (This.Void_Ptr, Result_W, Result_H);
        W := Integer (Result_W);
        H := Integer (Result_H);
    end Measure;


end FLTK.Labels;


