

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/browser-simple.cxx: a Hold_Browser and a
--  Multi_Browser, each with a callback that prints what's picked.


with

    Ada.Text_IO,
    FLTK.Static,
    FLTK.Widgets,
    FLTK.Widgets.Groups.Browsers.Textline,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Browsers.Textline.Multi,
    FLTK.Widgets.Groups.Windows.Double;


function Browser_Simple
    return Integer
is


    package TIO renames Ada.Text_IO;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Hld renames FLTK.Widgets.Groups.Browsers.Textline.Hold;
    package Mlt renames FLTK.Widgets.Groups.Browsers.Textline.Multi;
    package TLB renames FLTK.Widgets.Groups.Browsers.Textline;
    package Wdg renames FLTK.Widgets;


    --  Fl_Browser::text(0) is NULL, which glibc's printf shows as "(null)".
    function Text_Of
           (Brow : in TLB.Textline_Browser'Class;
            Line : in Natural)
        return String is
    begin
        if Line = 0 then
            return "(null)";
        else
            return Brow.Get_Line_Text (Line);
        end if;
    end Text_Of;


    procedure Hold_Browser_Callback
           (Item : in out Wdg.Widget'Class)
    is
        Brow : TLB.Textline_Browser'Class renames TLB.Textline_Browser'Class (Item);
        Line : constant Natural := Brow.Selected_Index;
    begin
        TIO.Put_Line
           ("[hold browser] item" & Integer'Image (Line) & " picked: " & Text_Of (Brow, Line));
    end Hold_Browser_Callback;


    procedure Multi_Browser_Callback
           (Item : in out Wdg.Widget'Class)
    is
        Brow : TLB.Textline_Browser'Class renames TLB.Textline_Browser'Class (Item);
    begin
        --  Multi browser can have many items selected, so print all selected
        for T in 1 .. Brow.Number_Of_Lines loop
            if Brow.Is_Selected (T) then
                TIO.Put_Line
                   ("[multi browser] item" & Integer'Image (T) & " selected: "
                    & Brow.Get_Line_Text (T));
            end if;
        end loop;
        TIO.New_Line;
    end Multi_Browser_Callback;


begin


    FLTK.Static.Set_Scheme ("gtk+");

    declare
        Win : Dbl.Double_Window := Dbl.Forge.Create (250, 220, "Simple Browser");

        --  Create Hold Browser
        Hold_Brow : Hld.Hold_Browser :=
            Hld.Forge.Create (Win, 10, 10, 250 - 20, 80, "Hold");

        --  Create Multi Browser
        Multi_Brow : Mlt.Multi_Browser :=
            Mlt.Forge.Create (Win, 10, 120, 250 - 20, 80, "Multi");
    begin
        Hold_Brow.Set_Callback (Hold_Browser_Callback'Unrestricted_Access);
        --  Add some items
        Hold_Brow.Add ("One");
        Hold_Brow.Add ("Two");
        Hold_Brow.Add ("Three");
        Hold_Brow.Add ("Four");
        --  Preselect first item "One"
        Hold_Brow.Set_Select (Line => 1);

        Multi_Brow.Set_Callback (Multi_Browser_Callback'Unrestricted_Access);
        --  Add some items
        Multi_Brow.Add ("Aaa");
        Multi_Brow.Add ("Bbb");
        Multi_Brow.Add ("Ccc");
        Multi_Brow.Add ("Ddd");
        --  Preselect first two items "Aaa" and "Bbb"
        Multi_Brow.Set_Select (Line => 1);
        Multi_Brow.Set_Select (Line => 2);

        Win.Set_Resizable (Win);
        Win.Show_With_Args;

        return FLTK.Run;
    end;


end Browser_Simple;
