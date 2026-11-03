

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Iterator_Interfaces;

private with

    System.Address_To_Access_Conversions;


package FLTK.Widgets.Groups is


    type Group is new Widget with private
        with Default_Iterator  => Iterate,
             Iterator_Element  => Widget_Reference,
             Variable_Indexing => Child;

    type Group_Reference (Data : not null access Group'Class) is limited null record
        with Implicit_Dereference => Data;

    subtype Index is Positive;
    subtype Extended_Index is Natural;
    No_Index : constant Extended_Index := Extended_Index'First;

    type Clip_Mode is (No_Clip, Clip);

    type Cursor is private;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Group;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Group;

    end Forge;




    --  Contents Modification  --

    procedure Add
           (This : in out Group;
            Item : in out Widget'Class);

    procedure Insert
           (This  : in out Group;
            Item  : in out Widget'Class;
            Place : in     Index);

    procedure Insert
           (This   : in out Group;
            Item   : in out Widget'Class;
            Before : in     Widget'Class);

    procedure Remove
           (This : in out Group;
            Item : in out Widget'Class);

    procedure Remove
           (This  : in out Group;
            Place : in     Index);

    procedure Clear
           (This : in out Group);




    --  Contents Query  --

    function Has_Child
           (This  : in Group;
            Place : in Index)
        return Boolean;

    function Has_Child
           (Place : in Cursor)
        return Boolean;

    function Child
           (This  : in Group;
            Place : in Index)
        return Widget_Reference
    with Pre => This.Has_Child (Place);

    function Child
           (This  : in Group;
            Place : in Cursor)
        return Widget_Reference;

    function Find
           (This : in Group;
            Item : in Widget'Class)
        return Extended_Index;

    function Number_Of_Children
           (This : in Group)
        return Natural;




    --  Iteration  --

    package Group_Iterators is
        new Ada.Iterator_Interfaces (Cursor, Has_Child);

    function Iterate
           (This : in Group)
        return Group_Iterators.Reversible_Iterator'Class;




    --  Clipping  --

    function Get_Clip_Mode
           (This : in Group)
        return Clip_Mode;

    procedure Set_Clip_Mode
           (This : in out Group;
            Mode : in     Clip_Mode := Clip);




    --  Dimensions  --

    procedure Add_Resizable
           (This : in out Group;
            Item : in out Widget'Class);

    function Get_Resizable
           (This : in Group)
        return access Widget'Class;

    procedure Set_Resizable
           (This : in out Group;
            Item : in     Widget'Class);

    --  Afterwards no child resizes when This does, they only move.
    procedure Clear_Resizable
           (This : in out Group);

    procedure Reset_Sizes
           (This : in out Group);

    procedure Resize
           (This       : in out Group;
            X, Y, W, H : in     Integer);




    --  Current  --

    function Get_Current
        return access Group'Class;

    procedure Set_Current
           (To : in Group'Class);

    procedure Begin_Current
           (This : in out Group);

    procedure End_Current
           (This : in out Group);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Group);

    procedure Draw_Child
           (This : in out Group;
            Item : in out Widget'Class);

    procedure Draw_Children
           (This : in out Group);

    procedure Draw_Outside_Label
           (This : in out Group;
            Item : in out Widget'Class);

    procedure Update_Child
           (This : in out Group;
            Item : in out Widget'Class);

    function Handle
           (This  : in out Group;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Address_Array is array (Positive range <>) of Storage.Integer_Address;
    type Address_Array_Access is access Address_Array;

    --  The children FLTK made itself in the C++ constructor, such as a
    --  Text_Display's scrollbars, which its destructor deletes and so
    --  must still be children when it runs.
    type Group is new Widget with record
        Internal : Address_Array_Access := null;
    end record;

    overriding procedure Initialize
           (This : in out Group);

    overriding procedure Finalize
           (This : in out Group);

    procedure Extra_Init
           (This       : in out Group;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Group);

    --  Removes the children with Ada objects, whose Ada objects delete
    --  them, and leaves the ones FLTK made for the C++ destructor.
    procedure Remove_Ada_Children
           (This : in out Group);


    package Group_Convert is new System.Address_To_Access_Conversions (Group);


    type Cursor is record
        My_Container : access Group;
        My_Index     : Index'Base := Index'First;
    end record;

    type Iterator is new Group_Iterators.Reversible_Iterator with record
        My_Container : access Group;
    end record;

    overriding function First
           (Object : in Iterator)
        return Cursor;

    overriding function Next
           (Object : in Iterator;
            Place  : in Cursor)
        return Cursor;

    overriding function Last
           (Object : in Iterator)
        return Cursor;

    overriding function Previous
           (Object : in Iterator;
            Place  : in Cursor)
        return Cursor;


    pragma Inline (Add);
    pragma Inline (Insert);
    pragma Inline (Remove);
    pragma Inline (Clear);

    pragma Inline (Has_Child);
    pragma Inline (Child);
    pragma Inline (Find);
    pragma Inline (Number_Of_Children);

    pragma Inline (Iterate);

    pragma Inline (Get_Clip_Mode);
    pragma Inline (Set_Clip_Mode);

    pragma Inline (Add_Resizable);
    pragma Inline (Set_Resizable);
    pragma Inline (Clear_Resizable);
    pragma Inline (Reset_Sizes);
    pragma Inline (Resize);

    pragma Inline (Set_Current);
    pragma Inline (Begin_Current);
    pragma Inline (End_Current);

    pragma Inline (Draw);
    pragma Inline (Draw_Child);
    pragma Inline (Draw_Children);
    pragma Inline (Draw_Outside_Label);
    pragma Inline (Update_Child);
    pragma Inline (Handle);


end FLTK.Widgets.Groups;


