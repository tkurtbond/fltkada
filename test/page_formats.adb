

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Text_IO,
    FLTK.Devices.Surface.Paged;


procedure Page_Formats is

    package TIO renames Ada.Text_IO;
    package PD  renames FLTK.Devices.Surface.Paged;

begin

    for Format in PD.Page_Formats'Range loop
        TIO.Put_Line (PD.Page_Formats (Format).Name);
        TIO.Put_Line (Integer'Image (PD.Page_Formats (Format).Width));
        TIO.Put_Line (Integer'Image (PD.Page_Formats (Format).Height));
        TIO.New_Line;
    end loop;

end Page_Formats;


