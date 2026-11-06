


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  The tooltip settings, and a tooltip for each part of a widget, after
--  pofltk's examples/Tooltips.Mod.
--
--  The left and right halves of the box have tooltips of their own:  the
--  box's Handle tells FLTK which half the mouse is in, and its area.  The
--  check button has a widget's usual tooltip, and turns tooltips on and
--  off.


with

    FLTK.Events,
    FLTK.Tooltips,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Windows;


function Tooltips
    return Integer
is


    package Ev  renames FLTK.Events;
    package Tip renames FLTK.Tooltips;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Win renames FLTK.Widgets.Groups.Windows;


    type Halves is new Bx.Box with record
        In_Right : Boolean := False;
    end record;

    overriding function Handle
           (This  : in out Halves;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    function Is_Right
           (This : in Halves'Class)
        return Boolean is (Ev.Mouse_X >= This.Get_X + This.Get_W / 2);


    procedure Enter_Half
           (This  : in out Halves'Class;
            Right : in     Boolean)
    is
        Half : constant Integer := This.Get_W / 2;
    begin
        This.In_Right := Right;
        if Right then
            Tip.Enter_Area (This, This.Get_X + Half, This.Get_Y, Half, This.Get_H,
                "the right half");
        else
            Tip.Enter_Area (This, This.Get_X, This.Get_Y, Half, This.Get_H, "the left half");
        end if;
    end Enter_Half;


    function Handle
           (This  : in out Halves;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        case Event is
            when FLTK.Enter =>
                Enter_Half (This, Is_Right (This));
                return FLTK.Handled;
            when FLTK.Move =>
                if Is_Right (This) /= This.In_Right then
                    Enter_Half (This, not This.In_Right);
                end if;
                return FLTK.Handled;
            when FLTK.Leave =>
                Tip.Enter_Area (This, 0, 0, 0, 0, "");
                return FLTK.Handled;
            when others =>
                return Bx.Box (This).Handle (Event);
        end case;
    end Handle;


    Window : Win.Window := Win.Forge.Create (300, 130, "Tooltips");
    Box    : Halves := (Bx.Forge.Create (Window, 20, 20, 260, 50, "two halves") with others => <>);
    Check  : Chk.Check_Button := Chk.Forge.Create (Window, 20, 85, 200, 25, "show tooltips");


    procedure Enable
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Tip.Set_Enabled (Check.Is_On);
    end Enable;


begin


    Tip.Set_Delay (0.2);
    Tip.Set_Background_Color (FLTK.Yellow_Color);
    Tip.Set_Text_Font (FLTK.Courier);
    Tip.Set_Text_Size (16);

    Box.Set_Box (FLTK.Up_Box);
    Check.Set_State (Btn.On);
    Check.Set_Tooltip ("this one is the widget's own");
    Check.Set_Callback (Enable'Unrestricted_Access);
    Window.Show;

    return FLTK.Run;


end Tooltips;


