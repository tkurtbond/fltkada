--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Draw,
    FLTK.Static,
    FLTK.Text_Buffers,
    FLTK.Tree_Items,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Browsers.Textline.Multi,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


package body Unittests_Scrollbarsize is


    package Bx renames FLTK.Widgets.Boxes;
    package Grp renames FLTK.Widgets.Groups;
    package Multi renames FLTK.Widgets.Groups.Browsers.Textline.Multi;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package TD renames FLTK.Widgets.Groups.Text_Displays;
    package TB renames FLTK.Text_Buffers;
    package Trees renames FLTK.Widgets.Groups.Trees;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    use FLTK, Unittests_Common;


    --  Test new 1.3.x global vs. local scrollbar sizing

    type Ut_Table is new Tbl.Table with null record;

    overriding procedure Draw_Cell
           (This        : in out Ut_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);

    --  Handle drawing table's cells.  FLTKAda's rows and columns are
    --  1-based, FLTK's 0-based.
    procedure Draw_Cell
           (This        : in out Ut_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0)
    is
        package FD renames FLTK.Draw;
    begin
        case Context is
        when Tbl.Start_Page =>   --  before page is drawn..
            FD.Set_Font (Helvetica, 8);
        when Tbl.Within_Cell =>   --  Draw data in cells
            FD.Push_Clip (X, Y, W, H);
            --  Draw cell bg
            FD.Set_Color (White_Color);
            FD.Rect_Fill (X, Y, W, H);
            --  Draw cell data
            FD.Set_Color (Grey0_Color);
            FD.Draw_Text (X, Y, W, H,
                (1 => Character'Val (Character'Pos ('A') + (Row - 1) + (Column - 1))),
                Align_Center);
            --  Draw box border
            FD.Set_Color (This.Get_Background_Color);
            FD.Rect (X, Y, W, H);
            FD.Pop_Clip;
        when others =>
            null;
        end case;
    end Draw_Cell;


    type String_Access is access constant String;

    Phonetics : constant array (Positive range <>) of String_Access :=
       (new String'("Alpha"), new String'("Bravo"), new String'("Charlie"),
        new String'("Delta"), new String'("Echo"), new String'("Foxtrot"),
        new String'("Golf"), new String'("Hotel"), new String'("India"),
        new String'("Juliet"), new String'("Kilo"), new String'("Lima"),
        new String'("Mike"), new String'("November"), new String'("Oscar"),
        new String'("Papa"), new String'("Quebec"), new String'("Romeo"),
        new String'("Sierra"), new String'("Tango"), new String'("Uniform"),
        new String'("Victor"), new String'("Whiskey"), new String'("X-ray"),
        new String'("Yankee"), new String'("Zulu"));

    Long_Entry : constant String := "Long entry will show h-bar";


    type Browser_Access is access Multi.Multi_Browser;
    type Tree_Access is access Trees.Tree;
    type Table_Access is access Ut_Table;
    type Text_Display_Access is access TD.Text_Display;
    type Text_Buffer_Access is access TB.Text_Buffer;
    type Terminal_Access is access Trm.Terminal;
    type Slider_Access is access HVS.Horizontal_Value_Slider;
    type Box_Access is access Bx.Box;
    type Group_Access is access Grp.Group;

    Brow_A, Brow_B, Brow_C    : Browser_Access;
    Tree_A, Tree_B, Tree_C    : Tree_Access;
    Table_A, Table_B, Table_C : Table_Access;
    Text_A, Text_B, Text_C    : Text_Display_Access;
    Term_A, Term_B, Term_C    : Terminal_Access;

    --  Only the A widgets, and Browser C's place, are used after they
    --  are made, as in the C++.
    pragma Unreferenced (Brow_B, Tree_B, Tree_C, Table_B, Table_C);
    pragma Unreferenced (Text_B, Text_C, Term_B, Term_C);


    function Make_Browser
           (X, Y, W, H : in Integer;
            L          : in String)
        return Browser_Access
    is
        B : constant Browser_Access :=
            new Multi.Multi_Browser'(Multi.Forge.Create (X, Y, W, H, L));
    begin
        B.Set_Label_Size (10);
        B.Set_Text_Size (10);
        B.Set_Alignment (Align_Top);
        for P of Phonetics loop
            B.Add (P.all);
            if P (P'First) = 'C' then
                B.Add (Long_Entry);
            end if;
        end loop;
        return B;
    end Make_Browser;


    --  The C++ also sets the tree's type to FL_TREE_SELECT_MULTI, which
    --  Fl_Tree doesn't use: its selection mode is selectmode().  That
    --  call is left out.
    function Make_Tree
           (X, Y, W, H : in Integer;
            L          : in String)
        return Tree_Access
    is
        B : constant Tree_Access := new Trees.Tree'(Trees.Forge.Create (X, Y, W, H, L));
        Item : FLTK.Tree_Items.Tree_Item;
        pragma Unreferenced (Item);
    begin
        B.Set_Label_Size (10);
        B.Set_Item_Label_Size (10);
        B.Set_Alignment (Align_Top);
        for P of Phonetics loop
            Item := B.Add (P.all);
            if P (P'First) = 'C' then
                Item := B.Add (Long_Entry);
            end if;
        end loop;
        return B;
    end Make_Tree;


    function Make_Table
           (X, Y, W, H : in Integer;
            L          : in String)
        return Table_Access
    is
        Mta : constant Table_Access :=
            new Ut_Table'(Tbl.Forge.Create (X, Y, W, H, L) with null record);
    begin
        --  Rows
        Mta.Set_Rows (13);              --  how many rows
        Mta.Set_All_Rows_Height (10);   --  default height of rows
        --  Cols
        Mta.Set_Columns (13);           --  how many columns
        Mta.Set_All_Columns_Width (10); --  default width of columns
        Mta.End_Current;                --  end the Table group
        Mta.Set_Label_Size (10);
        Mta.Set_Alignment (Align_Top);
        Mta.End_Current;
        return Mta;
    end Make_Table;


    function Make_Text_Display
           (X, Y, W, H : in Integer;
            L          : in String)
        return Text_Display_Access
    is
        Dpy : constant Text_Display_Access :=
            new TD.Text_Display'(TD.Forge.Create (X, Y, W, H, L));
        Buf : constant Text_Buffer_Access := new TB.Text_Buffer'(TB.Forge.Create);
    begin
        Dpy.Set_Label_Size (10);
        Dpy.Set_Text_Size (10);
        Dpy.Set_Buffer (Buf.all);
        for P of Phonetics loop
            Buf.Append_Text (P.all & ASCII.LF);
            if P (P'First) = 'C' then
                Buf.Append_Text (Long_Entry & ASCII.LF);
            end if;
        end loop;
        return Dpy;
    end Make_Text_Display;


    function Make_Term
           (X, Y, W, H : in Integer;
            L          : in String)
        return Terminal_Access
    is
        Term : constant Terminal_Access := new Trm.Terminal'(Trm.Forge.Create (X, Y, W, H, L));
    begin
        Term.Set_Label_Size (8);
        Term.Set_Text_Size (8);
        Term.End_Current;
        Term.Set_Display_Columns (40);   --  force wider than normal to show hscroll
        Term.Print (Long_Entry & ASCII.LF);
        return Term;
    end Make_Term;


    procedure Slide_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        S   : HVS.Horizontal_Value_Slider renames HVS.Horizontal_Value_Slider (Item);
        Val : constant Integer := Integer (Long_Float'Truncation (S.Get_Value));
    begin
        if S.Get_Label = "A: Scroll Size" then
            Brow_A.Set_Scrollbar_Size (Val);
            Tree_A.Set_Scrollbar_Size (Val);
            Table_A.Set_Scrollbar_Size (Val);
            Text_A.Set_Scrollbar_Size (Val);
            Term_A.Set_Scrollbar_Size (Val);
        else
            FLTK.Static.Set_Default_Scrollbar_Size (Val);
        end if;
        S.Top_Window.Redraw;
    end Slide_CB;


    Page_Group : Group_Access;


    function Create
        return Widget_Access
    is
        X : constant Integer := Test_Area_X;
        Y : constant Integer := Test_Area_Y;
        W : constant Integer := Test_Area_W;
        H : constant Integer := Test_Area_H;

        Tgrpy  : constant Integer := Y + 30;
        Tgrph  : constant Integer := H - 30;
        Ysep   : constant Integer := 20;   --  y separation between widgets
        Browy  : constant Integer := Tgrpy + 14;
        Browh  : constant Integer := Tgrph / 5 - 20;   --  5: number of widgets vertically
        Treey  : constant Integer := Browy + Browh + Ysep;
        Treeh  : constant Integer := Browh;
        Tabley : constant Integer := Treey + Treeh + Ysep;
        Tableh : constant Integer := Browh;
        Texty  : constant Integer := Tabley + Tableh + Ysep;
        Texth  : constant Integer := Browh;
        Termy  : constant Integer := Texty + Texth + Ysep;

        Slide_Glob, Slide_Browa : Slider_Access;
        Msgbox : Box_Access;
    begin
        Page_Group := new Grp.Group'(Grp.Forge.Create (X, Y, W, H));
        Page_Group.Begin_Current;
        Brow_A := Make_Browser (X + 10, Browy, 100, Browh, "Browser A");
        Brow_B := Make_Browser (X + 120, Browy, 100, Browh, "Browser B");
        Brow_C := Make_Browser (X + 230, Browy, 100, Browh, "Browser C");
        Tree_A := Make_Tree (X + 10, Treey, 100, Treeh, "Tree A");
        Tree_B := Make_Tree (X + 120, Treey, 100, Treeh, "Tree B");
        Tree_C := Make_Tree (X + 230, Treey, 100, Treeh, "Tree C");
        Table_A := Make_Table (X + 10, Tabley, 100, Tableh, "Table A");
        Table_B := Make_Table (X + 120, Tabley, 100, Tableh, "Table B");
        Table_C := Make_Table (X + 230, Tabley, 100, Tableh, "Table C");
        Text_A := Make_Text_Display (X + 10, Texty, 100, Texth, "Text Display A");
        Text_B := Make_Text_Display (X + 120, Texty, 100, Texth, "Text Display B");
        Text_C := Make_Text_Display (X + 230, Texty, 100, Texth, "Text Display C");
        Term_A := Make_Term (X + 10, Termy, 100, Texth, "Term A");
        Term_B := Make_Term (X + 120, Termy, 100, Texth, "Term B");
        Term_C := Make_Term (X + 230, Termy, 100, Texth, "Term C");

        Slide_Glob := new HVS.Horizontal_Value_Slider'
           (HVS.Forge.Create (X + 100, Y, 100, 18, "Global Scroll Size"));
        Slide_Glob.Set_Value (16.0);
        Slide_Glob.Set_Alignment (Align_Left);
        Slide_Glob.Set_Range (0.0, 30.0);
        Slide_Glob.Set_Step (1.0);
        Slide_Glob.Set_Callback (Slide_CB'Access);
        Slide_Glob.Set_Label_Size (12);

        Slide_Browa := new HVS.Horizontal_Value_Slider'
           (HVS.Forge.Create (X + 350, Y, 100, 18, "A: Scroll Size"));
        Slide_Browa.Set_Value (0.0);
        Slide_Browa.Set_Alignment (Align_Left);
        Slide_Browa.Set_Range (0.0, 30.0);
        Slide_Browa.Set_Step (1.0);
        Slide_Browa.Set_Callback (Slide_CB'Access);
        Slide_Browa.Set_Label_Size (12);

        declare
            Msgbox_X : constant Integer := Brow_C.Get_X + Brow_C.Get_W + 20;
            Msgbox_Y : constant Integer := Tgrpy;
            Msgbox_W : constant Integer := W - (Msgbox_X - X);
            Msgbox_H : constant Integer := Tgrph;
        begin
            Msgbox := new Bx.Box'(Bx.Forge.Create (Msgbox_X, Msgbox_Y, Msgbox_W, Msgbox_H));
            Msgbox.Set_Label
               (ASCII.LF & "Verify global scrollbar sizing and per-widget scrollbar sizing. " &
                "Scrollbar's size should change interactively as size sliders are changed. " &
                "Changing 'Global Scroll Size' should affect all scrollbars AS LONG AS the " &
                "'A: Scroll Size' slider is 0. Otherwise its value takes precedence for all " &
                "the 'A' group widgets.");
            Msgbox.Set_Label_Size (12);
            Msgbox.Set_Alignment (Align_Inside + Align_Center + Align_Left + Align_Wrap);
            Msgbox.Set_Box (Flat_Box);
            Msgbox.Set_Background_Color (53);   --  90% gray
        end;
        Page_Group.End_Current;
        return Widget_Access (Page_Group);
    end Create;


end Unittests_Scrollbarsize;
