

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Windows.Single.Menu is


    type Menu_Window is new Single_Window with private;

    type Menu_Window_Reference (Data : not null access Menu_Window'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Menu_Window;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Menu_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Menu_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Menu_Window;

    end Forge;




    procedure Show
           (This : in out Menu_Window);

    procedure Hide
           (This : in out Menu_Window);

    procedure Flush
           (This : in out Menu_Window);

    procedure Erase
           (This : in out Menu_Window);




    function Is_Overlay
           (This : in Menu_Window)
        return Boolean;

    procedure Set_Overlay
           (This  : in out Menu_Window;
            Value : in     Boolean := True);

    procedure Clear_Overlay
           (This : in out Menu_Window);


private


    type Menu_Window is new Single_Window with null record;

    overriding procedure Initialize
           (This : in out Menu_Window);

    overriding procedure Finalize
           (This : in out Menu_Window);

    procedure Extra_Init
           (This       : in out Menu_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Menu_Window)
    with Inline;


    pragma Inline (Show);
    pragma Inline (Hide);
    pragma Inline (Flush);
    pragma Inline (Erase);

    pragma Inline (Is_Overlay);
    pragma Inline (Set_Overlay);
    pragma Inline (Clear_Overlay);


end FLTK.Widgets.Groups.Windows.Single.Menu;


