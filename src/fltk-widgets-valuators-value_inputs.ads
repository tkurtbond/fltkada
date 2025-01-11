

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Inputs.Text;


package FLTK.Widgets.Valuators.Value_Inputs is


    type Value_Input is new Valuator with private;

    type Value_Input_Reference (Data : not null access Value_Input'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Value_Input;

    end Forge;




    function Text_Field
           (This : in out Value_Input)
        return FLTK.Widgets.Inputs.Text.Text_Input_Reference;




    function Get_Cursor_Color
           (This : in Value_Input)
        return Color;

    procedure Set_Cursor_Color
           (This : in out Value_Input;
            Col  : in     Color);




    function Get_Shortcut
           (This : in Value_Input)
        return Key_Combo;

    procedure Set_Shortcut
           (This : in out Value_Input;
            Key  : in     Key_Combo);




    function Is_Soft
           (This : in Value_Input)
        return Boolean;

    procedure Set_Soft
           (This : in out Value_Input;
            To   : in     Boolean);




    function Get_Text_Color
           (This : in Value_Input)
        return Color;

    procedure Set_Text_Color
           (This : in out Value_Input;
            Col  : in     Color);

    function Get_Text_Font
           (This : in Value_Input)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Value_Input;
            Font : in     Font_Kind);

    function Get_Text_Size
           (This : in Value_Input)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Value_Input;
            Size : in     Font_Size);




    procedure Resize
           (This       : in out Value_Input;
            X, Y, W, H : in     Integer);




    procedure Draw
           (This : in out Value_Input);

    function Handle
           (This  : in out Value_Input;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Value_Input is new Valuator with record
        My_Input : aliased Inputs.Text.Text_Input;
    end record;

    overriding procedure Initialize
           (This : in out Value_Input);

    overriding procedure Finalize
           (This : in out Value_Input);

    procedure Extra_Init
           (This       : in out Value_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Value_Input)
    with Inline;


    pragma Inline (Text_Field);

    pragma Inline (Get_Cursor_Color);
    pragma Inline (Set_Cursor_Color);

    pragma Inline (Get_Shortcut);
    pragma Inline (Set_Shortcut);

    pragma Inline (Is_Soft);
    pragma Inline (Set_Soft);

    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Resize);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Valuators.Value_Inputs;


