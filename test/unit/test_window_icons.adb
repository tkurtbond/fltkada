

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestImages icons:  a window's icons and the
--  default ones.  FLTK copies them, and X11's driver gives the window
--  manager each one's width, height and pixels (Probe.Icon_Words).
--  Wayland ignores them, so there only nothing breaking is checked.


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.RGB,
    FLTK.Probe,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Window_Icons is

    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package Win renames FLTK.Widgets.Groups.Windows;

    Bits : constant Color_Component_Array (1 .. 24) := (others => 128);

    Ignore : Boolean;

    procedure Show
           (Item : in out Win.Window) is
    begin
        Item.Show;
        for N in 1 .. 100 loop
            exit when Item.Is_Shown;
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
        Ignore := FLTK.Check;
    end Show;

    --  Checks that Item's icons are Count words long, on X11.
    procedure Words
           (Item  : in Win.Window;
            Count : in Natural;
            Name  : in String)
    is
        N : constant Integer := Prb.Icon_Words (Item);
    begin
        if N >= 0 then
            Check (N = Count, Name);
        else
            Skip (Name & ":  not on X11");
        end if;
    end Words;

begin

    declare
        Window : Win.Window := Win.Forge.Create (40, 40, "icons");
    begin
        Show (Window);
        Words (Window, 0, "a window starts with no icon");
        declare
            Icons : constant RGB.RGB_Image_Array :=
               (RGB.Forge.Create (Bits, 4, 2), RGB.Forge.Create (Bits, 2, 1));
        begin
            Window.Set_Icons (Icons);
        end;
        Ignore := FLTK.Check;
        Words (Window, 2 + 4 * 2 + 2 + 2 * 1, "Set_Icons:  both, after the images are gone");
        Window.Set_Icon (RGB.Forge.Create (Bits, 2, 2));
        Ignore := FLTK.Check;
        Words (Window, 2 + 2 * 2, "Set_Icon replaces them");
        Window.Hide;
    end;

    Win.Set_Default_Icon (RGB.Forge.Create (Bits, 4, 2));
    declare
        Window : Win.Window := Win.Forge.Create (40, 40, "default icon");
    begin
        Show (Window);
        Words (Window, 2 + 4 * 2, "a window shown after Set_Default_Icon has it");
        Window.Set_Icon (RGB.Forge.Create (Bits, 2, 1));
        Ignore := FLTK.Check;
        Words (Window, 2 + 2 * 1, "its own icon instead");
        Window.Reset_Icons;
        Ignore := FLTK.Check;
        Words (Window, 2 + 4 * 2, "Reset_Icons goes back to the default");
        Window.Hide;
    end;

    Win.Reset_Default_Icons;
    declare
        Window : Win.Window := Win.Forge.Create (40, 40, "no icon");
    begin
        Show (Window);
        Words (Window, 0, "and Reset_Default_Icons removes it");
        Window.Hide;
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Window_Icons;
