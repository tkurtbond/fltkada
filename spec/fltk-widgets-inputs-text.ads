

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Inputs.Text is


    type Text_Input is new Input with private;

    type Text_Input_Reference (Data : not null access Text_Input'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Text_Input;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Text_Input;

    end Forge;




    --  Menu Texts  --

    --  The labels of the Cut, Copy and Paste items in the menu that a
    --  text input, and a text display or editor, pops up on the right
    --  button, for every such widget.  FLTK keeps the text it is given,
    --  so FLTKAda keeps a copy of it (Fl_Input.cxx:48-52, 553-555;
    --  Fl_Text_Display.cxx:4177-4179).

    function Get_Cut_Menu_Text
        return String;

    function Get_Copy_Menu_Text
        return String;

    function Get_Paste_Menu_Text
        return String;

    procedure Set_Cut_Menu_Text
           (To : in String);

    procedure Set_Copy_Menu_Text
           (To : in String);

    procedure Set_Paste_Menu_Text
           (To : in String);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Text_Input);

    function Handle
           (This  : in out Text_Input;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Text_Input is new Input with null record;

    overriding procedure Initialize
           (This : in out Text_Input);

    overriding procedure Finalize
           (This : in out Text_Input);

    procedure Extra_Init
           (This       : in out Text_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Text_Input)
    with Inline;


    pragma Inline (Get_Cut_Menu_Text);
    pragma Inline (Get_Copy_Menu_Text);
    pragma Inline (Get_Paste_Menu_Text);
    pragma Inline (Set_Cut_Menu_Text);
    pragma Inline (Set_Copy_Menu_Text);
    pragma Inline (Set_Paste_Menu_Text);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Inputs.Text;


