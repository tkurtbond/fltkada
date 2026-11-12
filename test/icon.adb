--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/icon.cxx: a window's icon, a square of one colour the
--  choice picks, or none.  The window system shows it in the title bar,
--  the task bar and the like; Wayland has none.  The window copies its
--  icon, so the image can go once it is set.  Guided by pofltk's
--  Icon.Mod.


with

    FLTK.Images.RGB,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices;

use type

    FLTK.Color,
    FLTK.Size_Type;


function Icon
    return Integer
is

    package RGB renames FLTK.Images.RGB;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Chc renames FLTK.Widgets.Menus.Choices;

    --  Each item's colour, as FLTK's menu items have it for their data.
    Colors : constant array (1 .. 4) of FLTK.Color :=
       (0, FLTK.Red_Color, FLTK.Green_Color, FLTK.Blue_Color);

    Window : Dbl.Double_Window := Dbl.Forge.Create (400, 300, "FLTK Window Icon Test");
    Choice : Chc.Choice := Chc.Forge.Create (Window, 120, 100, 200, 25, "Window icon:");


    --  FLTK's choice_cb.  Its own callback, which the choice's do_callback
    --  calls, has no data, so it sets no icon; that is the "None" item's.
    procedure Choice_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        C : constant FLTK.Color := Colors (Choice.Chosen_Index);
    begin
        if C /= 0 then
            --  choice was "Red", "Green"..
            declare
                Buffer  : constant FLTK.Color_Component_Array (1 .. 32 * 32 * 3) :=
                    (others => 0);
                RGBIcon : RGB.RGB_Image := RGB.Forge.Create (Buffer, 32, 32, 3);
            begin
                RGBIcon.Color_Average (C, 0.0);
                Window.Set_Icon (RGBIcon);  --  once assigned, RGBIcon can go
            end;
        else
            --  choice was "None"..
            Window.Reset_Icons;             --  reset window icon
        end if;
    end Choice_CB;

begin

    Choice.Add ("None",  Choice_CB'Unrestricted_Access);
    Choice.Add ("Red",   Choice_CB'Unrestricted_Access);
    Choice.Add ("Green", Choice_CB'Unrestricted_Access);
    Choice.Add ("Blue",  Choice_CB'Unrestricted_Access);
    Choice.Set_Chosen (1);  --  FLTK's menu() chooses the first item
    Choice.Set_Callback (Choice_CB'Unrestricted_Access);
    Choice.Set_When (FLTK.When_Release_Always);
    Choice.Set_Tooltip
        ("Sets the application icon for window manager. " &
         "Affects e.g. titlebar, toolbar, Dock, Alt-Tab..");

    Window.End_Current;
    Window.Show_With_Args;
    Choice.Do_Callback;  --  make default take effect

    return FLTK.Run;

end Icon;
