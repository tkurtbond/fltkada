

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Groups.Packed is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_pack
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pack, "new_fl_pack");
    pragma Inline (new_fl_pack);

    procedure free_fl_pack
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_pack, "free_fl_pack");
    pragma Inline (free_fl_pack);




    function fl_pack_get_spacing
           (P : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_pack_get_spacing, "fl_pack_get_spacing");
    pragma Inline (fl_pack_get_spacing);

    procedure fl_pack_set_spacing
           (P : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_pack_set_spacing, "fl_pack_set_spacing");
    pragma Inline (fl_pack_set_spacing);

    function fl_widget_get_type
           (P : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_widget_get_type, "fl_widget_get_type");
    pragma Inline (fl_widget_get_type);

    procedure fl_widget_set_type
           (P : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_set_type, "fl_widget_set_type");
    pragma Inline (fl_widget_set_type);




    procedure fl_pack_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_pack_draw, "fl_pack_draw");
    pragma Inline (fl_pack_draw);

    function fl_pack_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_pack_handle, "fl_pack_handle");
    pragma Inline (fl_pack_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Packed_Group) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Packed_Group) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_pack (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Packed_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Packed_Group) is
    begin
        This.Draw_Ptr   := fl_pack_draw'Address;
        This.Handle_Ptr := fl_pack_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Packed_Group is
        begin
            return This : Packed_Group do
                This.Void_Ptr := new_fl_pack
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Get_Spacing
           (This : in Packed_Group)
        return Integer is
    begin
        return Integer (fl_pack_get_spacing (This.Void_Ptr));
    end Get_Spacing;


    procedure Set_Spacing
           (This : in out Packed_Group;
            To   : in     Integer) is
    begin
        fl_pack_set_spacing (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Spacing;


    function Get_Pack_Type
           (This : in Packed_Group)
        return Pack_Kind is
    begin
        return Pack_Kind'Val (fl_widget_get_type (This.Void_Ptr));
    exception
    when Constraint_Error => raise Internal_FLTK_Error;
    end Get_Pack_Type;


    procedure Set_Pack_Type
           (This : in out Packed_Group;
            Kind : in     Pack_Kind) is
    begin
        fl_widget_set_type (This.Void_Ptr, Pack_Kind'Pos (Kind));
    end Set_Pack_Type;




    procedure Draw
           (This : in out Packed_Group) is
    begin
        Group (This).Draw;
    end Draw;


end FLTK.Widgets.Groups.Packed;


