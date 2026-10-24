

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  An Ada port of FLTK's examples/animgifimage-simple.cxx: plays an
--  animated GIF, scaled to fit, as the backdrop of a box's label.
--
--  Usage: animgifimage-simple [file.gif]
--
--  Deliberate differences: the C++ version prints the image's raw ld()
--  value, which is the load error code for an animated GIF. The binding
--  exposes that as Fail_Code, which is what is printed here.


with

    Ada.Command_Line,
    Ada.Text_IO,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment;


function Animgifimage_Simple
    return Integer
is

    package ACL  renames Ada.Command_Line;
    package TIO  renames Ada.Text_IO;
    package Anim renames FLTK.Images.Pixmaps.GIF.Animated;
    package Box  renames FLTK.Widgets.Boxes;
    package WD   renames FLTK.Widgets.Groups.Windows.Double;


    Default_Image : constant String := "../test/images/fltk_animated.gif";


    function Image_Name
        return String is
    begin
        if ACL.Argument_Count >= 1 then
            return ACL.Argument (1);
        else
            return Default_Image;
        end if;
    end Image_Name;


    function Img
           (Value : in Integer)
        return String
    is
        Result : constant String := Integer'Image (Value);
    begin
        return (if Value < 0 then Result else Result (Result'First + 1 .. Result'Last));
    end Img;


    The_Window : WD.Double_Window := WD.Forge.Create (400, 300, "Fl_Anim_GIF_Image demo");

    --  prepare a canvas (widget) for the animation
    Canvas : Box.Box := Box.Forge.Create
       (The_Window, 20, 40, The_Window.Get_W - 40, The_Window.Get_H - 80,
        "Hello from FLTK GIF-animation!");


begin

    Canvas.Set_Alignment (FLTK.Align_Top + FLTK.Align_Image_Backdrop);
    Canvas.Set_Label_Size (20);

    The_Window.Set_Resizable (The_Window);
    The_Window.Show;

    declare
        --  Create and load the animated gif as image of the Canvas widget
        --  and start it immediately. The Dont_Resize_Canvas flag tells the
        --  animation *not* to change the canvas size (which is the default).
        Animation : Anim.Animated_GIF_Image := Anim.Forge.Create
           (Filename => Image_Name,
            Canvas   => Canvas,
            Flags    => Anim.Flag_Dont_Resize_Canvas);
    begin
        --  resize animation to canvas size
        Animation.Scale (Canvas.Get_W, Canvas.Get_H, Proportional => True, Can_Expand => True);

        --  check if loading succeeded
        TIO.Put_Line
           (Animation.Name & ": ld=" & Img (Animation.Fail_Code) &
            ", valid=" & Img (Boolean'Pos (Animation.Is_Loaded)) &
            ", frames=" & Img (Animation.Frames) &
            ", size=" & Img (Animation.Get_Canvas_W) & "x" & Img (Animation.Get_Canvas_H));

        if Animation.Is_Loaded then
            return FLTK.Run;
        end if;
    end;

    return 0;

end Animgifimage_Simple;


