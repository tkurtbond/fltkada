--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/resizebox.cxx: a window of coloured boxes, and radio
--  buttons that move its resizable box to one of four edges of the
--  middle, or turn it off.  Guided by pofltk's ResizeBox.Mod.


with

    Ada.Unchecked_Deallocation,
    FLTK.Asks,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Radio,
    FLTK.Widgets.Groups.Windows.Double;


function ResizeBox
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Rad renames FLTK.Widgets.Buttons.Radio;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    type Box_Access is access Bx.Box;
    procedure Free is new Ada.Unchecked_Deallocation (Bx.Box, Box_Access);

    --  FLTK's program has big = 0.
    W1 : constant := 40;
    B  : constant := 0;
    W3 : constant := 5 * W1 + 6 * B;

    Result : Integer;

begin

    FLTK.Static.Parse_Args;

    declare

        Window : Dbl.Double_Window := Dbl.Forge.Create (W3, W3);

        Boxes : array (1 .. 15) of Box_Access;
        Count : Natural := 0;

        Right  : Rad.Radio_Button := Rad.Forge.Create
            (Window, W1 + B + 50, W1 + B + 30, 20, 20, "@6>");
        Top    : Rad.Radio_Button := Rad.Forge.Create
            (Window, W1 + B + 30, W1 + B + 10, 20, 20, "@8>");
        Left   : Rad.Radio_Button := Rad.Forge.Create
            (Window, W1 + B + 10, W1 + B + 30, 20, 20, "@4>");
        Bottom : Rad.Radio_Button := Rad.Forge.Create
            (Window, W1 + B + 30, W1 + B + 50, 20, 20, "@2>");
        Off    : Rad.Radio_Button := Rad.Forge.Create
            (Window, W1 + B + 30, W1 + B + 30, 20, 20, "off");

        Resizable : Bx.Box := Bx.Forge.Create (Window, FLTK.Flat_Box, 0, 0, 0, 0, "resizable");


        procedure Add_Box
               (X, Y, W, H : in Integer;
                Hue        : in FLTK.Color) is
        begin
            Count := Count + 1;
            --  FLTK's FL_FRAME_BOX is FL_ENGRAVED_BOX.
            Boxes (Count) := new Bx.Box'(Bx.Forge.Create (Window, FLTK.Engraved_Box, X, Y, W, H));
            Boxes (Count).Set_Background_Color (Hue);
        end Add_Box;


        --  FLTK's b_cb, with the direction it is passed a formal.
        generic
            Direction : Natural;
        procedure B_CB
               (Item : in out FLTK.Widgets.Widget'Class);

        procedure B_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            if Window.Get_W /= W3 or Window.Get_H /= W3 then
                FLTK.Asks.Message_Box ("Put window back to minimum size before changing");
                return;
            end if;
            Window.Reset_Sizes;
            case Direction is
            when 0 =>
                Resizable.Hide;
                Window.Set_Box (FLTK.Flat_Box);
                Window.Clear_Resizable;
                return;
            when 8 => Resizable.Resize (W1 + B, W1, 2 * W1, B);
            when 2 => Resizable.Resize (W1 + B, W1 + B + 2 * W1, 2 * W1, B);
            when 4 => Resizable.Resize (W1 + B, W1, B, 2 * W1);
            when 6 => Resizable.Resize (W1 + B + 2 * W1, W1 + B, B, 2 * W1);
            when others => null;
            end case;
            Window.Set_Box (FLTK.No_Box);
            if Direction = 6 or Direction = 4 then
                Resizable.Set_Label ("re" & ASCII.LF & "siz" & ASCII.LF & "ab" & ASCII.LF & "le");
            else
                Resizable.Set_Label ("resizable");
            end if;
            Resizable.Show;
            Window.Set_Resizable (Resizable);
            Window.Redraw;
        end B_CB;

        procedure Right_CB  is new B_CB (6);
        procedure Top_CB    is new B_CB (8);
        procedure Left_CB   is new B_CB (4);
        procedure Bottom_CB is new B_CB (2);
        procedure Off_CB    is new B_CB (0);

    begin

        Window.Set_Box (FLTK.No_Box);

        for X in 0 .. 3 loop
            for Y in 0 .. 3 loop
                if (X = 1 or X = 2) and (Y = 1 or Y = 2) then
                    null;
                else
                    Add_Box (X * (B + W1) + B, Y * (B + W1) + B, W1, W1, FLTK.Color (X + Y + 8));
                end if;
            end loop;
        end loop;
        Add_Box (B, 4 * W1 + 5 * B, 4 * W1 + 3 * B, W1, 12);
        Add_Box (4 * W1 + 5 * B, B, W1, 5 * W1 + 4 * B, 13);
        Add_Box (W1 + B + B, W1 + B + B, 2 * W1 + B, 2 * W1 + B, 8);

        --  The boxes were made after the buttons, which FLTK's program
        --  makes after them, so put the buttons and the resizable box
        --  back on top, in FLTK's order.
        Window.Add (Right);
        Window.Add (Top);
        Window.Add (Left);
        Window.Add (Bottom);
        Window.Add (Off);
        Window.Add (Resizable);

        Right.Set_Callback (Right_CB'Unrestricted_Access);
        Top.Set_Callback (Top_CB'Unrestricted_Access);
        Left.Set_Callback (Left_CB'Unrestricted_Access);
        Bottom.Set_Callback (Bottom_CB'Unrestricted_Access);
        Off.Set_Callback (Off_CB'Unrestricted_Access);

        Resizable.Set_Background_Color (FLTK.Dark2_Color);
        Btn.Button (Right).Set_State (Btn.On);
        Right.Do_Callback;
        Window.End_Current;

        Window.Set_Size_Range (W3, W3);
        Window.Show_With_Args;

        Result := FLTK.Run;

        for Item of Boxes loop
            Window.Remove (Item.all);
            Free (Item);
        end loop;

    end;

    return Result;

end ResizeBox;
