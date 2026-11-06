

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A file input, which shows a path's directories as buttons above its
--  text, after pofltk's examples/FileInputs.Mod.  Click a directory to cut
--  the path back to it.  The box below shows the path as it changes.


with

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text.File;


function File_Inputs
    return Integer
is


    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Fin renames FLTK.Widgets.Inputs.Text.File;


    Window : Win.Window := Win.Forge.Create (400, 120, "FileInputs");
    Path   : Fin.File_Input := Fin.Forge.Create (Window, 50, 20, 330, 40, "path:");
    Shown  : Bx.Box := Bx.Forge.Create (Window, 50, 70, 330, 30);


    procedure Changed
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Shown.Set_Label (Path.Get_Value);
    end Changed;


begin


    Path.Set_Value ("/usr/share/doc/fltk-devel/html");
    Path.Set_When (FLTK.When_Changed);
    Path.Set_Callback (Changed'Unrestricted_Access);
    Changed (Path);
    Window.Show;

    return FLTK.Run;


end File_Inputs;

