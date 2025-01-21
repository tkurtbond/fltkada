

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Browsers.Textline.Hold is


    type Hold_Browser is new Textline_Browser with private;

    type Hold_Browser_Reference (Data : not null access Hold_Browser'Class) is
        limited null record with Implicit_Dereference => Data;


    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Hold_Browser;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Hold_Browser;

    end Forge;


private


    type Hold_Browser is new Textline_Browser with null record;

    overriding procedure Initialize
           (This : in out Hold_Browser);

    overriding procedure Finalize
           (This : in out Hold_Browser);

    procedure Extra_Init
           (This       : in out Hold_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Hold_Browser);


end FLTK.Widgets.Groups.Browsers.Textline.Hold;


