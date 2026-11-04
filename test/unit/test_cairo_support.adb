--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 114: Fl_Cairo_Window exists only in an FLTK built with Cairo
--  (Fl_Cairo_Window.H:26).  Without it a Cairo_Window is a Double_Window,
--  and a draw callback set on it would never be called, so Set_Cairo_Draw
--  raises Unsupported_Error.  This FLTK has Cairo, so a run here checks the
--  first case, that the callback is called; the raise was checked by putting
--  in front of fl_cairo_window_supported one that gives 0 (LD_PRELOAD).


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Groups.Windows.Double.Cairo,
    System;

use

    Checks,
    FLTK;


procedure Test_Cairo_Support is

    package Cai renames FLTK.Widgets.Groups.Windows.Double.Cairo;
    package Prb renames FLTK.Probe;

    use type System.Address;

    Draws, Null_Contexts : Natural := 0;

    procedure Note
           (This    : in out Cai.Cairo_Window;
            Context : in     System.Address)
    is
        pragma Unreferenced (This);
    begin
        Draws := Draws + 1;
        if Context = System.Null_Address then
            Null_Contexts := Null_Contexts + 1;
        end if;
    end Note;

    Window : Cai.Cairo_Window := Cai.Forge.Create (100, 80, "Cairo");

    procedure Set is
    begin
        Window.Set_Cairo_Draw (Note'Unrestricted_Access);
    end Set;

    Ignore : Boolean;

begin

    Window.Set_Resizable (Window);
    Check (Cai.Is_Supported = Prb.Has_Cairo,
        "Is_Supported says what this FLTK was built with: "
        & Boolean'Image (Cai.Is_Supported));

    if Cai.Is_Supported then
        No_Raise (Set'Access, "a Cairo draw callback can be set");
        Window.Show;
        for N in 1 .. 50 loop
            exit when Draws > 0;
            Ignore := FLTK.Wait (0.02) < 0.0;
        end loop;
        Check (Draws > 0, "the callback is called:" & Natural'Image (Draws));
        Check (Null_Contexts = 0, "each time with a context");
    else
        Raises (Set'Access, Unsupported_Error'Identity,
            "with no Cairo, Set_Cairo_Draw raises Unsupported_Error");
    end if;

    Summary;

end Test_Cairo_Support;
