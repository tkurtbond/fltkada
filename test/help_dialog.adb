--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/help_dialog.cxx: an HTML file in FLTK's own help window.
--
--  help_dialog [file]
--
--  Shows the file, by default help_dialog.html in the current directory.
--  FLTK's test/help_dialog.html is under FLTK's licence, so FLTKAda's
--  test/help_dialog.html is a page of its own that tries the same things;
--  give FLTK's as the argument, from FLTK's test/, to see that one.
--  Animated GIFs move: a timer redraws the windows every tenth of a
--  second.  FLTK's redraws the first window only, which is the help
--  window; FLTK made that window, so it has no Ada object, and
--  FLTK.Screen.Redraw redraws them all instead.


with

    Ada.Command_Line,
    FLTK.Help_Dialogs,
    FLTK.Images.Pixmaps.GIF,
    FLTK.Screen,
    FLTK.Static;


function Help_Dialog
    return Integer
is

    procedure Refresh is
    begin
        FLTK.Screen.Redraw;
        FLTK.Static.Repeat_Timeout (1.0 / 10.0, Refresh'Unrestricted_Access);
    end Refresh;

    Count : Natural;

begin

    --  Load GIFs that move as Animated_GIF_Images.
    FLTK.Images.Pixmaps.GIF.Set_Animate (True);

    declare
        Help : FLTK.Help_Dialogs.Help_Dialog := FLTK.Help_Dialogs.Forge.Create;
    begin
        FLTK.Static.Parse_Args (Count);
        if Count < Ada.Command_Line.Argument_Count then
            Help.Load (Ada.Command_Line.Argument (Count + 1));
        else
            Help.Load ("help_dialog.html");
        end if;

        Help.Show_With_Args;

        FLTK.Static.Add_Timeout (1.0 / 10.0, Refresh'Unrestricted_Access);
        return FLTK.Run;
    end;

end Help_Dialog;
