


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 38 (FLTKAda-BUGS.md): Clipboard_Contains and the kind it is given.
--  FLTK's drivers tell the kinds apart by comparing the pointer with
--  Fl::clipboard_plain_text or Fl::clipboard_image, not the text: on Wayland
--  always (fl_wayland_clipboard_dnd.cxx:51), and on X11 while this program
--  owns the clipboard (Fl_x.cxx:724-725).  A kind passed as a copy of the
--  text was never the same pointer, so text this program had just copied
--  was not found.


with

    Checks,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Clipboard_Kinds is

    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Clipboard_Kinds");

begin

    Window.Show;
    for N in 1 .. 10 loop
        exit when FLTK.Wait (0.02) < 0.0;
    end loop;

    FLTK.Static.Copy ("copied text", FLTK.Static.Clipboard);
    for N in 1 .. 5 loop
        exit when FLTK.Wait (0.02) < 0.0;
    end loop;

    Check (FLTK.Static.Clipboard_Contains ("text/plain"),
        "the clipboard holds the text this program copied");
    Check (not FLTK.Static.Clipboard_Contains ("image"),
        "the clipboard holds no image");
    Check (not FLTK.Static.Clipboard_Contains ("no such kind"),
        "the clipboard holds no unknown kind");

    Summary;

end Test_Clipboard_Kinds;


