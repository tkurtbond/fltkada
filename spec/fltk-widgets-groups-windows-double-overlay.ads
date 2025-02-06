

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Windows.Double.Overlay is


    type Overlay_Window is new Double_Window with private;

    type Overlay_Window_Reference (Data : not null access Overlay_Window'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Overlay_Window;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Overlay_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Overlay_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Overlay_Window;

    end Forge;




    --  Visibility  --

    procedure Show
           (This : in out Overlay_Window);

    procedure Show_With_Args
           (This : in out Overlay_Window);

    procedure Hide
           (This : in out Overlay_Window);

    procedure Flush
           (This : in out Overlay_Window);




    --  Settings  --

    function Can_Do_Overlay
           (This : in Overlay_Window)
        return Boolean;

    procedure Resize
           (This       : in out Overlay_Window;
            X, Y, W, H : in     Integer);




    --  Drawing  --

    --  You must override this subprogram
    procedure Draw_Overlay
           (This : in out Overlay_Window);

    procedure Redraw_Overlay
           (This : in out Overlay_Window);


private


    type Overlay_Window is new Double_Window with null record;

    overriding procedure Initialize
           (This : in out Overlay_Window);

    overriding procedure Finalize
           (This : in out Overlay_Window);

    procedure Extra_Init
           (This       : in out Overlay_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Overlay_Window)
    with Inline;


    pragma Inline (Show);
    pragma Inline (Show_With_Args);
    pragma Inline (Hide);
    pragma Inline (Flush);

    pragma Inline (Can_Do_Overlay);
    pragma Inline (Resize);

    pragma Inline (Redraw_Overlay);


end FLTK.Widgets.Groups.Windows.Double.Overlay;


