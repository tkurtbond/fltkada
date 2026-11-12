--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Boxes;

use type

    FLTK.Alignment;


package body Unittests_Viewport is


    package Bx renames FLTK.Widgets.Boxes;

    use Unittests_Common;


    --  A box that has the main window mark its corners while it is shown.
    type Viewport_Test is new Bx.Box with null record;

    overriding procedure Show
           (This : in out Viewport_Test);

    overriding procedure Hide
           (This : in out Viewport_Test);


    procedure Show
           (This : in out Viewport_Test) is
    begin
        Bx.Box (This).Show;
        Main_Win.Test_Alignment (True);
    end Show;


    procedure Hide
           (This : in out Viewport_Test) is
    begin
        Bx.Box (This).Hide;
        Main_Win.Test_Alignment (False);
    end Hide;


    type Viewport_Test_Access is access Viewport_Test;


    function Create
        return Widget_Access
    is
        Box : constant Viewport_Test_Access := new Viewport_Test'
           (Bx.Forge.Create (Test_Area_X, Test_Area_Y, Test_Area_W, Test_Area_H) with null record);
    begin
        Box.Set_Label
           ("Testing Viewport Alignment" & ASCII.LF & ASCII.LF &
            "Only green lines should be visible." & ASCII.LF &
            "If red lines are visible in the corners of this window," & ASCII.LF &
            "your viewport alignment and clipping is off." & ASCII.LF &
            "If there is a space between the green lines and the window border," & ASCII.LF &
            "the viewport is off, but some clipping may be working." & ASCII.LF &
            "Also, your window size may be off to begin with.");
        Box.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Center + FLTK.Align_Wrap);
        Box.Set_Box (FLTK.Border_Box);
        return Widget_Access (Box);
    end Create;


end Unittests_Viewport;
