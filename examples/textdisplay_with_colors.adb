

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/textdisplay-with-colors.cxx: an
--  Fl_Text_Display whose lines are colored by a style buffer.


with

    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Groups.Windows;


function Textdisplay_With_Colors
    return Integer
is


    package TB  renames FLTK.Text_Buffers;
    package TD  renames FLTK.Widgets.Groups.Text_Displays;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type TD.Styles.Style_Index;


    --  Style table
    --  FLTK keeps a pointer to this, so it must live as long as the display
    Style_Table : constant TD.Styles.Style_Array :=
        --         FONT COLOR               FONT FACE     FONT SIZE
        --         -----------------------  ------------  ---------
        ('A' => (Hue => FLTK.Red_Color,         Font => FLTK.Courier, Size => 18, others => <>),
         'B' => (Hue => FLTK.Dark_Yellow_Color, Font => FLTK.Courier, Size => 18, others => <>),
         'C' => (Hue => FLTK.Dark_Green_Color,  Font => FLTK.Courier, Size => 18, others => <>),
         'D' => (Hue => FLTK.Blue_Color,        Font => FLTK.Courier, Size => 18, others => <>));

    The_Window : Win.Window :=
        Win.Forge.Create (640, 480, "Simple Text Display With Colors");

    Disp : TD.Text_Display := TD.Forge.Create (The_Window, 20, 20, 640 - 40, 480 - 40);

    TBuff : TB.Text_Buffer := TB.Forge.Create;     --  text buffer
    SBuff : TB.Text_Buffer := TB.Forge.Create;     --  style buffer

    LF : constant Character := ASCII.LF;


begin


    Disp.Set_Buffer (TBuff);
    Disp.Highlight_Data (SBuff, Style_Table);

    --  Text
    TBuff.Set_Entire_Text
       ("Red Line 1" & LF & "Yel Line 2" & LF & "Grn Line 3" & LF & "Blu Line 4" & LF &
        "Red Line 5" & LF & "Yel Line 6" & LF & "Grn Line 7" & LF & "Blu Line 8" & LF);

    --  Style for text
    SBuff.Set_Entire_Text
       ("AAAAAAAAAA" & LF & "BBBBBBBBBB" & LF & "CCCCCCCCCC" & LF & "DDDDDDDDDD" & LF &
        "AAAAAAAAAA" & LF & "BBBBBBBBBB" & LF & "CCCCCCCCCC" & LF & "DDDDDDDDDD" & LF);

    The_Window.Set_Resizable (Disp);
    The_Window.Show;

    return FLTK.Run;


end Textdisplay_With_Colors;
