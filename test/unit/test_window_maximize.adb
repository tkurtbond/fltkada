--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 20, after pofltk's TestWidget and HaltScreenNum:
--  Maximize, Un_Maximize and Is_Maximized; Get_Size_Range;
--  Free_Position; and the screen a window is on, numbered from 1 as
--  FLTK.Screen numbers them.  FLTK resizes a maximized window itself on
--  X11 with no window manager; under Wayland the compositor decides, so
--  the size checks are skipped there.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Screen,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Window_Maximize is

    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 150, "Maximize");

    Min_W, Min_H, Max_W, Max_H, DW, DH : Integer;
    Aspect : Boolean;

    function Settled
           (Want : in Boolean)
        return Boolean is
    begin
        for N in 1 .. 100 loop
            exit when Window.Is_Maximized = Want;
            exit when FLTK.Wait (0.01) < 0.0;
        end loop;
        return Window.Is_Maximized = Want;
    end Settled;

    procedure Beyond is
        Other : Win.Window := Win.Forge.Create (0, 0, 100, 80, "Beyond");
    begin
        Other.Set_Screen_Num (FLTK.Screen.Count + 1);
    end Beyond;

begin

    declare
        Other : Win.Window := Win.Forge.Create (0, 0, 100, 80, "Other");
    begin
        Other.Set_Size_Range (50, 50);
        Other.Maximize;
        Check (not Other.Is_Maximized, "Maximize of a window not shown does nothing");
    end;

    --  A size range with steps and a shape, read back.
    declare
        Other : Win.Window := Win.Forge.Create (0, 0, 100, 80, "Other");
    begin
        Check (not Other.Has_Size_Range, "no size range given");
        Other.Set_Size_Range (100, 80, 0, 0, 5, 5, True);
        Other.Get_Size_Range (Min_W, Min_H, Max_W, Max_H, DW, DH, Aspect);
        Check (Other.Has_Size_Range and Min_W = 100 and Min_H = 80 and Max_W = 0 and Max_H = 0
            and DW = 5 and DH = 5 and Aspect, "Set_Size_Range with steps, read back");
        Other.Set_Size_Range (60, 50, 200, 150);
        Other.Get_Size_Range (Min_W, Min_H, Max_W, Max_H, DW, DH, Aspect);
        Check (Min_W = 60 and Min_H = 50 and Max_W = 200 and Max_H = 150
            and DW = 0 and DH = 0 and not Aspect, "Set_Size_Range clears the steps and shape");
    end;

    --  The screen.
    Check (Window.Get_Screen_Num = 1, "a window never shown is on screen 1");
    declare
        Other : Win.Window := Win.Forge.Create (0, 0, 100, 80, "Other");
    begin
        Other.Set_Screen_Num (FLTK.Screen.Count);
        Check (Other.Get_Screen_Num = FLTK.Screen.Count, "Set_Screen_Num, read back");
    end;
    Raises (Beyond'Access, Constraint_Error'Identity,
        "Set_Screen_Num of a screen there isn't raises (HaltScreenNum)");

    --  Free_Position.
    declare
        Other : Win.Window := Win.Forge.Create (30, 40, 100, 80, "Placed");
    begin
        Check (Other.Is_Position_Forced, "a window made at a place keeps it");
        Other.Free_Position;
        Check (not Other.Is_Position_Forced, "Free_Position lets the window manager place it");
        Check (Other.Get_X = 30 and Other.Get_Y = 40, "and leaves its X and Y");
    end;

    --  Maximize of a shown window.
    Window.Set_Size_Range (100, 100);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Check (Window.Get_Screen_Num = 1, "a window on the only screen is on 1");
    declare
        W0 : constant Integer := Window.Get_W;
        H0 : constant Integer := Window.Get_H;
        X, Y, W, H : Integer;
    begin
        Window.Maximize;
        Check (Settled (True), "Maximize");
        if not Prb.On_Wayland then
            FLTK.Screen.Work_Area (X, Y, W, H, 1);
            Check (Window.Get_X = X and Window.Get_Y = Y and Window.Get_W = W
                and Window.Get_H = H, "fills the work area, with no window manager");
        else
            Skip ("Maximize fills the work area:  the compositor decides under Wayland");
        end if;
        Window.Un_Maximize;
        Check (Settled (False), "Un_Maximize");
        if not Prb.On_Wayland then
            Check (Window.Get_W = W0 and Window.Get_H = H0, "gives the window back its size");
        else
            Skip ("Un_Maximize gives back the size:  the compositor decides under Wayland");
        end if;
    end;

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Window_Maximize;
