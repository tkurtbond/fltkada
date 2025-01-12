

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Windows.Double is


    type Double_Window is new Window with private;

    type Double_Window_Reference (Data : not null access Double_Window'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Double_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Double_Window;

    end Forge;




    procedure Show
           (This : in out Double_Window);

    procedure Show_With_Args
           (This : in out Double_Window);

    procedure Hide
           (This : in out Double_Window);

    procedure Flush
           (This : in out Double_Window);




    procedure Resize
           (This       : in out Double_Window;
            X, Y, W, H : in     Integer);


private


    type Double_Window is new Window with null record;

    overriding procedure Initialize
           (This : in out Double_Window);

    overriding procedure Finalize
           (This : in out Double_Window);

    procedure Extra_Init
           (This       : in out Double_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Double_Window)
    with Inline;


    pragma Inline (Show);
    pragma Inline (Show_With_Args);
    pragma Inline (Hide);
    pragma Inline (Flush);

    pragma Inline (Resize);


end FLTK.Widgets.Groups.Windows.Double;


