--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with FLTK.Widgets.Boxes;

package Leaks is
    type Box_Access is access FLTK.Widgets.Boxes.Box;
    pragma No_Heap_Finalization (Box_Access);
end Leaks;
