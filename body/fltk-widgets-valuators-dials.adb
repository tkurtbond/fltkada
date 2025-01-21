

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Dials is


    ------------------------
    --  Functions From C  --
    ------------------------

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




    function fl_dial_get_angle1
           (D : in Storage.Integer_Address)
        return Interfaces.C.short;
    pragma Import (C, fl_dial_get_angle1, "fl_dial_get_angle1");
    pragma Inline (fl_dial_get_angle1);

    procedure fl_dial_set_angle1
           (D : in Storage.Integer_Address;
            T : in Interfaces.C.short);
    pragma Import (C, fl_dial_set_angle1, "fl_dial_set_angle1");
    pragma Inline (fl_dial_set_angle1);

    function fl_dial_get_angle2
           (D : in Storage.Integer_Address)
        return Interfaces.C.short;
    pragma Import (C, fl_dial_get_angle2, "fl_dial_get_angle2");
    pragma Inline (fl_dial_get_angle2);

    procedure fl_dial_set_angle2
           (D : in Storage.Integer_Address;
            T : in Interfaces.C.short);
    pragma Import (C, fl_dial_set_angle2, "fl_dial_set_angle2");
    pragma Inline (fl_dial_set_angle2);

    procedure fl_dial_set_angles
           (D    : in Storage.Integer_Address;
            A, B : in Interfaces.C.short);
    pragma Import (C, fl_dial_set_angles, "fl_dial_set_angles");
    pragma Inline (fl_dial_set_angles);




    procedure fl_dial_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_dial_draw, "fl_dial_draw");
    pragma Inline (fl_dial_draw);

    procedure fl_dial_draw2
           (D          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_dial_draw2, "fl_dial_draw2");
    pragma Inline (fl_dial_draw2);

    function fl_dial_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_dial_handle, "fl_dial_handle");
    pragma Inline (fl_dial_handle);

    function fl_dial_handle2
           (D             : in Storage.Integer_Address;
            E, X, Y, W, H : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_dial_handle2, "fl_dial_handle2");
    pragma Inline (fl_dial_handle2);




    function fl_widget_get_type
           (D : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_widget_get_type, "fl_widget_get_type");
    pragma Inline (fl_widget_get_type);

    procedure fl_widget_set_type
           (D : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_set_type, "fl_widget_set_type");
    pragma Inline (fl_widget_set_type);




    -------------------
    --  Destructors  --
    -------------------

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
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Dial;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Valuator (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Dial) is
    begin
        This.Draw_Ptr   := fl_dial_draw'Address;
        This.Handle_Ptr := fl_dial_handle'Address;
    end Initialize;


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
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Dial is
        begin
            return This : Dial := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Get_First_Angle
           (This : in Dial)
        return Short_Integer is
    begin
        return Short_Integer (fl_dial_get_angle1 (This.Void_Ptr));
    end Get_First_Angle;


    procedure Set_First_Angle
           (This : in out Dial;
            To   : in     Short_Integer) is
    begin
        fl_dial_set_angle1 (This.Void_Ptr, Interfaces.C.short (To));
    end Set_First_Angle;


    function Get_Second_Angle
           (This : in Dial)
        return Short_Integer is
    begin
        return Short_Integer (fl_dial_get_angle2 (This.Void_Ptr));
    end Get_Second_Angle;


    procedure Set_Second_Angle
           (This : in out Dial;
            To   : in     Short_Integer) is
    begin
        fl_dial_set_angle2 (This.Void_Ptr, Interfaces.C.short (To));
    end Set_Second_Angle;


    procedure Set_Angles
           (This     : in out Dial;
            One, Two : in     Short_Integer) is
    begin
        fl_dial_set_angles
           (This.Void_Ptr,
            Interfaces.C.short (One),
            Interfaces.C.short (Two));
    end Set_Angles;




    procedure Draw
           (This : in out Dial) is
    begin
        Valuator (This).Draw;
    end Draw;


    procedure Draw
           (This       : in out Dial;
            X, Y, W, H : in     Integer) is
    begin
        fl_dial_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Draw;


    function Handle
           (This  : in out Dial;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Valuator (This).Handle (Event);
    end Handle;


    function Handle
           (This       : in out Dial;
            Event      : in     Event_Kind;
            X, Y, W, H : in     Integer)
        return Event_Outcome is
    begin
        return Event_Outcome'Val (fl_dial_handle2
           (This.Void_Ptr,
            Event_Kind'Pos (Event),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H)));
    exception
    when Constraint_Error => raise Internal_FLTK_Error;
    end Handle;




    function Get_Kind
           (This : in Dial)
        return Dial_Kind
    is
        Result : Interfaces.C.unsigned_char := fl_widget_get_type (This.Void_Ptr);
    begin
        return Dial_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Dial::type returned unexpected unsigned char value of " &
        Interfaces.C.unsigned_char'Image (Result);
    end Get_Kind;


    package body Extra is

        procedure Set_Kind
               (This : in out Dial;
                To   : in     Dial_Kind) is
        begin
            fl_widget_set_type (This.Void_Ptr, Dial_Kind'Pos (To));
        end Set_Kind;

        pragma Inline (Set_Kind);

    end Extra;


end FLTK.Widgets.Valuators.Dials;


