

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Windows.Double.Overlay is


    -------------
    --  Types  --
    -------------

    type Overlay_Window is new Double_Window with private;

    type Overlay_Window_Reference (Data : not null access Overlay_Window'Class) is
        limited null record with Implicit_Dereference => Data;




    --------------------
    --  Constructors  --
    --------------------

    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Overlay_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Overlay_Window;

    end Forge;




    ---------------
    --  Display  --
    ---------------

    procedure Show
           (This : in out Overlay_Window);

    procedure Hide
           (This : in out Overlay_Window);

    procedure Flush
           (This : in out Overlay_Window);




    -------------
    --  Other  --
    -------------

    function Can_Do_Overlay
           (This : in Overlay_Window)
        return Boolean;




    ----------------------------------
    --  Drawing and Event Handling  --
    ----------------------------------

    procedure Draw
           (This : in out Overlay_Window);

    procedure Draw_Overlay
           (This : in out Overlay_Window) is null;

    procedure Redraw_Overlay
           (This : in out Overlay_Window);

    function Handle
           (This  : in out Overlay_Window;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Overlay_Window is new Double_Window with null record;

    overriding procedure Finalize
           (This : in out Overlay_Window);

    procedure Extra_Init
           (This       : in out Overlay_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;


    pragma Inline (Show);
    pragma Inline (Hide);
    pragma Inline (Flush);

    pragma Inline (Can_Do_Overlay);

    pragma Inline (Draw);
    pragma Inline (Redraw_Overlay);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Windows.Double.Overlay;

