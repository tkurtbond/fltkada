

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Tabbed is


    type Tabbed_Group is new Group with private;

    type Tabbed_Group_Reference (Data : not null access Tabbed_Group'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Tabbed_Group;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Tabbed_Group;

    end Forge;


    --  What the tabs do when there are too many to fit.  Compress, the
    --  default, overlaps them; Clip leaves out those that don't fit;
    --  Pulldown adds a menu of them all at the right; Drag lets the tab bar
    --  be dragged sideways.
    type Overflow_Kind is (Compress_Overflow, Clip_Overflow, Pulldown_Overflow, Drag_Overflow);




    --  Child Area  --

    procedure Get_Client_Area
           (This       : in     Tabbed_Group;
            Tab_Height : in     Natural;
            X, Y, W, H :    out Integer);




    --  Operation  --

    function Get_Push
           (This : in Tabbed_Group)
        return access Widget'Class;

    procedure Set_Push
           (This : in out Tabbed_Group;
            Item : in out Widget'Class);

    function Get_Visible
           (This : in Tabbed_Group)
        return access Widget'Class;

    procedure Set_Visible
           (This : in out Tabbed_Group;
            Item : in out Widget'Class);

    function Get_Which
           (This             : in Tabbed_Group;
            Event_X, Event_Y : in Integer)
        return access Widget'Class;




    --  Tab Appearance  --

    --  How each tab's label is placed in its tab.  The default is
    --  Align_Center.
    function Get_Tab_Alignment
           (This : in Tabbed_Group)
        return Alignment;

    procedure Set_Tab_Alignment
           (This      : in out Tabbed_Group;
            New_Align : in     Alignment);

    --  FLTK keeps no way to read this back.
    procedure Handle_Overflow
           (This : in out Tabbed_Group;
            Kind : in     Overflow_Kind);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Tabbed_Group);

    procedure Redraw_Tabs
           (This : in out Tabbed_Group);

    function Handle
           (This  : in out Tabbed_Group;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Tabbed_Group is new Group with null record;

    overriding procedure Initialize
           (This : in out Tabbed_Group);

    overriding procedure Finalize
           (This : in out Tabbed_Group);

    procedure Extra_Init
           (This       : in out Tabbed_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Tabbed_Group)
    with Inline;


    pragma Inline (Get_Client_Area);

    pragma Inline (Get_Push);
    pragma Inline (Set_Push);
    pragma Inline (Get_Visible);
    pragma Inline (Set_Visible);
    pragma Inline (Get_Which);

    pragma Inline (Get_Tab_Alignment);
    pragma Inline (Set_Tab_Alignment);
    pragma Inline (Handle_Overflow);

    pragma Inline (Draw);
    pragma Inline (Redraw_Tabs);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Tabbed;


