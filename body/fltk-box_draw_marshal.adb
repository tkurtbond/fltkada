

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    FLTK.Hook_Exceptions,
    FLTK.Static,
    Interfaces.C;

use type

    FLTK.Static.Box_Draw_Function;


package body FLTK.Box_Draw_Marshal is


    package Chk renames Ada.Assertions;




    C_Ptr_Array      : array (Box_Kind) of Storage.Integer_Address;
    Ada_Access_Array : array (Box_Kind) of FLTK.Static.Box_Draw_Function;




    procedure fl_static_box_draw_marshal
           (F          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            T          : in Interfaces.C.unsigned);
    pragma Import (C, fl_static_box_draw_marshal, "fl_static_box_draw_marshal");
    pragma Inline (fl_static_box_draw_marshal);




    generic
        Kind : Box_Kind;
    procedure Generic_Box_Draw
           (X, Y, W, H : in Integer;
            Tone       : in Color)
    with Inline;

    procedure Generic_Box_Draw
           (X, Y, W, H : in Integer;
            Tone       : in Color) is
    begin
        fl_static_box_draw_marshal
           (C_Ptr_Array (Kind),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Tone));
    end Generic_Box_Draw;

    procedure No_Box_Draw                 is new Generic_Box_Draw (No_Box);
    procedure Flat_Box_Draw               is new Generic_Box_Draw (Flat_Box);
    procedure Up_Box_Draw                 is new Generic_Box_Draw (Up_Box);
    procedure Down_Box_Draw               is new Generic_Box_Draw (Down_Box);
    procedure Up_Frame_Draw               is new Generic_Box_Draw (Up_Frame);
    procedure Down_Frame_Draw             is new Generic_Box_Draw (Down_Frame);
    procedure Thin_Up_Box_Draw            is new Generic_Box_Draw (Thin_Up_Box);
    procedure Thin_Down_Box_Draw          is new Generic_Box_Draw (Thin_Down_Box);
    procedure Thin_Up_Frame_Draw          is new Generic_Box_Draw (Thin_Up_Frame);
    procedure Thin_Down_Frame_Draw        is new Generic_Box_Draw (Thin_Down_Frame);
    procedure Engraved_Box_Draw           is new Generic_Box_Draw (Engraved_Box);
    procedure Embossed_Box_Draw           is new Generic_Box_Draw (Embossed_Box);
    procedure Engraved_Frame_Draw         is new Generic_Box_Draw (Engraved_Frame);
    procedure Embossed_Frame_Draw         is new Generic_Box_Draw (Embossed_Frame);
    procedure Border_Box_Draw             is new Generic_Box_Draw (Border_Box);
    procedure Shadow_Box_Draw             is new Generic_Box_Draw (Shadow_Box);
    procedure Border_Frame_Draw           is new Generic_Box_Draw (Border_Frame);
    procedure Shadow_Frame_Draw           is new Generic_Box_Draw (Shadow_Frame);
    procedure Rounded_Box_Draw            is new Generic_Box_Draw (Rounded_Box);
    procedure RShadow_Box_Draw            is new Generic_Box_Draw (RShadow_Box);
    procedure Rounded_Frame_Draw          is new Generic_Box_Draw (Rounded_Frame);
    procedure RFlat_Box_Draw              is new Generic_Box_Draw (RFlat_Box);
    procedure Round_Up_Box_Draw           is new Generic_Box_Draw (Round_Up_Box);
    procedure Round_Down_Box_Draw         is new Generic_Box_Draw (Round_Down_Box);
    procedure Diamond_Up_Box_Draw         is new Generic_Box_Draw (Diamond_Up_Box);
    procedure Diamond_Down_Box_Draw       is new Generic_Box_Draw (Diamond_Down_Box);
    procedure Oval_Box_Draw               is new Generic_Box_Draw (Oval_Box);
    procedure OShadow_Box_Draw            is new Generic_Box_Draw (OShadow_Box);
    procedure Oval_Frame_Draw             is new Generic_Box_Draw (Oval_Frame);
    procedure OFlat_Box_Draw              is new Generic_Box_Draw (OFlat_Box);
    procedure Plastic_Up_Box_Draw         is new Generic_Box_Draw (Plastic_Up_Box);
    procedure Plastic_Down_Box_Draw       is new Generic_Box_Draw (Plastic_Down_Box);
    procedure Plastic_Up_Frame_Draw       is new Generic_Box_Draw (Plastic_Up_Frame);
    procedure Plastic_Down_Frame_Draw     is new Generic_Box_Draw (Plastic_Down_Frame);
    procedure Plastic_Thin_Up_Box_Draw    is new Generic_Box_Draw (Plastic_Thin_Up_Box);
    procedure Plastic_Thin_Down_Box_Draw  is new Generic_Box_Draw (Plastic_Thin_Down_Box);
    procedure Plastic_Round_Up_Box_Draw   is new Generic_Box_Draw (Plastic_Round_Up_Box);
    procedure Plastic_Round_Down_Box_Draw is new Generic_Box_Draw (Plastic_Round_Down_Box);
    procedure Gtk_Up_Box_Draw             is new Generic_Box_Draw (Gtk_Up_Box);
    procedure Gtk_Down_Box_Draw           is new Generic_Box_Draw (Gtk_Down_Box);
    procedure Gtk_Up_Frame_Draw           is new Generic_Box_Draw (Gtk_Up_Frame);
    procedure Gtk_Down_Frame_Draw         is new Generic_Box_Draw (Gtk_Down_Frame);
    procedure Gtk_Thin_Up_Box_Draw        is new Generic_Box_Draw (Gtk_Thin_Up_Box);
    procedure Gtk_Thin_Down_Box_Draw      is new Generic_Box_Draw (Gtk_Thin_Down_Box);
    procedure Gtk_Thin_Up_Frame_Draw      is new Generic_Box_Draw (Gtk_Thin_Up_Frame);
    procedure Gtk_Thin_Down_Frame_Draw    is new Generic_Box_Draw (Gtk_Thin_Down_Frame);
    procedure Gtk_Round_Up_Box_Draw       is new Generic_Box_Draw (Gtk_Round_Up_Box);
    procedure Gtk_Round_Down_Box_Draw     is new Generic_Box_Draw (Gtk_Round_Down_Box);
    procedure Gleam_Up_Box_Draw           is new Generic_Box_Draw (Gleam_Up_Box);
    procedure Gleam_Down_Box_Draw         is new Generic_Box_Draw (Gleam_Down_Box);
    procedure Gleam_Up_Frame_Draw         is new Generic_Box_Draw (Gleam_Up_Frame);
    procedure Gleam_Down_Frame_Draw       is new Generic_Box_Draw (Gleam_Down_Frame);
    procedure Gleam_Thin_Up_Box_Draw      is new Generic_Box_Draw (Gleam_Thin_Up_Box);
    procedure Gleam_Thin_Down_Box_Draw    is new Generic_Box_Draw (Gleam_Thin_Down_Box);
    procedure Gleam_Round_Up_Box_Draw     is new Generic_Box_Draw (Gleam_Round_Up_Box);
    procedure Gleam_Round_Down_Box_Draw   is new Generic_Box_Draw (Gleam_Round_Down_Box);
    procedure Oxy_Up_Box_Draw             is new Generic_Box_Draw (Oxy_Up_Box);
    procedure Oxy_Down_Box_Draw           is new Generic_Box_Draw (Oxy_Down_Box);
    procedure Oxy_Up_Frame_Draw           is new Generic_Box_Draw (Oxy_Up_Frame);
    procedure Oxy_Down_Frame_Draw         is new Generic_Box_Draw (Oxy_Down_Frame);
    procedure Oxy_Thin_Up_Box_Draw        is new Generic_Box_Draw (Oxy_Thin_Up_Box);
    procedure Oxy_Thin_Down_Box_Draw      is new Generic_Box_Draw (Oxy_Thin_Down_Box);
    procedure Oxy_Thin_Up_Frame_Draw      is new Generic_Box_Draw (Oxy_Thin_Up_Frame);
    procedure Oxy_Thin_Down_Frame_Draw    is new Generic_Box_Draw (Oxy_Thin_Down_Frame);
    procedure Oxy_Round_Up_Box_Draw       is new Generic_Box_Draw (Oxy_Round_Up_Box);
    procedure Oxy_Round_Down_Box_Draw     is new Generic_Box_Draw (Oxy_Round_Down_Box);
    procedure Oxy_Button_Up_Box_Draw      is new Generic_Box_Draw (Oxy_Button_Up_Box);
    procedure Oxy_Button_Down_Box_Draw    is new Generic_Box_Draw (Oxy_Button_Down_Box);
    procedure Free_Box_Draw               is new Generic_Box_Draw (Free_Box);




    generic
        Kind : Box_Kind;
    procedure Generic_Box_Draw_Hook
           (X, Y, W, H : in Interfaces.C.int;
            Tone       : in Interfaces.C.unsigned)
    with Inline, Convention => C;

    procedure Generic_Box_Draw_Hook
           (X, Y, W, H : in Interfaces.C.int;
            Tone       : in Interfaces.C.unsigned) is
    begin
        pragma Assert (Ada_Access_Array (Kind) /= null);
        Ada_Access_Array (Kind)
           (Integer (X), Integer (Y),
            Integer (W), Integer (H),
            Color (Tone));
    exception
    when Chk.Assertion_Error =>
        Hook_Exceptions.Save_New
           (Internal_FLTK_Error'Identity,
            "Box_Draw_Function hook tried to get a null subprogram access");
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Generic_Box_Draw_Hook;

    procedure No_Box_Hook                 is new Generic_Box_Draw_Hook (No_Box);
    procedure Flat_Box_Hook               is new Generic_Box_Draw_Hook (Flat_Box);
    procedure Up_Box_Hook                 is new Generic_Box_Draw_Hook (Up_Box);
    procedure Down_Box_Hook               is new Generic_Box_Draw_Hook (Down_Box);
    procedure Up_Frame_Hook               is new Generic_Box_Draw_Hook (Up_Frame);
    procedure Down_Frame_Hook             is new Generic_Box_Draw_Hook (Down_Frame);
    procedure Thin_Up_Box_Hook            is new Generic_Box_Draw_Hook (Thin_Up_Box);
    procedure Thin_Down_Box_Hook          is new Generic_Box_Draw_Hook (Thin_Down_Box);
    procedure Thin_Up_Frame_Hook          is new Generic_Box_Draw_Hook (Thin_Up_Frame);
    procedure Thin_Down_Frame_Hook        is new Generic_Box_Draw_Hook (Thin_Down_Frame);
    procedure Engraved_Box_Hook           is new Generic_Box_Draw_Hook (Engraved_Box);
    procedure Embossed_Box_Hook           is new Generic_Box_Draw_Hook (Embossed_Box);
    procedure Engraved_Frame_Hook         is new Generic_Box_Draw_Hook (Engraved_Frame);
    procedure Embossed_Frame_Hook         is new Generic_Box_Draw_Hook (Embossed_Frame);
    procedure Border_Box_Hook             is new Generic_Box_Draw_Hook (Border_Box);
    procedure Shadow_Box_Hook             is new Generic_Box_Draw_Hook (Shadow_Box);
    procedure Border_Frame_Hook           is new Generic_Box_Draw_Hook (Border_Frame);
    procedure Shadow_Frame_Hook           is new Generic_Box_Draw_Hook (Shadow_Frame);
    procedure Rounded_Box_Hook            is new Generic_Box_Draw_Hook (Rounded_Box);
    procedure RShadow_Box_Hook            is new Generic_Box_Draw_Hook (RShadow_Box);
    procedure Rounded_Frame_Hook          is new Generic_Box_Draw_Hook (Rounded_Frame);
    procedure RFlat_Box_Hook              is new Generic_Box_Draw_Hook (RFlat_Box);
    procedure Round_Up_Box_Hook           is new Generic_Box_Draw_Hook (Round_Up_Box);
    procedure Round_Down_Box_Hook         is new Generic_Box_Draw_Hook (Round_Down_Box);
    procedure Diamond_Up_Box_Hook         is new Generic_Box_Draw_Hook (Diamond_Up_Box);
    procedure Diamond_Down_Box_Hook       is new Generic_Box_Draw_Hook (Diamond_Down_Box);
    procedure Oval_Box_Hook               is new Generic_Box_Draw_Hook (Oval_Box);
    procedure OShadow_Box_Hook            is new Generic_Box_Draw_Hook (OShadow_Box);
    procedure Oval_Frame_Hook             is new Generic_Box_Draw_Hook (Oval_Frame);
    procedure OFlat_Box_Hook              is new Generic_Box_Draw_Hook (OFlat_Box);
    procedure Plastic_Up_Box_Hook         is new Generic_Box_Draw_Hook (Plastic_Up_Box);
    procedure Plastic_Down_Box_Hook       is new Generic_Box_Draw_Hook (Plastic_Down_Box);
    procedure Plastic_Up_Frame_Hook       is new Generic_Box_Draw_Hook (Plastic_Up_Frame);
    procedure Plastic_Down_Frame_Hook     is new Generic_Box_Draw_Hook (Plastic_Down_Frame);
    procedure Plastic_Thin_Up_Box_Hook    is new Generic_Box_Draw_Hook (Plastic_Thin_Up_Box);
    procedure Plastic_Thin_Down_Box_Hook  is new Generic_Box_Draw_Hook (Plastic_Thin_Down_Box);
    procedure Plastic_Round_Up_Box_Hook   is new Generic_Box_Draw_Hook (Plastic_Round_Up_Box);
    procedure Plastic_Round_Down_Box_Hook is new Generic_Box_Draw_Hook (Plastic_Round_Down_Box);
    procedure Gtk_Up_Box_Hook             is new Generic_Box_Draw_Hook (Gtk_Up_Box);
    procedure Gtk_Down_Box_Hook           is new Generic_Box_Draw_Hook (Gtk_Down_Box);
    procedure Gtk_Up_Frame_Hook           is new Generic_Box_Draw_Hook (Gtk_Up_Frame);
    procedure Gtk_Down_Frame_Hook         is new Generic_Box_Draw_Hook (Gtk_Down_Frame);
    procedure Gtk_Thin_Up_Box_Hook        is new Generic_Box_Draw_Hook (Gtk_Thin_Up_Box);
    procedure Gtk_Thin_Down_Box_Hook      is new Generic_Box_Draw_Hook (Gtk_Thin_Down_Box);
    procedure Gtk_Thin_Up_Frame_Hook      is new Generic_Box_Draw_Hook (Gtk_Thin_Up_Frame);
    procedure Gtk_Thin_Down_Frame_Hook    is new Generic_Box_Draw_Hook (Gtk_Thin_Down_Frame);
    procedure Gtk_Round_Up_Box_Hook       is new Generic_Box_Draw_Hook (Gtk_Round_Up_Box);
    procedure Gtk_Round_Down_Box_Hook     is new Generic_Box_Draw_Hook (Gtk_Round_Down_Box);
    procedure Gleam_Up_Box_Hook           is new Generic_Box_Draw_Hook (Gleam_Up_Box);
    procedure Gleam_Down_Box_Hook         is new Generic_Box_Draw_Hook (Gleam_Down_Box);
    procedure Gleam_Up_Frame_Hook         is new Generic_Box_Draw_Hook (Gleam_Up_Frame);
    procedure Gleam_Down_Frame_Hook       is new Generic_Box_Draw_Hook (Gleam_Down_Frame);
    procedure Gleam_Thin_Up_Box_Hook      is new Generic_Box_Draw_Hook (Gleam_Thin_Up_Box);
    procedure Gleam_Thin_Down_Box_Hook    is new Generic_Box_Draw_Hook (Gleam_Thin_Down_Box);
    procedure Gleam_Round_Up_Box_Hook     is new Generic_Box_Draw_Hook (Gleam_Round_Up_Box);
    procedure Gleam_Round_Down_Box_Hook   is new Generic_Box_Draw_Hook (Gleam_Round_Down_Box);
    procedure Oxy_Up_Box_Hook             is new Generic_Box_Draw_Hook (Oxy_Up_Box);
    procedure Oxy_Down_Box_Hook           is new Generic_Box_Draw_Hook (Oxy_Down_Box);
    procedure Oxy_Up_Frame_Hook           is new Generic_Box_Draw_Hook (Oxy_Up_Frame);
    procedure Oxy_Down_Frame_Hook         is new Generic_Box_Draw_Hook (Oxy_Down_Frame);
    procedure Oxy_Thin_Up_Box_Hook        is new Generic_Box_Draw_Hook (Oxy_Thin_Up_Box);
    procedure Oxy_Thin_Down_Box_Hook      is new Generic_Box_Draw_Hook (Oxy_Thin_Down_Box);
    procedure Oxy_Thin_Up_Frame_Hook      is new Generic_Box_Draw_Hook (Oxy_Thin_Up_Frame);
    procedure Oxy_Thin_Down_Frame_Hook    is new Generic_Box_Draw_Hook (Oxy_Thin_Down_Frame);
    procedure Oxy_Round_Up_Box_Hook       is new Generic_Box_Draw_Hook (Oxy_Round_Up_Box);
    procedure Oxy_Round_Down_Box_Hook     is new Generic_Box_Draw_Hook (Oxy_Round_Down_Box);
    procedure Oxy_Button_Up_Box_Hook      is new Generic_Box_Draw_Hook (Oxy_Button_Up_Box);
    procedure Oxy_Button_Down_Box_Hook    is new Generic_Box_Draw_Hook (Oxy_Button_Down_Box);
    procedure Free_Box_Hook               is new Generic_Box_Draw_Hook (Free_Box);




    function To_Ada
           (Kind : in Box_Kind;
            Ptr  : in Storage.Integer_Address)
        return FLTK.Static.Box_Draw_Function is
    begin
        if Ptr = Null_Pointer then
            return null;
        end if;
        C_Ptr_Array (Kind) := Ptr;
        case Kind is
        when No_Box => return
           (if Ptr = Storage.To_Integer (No_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else No_Box_Draw'Access);
        when Flat_Box => return
           (if Ptr = Storage.To_Integer (Flat_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Flat_Box_Draw'Access);
        when Up_Box => return
           (if Ptr = Storage.To_Integer (Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Up_Box_Draw'Access);
        when Down_Box => return
           (if Ptr = Storage.To_Integer (Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Down_Box_Draw'Access);
        when Up_Frame => return
           (if Ptr = Storage.To_Integer (Up_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Up_Frame_Draw'Access);
        when Down_Frame => return
           (if Ptr = Storage.To_Integer (Down_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Down_Frame_Draw'Access);
        when Thin_Up_Box => return
           (if Ptr = Storage.To_Integer (Thin_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Thin_Up_Box_Draw'Access);
        when Thin_Down_Box => return
           (if Ptr = Storage.To_Integer (Thin_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Thin_Down_Box_Draw'Access);
        when Thin_Up_Frame => return
           (if Ptr = Storage.To_Integer (Thin_Up_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Thin_Up_Frame_Draw'Access);
        when Thin_Down_Frame => return
           (if Ptr = Storage.To_Integer (Thin_Down_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Thin_Down_Frame_Draw'Access);
        when Engraved_Box => return
           (if Ptr = Storage.To_Integer (Engraved_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Engraved_Box_Draw'Access);
        when Embossed_Box => return
           (if Ptr = Storage.To_Integer (Embossed_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Embossed_Box_Draw'Access);
        when Engraved_Frame => return
           (if Ptr = Storage.To_Integer (Engraved_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Engraved_Frame_Draw'Access);
        when Embossed_Frame => return
           (if Ptr = Storage.To_Integer (Embossed_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Embossed_Frame_Draw'Access);
        when Border_Box => return
           (if Ptr = Storage.To_Integer (Border_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Border_Box_Draw'Access);
        when Shadow_Box => return
           (if Ptr = Storage.To_Integer (Shadow_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Shadow_Box_Draw'Access);
        when Border_Frame => return
           (if Ptr = Storage.To_Integer (Border_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Border_Frame_Draw'Access);
        when Shadow_Frame => return
           (if Ptr = Storage.To_Integer (Shadow_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Shadow_Frame_Draw'Access);
        when Rounded_Box => return
           (if Ptr = Storage.To_Integer (Rounded_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Rounded_Box_Draw'Access);
        when RShadow_Box => return
           (if Ptr = Storage.To_Integer (RShadow_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else RShadow_Box_Draw'Access);
        when Rounded_Frame => return
           (if Ptr = Storage.To_Integer (Rounded_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Rounded_Frame_Draw'Access);
        when RFlat_Box => return
           (if Ptr = Storage.To_Integer (RFlat_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else RFlat_Box_Draw'Access);
        when Round_Up_Box => return
           (if Ptr = Storage.To_Integer (Round_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Round_Up_Box_Draw'Access);
        when Round_Down_Box => return
           (if Ptr = Storage.To_Integer (Round_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Round_Down_Box_Draw'Access);
        when Diamond_Up_Box => return
           (if Ptr = Storage.To_Integer (Diamond_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Diamond_Up_Box_Draw'Access);
        when Diamond_Down_Box => return
           (if Ptr = Storage.To_Integer (Diamond_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Diamond_Down_Box_Draw'Access);
        when Oval_Box => return
           (if Ptr = Storage.To_Integer (Oval_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oval_Box_Draw'Access);
        when OShadow_Box => return
           (if Ptr = Storage.To_Integer (OShadow_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else OShadow_Box_Draw'Access);
        when Oval_Frame => return
           (if Ptr = Storage.To_Integer (Oval_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oval_Frame_Draw'Access);
        when OFlat_Box => return
           (if Ptr = Storage.To_Integer (OFlat_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else OFlat_Box_Draw'Access);
        when Plastic_Up_Box => return
           (if Ptr = Storage.To_Integer (Plastic_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Plastic_Up_Box_Draw'Access);
        when Plastic_Down_Box => return
           (if Ptr = Storage.To_Integer (Plastic_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Plastic_Down_Box_Draw'Access);
        when Plastic_Up_Frame => return
           (if Ptr = Storage.To_Integer (Plastic_Up_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Plastic_Up_Frame_Draw'Access);
        when Plastic_Down_Frame => return
           (if Ptr = Storage.To_Integer (Plastic_Down_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Plastic_Down_Frame_Draw'Access);
        when Plastic_Thin_Up_Box => return
           (if Ptr = Storage.To_Integer (Plastic_Thin_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Plastic_Thin_Up_Box_Draw'Access);
        when Plastic_Thin_Down_Box => return
           (if Ptr = Storage.To_Integer (Plastic_Thin_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Plastic_Thin_Down_Box_Draw'Access);
        when Plastic_Round_Up_Box => return
           (if Ptr = Storage.To_Integer (Plastic_Round_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Plastic_Round_Up_Box_Draw'Access);
        when Plastic_Round_Down_Box => return
           (if Ptr = Storage.To_Integer (Plastic_Round_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Plastic_Round_Down_Box_Draw'Access);
        when Gtk_Up_Box => return
           (if Ptr = Storage.To_Integer (Gtk_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Up_Box_Draw'Access);
        when Gtk_Down_Box => return
           (if Ptr = Storage.To_Integer (Gtk_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Down_Box_Draw'Access);
        when Gtk_Up_Frame => return
           (if Ptr = Storage.To_Integer (Gtk_Up_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Up_Frame_Draw'Access);
        when Gtk_Down_Frame => return
           (if Ptr = Storage.To_Integer (Gtk_Down_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Down_Frame_Draw'Access);
        when Gtk_Thin_Up_Box => return
           (if Ptr = Storage.To_Integer (Gtk_Thin_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Thin_Up_Box_Draw'Access);
        when Gtk_Thin_Down_Box => return
           (if Ptr = Storage.To_Integer (Gtk_Thin_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Thin_Down_Box_Draw'Access);
        when Gtk_Thin_Up_Frame => return
           (if Ptr = Storage.To_Integer (Gtk_Thin_Up_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Thin_Up_Frame_Draw'Access);
        when Gtk_Thin_Down_Frame => return
           (if Ptr = Storage.To_Integer (Gtk_Thin_Down_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Thin_Down_Frame_Draw'Access);
        when Gtk_Round_Up_Box => return
           (if Ptr = Storage.To_Integer (Gtk_Round_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Round_Up_Box_Draw'Access);
        when Gtk_Round_Down_Box => return
           (if Ptr = Storage.To_Integer (Gtk_Round_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gtk_Round_Down_Box_Draw'Access);
        when Gleam_Up_Box => return
           (if Ptr = Storage.To_Integer (Gleam_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gleam_Up_Box_Draw'Access);
        when Gleam_Down_Box => return
           (if Ptr = Storage.To_Integer (Gleam_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gleam_Down_Box_Draw'Access);
        when Gleam_Up_Frame => return
           (if Ptr = Storage.To_Integer (Gleam_Up_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gleam_Up_Frame_Draw'Access);
        when Gleam_Down_Frame => return
           (if Ptr = Storage.To_Integer (Gleam_Down_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gleam_Down_Frame_Draw'Access);
        when Gleam_Thin_Up_Box => return
           (if Ptr = Storage.To_Integer (Gleam_Thin_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gleam_Thin_Up_Box_Draw'Access);
        when Gleam_Thin_Down_Box => return
           (if Ptr = Storage.To_Integer (Gleam_Thin_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gleam_Thin_Down_Box_Draw'Access);
        when Gleam_Round_Up_Box => return
           (if Ptr = Storage.To_Integer (Gleam_Round_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gleam_Round_Up_Box_Draw'Access);
        when Gleam_Round_Down_Box => return
           (if Ptr = Storage.To_Integer (Gleam_Round_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Gleam_Round_Down_Box_Draw'Access);
        when Oxy_Up_Box => return
           (if Ptr = Storage.To_Integer (Oxy_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Up_Box_Draw'Access);
        when Oxy_Down_Box => return
           (if Ptr = Storage.To_Integer (Oxy_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Down_Box_Draw'Access);
        when Oxy_Up_Frame => return
           (if Ptr = Storage.To_Integer (Oxy_Up_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Up_Frame_Draw'Access);
        when Oxy_Down_Frame => return
           (if Ptr = Storage.To_Integer (Oxy_Down_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Down_Frame_Draw'Access);
        when Oxy_Thin_Up_Box => return
           (if Ptr = Storage.To_Integer (Oxy_Thin_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Thin_Up_Box_Draw'Access);
        when Oxy_Thin_Down_Box => return
           (if Ptr = Storage.To_Integer (Oxy_Thin_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Thin_Down_Box_Draw'Access);
        when Oxy_Thin_Up_Frame => return
           (if Ptr = Storage.To_Integer (Oxy_Thin_Up_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Thin_Up_Frame_Draw'Access);
        when Oxy_Thin_Down_Frame => return
           (if Ptr = Storage.To_Integer (Oxy_Thin_Down_Frame_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Thin_Down_Frame_Draw'Access);
        when Oxy_Round_Up_Box => return
           (if Ptr = Storage.To_Integer (Oxy_Round_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Round_Up_Box_Draw'Access);
        when Oxy_Round_Down_Box => return
           (if Ptr = Storage.To_Integer (Oxy_Round_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Round_Down_Box_Draw'Access);
        when Oxy_Button_Up_Box => return
           (if Ptr = Storage.To_Integer (Oxy_Button_Up_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Button_Up_Box_Draw'Access);
        when Oxy_Button_Down_Box => return
           (if Ptr = Storage.To_Integer (Oxy_Button_Down_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Oxy_Button_Down_Box_Draw'Access);
        when Free_Box => return
           (if Ptr = Storage.To_Integer (Free_Box_Hook'Address)
            then Ada_Access_Array (Kind)
            else Free_Box_Draw'Access);
        end case;
    end To_Ada;




    function To_C
           (Kind : in Box_Kind;
            Func : in FLTK.Static.Box_Draw_Function)
        return Storage.Integer_Address is
    begin
        if Func = null then
            return Null_Pointer;
        end if;
        Ada_Access_Array (Kind) := Func;
        case Kind is
        when No_Box => return
           (if Func = No_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (No_Box_Hook'Address));
        when Flat_Box => return
           (if Func = Flat_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Flat_Box_Hook'Address));
        when Up_Box => return
           (if Func = Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Up_Box_Hook'Address));
        when Down_Box => return
           (if Func = Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Down_Box_Hook'Address));
        when Up_Frame => return
           (if Func = Up_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Up_Frame_Hook'Address));
        when Down_Frame => return
           (if Func = Down_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Down_Frame_Hook'Address));
        when Thin_Up_Box => return
           (if Func = Thin_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Thin_Up_Box_Hook'Address));
        when Thin_Down_Box => return
           (if Func = Thin_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Thin_Down_Box_Hook'Address));
        when Thin_Up_Frame => return
           (if Func = Thin_Up_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Thin_Up_Frame_Hook'Address));
        when Thin_Down_Frame => return
           (if Func = Thin_Down_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Thin_Down_Frame_Hook'Address));
        when Engraved_Box => return
           (if Func = Engraved_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Engraved_Box_Hook'Address));
        when Embossed_Box => return
           (if Func = Embossed_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Embossed_Box_Hook'Address));
        when Engraved_Frame => return
           (if Func = Engraved_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Engraved_Frame_Hook'Address));
        when Embossed_Frame => return
           (if Func = Embossed_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Embossed_Frame_Hook'Address));
        when Border_Box => return
           (if Func = Border_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Border_Box_Hook'Address));
        when Shadow_Box => return
           (if Func = Shadow_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Shadow_Box_Hook'Address));
        when Border_Frame => return
           (if Func = Border_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Border_Frame_Hook'Address));
        when Shadow_Frame => return
           (if Func = Shadow_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Shadow_Frame_Hook'Address));
        when Rounded_Box => return
           (if Func = Rounded_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Rounded_Box_Hook'Address));
        when RShadow_Box => return
           (if Func = RShadow_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (RShadow_Box_Hook'Address));
        when Rounded_Frame => return
           (if Func = Rounded_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Rounded_Frame_Hook'Address));
        when RFlat_Box => return
           (if Func = RFlat_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (RFlat_Box_Hook'Address));
        when Round_Up_Box => return
           (if Func = Round_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Round_Up_Box_Hook'Address));
        when Round_Down_Box => return
           (if Func = Round_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Round_Down_Box_Hook'Address));
        when Diamond_Up_Box => return
           (if Func = Diamond_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Diamond_Up_Box_Hook'Address));
        when Diamond_Down_Box => return
           (if Func = Diamond_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Diamond_Down_Box_Hook'Address));
        when Oval_Box => return
           (if Func = Oval_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oval_Box_Hook'Address));
        when OShadow_Box => return
           (if Func = OShadow_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (OShadow_Box_Hook'Address));
        when Oval_Frame => return
           (if Func = Oval_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oval_Frame_Hook'Address));
        when OFlat_Box => return
           (if Func = OFlat_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (OFlat_Box_Hook'Address));
        when Plastic_Up_Box => return
           (if Func = Plastic_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Plastic_Up_Box_Hook'Address));
        when Plastic_Down_Box => return
           (if Func = Plastic_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Plastic_Down_Box_Hook'Address));
        when Plastic_Up_Frame => return
           (if Func = Plastic_Up_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Plastic_Up_Frame_Hook'Address));
        when Plastic_Down_Frame => return
           (if Func = Plastic_Down_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Plastic_Down_Frame_Hook'Address));
        when Plastic_Thin_Up_Box => return
           (if Func = Plastic_Thin_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Plastic_Thin_Up_Box_Hook'Address));
        when Plastic_Thin_Down_Box => return
           (if Func = Plastic_Thin_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Plastic_Thin_Down_Box_Hook'Address));
        when Plastic_Round_Up_Box => return
           (if Func = Plastic_Round_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Plastic_Round_Up_Box_Hook'Address));
        when Plastic_Round_Down_Box => return
           (if Func = Plastic_Round_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Plastic_Round_Down_Box_Hook'Address));
        when Gtk_Up_Box => return
           (if Func = Gtk_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Up_Box_Hook'Address));
        when Gtk_Down_Box => return
           (if Func = Gtk_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Down_Box_Hook'Address));
        when Gtk_Up_Frame => return
           (if Func = Gtk_Up_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Up_Frame_Hook'Address));
        when Gtk_Down_Frame => return
           (if Func = Gtk_Down_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Down_Frame_Hook'Address));
        when Gtk_Thin_Up_Box => return
           (if Func = Gtk_Thin_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Thin_Up_Box_Hook'Address));
        when Gtk_Thin_Down_Box => return
           (if Func = Gtk_Thin_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Thin_Down_Box_Hook'Address));
        when Gtk_Thin_Up_Frame => return
           (if Func = Gtk_Thin_Up_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Thin_Up_Frame_Hook'Address));
        when Gtk_Thin_Down_Frame => return
           (if Func = Gtk_Thin_Down_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Thin_Down_Frame_Hook'Address));
        when Gtk_Round_Up_Box => return
           (if Func = Gtk_Round_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Round_Up_Box_Hook'Address));
        when Gtk_Round_Down_Box => return
           (if Func = Gtk_Round_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gtk_Round_Down_Box_Hook'Address));
        when Gleam_Up_Box => return
           (if Func = Gleam_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gleam_Up_Box_Hook'Address));
        when Gleam_Down_Box => return
           (if Func = Gleam_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gleam_Down_Box_Hook'Address));
        when Gleam_Up_Frame => return
           (if Func = Gleam_Up_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gleam_Up_Frame_Hook'Address));
        when Gleam_Down_Frame => return
           (if Func = Gleam_Down_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gleam_Down_Frame_Hook'Address));
        when Gleam_Thin_Up_Box => return
           (if Func = Gleam_Thin_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gleam_Thin_Up_Box_Hook'Address));
        when Gleam_Thin_Down_Box => return
           (if Func = Gleam_Thin_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gleam_Thin_Down_Box_Hook'Address));
        when Gleam_Round_Up_Box => return
           (if Func = Gleam_Round_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gleam_Round_Up_Box_Hook'Address));
        when Gleam_Round_Down_Box => return
           (if Func = Gleam_Round_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Gleam_Round_Down_Box_Hook'Address));
        when Oxy_Up_Box => return
           (if Func = Oxy_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Up_Box_Hook'Address));
        when Oxy_Down_Box => return
           (if Func = Oxy_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Down_Box_Hook'Address));
        when Oxy_Up_Frame => return
           (if Func = Oxy_Up_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Up_Frame_Hook'Address));
        when Oxy_Down_Frame => return
           (if Func = Oxy_Down_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Down_Frame_Hook'Address));
        when Oxy_Thin_Up_Box => return
           (if Func = Oxy_Thin_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Thin_Up_Box_Hook'Address));
        when Oxy_Thin_Down_Box => return
           (if Func = Oxy_Thin_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Thin_Down_Box_Hook'Address));
        when Oxy_Thin_Up_Frame => return
           (if Func = Oxy_Thin_Up_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Thin_Up_Frame_Hook'Address));
        when Oxy_Thin_Down_Frame => return
           (if Func = Oxy_Thin_Down_Frame_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Thin_Down_Frame_Hook'Address));
        when Oxy_Round_Up_Box => return
           (if Func = Oxy_Round_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Round_Up_Box_Hook'Address));
        when Oxy_Round_Down_Box => return
           (if Func = Oxy_Round_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Round_Down_Box_Hook'Address));
        when Oxy_Button_Up_Box => return
           (if Func = Oxy_Button_Up_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Button_Up_Box_Hook'Address));
        when Oxy_Button_Down_Box => return
           (if Func = Oxy_Button_Down_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Oxy_Button_Down_Box_Hook'Address));
        when Free_Box => return
           (if Func = Free_Box_Draw'Access
            then C_Ptr_Array (Kind)
            else Storage.To_Integer (Free_Box_Hook'Address));
        end case;
    end To_C;


end FLTK.Box_Draw_Marshal;


