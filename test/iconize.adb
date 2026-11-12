--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/iconize.cxx: an empty main window, and a control window
--  whose buttons hide, iconize and show it, or show the control window
--  itself.  Closing the control window ends the program.  Iconizing needs
--  a window manager on X11.  Guided by pofltk's Iconize.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;


function Iconize
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;

begin

    FLTK.Static.Parse_Args;

    declare

        Main_W : Win.Window := Win.Forge.Create (200, 200);

    begin

        Main_W.End_Current;
        Main_W.Show_With_Args;

        declare

            Control : Win.Window := Win.Forge.Create (120, 120);

            Hide_Button    : Btn.Button := Btn.Forge.Create (Control, 0, 0, 120, 30, "hide()");
            Iconize_Button : Btn.Button := Btn.Forge.Create
                (Control, 0, 30, 120, 30, "iconize()");
            Show_Button    : Btn.Button := Btn.Forge.Create (Control, 0, 60, 120, 30, "show()");
            Show_Button2   : Btn.Button := Btn.Forge.Create
                (Control, 0, 90, 120, 30, "show this");


            procedure Hide_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                pragma Unreferenced (Item);
            begin
                Main_W.Hide;
            end Hide_CB;


            procedure Iconize_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                pragma Unreferenced (Item);
            begin
                Main_W.Iconify;
            end Iconize_CB;


            procedure Show_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                pragma Unreferenced (Item);
            begin
                Main_W.Show;
            end Show_CB;


            procedure Show_This_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                pragma Unreferenced (Item);
            begin
                Control.Show;
            end Show_This_CB;


            --  FLTK's window_cb calls exit (0).  Hiding both windows ends
            --  Run instead, so the windows are finalized.
            procedure Window_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                pragma Unreferenced (Item);
            begin
                Main_W.Hide;
                Control.Hide;
            end Window_CB;

        begin

            Hide_Button.Set_Callback (Hide_CB'Unrestricted_Access);
            Iconize_Button.Set_Callback (Iconize_CB'Unrestricted_Access);
            Show_Button.Set_Callback (Show_CB'Unrestricted_Access);
            Show_Button2.Set_Callback (Show_This_CB'Unrestricted_Access);

            --  Fl_Box box(FL_NO_BOX,0,60,120,30,"Also try running\nwith -i switch");

            Control.End_Current;
            Control.Show;
            Control.Set_Callback (Window_CB'Unrestricted_Access);

            return FLTK.Run;

        end;

    end;

end Iconize;
