


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/boxtype.cxx: every box and frame type, on a bright blue
--  background that shows a box from a frame.  A scheme is chosen with the
--  command line's -s, as in FLTK, or with the choice.  FLTK's BoxGroup
--  draws outlines for debugging when that is switched on in its source,
--  and is otherwise a group with no box, as here.


with

    Ada.Unchecked_Deallocation,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices.Schemes;


function Boxtype
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Sch renames FLTK.Widgets.Menus.Choices.Schemes;

    use type FLTK.Box_Kind;


    W    : constant := 200;
    H    : constant := 50;
    Rows : constant := 14;

    --  In FLTK's order, which isn't the enumeration's.  A Gap leaves the
    --  rest of a row empty, so that the boxes and frames line up.
    type Entry_Kind is (Box, Gap);

    type Place is record
        Kind : Entry_Kind;
        Item : FLTK.Box_Kind;
    end record;

    function B
           (Item : in FLTK.Box_Kind)
        return Place is (Box, Item);

    Skip : constant Place := (Gap, FLTK.No_Box);

    Layout : constant array (Positive range <>) of Place :=
       (B (FLTK.No_Box), B (FLTK.Flat_Box), Skip,
        B (FLTK.Up_Box), B (FLTK.Down_Box), B (FLTK.Up_Frame), B (FLTK.Down_Frame),
        B (FLTK.Thin_Up_Box), B (FLTK.Thin_Down_Box),
        B (FLTK.Thin_Up_Frame), B (FLTK.Thin_Down_Frame),
        B (FLTK.Engraved_Box), B (FLTK.Embossed_Box),
        B (FLTK.Engraved_Frame), B (FLTK.Embossed_Frame),
        B (FLTK.Border_Box), B (FLTK.Shadow_Box),
        B (FLTK.Border_Frame), B (FLTK.Shadow_Frame),
        B (FLTK.Rounded_Box), B (FLTK.RShadow_Box),
        B (FLTK.Rounded_Frame), B (FLTK.RFlat_Box),
        B (FLTK.Oval_Box), B (FLTK.OShadow_Box), B (FLTK.Oval_Frame), B (FLTK.OFlat_Box),
        B (FLTK.Round_Up_Box), B (FLTK.Round_Down_Box),
        B (FLTK.Diamond_Up_Box), B (FLTK.Diamond_Down_Box),
        B (FLTK.Plastic_Up_Box), B (FLTK.Plastic_Down_Box),
        B (FLTK.Plastic_Up_Frame), B (FLTK.Plastic_Down_Frame),
        B (FLTK.Plastic_Thin_Up_Box), B (FLTK.Plastic_Thin_Down_Box), Skip,
        B (FLTK.Plastic_Round_Up_Box), B (FLTK.Plastic_Round_Down_Box), Skip,
        B (FLTK.Gtk_Up_Box), B (FLTK.Gtk_Down_Box),
        B (FLTK.Gtk_Up_Frame), B (FLTK.Gtk_Down_Frame),
        B (FLTK.Gtk_Thin_Up_Box), B (FLTK.Gtk_Thin_Down_Box),
        B (FLTK.Gtk_Thin_Up_Frame), B (FLTK.Gtk_Thin_Down_Frame),
        B (FLTK.Gtk_Round_Up_Box), B (FLTK.Gtk_Round_Down_Box));


    The_Window : Dbl.Double_Window := Dbl.Forge.Create (4 * W, Rows * H);

    The_Group : Grp.Group :=
        Grp.Forge.Create (The_Window, 0, 0, The_Window.Get_W, The_Window.Get_H);

    type Button_Access is access Btn.Button;

    --  Freed when the program ends.
    Buttons : array (Layout'Range) of Button_Access;

    procedure Free is new Ada.Unchecked_Deallocation (Btn.Button, Button_Access);

    N : Natural := 0;


    function Scheme_Name
        return String is
    begin
        if FLTK.Static.Get_Scheme = "" then
            return "none";
        else
            return FLTK.Static.Get_Scheme;
        end if;
    end Scheme_Name;


begin


    The_Window.Set_Box (FLTK.Flat_Box);
    FLTK.Static.Parse_Args;
    FLTK.Static.System_Colors;
    --  Light blue, #33adff.
    The_Window.Set_Background_Color (FLTK.RGB_Color (51, 173, 255));

    FLTK.Static.Set_Scheme (FLTK.Static.Get_Scheme);
    The_Window.Set_Label ("FLTK boxtypes: scheme = '" & Scheme_Name & "'");

    The_Group.Set_Box (FLTK.No_Box);
    for Index in Layout'Range loop
        case Layout (Index).Kind is
            when Gap =>
                --  To the start of the next row.
                N := N + 2;
            when Box =>
                Buttons (Index) := new Btn.Button'(Btn.Forge.Create
                   (The_Group, N mod 4 * W + 10, N / 4 * H + 10, W - 20, H - 20,
                    "FL_" & FLTK.Box_Kind'Image (Layout (Index).Item)));
                Buttons (Index).Set_Box (Layout (Index).Item);
                Buttons (Index).Set_Label_Size (11);
                N := N + 1;
        end case;
    end loop;
    The_Window.Set_Resizable (The_Window);

    declare
        Choice : constant Sch.Scheme_Choice :=
            Sch.Forge.Create (The_Window, 610, 10, 150, 30, "Scheme:");
        pragma Unreferenced (Choice);
    begin
        The_Window.Show;
        return Result : constant Integer := FLTK.Run do
            for Item of Buttons loop
                Free (Item);
            end loop;
        end return;
    end;


end Boxtype;

