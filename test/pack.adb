--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/pack.cxx, with its default settings (an Fl_Pack inside an
--  Fl_Scroll): 24 buttons in a pack, two radio buttons that make it
--  horizontal or vertical, and a slider for its spacing.  Guided by
--  pofltk's Pack.Mod.


with

    Ada.Unchecked_Deallocation,
    FLTK.Static,
    FLTK.Widgets.Buttons.Light,
    FLTK.Widgets.Groups.Packed,
    FLTK.Widgets.Groups.Scrolls,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Sliders.Value;


function Pack
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Lgt renames FLTK.Widgets.Buttons.Light;
    package Pck renames FLTK.Widgets.Groups.Packed;
    package Scr renames FLTK.Widgets.Groups.Scrolls;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package VSl renames FLTK.Widgets.Valuators.Sliders.Value;

    type Button_Access is access Btn.Button;
    procedure Free is new Ada.Unchecked_Deallocation (Btn.Button, Button_Access);

    N_Buttons : constant := 24;

    Result : Integer;

begin

    FLTK.Static.Parse_Args;

    declare

        W      : Dbl.Double_Window := Dbl.Forge.Create (360, 370);
        Scroll : Scr.Scroll := Scr.Forge.Create (W, 10, 10, 340, 285);
        Packed : Pck.Packed_Group := Pck.Forge.Create (Scroll, 10, 10, 340, 285);

        Buttons : array (1 .. N_Buttons) of Button_Access;

        Horizontal : Lgt.Light_Button := Lgt.Forge.Create (W, 10, 305, 165, 25, "HORIZONTAL");
        Vertical   : Lgt.Light_Button := Lgt.Forge.Create (W, 185, 305, 165, 25, "VERTICAL");
        Spacing    : VSl.Value_Slider := VSl.Forge.Create (W, 100, 335, 250, 25, "Spacing: ");


        --  FLTK's type_cb, with the type it is passed a formal.
        generic
            Kind : Pck.Pack_Kind;
        procedure Type_CB
               (Item : in out FLTK.Widgets.Widget'Class);

        procedure Type_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            for I in 1 .. Packed.Number_Of_Children loop
                Packed.Child (I).Resize (0, 0, 25, 25);
            end loop;
            Packed.Set_Kind (Kind);
            Packed.Resize (Scroll.Get_X, Scroll.Get_Y, Scroll.Get_W, Scroll.Get_H);
            Packed.Parent.Redraw;
            Packed.Redraw;
        end Type_CB;

        procedure Horizontal_CB is new Type_CB (Pck.Horizontal_Pack);
        procedure Vertical_CB   is new Type_CB (Pck.Vertical_Pack);


        procedure Spacing_CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            Packed.Set_Spacing
               (Integer (Long_Float'Truncation (VSl.Value_Slider (Item).Get_Value)));
            Packed.Parent.Redraw;
        end Spacing_CB;

    begin

        Packed.Set_Box (FLTK.Down_Frame);

        --  create buttons: position (xx, xx) will be "fixed" by Fl_Pack
        for I in Buttons'Range loop
            Buttons (I) := new Btn.Button'
               (Btn.Forge.Create (Packed, 25 + 10 * I, 25 + 10 * I, 25, 25));
            declare
                Image : constant String := I'Image;
            begin
                Buttons (I).Set_Label ("b" & Image (Image'First + 1 .. Image'Last));
            end;
        end loop;

        Packed.End_Current;
        W.Set_Resizable (Packed);
        Scroll.End_Current;

        Horizontal.Set_Kind (Btn.Radio_Kind);
        Horizontal.Set_Callback (Horizontal_CB'Unrestricted_Access);

        Vertical.Set_Kind (Btn.Radio_Kind);
        Vertical.Set_State (Btn.On);
        Vertical.Set_Callback (Vertical_CB'Unrestricted_Access);

        Spacing.Set_Alignment (FLTK.Align_Left);
        Sld.Extra.Set_Kind (Sld.Slider (Spacing), Sld.Horizontal_Slider);
        Spacing.Set_Range (0.0, 30.0);
        Spacing.Set_Step (1);
        Spacing.Set_Callback (Spacing_CB'Unrestricted_Access);

        W.End_Current;
        W.Set_Size_Range (300, 300);
        W.Show_With_Args;

        Result := FLTK.Run;

        for B of Buttons loop
            Packed.Remove (B.all);
            Free (B);
        end loop;

    end;

    return Result;

end Pack;
