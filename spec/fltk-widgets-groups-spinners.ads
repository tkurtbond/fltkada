

--  Programmed by Jedidiah Barber
--  Released into the public domain


private with

    Interfaces.C.Strings;


package FLTK.Widgets.Groups.Spinners is


    type Spinner is new Group with private;

    type Spinner_Reference (Data : not null access Spinner'Class) is limited null record
        with Implicit_Dereference => Data;

    type Spinner_Kind is (Float_Spin, Int_Spin);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Spinner;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Spinner;

    end Forge;




    --  Settings  --

    function Get_Background_Color
           (This : in Spinner)
        return Color;

    procedure Set_Background_Color
           (This : in out Spinner;
            To   : in     Color);

    function Get_Selection_Color
           (This : in Spinner)
        return Color;

    procedure Set_Selection_Color
           (This : in out Spinner;
            To   : in     Color);

    --  The colors are the input field's, as with the two above, not the
    --  group's behind it (pofltk 13).
    overriding procedure Set_Colors
           (This      : in out Spinner;
            Back, Sel : in     Color);

    function Get_Text_Color
           (This : in Spinner)
        return Color;

    procedure Set_Text_Color
           (This : in out Spinner;
            To   : in     Color);

    function Get_Text_Font
           (This : in Spinner)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Spinner;
            To   : in     Font_Kind);

    function Get_Text_Size
           (This : in Spinner)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Spinner;
            To   : in     Font_Size);




    --  Values  --

    function Get_Minimum
           (This : in Spinner)
        return Long_Float;

    procedure Set_Minimum
           (This : in out Spinner;
            To   : in     Long_Float);

    function Get_Maximum
           (This : in Spinner)
        return Long_Float;

    procedure Set_Maximum
           (This : in out Spinner;
            To   : in     Long_Float);

    procedure Get_Range
           (This     : in     Spinner;
            Min, Max :    out Long_Float);

    procedure Set_Range
           (This     : in out Spinner;
            Min, Max : in     Long_Float);

    function Get_Step
           (This : in Spinner)
        return Long_Float;

    procedure Set_Step
           (This : in out Spinner;
            To   : in     Long_Float);

    function Get_Value
           (This : in Spinner)
        return Long_Float;

    --  Get_Value rounded to the nearest whole number, a half up:  an
    --  Int_Spin's value as an Integer.  Set_Value doesn't round what it is
    --  given, even for an Int_Spin.  Raises Constraint_Error for a value
    --  that, rounded, isn't an Integer.
    function Get_Integer_Value
           (This : in Spinner)
        return Integer;

    procedure Set_Value
           (This : in out Spinner;
            To   : in     Long_Float);




    --  Formatting  --

    function Get_Format
           (This : in Spinner)
        return String;

    --  FLTK gives the format to snprintf with the value, a double, or with
    --  the step's number of decimals and then the value when it starts with
    --  "%.*" (Fl_Spinner.cxx:79-91).  So a format must have at most one
    --  conversion, one of a A e E f F g G, with no length but l, and a
    --  '*' only as that leading "%.*".  Its width and precision are at most
    --  3 digits, and "%%" is a percent sign.  Any other format raises
    --  Constraint_Error, and the one before is kept (pofltk 13).
    procedure Set_Format
           (This : in out Spinner;
            To   : in     String);

    function Get_Kind
           (This : in Spinner)
        return Spinner_Kind;

    procedure Set_Kind
           (This : in out Spinner;
            To   : in     Spinner_Kind);

    --  Whether the buttons and the Up and Down keys take the value past one
    --  bound round to the other, True to start with; if not, they stop at
    --  the bound.  A value typed in is clipped to the range either way
    --  (Fl_Spinner.H:111-139).
    function Get_Wrap
           (This : in Spinner)
        return Boolean;

    procedure Set_Wrap
           (This : in out Spinner;
            To   : in     Boolean);




    --  Dimensions  --

    procedure Resize
           (This       : in out Spinner;
            X, Y, W, H : in     Integer);




    --  Events  --

    function Handle
           (This  : in out Spinner;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Spinner is new Group with record
        Format_Str : Interfaces.C.Strings.chars_ptr;
    end record;

    overriding procedure Initialize
           (This : in out Spinner);

    overriding procedure Finalize
           (This : in out Spinner);

    procedure Extra_Init
           (This       : in out Spinner;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Spinner)
    with Inline;


    pragma Inline (Get_Background_Color);
    pragma Inline (Set_Background_Color);
    pragma Inline (Get_Selection_Color);
    pragma Inline (Set_Selection_Color);
    pragma Inline (Set_Colors);
    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Get_Minimum);
    pragma Inline (Set_Minimum);
    pragma Inline (Get_Maximum);
    pragma Inline (Set_Maximum);
    pragma Inline (Set_Range);
    pragma Inline (Get_Step);
    pragma Inline (Set_Step);
    pragma Inline (Get_Value);
    pragma Inline (Set_Value);

    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);
    pragma Inline (Get_Wrap);
    pragma Inline (Set_Wrap);

    pragma Inline (Resize);

    pragma Inline (Handle);


end FLTK.Widgets.Groups.Spinners;


