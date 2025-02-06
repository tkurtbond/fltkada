

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Charts is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_chart
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_chart, "new_fl_chart");
    pragma Inline (new_fl_chart);

    procedure free_fl_chart
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_chart, "free_fl_chart");
    pragma Inline (free_fl_chart);




    --  Data  --

    procedure fl_chart_add
           (C : in Storage.Integer_Address;
            V : in Interfaces.C.double;
            L : in Interfaces.C.char_array;
            P : in Interfaces.C.unsigned);
    pragma Import (C, fl_chart_add, "fl_chart_add");
    pragma Inline (fl_chart_add);

    procedure fl_chart_insert
           (C : in Storage.Integer_Address;
            I : in Interfaces.C.int;
            V : in Interfaces.C.double;
            L : in Interfaces.C.char_array;
            P : in Interfaces.C.unsigned);
    pragma Import (C, fl_chart_insert, "fl_chart_insert");
    pragma Inline (fl_chart_insert);

    procedure fl_chart_replace
           (C : in Storage.Integer_Address;
            I : in Interfaces.C.int;
            V : in Interfaces.C.double;
            L : in Interfaces.C.char_array;
            P : in Interfaces.C.unsigned);
    pragma Import (C, fl_chart_replace, "fl_chart_replace");
    pragma Inline (fl_chart_replace);

    procedure fl_chart_clear
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_chart_clear, "fl_chart_clear");
    pragma Inline (fl_chart_clear);




    --  Settings  --

    function fl_chart_get_autosize
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_chart_get_autosize, "fl_chart_get_autosize");
    pragma Inline (fl_chart_get_autosize);

    procedure fl_chart_set_autosize
           (C : in Storage.Integer_Address;
            A : in Interfaces.C.int);
    pragma Import (C, fl_chart_set_autosize, "fl_chart_set_autosize");
    pragma Inline (fl_chart_set_autosize);

    procedure fl_chart_get_bounds
           (C    : in     Storage.Integer_Address;
            L, U :    out Interfaces.C.double);
    pragma Import (C, fl_chart_get_bounds, "fl_chart_get_bounds");
    pragma Inline (fl_chart_get_bounds);

    procedure fl_chart_set_bounds
           (C    : in Storage.Integer_Address;
            L, U : in Interfaces.C.double);
    pragma Import (C, fl_chart_set_bounds, "fl_chart_set_bounds");
    pragma Inline (fl_chart_set_bounds);

    function fl_chart_get_maxsize
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_chart_get_maxsize, "fl_chart_get_maxsize");
    pragma Inline (fl_chart_get_maxsize);

    procedure fl_chart_set_maxsize
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_chart_set_maxsize, "fl_chart_set_maxsize");
    pragma Inline (fl_chart_set_maxsize);

    function fl_chart_size
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_chart_size, "fl_chart_size");
    pragma Inline (fl_chart_size);




    --  Text Settings  --

    function fl_chart_get_textcolor
           (C : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_chart_get_textcolor, "fl_chart_get_textcolor");
    pragma Inline (fl_chart_get_textcolor);

    procedure fl_chart_set_textcolor
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_chart_set_textcolor, "fl_chart_set_textcolor");
    pragma Inline (fl_chart_set_textcolor);

    function fl_chart_get_textfont
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_chart_get_textfont, "fl_chart_get_textfont");
    pragma Inline (fl_chart_get_textfont);

    procedure fl_chart_set_textfont
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_chart_set_textfont, "fl_chart_set_textfont");
    pragma Inline (fl_chart_set_textfont);

    function fl_chart_get_textsize
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_chart_get_textsize, "fl_chart_get_textsize");
    pragma Inline (fl_chart_get_textsize);

    procedure fl_chart_set_textsize
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_chart_set_textsize, "fl_chart_set_textsize");
    pragma Inline (fl_chart_set_textsize);




    --  Dimensions  --

    procedure fl_chart_size2
           (C    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int);
    pragma Import (C, fl_chart_size2, "fl_chart_size2");
    pragma Inline (fl_chart_size2);




    --  Drawing, Events  --

    procedure fl_chart_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_chart_draw, "fl_chart_draw");
    pragma Inline (fl_chart_draw);

    function fl_chart_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_chart_handle, "fl_chart_handle");
    pragma Inline (fl_chart_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Chart) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Chart) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_chart (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Chart;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Chart) is
    begin
        This.Draw_Ptr   := fl_chart_draw'Address;
        This.Handle_Ptr := fl_chart_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Chart is
        begin
            return This : Chart do
                This.Void_Ptr := new_fl_chart
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
            return Chart is
        begin
            return This : Chart := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Data  --

    procedure Add
           (This       : in out Chart;
            Data_Value : in     Long_Float;
            Data_Label : in     String := "";
            Data_Color : in     Color := Foreground_Color) is
    begin
        fl_chart_add
           (This.Void_Ptr,
            Interfaces.C.double (Data_Value),
            Interfaces.C.To_C (Data_Label),
            Interfaces.C.unsigned (Data_Color));
    end Add;


    procedure Insert
           (This       : in out Chart;
            Position   : in     Natural;
            Data_Value : in     Long_Float;
            Data_Label : in     String := "";
            Data_Color : in     Color := Foreground_Color) is
    begin
        fl_chart_insert
           (This.Void_Ptr,
            Interfaces.C.int (Position),
            Interfaces.C.double (Data_Value),
            Interfaces.C.To_C (Data_Label),
            Interfaces.C.unsigned (Data_Color));
    end Insert;


    procedure Replace
           (This       : in out Chart;
            Position   : in     Natural;
            Data_Value : in     Long_Float;
            Data_Label : in     String := "";
            Data_Color : in     Color := Foreground_Color) is
    begin
        fl_chart_replace
           (This.Void_Ptr,
            Interfaces.C.int (Position),
            Interfaces.C.double (Data_Value),
            Interfaces.C.To_C (Data_Label),
            Interfaces.C.unsigned (Data_Color));
    end Replace;


    procedure Clear
           (This : in out Chart) is
    begin
        fl_chart_clear (This.Void_Ptr);
    end Clear;




    --  Settings  --

    function Will_Autosize
           (This : in Chart)
        return Boolean is
    begin
        return fl_chart_get_autosize (This.Void_Ptr) /= 0;
    end Will_Autosize;


    procedure Set_Autosize
           (This : in out Chart;
            To   : in     Boolean) is
    begin
        fl_chart_set_autosize (This.Void_Ptr, Boolean'Pos (To));
    end Set_Autosize;


    procedure Get_Bounds
           (This         : in     Chart;
            Lower, Upper :    out Long_Float) is
    begin
        fl_chart_get_bounds
           (This.Void_Ptr,
            Interfaces.C.double (Lower),
            Interfaces.C.double (Upper));
    end Get_Bounds;


    procedure Set_Bounds
           (This         : in out Chart;
            Lower, Upper : in     Long_Float) is
    begin
        fl_chart_set_bounds
           (This.Void_Ptr,
            Interfaces.C.double (Lower),
            Interfaces.C.double (Upper));
    end Set_Bounds;


    function Get_Maximum_Size
           (This : in Chart)
        return Natural is
    begin
        return Natural (fl_chart_get_maxsize (This.Void_Ptr));
    end Get_Maximum_Size;


    procedure Set_Maximum_Size
           (This : in out Chart;
            To   : in     Natural) is
    begin
        fl_chart_set_maxsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Maximum_Size;


    function Get_Size
           (This : in Chart)
        return Natural is
    begin
        return Natural (fl_chart_size (This.Void_Ptr));
    end Get_Size;




    --  Text Settings  --

    function Get_Text_Color
           (This : in Chart)
        return Color is
    begin
        return Color (fl_chart_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Chart;
            To   : in     Color) is
    begin
        fl_chart_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Chart)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_chart_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Chart;
            To   : in     Font_Kind) is
    begin
        fl_chart_set_textfont (This.Void_Ptr, Font_Kind'Pos (To));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Chart)
        return Font_Size is
    begin
        return Font_Size (fl_chart_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Chart;
            To   : in     Font_Size) is
    begin
        fl_chart_set_textsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Text_Size;




    --  Dimensions  --

    procedure Resize
           (This : in out Chart;
            W, H : in     Integer) is
    begin
        fl_chart_size2 (This.Void_Ptr, Interfaces.C.int (W), Interfaces.C.int (H));
    end Resize;




    --  Drawing  --

    procedure Draw
           (This : in out Chart) is
    begin
        Widget (This).Draw;
    end Draw;


end FLTK.Widgets.Charts;


