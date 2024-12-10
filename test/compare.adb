

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Text_IO,
    FLTK.Filenames;


procedure Compare is

    package TIO renames Ada.Text_IO;
    package FFN renames FLTK.Filenames;

    Aardvark : String := "aardvark";
    Zebra    : String := "Zebra";
    Two      : String := "item_2";
    Ten      : String := "item_10";
    Cap_Ten  : String := "Item_10";

begin

    TIO.Put_Line ("Alphabetic comparison of " & Aardvark & " and " & Zebra & ": " &
        FFN.Comparison'Image (FFN.Alpha_Sort (Aardvark, Zebra)));
    TIO.Put_Line ("Case insensitive comparison of " & Aardvark & " and " & Zebra & ": " &
        FFN.Comparison'Image (FFN.Case_Alpha_Sort (Aardvark, Zebra)));
    TIO.New_Line;

    TIO.Put_Line ("Alphabetic comparison of " & Two & " and " & Ten & ": " &
        FFN.Comparison'Image (FFN.Alpha_Sort (Two, Ten)));
    TIO.Put_Line ("Numeric comparison of " & Two & " and " & Ten & ": " &
        FFN.Comparison'Image (FFN.Numeric_Sort (Two, Ten)));
    TIO.New_Line;

    TIO.Put_Line ("Numeric comparison of " & Two & " and " & Cap_Ten & ": " &
        FFN.Comparison'Image (FFN.Numeric_Sort (Two, Cap_Ten)));
    TIO.Put_Line ("Case insensitive comparison of " & Two & " and " & Cap_Ten & ": " &
        FFN.Comparison'Image (FFN.Case_Numeric_Sort (Two, Cap_Ten)));

end Compare;


