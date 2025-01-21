

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    System;


package FLTK.Widgets.Groups.Windows.Double.Cairo is


    --  If FLTK has not been built with Cairo support then
    --  this will just be a duplicate of Double_Window and the
    --  callback set with Set_Cairo_Draw will never be triggered.

    --  Building with Cairo support requires either of
    --  1. CMake option FLTK_OPTION_CAIRO_WINDOW
    --  2. configure -enable-cairo
    --  when building FLTK itself.


    type Cairo_Window is new Double_Window with private;

    type Cairo_Window_Reference (Data : not null access Cairo_Window'Class) is
        limited null record with Implicit_Dereference => Data;

    type Cairo_Callback is access procedure
           (This    : in out Cairo_Window;
            Context : in     System.Address);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Cairo_Window;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Cairo_Window;

        function Create
               (W, H : in Integer;
                Text : in String)
            return Cairo_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer;
                Text   : in     String)
            return Cairo_Window;

        function Create
               (W, H : in Integer)
            return Cairo_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer)
            return Cairo_Window;

    end Forge;




    procedure Set_Cairo_Draw
           (This : in out Cairo_Window;
            Func : in     Cairo_Callback);




    procedure Draw
           (This : in out Cairo_Window);


private


    type Cairo_Window is new Double_Window with record
        My_Func : Cairo_Callback;
    end record;

    overriding procedure Initialize
           (This : in out Cairo_Window);

    overriding procedure Finalize
           (This : in out Cairo_Window);

    procedure Extra_Init
           (This       : in out Cairo_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Cairo_Window);


    pragma Inline (Set_Cairo_Draw);

    pragma Inline (Draw);


end FLTK.Widgets.Groups.Windows.Double.Cairo;


