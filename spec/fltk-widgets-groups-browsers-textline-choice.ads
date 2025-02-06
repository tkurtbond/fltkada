

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Select_Browsers except select is a reserved word


package FLTK.Widgets.Groups.Browsers.Textline.Choice is


    type Choice_Browser is new Textline_Browser with private;

    type Choice_Browser_Reference (Data : not null access Choice_Browser'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Choice_Browser;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Choice_Browser;

    end Forge;


private


    type Choice_Browser is new Textline_Browser with null record;

    overriding procedure Initialize
           (This : in out Choice_Browser);

    overriding procedure Finalize
           (This : in out Choice_Browser);

    procedure Extra_Init
           (This       : in out Choice_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Choice_Browser);


end FLTK.Widgets.Groups.Browsers.Textline.Choice;


