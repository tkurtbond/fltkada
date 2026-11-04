


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 61: Fl_Window::shape on X11.  For an image
--  with an alpha channel, Fl_X11_Window_Driver::shape_alpha_ reads w() by
--  h() pixels of data(), which holds only data_w() by data_h(), so an
--  image scaled larger is read past its end.  FLTK keeps the image's
--  pointer as shape_, and for a bitmap combine_mask copies shape_ again
--  each time the window's size changes (Fl_X11_Window_Driver.cxx:146-152,
--  301-302), so an image freed before the window is read from freed
--  memory.  Valgrind sees both.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Images.Bitmaps,
    FLTK.Images.RGB,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Windows.Double;

use

    Checks,
    FLTK;


procedure Test_Window_Shape is

    package Bmp renames FLTK.Images.Bitmaps;
    package RGB renames FLTK.Images.RGB;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    type Data_Access is access Color_Component_Array;

    procedure Free is new Ada.Unchecked_Deallocation (Color_Component_Array, Data_Access);

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Bits : constant Color_Component_Array
        (1 .. Size_Type (Bmp.Bytes_Needed (100)) * 100) := (others => 16#FF#);

    Window : Win.Window := Win.Forge.Create (0, 0, 100, 100, "Test_Window_Shape");

    --  Ten by ten pixels with alpha, on the heap so valgrind sees its end.
    Pixels : Data_Access := new Color_Component_Array'(1 .. 10 * 10 * 4 => 255);

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump (3);

    --  An image scaled to the window's size, larger than its data.
    declare
        Small : RGB.RGB_Image := RGB.Forge.Create (Pixels.all, 10, 10, 4);
    begin
        Small.Scale (100, 100, Proportional => False, Can_Expand => True);
        Check (Small.Get_W = 100 and then Small.Get_H = 100,
            "the image is scaled:" & Integer'Image (Small.Get_W));
        Window.Shape (Small);
        Pump (3);
    end;
    Free (Pixels);
    Check (not Window.Has_Border, "a shaped window has no border");

    --  A bitmap that goes before the window does, and the window resized.
    declare
        Mask : constant Bmp.Bitmap := Bmp.Forge.Create (Bits, 100, 100);
    begin
        Window.Shape (Mask);
        Pump (3);
    end;
    Window.Resize (0, 0, 150, 120);
    Window.Redraw;
    Pump (5);
    Check (Window.Get_W = 150 and then Window.Get_H = 120,
        "a shaped window resized:" & Integer'Image (Window.Get_W)
        & Integer'Image (Window.Get_H));
    Window.Resize (0, 0, 120, 150);
    Window.Redraw;
    Pump (5);
    Check (Window.Is_Shown, "a shaped window whose image went is still shown");

    --  Another kind of window, shaped and finalized with its shape.
    declare
        Other : Dbl.Double_Window := Dbl.Forge.Create (0, 0, 100, 100, "Other");
        Mask  : constant Bmp.Bitmap := Bmp.Forge.Create (Bits, 100, 100);
    begin
        Other.Show;
        Other.Shape (Mask);
        Pump (3);
        Check (not Other.Has_Border, "a double window shaped");
        Other.Hide;
    end;

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Window_Shape;


