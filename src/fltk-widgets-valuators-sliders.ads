

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Valuators.Sliders is


    type Slider is new Valuator with private;

    type Slider_Reference (Data : not null access Slider'Class) is limited null record
        with Implicit_Dereference => Data;

    type Slider_Kind is
       (Vertical_Kind, Horizontal_Kind,
        Vert_Fill_Kind, Hor_Fill_Kind,
        Vert_Nice_Kind, Hor_Nice_Kind);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Slider;

        function Create
               (Kind       : in Slider_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Slider;

    end Forge;




    procedure Set_Bounds
           (This     : in out Slider;
            Min, Max : in     Long_Float);

    function Get_Box
           (This : in Slider)
        return Box_Kind;

    procedure Set_Box
           (This : in out Slider;
            To   : in     Box_Kind);

    function Get_Slide_Size
           (This : in Slider)
        return Float;

    procedure Set_Slide_Size
           (This : in out Slider;
            To   : in     Long_Float);

    procedure Set_Scrollvalue
           (This            : in out Slider;
            Pos_First_Line  : in     Natural;
            Lines_In_Window : in     Natural;
            First_Line_Num  : in     Natural;
            Total_Lines     : in     Natural);




    procedure Draw
           (This : in out Slider);

    procedure Draw
           (This       : in out Slider;
            X, Y, W, H : in     Integer);

    function Handle
           (This  : in out Slider;
            Event : in     Event_Kind)
        return Event_Outcome;

    function Handle
           (This       : in out Slider;
            Event      : in     Event_Kind;
            X, Y, W, H : in     Integer)
        return Event_Outcome;




    function Get_Slider_Type
           (This : in Slider)
        return Slider_Kind;

    package Extra is

        procedure Set_Slider_Type
               (This : in out Slider;
                To   : in     Slider_Kind);

    end Extra;


private


    type Slider is new Valuator with null record;

    overriding procedure Initialize
           (This : in out Slider);

    overriding procedure Finalize
           (This : in out Slider);

    procedure Extra_Init
           (This       : in out Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Slider)
    with Inline;


    pragma Inline (Set_Bounds);
    pragma Inline (Get_Box);
    pragma Inline (Set_Box);
    pragma Inline (Get_Slide_Size);
    pragma Inline (Set_Slide_Size);
    pragma Inline (Set_Scrollvalue);

    pragma Inline (Draw);
    pragma Inline (Handle);

    pragma Inline (Get_Slider_Type);


end FLTK.Widgets.Valuators.Sliders;


