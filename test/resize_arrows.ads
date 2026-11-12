--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/resize-arrows.h and .cxx, which the resize-example programs
--  share:  boxes with an arrow across them, black on white, showing a
--  width or a height.  Guided by pofltk's ResizeArrows.Mod.


with

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups;


package Resize_Arrows is


    --  A horizontal arrow across the middle, with no border and the label
    --  below.
    type Harrow is new FLTK.Widgets.Boxes.Box with null record;

    --  A vertical arrow down the middle, with no border and the label to
    --  the right.
    type Varrow is new FLTK.Widgets.Boxes.Box with null record;


    overriding procedure Draw
           (This : in out Harrow);

    overriding procedure Draw
           (This : in out Varrow);


    package Forge is

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Harrow;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Varrow;

    end Forge;


end Resize_Arrows;

