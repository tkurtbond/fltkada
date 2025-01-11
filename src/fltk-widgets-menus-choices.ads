

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Menus.Choices is


    type Choice is new Menu with private;

    type Choice_Reference (Data : not null access Choice'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Choice;

    end Forge;




    function Get_Chosen
           (This : in Choice)
        return FLTK.Menu_Items.Menu_Item_Reference;

    function Chosen_Index
           (This : in Choice)
        return Extended_Index;

    procedure Set_Chosen
           (This  : in out Choice;
            Place : in     Index);

    procedure Set_Chosen
           (This : in out Choice;
            Item : in     FLTK.Menu_Items.Menu_Item);




    procedure Draw
           (This : in out Choice);

    function Handle
           (This  : in out Choice;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Choice is new Menu with null record;

    overriding procedure Initialize
           (This : in out Choice);

    overriding procedure Finalize
           (This : in out Choice);

    procedure Extra_Init
           (This       : in out Choice;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Choice)
    with Inline;


    pragma Inline (Chosen);
    pragma Inline (Chosen_Index);
    pragma Inline (Set_Chosen);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Menus.Choices;


