

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Characters.Latin_1,
    Ada.Command_Line,
    Ada.Text_IO,
    FLTK.Filenames;


procedure Dirlist is

    package Latin renames Ada.Characters.Latin_1;
    package ACom  renames Ada.Command_Line;
    package TIO   renames Ada.Text_IO;
    package Fil   renames FLTK.Filenames;

begin

    TIO.Put_Line ("Test program for FLTK directory listing function.");
    TIO.New_Line;
    TIO.Put ("Input: ");
    for Index in 1 .. ACom.Argument_Count loop
        TIO.Put (ACom.Argument (Index));
        exit when Index = ACom.Argument_Count;
        TIO.Put (" ");
    end loop;
    TIO.New_Line;
    TIO.New_Line;

    if ACom.Argument_Count /= 1 then
        TIO.Put_Line ("Error: Need exactly one argument to denote a directory to list.");
        ACom.Set_Exit_Status (ACom.Failure);
        return;
    end if;

    declare
        Name : constant Fil.Path_String := Fil.Expand (ACom.Argument (1));
    begin
        if not Fil.Is_Directory (Name) then
            TIO.Put_Line ("Error: " & Name & " is not a valid directory.");
            ACom.Set_Exit_Status (ACom.Failure);
            return;
        end if;

        declare
            The_List : constant Fil.File_List := Fil.Get_Listing (Name, Fil.Alpha_Sort'Access);
        begin
            TIO.Put_Line ("Alphabetical Sort:");
            for Index in 1 .. The_List.Length loop
                TIO.Put_Line (Latin.HT & The_List.Item (Index));
            end loop;
            TIO.New_Line;
        end;

        declare
            The_List : constant Fil.File_List := Fil.Get_Listing (Name, Fil.Case_Alpha_Sort'Access);
        begin
            TIO.Put_Line ("Case Insensitive Alphabetical Sort:");
            for Index in 1 .. The_List.Length loop
                TIO.Put_Line (Latin.HT & The_List.Item (Index));
            end loop;
            TIO.New_Line;
        end;

        declare
            The_List : constant Fil.File_List := Fil.Get_Listing (Name, Fil.Numeric_Sort'Access);
        begin
            TIO.Put_Line ("Numeric Sort:");
            for Index in 1 .. The_List.Length loop
                TIO.Put_Line (Latin.HT & The_List.Item (Index));
            end loop;
            TIO.New_Line;
        end;

        declare
            The_List : constant Fil.File_List :=
                Fil.Get_Listing (Name, Fil.Case_Numeric_Sort'Access);
        begin
            TIO.Put_Line ("Case Insensitive Numeric Sort:");
            for Index in 1 .. The_List.Length loop
                TIO.Put_Line (Latin.HT & The_List.Item (Index));
            end loop;
            TIO.New_Line;
        end;
    end;

end Dirlist;


