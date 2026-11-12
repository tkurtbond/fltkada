--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/scroll.cxx: a scroll of 80 buttons and a drawing, bigger
--  than its window.  The light button gives the scroll a frame, and the
--  choices change which scrollbars it shows and where.  Guided by
--  pofltk's Scroll.Mod.


with

    Ada.Numerics.Long_Elementary_Functions,
    Ada.Unchecked_Deallocation,
    FLTK.Draw,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light,
    FLTK.Widgets.Groups.Scrolls,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices;

use type

    FLTK.Alignment;


function Scroll
    return Integer
is

    package Drw renames FLTK.Draw;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Lgt renames FLTK.Widgets.Buttons.Light;
    package Scr renames FLTK.Widgets.Groups.Scrolls;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Chc renames FLTK.Widgets.Menus.Choices;

    use Ada.Numerics.Long_Elementary_Functions;


    type Drawing is new FLTK.Widgets.Widget with null record;

    overriding procedure Draw
           (This : in out Drawing);


    --  A star of lines between 20 points on an ellipse filling the widget.
    procedure Draw
           (This : in out Drawing)
    is
        Pi : constant := Ada.Numerics.Pi;
    begin
        This.Draw_Box;
        Drw.Push_Matrix;
        Drw.Translate
           (Long_Float (This.Get_X + This.Get_W / 2), Long_Float (This.Get_Y + This.Get_H / 2));
        Drw.Scale (Long_Float (This.Get_W / 2), Long_Float (This.Get_H / 2));
        Drw.Set_Color (FLTK.Black_Color);
        for I in 0 .. 19 loop
            for J in I + 1 .. 19 loop
                Drw.Begin_Line;
                Drw.Vertex
                   (Cos (Pi * Long_Float (I) / 10.0 + 0.1), Sin (Pi * Long_Float (I) / 10.0 + 0.1));
                Drw.Vertex
                   (Cos (Pi * Long_Float (J) / 10.0 + 0.1), Sin (Pi * Long_Float (J) / 10.0 + 0.1));
                Drw.End_Line;
            end loop;
        end loop;
        Drw.Pop_Matrix;
    end Draw;


    type Button_Access is access Btn.Button;
    procedure Free is new Ada.Unchecked_Deallocation (Btn.Button, Button_Access);

    Result : Integer;

begin

    FLTK.Static.Parse_Args;

    declare

        Window     : Dbl.Double_Window := Dbl.Forge.Create (5 * 75, 400);
        The_Scroll : Scr.Scroll := Scr.Forge.Create (Window, 0, 0, 5 * 75, 300);

        Buttons : array (0 .. 79) of Button_Access;

        Picture : Drawing :=
           (FLTK.Widgets.Forge.Create (The_Scroll, 0, 8 * 25, 5 * 75, 5 * 75) with null record);

        --  gray area below the scroll
        Box : Bx.Box := Bx.Forge.Create (Window, 0, 300, 5 * 75, 400 - 300);

        But1    : Lgt.Light_Button := Lgt.Forge.Create (Window, 150, 310, 200, 25, "box");
        Choice  : Chc.Choice := Chc.Forge.Create (Window, 150, 335, 200, 25, "type():");
        AChoice : Chc.Choice := Chc.Forge.Create
            (Window, 150, 360, 200, 25, "scrollbar.align():");


        procedure Box_CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            if Btn.Button'Class (Item).Is_On then
                The_Scroll.Set_Box (FLTK.Down_Frame);
            else
                The_Scroll.Set_Box (FLTK.No_Box);
            end if;
            The_Scroll.Redraw;
        end Box_CB;


        --  The items' kinds:  FLTK's menu leaves out ALWAYS_ON.
        Kinds : constant array (1 .. 7) of Scr.Scroll_Kind :=
           (Scr.Neither, Scr.Horizontal, Scr.Vertical, Scr.Both,
            Scr.Horizontal_Always, Scr.Vertical_Always, Scr.Both_Always);

        procedure Type_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            if Choice.Chosen_Index /= FLTK.Widgets.Menus.No_Index then
                The_Scroll.Set_Kind (Kinds (Choice.Chosen_Index));
                The_Scroll.Redraw;
            end if;
        end Type_CB;


        Alignments : constant array (1 .. 4) of FLTK.Alignment :=
           (FLTK.Align_Left + FLTK.Align_Top,
            FLTK.Align_Left + FLTK.Align_Bottom,
            FLTK.Align_Right + FLTK.Align_Top,
            FLTK.Align_Right + FLTK.Align_Bottom);

        procedure Align_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            if AChoice.Chosen_Index /= FLTK.Widgets.Menus.No_Index then
                The_Scroll.Set_Scrollbar_Alignment (Alignments (AChoice.Chosen_Index));
                The_Scroll.Redraw;
            end if;
        end Align_CB;

    begin

        Window.Set_Box (FLTK.No_Box);

        --  The buttons go in the scroll before the drawing, as in FLTK's
        --  program, so put the drawing back at the end.
        for N in Buttons'Range loop
            declare
                X     : constant Integer := N mod 5;
                Y     : constant Integer := N / 5;
                Image : constant String := N'Image;
            begin
                Buttons (N) := new Btn.Button'
                   (Btn.Forge.Create
                       (The_Scroll, X * 75, Y * 25 + (if Y >= 8 then 5 * 75 else 0), 75, 25,
                        Image (Image'First + 1 .. Image'Last)));
                Buttons (N).Set_Background_Color (FLTK.Color (N + 1));
                Buttons (N).Set_Label_Color (FLTK.White_Color);
            end;
        end loop;
        The_Scroll.Add (Picture);

        Picture.Set_Alignment (FLTK.Align_Top);
        Picture.Set_Box (FLTK.Flat_Box);
        Picture.Set_Background_Color (FLTK.White_Color);
        The_Scroll.End_Current;
        Window.Set_Resizable (The_Scroll);

        Box.Set_Box (FLTK.Flat_Box);

        But1.Set_Callback (Box_CB'Unrestricted_Access);

        Choice.Add ("0");
        Choice.Add ("HORIZONTAL");
        Choice.Add ("VERTICAL");
        Choice.Add ("BOTH");
        Choice.Add ("HORIZONTAL_ALWAYS");
        Choice.Add ("VERTICAL_ALWAYS");
        Choice.Add ("BOTH_ALWAYS");
        Choice.Set_Callback (Type_CB'Unrestricted_Access);
        Choice.Set_Chosen (4);

        AChoice.Add ("left+top");
        AChoice.Add ("left+bottom");
        AChoice.Add ("right+top");
        AChoice.Add ("right+bottom");
        AChoice.Set_Callback (Align_CB'Unrestricted_Access);
        AChoice.Set_Chosen (4);

        Window.End_Current;
        Window.Show_With_Args;

        Result := FLTK.Run;

        for B of Buttons loop
            The_Scroll.Remove (B.all);
            Free (B);
        end loop;

    end;

    return Result;

end Scroll;
