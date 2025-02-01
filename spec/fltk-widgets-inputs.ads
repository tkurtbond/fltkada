

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;

private with

    Interfaces.C.Strings,
    System;


package FLTK.Widgets.Inputs is


    type Input is new Widget with private;

    type Input_Reference (Data : not null access Input'Class) is limited null record
        with Implicit_Dereference => Data;

    type Input_Kind is
       (Normal_Field, Float_Field,  Integer_Field,   Multi_In_Field,
        Secret_Field, Output_Field, Multi_Out_Field, Wrap_Field,
        Multi_In_Wrap_Field, Multi_Out_Wrap_Field);

    type Clipboard_Kind is (Selection_Buffer, Cut_Paste_Board);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Input;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Input;

    end Forge;




    procedure Copy
           (This        : in out Input;
            Destination : in     Clipboard_Kind := Cut_Paste_Board);

    function Copy
           (This        : in out Input;
            Destination : in     Clipboard_Kind := Cut_Paste_Board)
        return Boolean;

    procedure Cut
           (This : in out Input);

    function Cut
           (This : in out Input)
        return Boolean;

    procedure Cut
           (This      : in out Input;
            Num_Bytes : in     Integer);

    function Cut
           (This      : in out Input;
            Num_Bytes : in     Integer)
        return Boolean;

    procedure Cut
           (This          : in out Input;
            Start, Finish : in     Integer);

    function Cut
           (This          : in out Input;
            Start, Finish : in     Integer)
        return Boolean;

    procedure Copy_Cuts
           (This : in out Input);

    function Copy_Cuts
           (This : in out Input)
        return Boolean;

    procedure Undo
           (This : in out Input);

    function Undo
           (This : in out Input)
        return Boolean;




    function Is_Readonly
           (This : in Input)
        return Boolean;

    procedure Set_Readonly
           (This : in out Input;
            To   : in     Boolean);

    function Is_Tab_Nav
           (This : in Input)
        return Boolean;

    procedure Set_Tab_Nav
           (This : in out Input;
            To   : in     Boolean);

    function Is_Wrap
           (This : in Input)
        return Boolean;

    procedure Set_Wrap
           (This : in out Input;
            To   : in     Boolean);




    function Get_Kind
           (This : in Input)
        return Input_Kind;

    function Get_Shortcut
           (This : in Input)
        return Key_Combo;

    procedure Set_Shortcut
           (This : in out Input;
            To   : in     Key_Combo);

    function Get_Mark
           (This : in Input)
        return Natural;

    procedure Set_Mark
           (This : in out Input;
            To   : in     Natural);

    function Set_Mark
           (This : in out Input;
            To   : in     Natural)
        return Boolean;

    function Get_Position
           (This : in Input)
        return Natural;

    procedure Set_Position
           (This : in out Input;
            To   : in     Natural);

    function Set_Position
           (This : in out Input;
            To   : in     Natural)
        return Boolean;

    procedure Set_Position_Mark
           (This  : in out Input;
            Place : in     Natural;
            Mark  : in     Natural);

    function Set_Position_Mark
           (This  : in out Input;
            Place : in     Natural;
            Mark  : in     Natural)
        return Boolean;




    function Index
           (This  : in Input;
            Place : in Integer)
        return Character;

    procedure Insert
           (This : in out Input;
            Str  : in     String);

    function Insert
           (This : in out Input;
            Str  : in     String)
        return Boolean;

    procedure Replace
           (This     : in out Input;
            From, To : in     Natural;
            New_Text : in     String);

    function Replace
           (This     : in out Input;
            From, To : in     Natural;
            New_Text : in     String)
        return Boolean;

    function Get_Value
           (This : in Input)
        return String;

    procedure Set_Value
           (This : in out Input;
            To   : in     String);

    function Set_Value
           (This : in out Input;
            To   : in     String)
        return Boolean;




    function Get_Maximum_Size
           (This : in Input)
        return Natural;

    procedure Set_Maximum_Size
           (This : in out Input;
            To   : in     Natural);

    function Size
           (This : in Input)
        return Natural;




    function Get_Cursor_Color
           (This : in Input)
        return Color;

    procedure Set_Cursor_Color
           (This : in out Input;
            To   : in     Color);

    function Get_Text_Color
           (This : in Input)
        return Color;

    procedure Set_Text_Color
           (This : in out Input;
            To   : in     Color);

    function Get_Text_Font
           (This : in Input)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Input;
            To   : in     Font_Kind);

    function Get_Text_Size
           (This : in Input)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Input;
            To   : in     Font_Size);




    procedure Resize
           (This : in out Input;
            W, H : in     Integer);

    procedure Resize
           (This       : in out Input;
            X, Y, W, H : in     Integer);




    package Extra is

        procedure Set_Kind
               (This : in out Input;
                To   : in     Input_Kind);

    end Extra;


private


    type Input is new Widget with null record;

    overriding procedure Initialize
           (This : in out Input);

    overriding procedure Finalize
           (This : in out Input);

    procedure Extra_Init
           (This       : in out Input;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Input)
    with Inline;


    pragma Inline (Copy);
    pragma Inline (Cut);
    pragma Inline (Copy_Cuts);
    pragma Inline (Undo);

    pragma Inline (Is_Readonly);
    pragma Inline (Set_Readonly);
    pragma Inline (Is_Tab_Nav);
    pragma Inline (Set_Tab_Nav);
    pragma Inline (Is_Wrap);
    pragma Inline (Set_Wrap);

    pragma Inline (Get_Kind);
    pragma Inline (Get_Shortcut);
    pragma Inline (Set_Shortcut);
    pragma Inline (Get_Mark);
    pragma Inline (Set_Mark);
    pragma Inline (Get_Position);
    pragma Inline (Set_Position);

    pragma Inline (Index);
    pragma Inline (Insert);
    pragma Inline (Replace);
    pragma Inline (Get_Value);
    pragma Inline (Set_Value);

    pragma Inline (Get_Maximum_Size);
    pragma Inline (Set_Maximum_Size);
    pragma Inline (Size);

    pragma Inline (Get_Cursor_Color);
    pragma Inline (Set_Cursor_Color);
    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Resize);

    pragma Inline (Draw);
    pragma Inline (Handle);


    Input_Kind_Values : array (Input_Kind) of Interfaces.C.int :=
       (Normal_Field         => 0,
        Float_Field          => 1,
        Integer_Field        => 2,
        Multi_In_Field       => 4,
        Secret_Field         => 5,
        Output_Field         => 8,
        Multi_Out_Field      => 12,
        Wrap_Field           => 16,
        Multi_In_Wrap_Field  => 20,
        Multi_Out_Wrap_Field => 28);


    function fl_input_get_value
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_input_get_value, "fl_input_get_value");
    pragma Inline (fl_input_get_value);


end FLTK.Widgets.Inputs;


