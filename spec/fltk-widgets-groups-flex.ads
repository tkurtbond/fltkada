

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package FLTK.Widgets.Groups.Flex is


    type Flex_Group is new Group with private;

    type Flex_Group_Reference (Data : not null access Flex_Group'Class) is
        limited null record with Implicit_Dereference => Data;

    --  Vertical_Flex is a single column, Horizontal_Flex is a single row
    type Flex_Kind is (Vertical_Flex, Horizontal_Flex);

    Column_Flex : constant Flex_Kind := Vertical_Flex;
    Row_Flex    : constant Flex_Kind := Horizontal_Flex;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Flex_Group;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Flex_Group;

        function Create
               (X, Y, W, H : in Integer;
                Kind       : in Flex_Kind)
            return Flex_Group;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Kind       : in     Flex_Kind)
            return Flex_Group;

        function Create
               (W, H : in Integer;
                Kind : in Flex_Kind)
            return Flex_Group;

        function Create
               (Parent : in out Group'Class;
                W, H   : in     Integer;
                Kind   : in     Flex_Kind)
            return Flex_Group;

        function Create
               (Kind : in Flex_Kind)
            return Flex_Group;

        function Create
               (Parent : in out Group'Class;
                Kind   : in     Flex_Kind)
            return Flex_Group;

    end Forge;




    --  Current  --

    procedure End_Current
           (This : in out Flex_Group);




    --  Layout  --

    procedure Layout
           (This : in out Flex_Group);

    function Get_Need_Layout
           (This : in Flex_Group)
        return Boolean;

    procedure Set_Need_Layout
           (This : in out Flex_Group;
            To   : in     Boolean := True);




    --  Fixed Sizes  --

    procedure Set_Fixed
           (This : in out Flex_Group;
            Item : in     Widget'Class;
            Size : in     Integer);

    function Is_Fixed
           (This : in Flex_Group;
            Item : in Widget'Class)
        return Boolean;




    --  Settings  --

    function Get_Kind
           (This : in Flex_Group)
        return Flex_Kind;

    procedure Set_Kind
           (This : in out Flex_Group;
            Kind : in     Flex_Kind);

    function Is_Horizontal
           (This : in Flex_Group)
        return Boolean;

    --  Returns the left margin
    function Get_Margin
           (This : in Flex_Group)
        return Integer;

    procedure Get_Margin
           (This                     : in     Flex_Group;
            Left, Top, Right, Bottom :    out Integer);

    --  Returns whether all four margins are equal
    function Get_Margin
           (This                     : in     Flex_Group;
            Left, Top, Right, Bottom :    out Integer)
        return Boolean;

    procedure Set_Margin
           (This : in out Flex_Group;
            To   : in     Integer);

    procedure Set_Margin
           (This : in out Flex_Group;
            To   : in     Integer;
            Gap  : in     Integer);

    procedure Set_Margin
           (This                     : in out Flex_Group;
            Left, Top, Right, Bottom : in     Integer);

    function Get_Gap
           (This : in Flex_Group)
        return Integer;

    procedure Set_Gap
           (This : in out Flex_Group;
            To   : in     Integer);

    function Get_Spacing
           (This : in Flex_Group)
        return Integer;

    procedure Set_Spacing
           (This : in out Flex_Group;
            To   : in     Integer);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Flex_Group);

    function Handle
           (This  : in out Flex_Group;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Flex_Group is new Group with null record;

    overriding procedure Initialize
           (This : in out Flex_Group);

    overriding procedure Finalize
           (This : in out Flex_Group);

    procedure Extra_Init
           (This       : in out Flex_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Flex_Group)
    with Inline;


    pragma Inline (End_Current);

    pragma Inline (Layout);
    pragma Inline (Get_Need_Layout);
    pragma Inline (Set_Need_Layout);

    pragma Inline (Set_Fixed);
    pragma Inline (Is_Fixed);

    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);
    pragma Inline (Is_Horizontal);
    pragma Inline (Get_Margin);
    pragma Inline (Set_Margin);
    pragma Inline (Get_Gap);
    pragma Inline (Set_Gap);
    pragma Inline (Get_Spacing);
    pragma Inline (Set_Spacing);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Flex;


