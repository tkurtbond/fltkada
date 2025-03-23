

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Command_Line,
    Ada.Text_IO,
    FLTK.Filenames;


procedure Filename is

    package ACom  renames Ada.Command_Line;
    package TIO   renames Ada.Text_IO;
    package Fil   renames FLTK.Filenames;

begin

    TIO.Put_Line ("Test program for FLTK filename absolute and expand functions.");
    TIO.New_Line;
    TIO.Put ("Input: ");

    if ACom.Argument_Count /= 1 then
        TIO.Put_Line ("Error: Need exactly one filename argument.");
        ACom.Set_Exit_Status (ACom.Failure);
        return;
    end if;

    TIO.Put_Line (ACom.Argument (1));
    TIO.New_Line;

    TIO.Put_Line ("Absolute: " & Fil.Absolute (ACom.Argument (1)));
    TIO.Put_Line ("Expanded: " & Fil.Expand (ACom.Argument (1)));

end Filename;


