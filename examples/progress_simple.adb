

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/progress-simple.cxx: pressing the button
--  adds an Fl_Progress to the window, runs it from 0% to 100% while
--  keeping the GUI alive with Fl::check(), then removes it again.


with

    Ada.Strings.Fixed,
    FLTK.Widgets,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Progress_Bars;


function Progress_Simple
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Prg renames FLTK.Widgets.Progress_Bars;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;


    The_Window : Win.Window := Win.Forge.Create (220, 90);

    Butt : Btn.Button := Btn.Forge.Create (The_Window, 10, 10, 100, 25, "Press");


    procedure Butt_CB
           (Item : in out Wdg.Widget'Class)
    is
        Ignore : Boolean;
    begin
        Item.Deactivate;                           --  prevent button from being pressed again
        Ignore := FLTK.Check;                      --  give fltk some cpu to gray out button
        declare
            --  add progress bar to the window..
            Progress : Prg.Progress_Bar := Prg.Forge.Create (The_Window, 10, 50, 200, 30);
        begin
            Progress.Set_Minimum (0.0);            --  set progress range to be 0.0 ~ 1.0
            Progress.Set_Maximum (1.0);
            Progress.Set_Background_Color (16#88888800#);  --  background color
            Progress.Set_Selection_Color (16#4444ff00#);   --  progress bar color
            Progress.Set_Label_Color (FLTK.White_Color);   --  percent text color
            for T in 1 .. 500 loop
                --  update progress bar with 0.0 ~ 1.0 value
                Progress.Set_Value (Float (Long_Float (T) / 500.0));
                --  update progress bar's label
                Progress.Set_Label
                   (Ada.Strings.Fixed.Trim
                       (Integer'Image (Integer (Long_Float'Truncation
                           (Long_Float (T) / 500.0 * 100.0))), Ada.Strings.Left)
                    & "%");
                Ignore := FLTK.Check;              --  give fltk some cpu to update the screen
                delay 0.001;                       --  'your stuff' that's compute intensive
            end loop;
            The_Window.Remove (Progress);          --  remove progress bar from window
        end;                                       --  deallocate it
        Item.Activate;                             --  reactivate button
        The_Window.Redraw;                         --  tell window to redraw now progress removed
    end Butt_CB;


begin


    Butt.Set_Callback (Butt_CB'Unrestricted_Access);
    The_Window.Set_Resizable (The_Window);
    The_Window.Show;

    return FLTK.Run;


end Progress_Simple;
