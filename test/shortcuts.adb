


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Choosing a button's shortcut with a shortcut button, after pofltk's
--  examples/Shortcuts.Mod.
--
--  Click the shortcut button and press a key, and that key is the other
--  button's shortcut.  The shortcut button takes keys until it loses the
--  focus, so click the other button before trying it.  Each press of the
--  other button is counted on standard output.


with

    Ada.Text_IO,
    FLTK.Widgets.Buttons.Shortcut,
    FLTK.Widgets.Groups.Windows;


function Shortcuts
    return Integer
is


    package Wdg renames FLTK.Widgets;
    package Btn renames FLTK.Widgets.Buttons;
    package Sht renames FLTK.Widgets.Buttons.Shortcut;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type FLTK.Modifier;


    Window  : Win.Window := Win.Forge.Create (300, 120, "Shortcuts");
    Choose  : Sht.Shortcut_Button := Sht.Forge.Create (Window, 110, 20, 170, 30, "shortcut:");
    Button  : Btn.Button := Btn.Forge.Create (Window, 110, 70, 170, 30, "press me");
    Presses : Natural := 0;


    procedure Chosen
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Button.Set_Shortcut (Choose.Get_Value);
    end Chosen;


    procedure Pressed
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Presses := Presses + 1;
        Ada.Text_IO.Put_Line ("pressed" & Natural'Image (Presses));
    end Pressed;


begin


    Choose.Set_When (FLTK.When_Changed);
    Choose.Set_Callback (Chosen'Unrestricted_Access);
    Button.Set_Callback (Pressed'Unrestricted_Access);
    Choose.Set_Value (FLTK.Mod_Alt + 'p');
    Button.Set_Shortcut (FLTK.Mod_Alt + 'p');
    Window.Show;

    return FLTK.Run;


end Shortcuts;


