

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/texteditor-with-dynamic-colors.cxx: an
--  Fl_Text_Editor that colors digits 0-4 green and 5-9 red as you type,
--  by keeping a style buffer in step from the text buffer's modify
--  callback.
--
--  The C++ MyEditor subclass hands its static modify callback "this" as
--  user data; here My_Editor is a Text_Editor extension holding its two
--  buffers, and the callback is a nested procedure that refers to the
--  one My_Editor object directly.


with

    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Groups.Windows;


function Texteditor_With_Dynamic_Colors
    return Integer
is


    package TB  renames FLTK.Text_Buffers;
    package TD  renames FLTK.Widgets.Groups.Text_Displays;
    package TE  renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package Win renames FLTK.Widgets.Groups.Windows;


    type My_Editor is new TE.Text_Editor with record
        TBuff : TB.Text_Buffer := TB.Forge.Create;     --  text buffer
        SBuff : TB.Text_Buffer := TB.Forge.Create;     --  style buffer
    end record;


    --  Style table for the respective styles
    Style_Table : constant TD.Styles.Style_Array :=
        --         FONT COLOR               FONT FACE     FONT SIZE
        --         -----------------------  ------------  ---------
        ('A' => (Hue => FLTK.Black_Color,       Font => FLTK.Courier, Size => 14, others => <>),
         'B' => (Hue => FLTK.Dark_Green_Color,  Font => FLTK.Courier, Size => 14, others => <>),
         'C' => (Hue => FLTK.Red_Color,         Font => FLTK.Courier, Size => 14, others => <>));


    The_Window : Win.Window := Win.Forge.Create (720, 480, "Text Editor With Dynamic Coloring");

    Win_W : constant Integer := The_Window.Get_W;
    Win_H : constant Integer := The_Window.Get_H;

    Med : My_Editor :=
        (TE.Forge.Create (The_Window, 10, 10, Win_W - 20, Win_H - 20) with others => <>);


    --  Modify callback handler
    procedure Modify_Callback
           (Place        : in TB.Position;     --  position of update
            Inserted     : in Natural;         --  number of inserted chars
            Deleted      : in Natural;         --  number of deleted chars
            Ignore_R     : in Natural;         --  number of restyled chars (unused here)
            Ignore_T     : in String)          --  text deleted (unused here)
    is
        Start, Finish : Natural;
    begin
        --  Nothing inserted or deleted?
        if Inserted = 0 and Deleted = 0 then
            return;
        end if;

        --  Characters inserted into tbuff?
        --      Insert same number of chars into style buffer..
        if Inserted > 0 then
            --  insert "A"s into style buffer
            Med.SBuff.Insert_Text (Place, (1 .. Inserted => 'A'));
        end if;

        --  Characters deleted from tbuff?
        --     Delete same number of chars from style buffer..
        if Deleted > 0 then
            Med.SBuff.Remove_Text (Place, Place + Deleted);
            return;     --  nothing more to do; deleting won't affect our single char coloring
        end if;

        --  Focus on characters inserted
        Start  := Place;
        Finish := Place + Inserted;

        --  SIMPLE EXAMPLE:
        --      Color the digits 0-4 in green, 5-9 in red.
        for I in Start .. Finish - 1 loop
            case Med.TBuff.Character_At (I) is
                when '0' .. '4' => Med.SBuff.Replace_Text (I, I + 1, "B");   --  style 'B' (green)
                when '5' .. '9' => Med.SBuff.Replace_Text (I, I + 1, "C");   --  style 'C' (red)
                when others     => Med.SBuff.Replace_Text (I, I + 1, "A");   --  style 'A' (black)
            end case;
        end loop;
    end Modify_Callback;


    LF : constant Character := ASCII.LF;


begin


    Med.Set_Buffer (Med.TBuff);
    Med.Highlight_Data (Med.SBuff, Style_Table);
    Med.TBuff.Add_Modify_Details_Callback (Modify_Callback'Unrestricted_Access);

    --  Initial text in editor.
    Med.TBuff.Set_Entire_Text
       ("In this editor, digits 0-4 are shown in green, 5-9 shown in red." & LF &
        "So here's some numbers 0123456789." & LF &
        "Coloring is handled automatically by the add_modify_callback()." & LF &
        LF &
        "You can type here to test. ");

    The_Window.Set_Resizable (Med);
    The_Window.Show;

    return FLTK.Run;


end Texteditor_With_Dynamic_Colors;
