

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Menu_Items,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Menu_Buttons;


package FLTK.Widgets.Groups.Input_Choices is


    type Input_Choice is new Group with private;

    type Input_Choice_Reference (Data : not null access Input_Choice'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Input_Choice;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Input_Choice;

    end Forge;




    function Text_Field
           (This : in out Input_Choice)
        return FLTK.Widgets.Inputs.Text.Text_Input_Reference;

    function Button_Menu
           (This : in out Input_Choice)
        return FLTK.Widgets.Menus.Menu_Buttons.Menu_Button_Reference;




    function Has_Item
           (This  : in Input_Choice;
            Place : in FLTK.Widgets.Menus.Index)
        return Boolean;

    function Item
           (This  : in Input_Choice;
            Place : in FLTK.Widgets.Menus.Index)
        return FLTK.Menu_Items.Menu_Item_Reference;

    procedure Use_Same_Items
           (This  : in out Input_Choice;
            Donor : in     FLTK.Widgets.Menus.Menu'Class);

    procedure Clear
           (This : in out Input_Choice);




    function Has_Changed
           (This : in Input_Choice)
        return Boolean;

    procedure Clear_Changed
           (This : in out Input_Choice);

    procedure Set_Changed
           (This : in out Input_Choice;
            To   : in     Boolean);

    function Get_Down_Box
           (This : in Input_Choice)
        return Box_Kind;

    procedure Set_Down_Box
           (This : in out Input_Choice;
            To   : in     Box_Kind);

    function Get_Text_Color
           (This : in Input_Choice)
        return Color;

    procedure Set_Text_Color
           (This : in out Input_Choice;
            To   : in     Color);

    function Get_Text_Font
           (This : in Input_Choice)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Input_Choice;
            To   : in     Font_Kind);

    function Get_Text_Size
           (This : in Input_Choice)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Input_Choice;
            To   : in     Font_Size);

    function Get_Input
           (This : in Input_Choice)
        return String;

    procedure Set_Input
           (This : in out Input_Choice;
            To   : in     String);

    procedure Set_Item
           (This : in out Input_Choice;
            Num  : in     Integer);




    procedure Resize
           (This       : in out Input_Choice;
            X, Y, W, H : in     Integer);


private


    type Input_Choice is new Group with record
        My_Input       : aliased Inputs.Text.Text_Input;
        My_Menu_Button : aliased Menus.Menu_Buttons.Menu_Button;
    end record;

    overriding procedure Initialize
           (This : in out Input_Choice);

    overriding procedure Finalize
           (This : in out Input_Choice);

    procedure Extra_Init
           (This       : in out Input_Choice;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Input_Choice);


    pragma Inline (Text_Field);
    pragma Inline (Button_Menu);

    pragma Inline (Has_Item);
    pragma Inline (Item);
    pragma Inline (Use_Same_Items);
    pragma Inline (Clear);

    pragma Inline (Has_Changed);
    pragma Inline (Clear_Changed);
    pragma Inline (Get_Down_Box);
    pragma Inline (Set_Down_Box);
    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);
    pragma Inline (Get_Input);
    pragma Inline (Set_Input);
    pragma Inline (Set_Item);

    pragma Inline (Resize);


end FLTK.Widgets.Groups.Input_Choices;


