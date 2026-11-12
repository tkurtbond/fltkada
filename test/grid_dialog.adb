--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/grid_dialog.cxx: a message dialog laid out with an
--  Fl_Grid: an icon, a message that wraps as the window is resized, and a
--  row of buttons at the bottom right.  Quit closes it, and Copy copies
--  the message to the clipboard.  FLTK's rows and columns are numbered
--  from 0, FLTKAda's from 1.  Guided by pofltk's GridDialog.Mod.


with

    Ada.Text_IO,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment;


function Grid_Dialog
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    Rows     : constant := 2;
    Buttons  : constant := 4;  --  default = 4, use 1 to 5 to test
    Cols     : constant := Buttons + 2;
    Button_H : constant := 25;
    Icon_W   : constant := 60;
    Icon_H   : constant := 70;
    Margin   : constant := 10;
    Gap      : constant := 8;

    type Label_Access is access constant String;

    Quit_Label   : aliased constant String := "Quit";
    Copy_Label   : aliased constant String := "Copy";
    Cancel_Label : aliased constant String := "Cancel";
    OK_Label     : aliased constant String := "OK";
    More_Label   : aliased constant String := "More ...";

    Labels : constant array (0 .. 4) of Label_Access :=
       (Quit_Label'Access, Copy_Label'Access, Cancel_Label'Access, OK_Label'Access,
        More_Label'Access);

    Quit_Tip   : aliased constant String := "Quit this program";
    Copy_Tip   : aliased constant String := "Copy the message text to the clipboard";
    Cancel_Tip : aliased constant String := "Cancel - does nothing";
    OK_Tip     : aliased constant String := "OK - does nothing";
    More_Tip   : aliased constant String := "More buttons could be added here";

    Tooltips : constant array (0 .. 4) of Label_Access :=
       (Quit_Tip'Access, Copy_Tip'Access, Cancel_Tip'Access, OK_Tip'Access, More_Tip'Access);

    Button_W : constant array (0 .. 4) of Integer := (50, 50, 70, 40, 100);

    Col_Weights : constant Grd.Size_Array := (0, 100, 0, 0, 0, 0, 0);
    Row_Weights : constant Grd.Size_Array := (100, 0, 0, 0, 0, 0, 0);

    Message_Text : constant String :=
        "This is a long message in an Fl_Grid based dialog " &
        "that may wrap over more than one line. " &
        "Resize the window to see how it (un)wraps.";


    --  The minimum size: the icon, the margins, the gaps and the buttons.
    function Min_W
        return Integer
    is
        Result : Integer := Icon_W + 2 * Margin + (Buttons + 1) * Gap;
    begin
        for I in 0 .. Buttons - 1 loop
            Result := Result + Button_W (I);
        end loop;
        return Result;
    end Min_W;

    Min_H : constant := Icon_H + 10 + 2 * Margin + Gap + Button_H;


    --  A button of the bottom row, I counting from 0 as in FLTK.
    function Make_Button
           (Parent : in out Grd.Grid;
            I      : in     Natural)
        return Btn.Button is
    begin
        return This : Btn.Button :=
            Btn.Forge.Create (Parent, 0, 0, Button_W (I), Button_H, Labels (I).all)
        do
            This.Set_Tooltip (Tooltips (I).all);
        end return;
    end Make_Button;

begin

    FLTK.Static.Parse_Args;

    declare

        Win : Dbl.Double_Window := Dbl.Forge.Create (Min_W, Min_H, "Fl_Grid Based Dialog");

        Grid : Grd.Grid := Grd.Forge.Create (Win, 0, 0, Win.Get_W, Win.Get_H);

        Icon        : Bx.Box := Bx.Forge.Create (Grid, 0, 0, Icon_W, Icon_H, "ICON");
        Message_Box : Bx.Box := Bx.Forge.Create (Grid, 0, 0, 0, 0);

        B0 : Btn.Button := Make_Button (Grid, 0);
        B1 : Btn.Button := Make_Button (Grid, 1);
        B2 : Btn.Button := Make_Button (Grid, 2);
        B3 : Btn.Button := Make_Button (Grid, 3);


        --  FLTK's button_cb, with the button's number found from its label.
        procedure Button_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            Val : Natural := 0;
        begin
            for I in Labels'Range loop
                if Labels (I).all = Item.Get_Label then
                    Val := I;
                end if;
            end loop;
            Ada.Text_IO.Put_Line
               ("Button" & Natural'Image (Val) & ": '" & Item.Get_Label & "'");
            case Val is
                when 0 =>  --  Quit
                    Item.Nearest_Window.Hide;
                when 1 =>  --  Copy
                    FLTK.Static.Copy (Message_Box.Get_Label, FLTK.Static.Clipboard);
                    Ada.Text_IO.Put_Line ("Message copied to clipboard.");
                when others =>
                    null;
            end case;
            Ada.Text_IO.Flush;
        end Button_CB;

    begin

        Grid.Set_Layout (Rows, Cols, Margin, Gap);
        Grid.Set_Background_Color (FLTK.White_Color);
        Grid.Set_Tooltip ("Resize the window to see this dialog ""in action""");

        Grid.Set_Widget (Icon, 1, 1, 1, 1, Grd.Grid_Top);
        Icon.Set_Box (FLTK.Thin_Up_Box);
        Icon.Set_Background_Color (16#ddffff00#);
        Icon.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside + FLTK.Align_Clip);
        Icon.Set_Tooltip ("This could also be a full Fl_Image or subclass thereof");

        Grid.Set_Widget (Message_Box, 1, 2, 1, Buttons + 1, Grd.Grid_Fill);
        Message_Box.Set_Label (Message_Text);
        Message_Box.Set_Alignment (FLTK.Align_Top + FLTK.Align_Inside + FLTK.Align_Wrap);
        Message_Box.Set_Tooltip ("The text in this box can be copied to the clipboard");

        Grid.Set_Widget (B0, 2, 3);
        B0.Set_Callback (Button_CB'Unrestricted_Access);
        Grid.Set_Widget (B1, 2, 4);
        B1.Set_Callback (Button_CB'Unrestricted_Access);
        Grid.Set_Widget (B2, 2, 5);
        B2.Set_Callback (Button_CB'Unrestricted_Access);
        Grid.Set_Widget (B3, 2, 6);
        B3.Set_Callback (Button_CB'Unrestricted_Access);

        Grid.End_Current;

        Grid.Set_Row_Weight (Row_Weights (1 .. Rows));
        Grid.Set_Column_Weight (Col_Weights (1 .. Cols));

        Win.End_Current;
        Win.Set_Resizable (Grid);
        Win.Set_Size_Range (Min_W, Min_H, 3 * Min_W, Min_H + 50);
        Win.Show_With_Args;

        return FLTK.Run;

    end;

end Grid_Dialog;

