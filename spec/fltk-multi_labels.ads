

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    FLTK.Images,
    FLTK.Widgets;

private with

    Interfaces.C.Strings;


package FLTK.Multi_Labels is


    --  A label made of two parts drawn side by side, the first then the
    --  second just to its right.  Each part is either text, an image, or
    --  another Multi_Label, so longer labels can be built by chaining.
    --
    --  Neither the parts given to a Multi_Label nor the Multi_Label itself
    --  are copied by whatever it is assigned to, so they must last at least
    --  as long as that.
    type Multi_Label is new Wrapper with private;




    package Forge is

        function Create
            return Multi_Label;

    end Forge;




    --  Parts  --

    procedure Set_First
           (This : in out Multi_Label;
            Text : in     String;
            Kind : in     Label_Kind := Normal_Label);

    procedure Set_First
           (This : in out Multi_Label;
            Pict : in out FLTK.Images.Image'Class);

    procedure Set_First
           (This : in out Multi_Label;
            Next : in out Multi_Label'Class);

    procedure Set_Second
           (This : in out Multi_Label;
            Text : in     String;
            Kind : in     Label_Kind := Normal_Label);

    procedure Set_Second
           (This : in out Multi_Label;
            Pict : in out FLTK.Images.Image'Class);

    procedure Set_Second
           (This : in out Multi_Label;
            Next : in out Multi_Label'Class);




    --  Widgets  --

    --  Item shows Label, which must last as long as Item does or until Item
    --  is given another label.  Text set with Set_Label replaces it, as a
    --  Normal_Label; Get_Label is "" while it shows; Set_Label_Kind changes
    --  nothing, since its parts have kinds of their own.  pofltk 55.
    procedure Set_Multi_Label
           (Item  : in out FLTK.Widgets.Widget'Class;
            Label : in out Multi_Label'Class);


private


    type Multi_Label is new Wrapper with record
        My_Text_A, My_Text_B : Interfaces.C.Strings.chars_ptr;
    end record;

    overriding procedure Finalize
           (This : in out Multi_Label);


    pragma Inline (Set_First);
    pragma Inline (Set_Second);

    pragma Inline (Set_Multi_Label);


end FLTK.Multi_Labels;


