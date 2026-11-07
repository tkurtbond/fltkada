

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Fl_Rect: a place and a size, and the arithmetic FLTK does on them.
--  FLTK's class is all inline code, so this is plain Ada, with nothing
--  from the shim.  Right and Bottom are the first coordinates outside the
--  rectangle.  Nothing is checked: a rectangle can be inset until its width
--  or height is negative, as FLTK's can.


with

    FLTK.Widgets;


package FLTK.Rects is


    type Rect is record
        X, Y, W, H : Integer := 0;
    end record;




    package Forge is

        --  At 0, 0.
        function Create
               (W, H : in Integer)
            return Rect;

        function Create
               (X, Y, W, H : in Integer)
            return Rect;

        --  Inset by the frame of Box, to what a box of that kind has inside.
        function Create
               (X, Y, W, H : in Integer;
                Box        : in Box_Kind)
            return Rect;

        --  Where Item is, and its size.
        function Create
               (Item : in FLTK.Widgets.Widget'Class)
            return Rect;

    end Forge;




    function Get_Right
           (This : in Rect)
        return Integer;

    function Get_Bottom
           (This : in Rect)
        return Integer;

    --  Moves the right or bottom edge alone, so the width or height changes.
    procedure Set_Right
           (This  : in out Rect;
            Right : in     Integer);

    procedure Set_Bottom
           (This   : in out Rect;
            Bottom : in     Integer);




    --  Shrinks This by D on each side, or enlarges it for a negative D.
    procedure Inset
           (This : in out Rect;
            D    : in     Integer);

    --  Shrinks This by each amount on its side, or enlarges it for a
    --  negative amount.
    procedure Inset
           (This                     : in out Rect;
            Left, Top, Right, Bottom : in     Integer);

    --  Shrinks This by the frame of Box, to what a box of that kind has
    --  inside.
    procedure Inset
           (This : in out Rect;
            Box  : in     Box_Kind);


private


    pragma Inline (Get_Right);
    pragma Inline (Get_Bottom);
    pragma Inline (Set_Right);
    pragma Inline (Set_Bottom);


end FLTK.Rects;


