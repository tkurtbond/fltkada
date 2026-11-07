

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images;

private with

    Interfaces.C.Strings;


package FLTK.Labels is


    type Label is new Wrapper with private;

    type Label_Reference (Data : not null access Label'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        function Create
               (Value    : in     String;
                Font     : in     Font_Kind               := Helvetica;
                Size     : in     Font_Size               := Get_Normal_Size;
                Hue      : in     Color                   := Foreground_Color;
                Kind     : in     Label_Kind              := Normal_Label;
                Place    : in     Alignment               := Align_Center;
                Active   : access FLTK.Images.Image'Class := null;
                Inactive : access FLTK.Images.Image'Class := null)
            return Label;

    end Forge;




    --  Attributes  --

    function Get_Value
           (This : in Label)
        return String;

    procedure Set_Value
           (This : in out Label;
            Text : in     String);

    function Get_Font
           (This : in Label)
        return Font_Kind;

    procedure Set_Font
           (This : in out Label;
            Font : in     Font_Kind);

    function Get_Size
           (This : in Label)
        return Font_Size;

    procedure Set_Size
           (This : in out Label;
            Size : in     Font_Size);

    function Get_Color
           (This : in Label)
        return Color;

    procedure Set_Color
           (This : in out Label;
            Hue  : in     Color);

    function Get_Kind
           (This : in Label)
        return Label_Kind;

    procedure Set_Kind
           (This : in out Label;
            Kind : in     Label_Kind);

    function Get_Alignment
           (This : in Label)
        return Alignment;

    procedure Set_Alignment
           (This  : in out Label;
            Place : in     Alignment);

    function Get_Active
           (This : in Label)
        return access FLTK.Images.Image'Class;

    procedure Set_Active
           (This : in out Label;
            Pic  : access FLTK.Images.Image'Class);

    function Get_Inactive
           (This : in Label)
        return access FLTK.Images.Image'Class;

    procedure Set_Inactive
           (This : in out Label;
            Pic  : access FLTK.Images.Image'Class);




    --  Drawing  --

    procedure Draw
           (This       : in out Label;
            X, Y, W, H : in     Integer;
            Place      : in     Alignment);

    procedure Measure
           (This : in     Label;
            W, H :    out Integer);


private


    type Label is new Wrapper with record
        My_Active   : access FLTK.Images.Image'Class;
        My_Inactive : access FLTK.Images.Image'Class;
        My_Text     : Interfaces.C.Strings.chars_ptr;
    end record;

    overriding procedure Finalize
           (This : in out Label);


    pragma Inline (Get_Value);
    pragma Inline (Get_Font);
    pragma Inline (Set_Font);
    pragma Inline (Get_Size);
    pragma Inline (Set_Size);
    pragma Inline (Get_Color);
    pragma Inline (Set_Color);
    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);
    pragma Inline (Get_Alignment);
    pragma Inline (Set_Alignment);
    pragma Inline (Get_Active);
    pragma Inline (Get_Inactive);

    pragma Inline (Draw);
    pragma Inline (Measure);


end FLTK.Labels;


