

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Valuators.Sliders.Scrollbars;


package FLTK.Widgets.Groups.Scrolls is


    type Scroll is new Group with private;

    type Scroll_Reference (Data : not null access Scroll'Class) is limited null record
        with Implicit_Dereference => Data;

    --  FLTK's Fl_Scroll::type: Neither is 0, which shows no scrollbars,
    --  and the rest are Fl_Scroll's HORIZONTAL to BOTH_ALWAYS.
    type Scroll_Kind is
       (Neither,
        Horizontal,
        Vertical,
        Both,
        Always_On,
        Horizontal_Always,
        Vertical_Always,
        Both_Always);


    type Region is record
        X, Y, W, H : Integer;
    end record;

    type Scrollbar_Data is record
        X, Y, W, H      : Integer;
        Size, Total     : Natural;
        First, Position : Integer;
    end record;

    type Scroll_Info is record
        Child_Box           : Region;
        Inner_Inc, Inner_Ex : Region;
        H_Needed, V_Needed  : Boolean;
        H_Data, V_Data      : Scrollbar_Data;
        Scroll_Size         : Natural;
    end record;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Scroll;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Scroll;

    end Forge;




    --  Attributes  --

    function H_Bar
           (This : in out Scroll)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference;

    function V_Bar
           (This : in out Scroll)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference;




    --  Contents  --

    procedure Clear
           (This : in out Scroll);




    --  Scrolling  --

    procedure Scroll_To
           (This : in out Scroll;
            X, Y : in     Integer);

    --  These two functions are far too similar in name and
    --  function to the Get_X and Get_Y for Widgets.
    function Get_Scroll_X
           (This : in Scroll)
        return Integer;

    function Get_Scroll_Y
           (This : in Scroll)
        return Integer;




    --  Scrollbar Settings  --

    function Get_Scrollbar_Size
           (This : in Scroll)
        return Integer;

    procedure Set_Scrollbar_Size
           (This : in out Scroll;
            To   : in     Integer);

    --  Fl_Scroll::scrollbar.align (): where the scrollbars go.  Align_Left
    --  puts the vertical one at the left, Align_Top the horizontal one at
    --  the top; otherwise they are right and bottom.  Starts as
    --  Align_Bottom, a valuator's default (Fl_Scroll.cxx).
    function Get_Scrollbar_Alignment
           (This : in Scroll)
        return Alignment;

    procedure Set_Scrollbar_Alignment
           (This : in out Scroll;
            To   : in     Alignment);

    function Get_Kind
           (This : in Scroll)
        return Scroll_Kind;

    procedure Set_Kind
           (This : in out Scroll;
            Mode : in     Scroll_Kind);




    --  Dimensions  --

    procedure Resize
           (This       : in out Scroll;
            X, Y, W, H : in     Integer);

    procedure Recalculate_Scrollbars
           (This : in     Scroll;
            Data :    out Scroll_Info);




    --  Drawing, Events  --

    procedure Bounding_Box
           (This       : in     Scroll;
            X, Y, W, H :    out Integer);

    procedure Draw
           (This : in out Scroll);

    function Handle
           (This  : in out Scroll;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Scroll is new Group with record
        Horizon, Vertigo : aliased Valuators.Sliders.Scrollbars.Scrollbar;
    end record;

    overriding procedure Initialize
           (This : in out Scroll);

    overriding procedure Finalize
           (This : in out Scroll);

    procedure Extra_Init
           (This       : in out Scroll;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Scroll);


    pragma Inline (Clear);

    pragma Inline (Scroll_To);
    pragma Inline (Get_Scroll_X);
    pragma Inline (Get_Scroll_Y);

    pragma Inline (Get_Scrollbar_Size);
    pragma Inline (Set_Scrollbar_Size);
    pragma Inline (Get_Scrollbar_Alignment);
    pragma Inline (Set_Scrollbar_Alignment);
    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);

    pragma Inline (Resize);

    pragma Inline (Bounding_Box);
    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Scrolls;


