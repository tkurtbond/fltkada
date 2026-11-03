

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  The test tools themselves: FLTK.Probe captures a widget's pixels, and
--  its synthetic events reach widgets as the user's would.  Every other
--  test relies on these, so they are checked first.


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text;

use

    Checks,
    FLTK;


procedure Test_Probe is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;

    Pressed : Natural := 0;

    procedure Count
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Pressed := Pressed + 1;
    end Count;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 150, "Test_Probe");

    Red_Box : Wdg.Boxes.Box := Wdg.Boxes.Forge.Create
       (Window, Flat_Box, 10, 10, 40, 30);

    Button : Wdg.Buttons.Button := Wdg.Buttons.Forge.Create
       (Window, 60, 10, 80, 30, "Press");

    Input : Wdg.Inputs.Text.Text_Input := Wdg.Inputs.Text.Forge.Create
       (Window, 10, 60, 150, 30);

    Read_End, Write_End : Prb.File_Descriptor;

begin

    Red_Box.Set_Background_Color (RGB_Red_Color);
    Button.Set_Callback (Count'Unrestricted_Access);

    Check (Prb.To_RGB (255, 0, 0) = 16#FF0000#, "To_RGB packs red, green, blue");

    Check (Prb.Capture (Red_Box), "Capture of a box is its size");
    Check (Prb.Pixel (20, 15) = Prb.To_RGB (255, 0, 0),
        "a red flat box's pixel is red:" & Prb.RGB'Image (Prb.Pixel (20, 15)));
    Check (Prb.Pixel (40, 0) = -1, "a pixel outside the capture is -1");
    Prb.Release;

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;

    Check (Prb.Mouse (Window, Push, 100, 25), "a push on the button is used");
    Check (Prb.Mouse (Window, Release, 100, 25), "the release is used");
    Check (Pressed = 1, "push and release on a button run its callback once");

    if Input.Take_Focus then
        Check (Prb.Key (Keydown, Press ('a'), Text => "a"), "a key reaches the focused input");
        Check (Input.Get_Value = "a", "the input has the key's text: """ & Input.Get_Value & """");
    else
        Check (False, "the input takes the focus");
    end if;

    Check (not Prb.Modal, "no dialog is up");

    Prb.Make_Pipe (Read_End, Write_End);
    Check (Prb.Write (Write_End, "hello") = 5, "Write to a pipe writes it all");
    Check (Prb.Read (Read_End) = "hello", "Read from the pipe reads it back");
    Prb.Close (Read_End);
    Prb.Close (Write_End);

    Check (Prb.Has_X11 or Prb.Has_Wayland, "this FLTK has a display back end");

    Window.Hide;
    Summary;

end Test_Probe;

