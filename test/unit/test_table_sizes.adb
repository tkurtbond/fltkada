--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 136: a table's row heights and column widths were
--  Positive, but Fl_Table takes and gives 0, a row or column that is
--  not shown.  FLTK's test/table.cxx sets Row Height and Col Width to 0
--  when asked; the port of it could only set 1.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Table_Sizes is

    package Tab renames FLTK.Widgets.Groups.Tables;
    package Win renames FLTK.Widgets.Groups.Windows;

    Zero : constant Natural := 0;

    Window : Win.Window := Win.Forge.Create (300, 200, "sizes");
    T      : Tab.Table := Tab.Forge.Create (Window, 0, 0, 300, 200);

begin

    T.Set_Rows (4);
    T.Set_Columns (3);

    T.Set_All_Rows_Height (Zero);
    Check (T.Get_Row_Height (1) = 0 and T.Get_Row_Height (4) = 0, "every row's height can be 0");
    T.Set_All_Columns_Width (Zero);
    Check (T.Get_Column_Width (1) = 0 and T.Get_Column_Width (3) = 0,
        "every column's width can be 0");

    T.Set_All_Rows_Height (20);
    T.Set_All_Columns_Width (50);
    T.Set_Row_Height (2, Zero);
    Check (T.Get_Row_Height (2) = 0 and T.Get_Row_Height (3) = 20, "one row's height can be 0");
    T.Set_Column_Width (3, Zero);
    Check (T.Get_Column_Width (3) = 0 and T.Get_Column_Width (2) = 50,
        "one column's width can be 0");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Table_Sizes;
