--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  What every page of the unit tests shares (FLTK's test/unittests.h):
--  the test area's size and place, and the main window, which can draw
--  marks in its corners for the viewport test.


with

    FLTK.Widgets.Groups.Windows.Double;


package Unittests_Common is


    Main_Window_W : constant := 700;
    Main_Window_H : constant := 600;

    Browser_X : constant := 10;
    Browser_Y : constant := 25;
    Browser_W : constant := 150;
    Browser_H : constant := Main_Window_H - 35;

    Test_Area_X : constant := Browser_W + 20;
    Test_Area_Y : constant := 25;
    Test_Area_W : constant := Main_Window_W - Browser_W - 30;
    Test_Area_H : constant := Main_Window_H - 35;


    type Widget_Access is access all FLTK.Widgets.Widget'Class;


    type Main_Window is new FLTK.Widgets.Groups.Windows.Double.Double_Window with record
        Draw_Alignment_Test : Boolean := False;
    end record;

    overriding procedure Draw
           (This : in out Main_Window);

    --  Whether the window draws the marks in its corners.
    procedure Test_Alignment
           (This : in out Main_Window;
            Show : in     Boolean);

    type Main_Window_Access is access all Main_Window;


    --  The yellow box, 18 high, that labels a test and explains it in its
    --  tooltip, in the current group.
    procedure Add_Box
           (X, Y, W : in Integer;
            Label   : in String;
            Tooltip : in String);

    --  An 80 by 18 box with Label inside on the left, over a column of
    --  tests.
    procedure Add_Heading
           (X, Y  : in Integer;
            Label : in String);

    Main_Win : Main_Window_Access;


end Unittests_Common;


