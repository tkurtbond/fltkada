--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 38: Fl_Browser_ turns its scroll position into
--  its top line only in the private update_top, which draw and find_item
--  call (Fl_Browser_.cxx:132-184, 330, 583).  Until a browser draws,
--  topline (), displayed () and top () read the old top line, or none.
--  The browsers here are never shown, so never drawn.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Groups.Browsers,
    FLTK.Widgets.Groups.Browsers.Textline;

use

    Checks,
    FLTK;


procedure Test_Browser_Top is

    package Brw renames FLTK.Widgets.Groups.Browsers;
    package Txt renames FLTK.Widgets.Groups.Browsers.Textline;

    use type Brw.Item_Cursor;

    function Filled
        return Txt.Textline_Browser is
    begin
        return Item : Txt.Textline_Browser := Txt.Forge.Create (0, 0, 100, 100) do
            for N in 1 .. 50 loop
                Item.Add ("line" & Integer'Image (N));
            end loop;
        end return;
    end Filled;

begin

    declare
        Item : constant Txt.Textline_Browser := Filled;
    begin
        Check (Item.Get_Top_Line = 1, "a new browser's top line is 1");
        Check (Brw.Browser (Item).Top_Item /= Brw.No_Item, "a new browser has a top item");
        Check (Item.Is_Displayed (Positive'(1)), "a new browser shows line 1");
        Check (not Item.Is_Displayed (Positive'(40)), "a new browser doesn't show line 40");
    end;

    declare
        Item : Txt.Textline_Browser := Filled;
    begin
        Item.Set_Top_Line (20);
        Check (Item.Get_Top_Line = 20, "Set_Top_Line (20), then the top line is"
            & Integer'Image (Item.Get_Top_Line));
        Check (Item.Is_Displayed (Positive'(20)), "line 20 shows at the top");
        Check (not Item.Is_Displayed (Positive'(1)), "line 1 no longer shows");
        Check (Brw.Browser (Item).Is_Displayed (Brw.Browser (Item).Top_Item),
            "the top item shows");
    end;

    declare
        Item : Txt.Textline_Browser := Filled;
    begin
        Item.Make_Visible (40);
        Check (Item.Is_Displayed (Positive'(40)), "Make_Visible (40), then line 40 shows");
        Check (Item.Get_Top_Line > 1, "and the top line has moved");
    end;

    --  FLTK's topline () is 0 when there are no lines, which Get_Top_Line
    --  could not return (FLTKAda-BUGS.md 60).
    declare
        Item : constant Txt.Textline_Browser := Txt.Forge.Create (0, 0, 100, 100);
    begin
        Check (Item.Get_Top_Line = 0, "an empty browser's top line is 0");
    exception
    when Occurrence : others =>
        Check (False, "an empty browser's top line: "
            & Ada.Exceptions.Exception_Information (Occurrence));
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Browser_Top;
