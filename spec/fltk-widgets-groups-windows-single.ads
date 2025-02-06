

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Windows.Single is


    type Single_Window is new Window with private;

    type Single_Window_Reference (Data : not null access Single_Window'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Single_Window;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Single_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Single_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Single_Window;

    end Forge;




    --  Visibility  --

    procedure Show
           (This : in out Single_Window);

    procedure Show_With_Args
           (This : in out Single_Window);

    procedure Flush
           (This : in out Single_Window);




    --  Current  --

    procedure Make_Current
           (This : in out Single_Window);


private


    type Single_Window is new Window with null record;

    overriding procedure Initialize
           (This : in out Single_Window);

    overriding procedure Finalize
           (This : in out Single_Window);

    procedure Extra_Init
           (This       : in out Single_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Single_Window)
    with Inline;


    pragma Inline (Show);
    pragma Inline (Show_With_Args);
    pragma Inline (Flush);

    pragma Inline (Make_Current);


end FLTK.Widgets.Groups.Windows.Single;


