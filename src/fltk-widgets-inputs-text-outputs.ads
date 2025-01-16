

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Inputs.Text.Outputs is


    type Output is new Text_Input with private;

    type Output_Reference (Data : not null access Output'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Output;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Output;

    end Forge;


private


    type Output is new Text_Input with null record;

    overriding procedure Initialize
           (This : in out Output);

    overriding procedure Finalize
           (This : in out Output);

    procedure Extra_Init
           (This       : in out Output;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Output)
    with Inline;


end FLTK.Widgets.Inputs.Text.Outputs;


