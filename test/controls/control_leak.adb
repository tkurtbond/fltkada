--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Negative control: a widget whose Ada object is never finalized leaks
--  the C++ widget the shim allocated, which vg-check.sh must flag.

with FLTK.Widgets.Boxes;
with Leaks;

procedure Control_Leak is
    Leaked : Leaks.Box_Access;
    pragma Warnings (Off, Leaked);  --  never read, and that is the point
begin
    Leaked := new FLTK.Widgets.Boxes.Box'
       (FLTK.Widgets.Boxes.Forge.Create (0, 0, 10, 10, "leak"));
    Leaked := null;
end Control_Leak;
