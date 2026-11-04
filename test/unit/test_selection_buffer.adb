--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 50: Wayland has no selection buffer.  Its Copy to the selection
--  buffer keeps the text but offers it to no one, and its Paste from it
--  returns at once (fl_wayland_clipboard_dnd.cxx:617-618, 659-686).  X11
--  has both.  The clipboard works on both.


with

    Checks,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text;

use

    Checks;


procedure Test_Selection_Buffer is

    package Inp renames FLTK.Widgets.Inputs.Text;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (200, 50, "Selection");
    Input  : Inp.Text_Input := Inp.Forge.Create (Window, 10, 10, 180, 25);

    procedure Pump is
    begin
        for I in 1 .. 10 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    function Pasted
           (Kind : in FLTK.Static.Buffer_Kind;
            Text : in String)
        return String is
    begin
        Input.Set_Value ("");
        FLTK.Static.Copy (Text, Kind);
        FLTK.Static.Paste (Input, Kind);
        Pump;
        return Input.Get_Value;
    end Pasted;

begin

    Window.End_Current;
    Window.Show;
    Pump;
    FLTK.Events.Set_Focus (Input);
    Pump;

    declare
        Clip : constant String := Pasted (FLTK.Static.Clipboard, "clip");
        Sel  : constant String := Pasted (FLTK.Static.Selection, "sel");
    begin
        Check (Clip = "clip", "the clipboard pastes: """ & Clip & """");
        if Prb.On_Wayland then
            Check (Sel = "", "on Wayland the selection buffer pastes nothing: """ & Sel & """");
        else
            Check (Sel = "sel", "on X11 the selection buffer pastes: """ & Sel & """");
        end if;
    end;

    Summary;

end Test_Selection_Buffer;
