

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/texteditor-simple.cxx: an Fl_Text_Editor
--  attached to a text buffer preloaded with some lines.


with

    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Groups.Windows.Double;


function Texteditor_Simple
    return Integer
is


    package TB  renames FLTK.Text_Buffers;
    package TE  renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package SU  renames Ada.Strings.Unbounded;


    Win : DW.Double_Window := DW.Forge.Create (640, 480, "Simple Fl_Text_Editor");

    Buff : TB.Text_Buffer := TB.Forge.Create;

    Edit : TE.Text_Editor := TE.Forge.Create (Win, 20, 20, 640 - 40, 480 - 40);

    Lines : SU.Unbounded_String;


begin


    Edit.Set_Buffer (Buff);        --  attach the text buffer to our editor widget
    Win.Set_Resizable (Edit);
    Win.Show;

    for N in 0 .. 23 loop
        SU.Append (Lines, "line " & Ada.Strings.Fixed.Trim (Integer'Image (N), Ada.Strings.Left)
                   & ASCII.LF);
    end loop;
    Buff.Set_Entire_Text (SU.To_String (Lines));

    return FLTK.Run;


end Texteditor_Simple;
