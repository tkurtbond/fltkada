

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Dials is


    procedure dial_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, dial_set_draw_hook, "dial_set_draw_hook");
    pragma Inline (dial_set_draw_hook);

    procedure dial_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, dial_set_handle_hook, "dial_set_handle_hook");
    pragma Inline (dial_set_handle_hook);




    function new_fl_dial
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_dial, "new_fl_dial");
    pragma Inline (new_fl_dial);

    procedure free_fl_dial
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_dial, "free_fl_dial");
    pragma Inline (free_fl_dial);




    function fl_dial_get_type
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_dial_get_type, "fl_dial_get_type");
    pragma Inline (fl_dial_get_type);

    procedure fl_dial_set_type
           (D : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_dial_set_type, "fl_dial_set_type");
    pragma Inline (fl_dial_set_type);




    function fl_dial_get_angle1
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_dial_get_angle1, "fl_dial_get_angle1");
    pragma Inline (fl_dial_get_angle1);

    procedure fl_dial_set_angle1
           (D : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_dial_set_angle1, "fl_dial_set_angle1");
    pragma Inline (fl_dial_set_angle1);

    function fl_dial_get_angle2
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_dial_get_angle2, "fl_dial_get_angle2");
    pragma Inline (fl_dial_get_angle2);

    procedure fl_dial_set_angle2
           (D : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_dial_set_angle2, "fl_dial_set_angle2");
    pragma Inline (fl_dial_set_angle2);

    procedure fl_dial_set_angles
           (D    : in Storage.Integer_Address;
            A, B : in Interfaces.C.int);
    pragma Import (C, fl_dial_set_angles, "fl_dial_set_angles");
    pragma Inline (fl_dial_set_angles);




    procedure fl_dial_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_dial_draw, "fl_dial_draw");
    pragma Inline (fl_dial_draw);

    function fl_dial_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_dial_handle, "fl_dial_handle");
    pragma Inline (fl_dial_handle);




    procedure Extra_Final
           (This : in out Dial) is
    begin
        Extra_Final (Valuator (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Dial) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_dial (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Dial;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Valuator (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Dial is
        begin
            return This : Dial do
                This.Void_Ptr := new_fl_dial
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                dial_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                dial_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    function Get_Dial_Type
           (This : in Dial)
        return Dial_Kind is
    begin
        return Dial_Kind'Val (fl_dial_get_type (This.Void_Ptr));
    end Get_Dial_Type;


    function Get_First_Angle
           (This : in Dial)
        return Integer is
    begin
        return Integer (fl_dial_get_angle1 (This.Void_Ptr));
    end Get_First_Angle;


    procedure Set_First_Angle
           (This : in out Dial;
            To   : in     Integer) is
    begin
        fl_dial_set_angle1 (This.Void_Ptr, Interfaces.C.int (To));
    end Set_First_Angle;


    function Get_Second_Angle
           (This : in Dial)
        return Integer is
    begin
        return Integer (fl_dial_get_angle2 (This.Void_Ptr));
    end Get_Second_Angle;


    procedure Set_Second_Angle
           (This : in out Dial;
            To   : in     Integer) is
    begin
        fl_dial_set_angle2 (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Second_Angle;


    procedure Set_Angles
           (This     : in out Dial;
            One, Two : in     Integer) is
    begin
        fl_dial_set_angles (This.Void_Ptr, Interfaces.C.int (One), Interfaces.C.int (Two));
    end Set_Angles;




    procedure Draw
           (This : in out Dial) is
    begin
        fl_dial_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Dial;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_dial_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;




    package body Extra is

        procedure Set_Dial_Type
               (This : in out Dial;
                To   : in     Dial_Kind) is
        begin
            fl_dial_set_type (This.Void_Ptr, Dial_Kind'Pos (To));
        end Set_Dial_Type;

        pragma Inline (Set_Dial_Type);

    end Extra;


end FLTK.Widgets.Valuators.Dials;

