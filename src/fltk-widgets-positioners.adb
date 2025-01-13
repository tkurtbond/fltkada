

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Interfaces.C;


package body FLTK.Widgets.Positioners is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_positioner
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_positioner, "new_fl_positioner");
    pragma Inline (new_fl_positioner);

    procedure free_fl_positioner
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_positioner, "free_fl_positioner");
    pragma Inline (free_fl_positioner);




    function fl_positioner_set_value
           (P    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.double)
        return Interfaces.C.int;
    pragma Import (C, fl_positioner_set_value, "fl_positioner_set_value");
    pragma Inline (fl_positioner_set_value);




    procedure fl_positioner_xbounds
           (P    : in Storage.Integer_Address;
            L, H : in Interfaces.C.double);
    pragma Import (C, fl_positioner_xbounds, "fl_positioner_xbounds");
    pragma Inline (fl_positioner_xbounds);

    procedure fl_positioner_xstep
           (P : in Storage.Integer_Address;
            A : in Interfaces.C.double);
    pragma Import (C, fl_positioner_xstep, "fl_positioner_xstep");
    pragma Inline (fl_positioner_xstep);

    function fl_positioner_get_xminimum
           (P : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_positioner_get_xminimum, "fl_positioner_get_xminimum");
    pragma Inline (fl_positioner_get_xminimum);

    procedure fl_positioner_set_xminimum
           (P : in Storage.Integer_Address;
            A : in Interfaces.C.double);
    pragma Import (C, fl_positioner_set_xminimum, "fl_positioner_set_xminimum");
    pragma Inline (fl_positioner_set_xminimum);

    function fl_positioner_get_xmaximum
           (P : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_positioner_get_xmaximum, "fl_positioner_get_xmaximum");
    pragma Inline (fl_positioner_get_xmaximum);

    procedure fl_positioner_set_xmaximum
           (P : in Storage.Integer_Address;
            A : in Interfaces.C.double);
    pragma Import (C, fl_positioner_set_xmaximum, "fl_positioner_set_xmaximum");
    pragma Inline (fl_positioner_set_xmaximum);

    function fl_positioner_get_xvalue
           (P : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_positioner_get_xvalue, "fl_positioner_get_xvalue");
    pragma Inline (fl_positioner_get_xvalue);

    function fl_positioner_set_xvalue
           (P : in Storage.Integer_Address;
            V : in Interfaces.C.double)
        return Interfaces.C.int;
    pragma Import (C, fl_positioner_set_xvalue, "fl_positioner_set_xvalue");
    pragma Inline (fl_positioner_set_xvalue);




    procedure fl_positioner_ybounds
           (P    : in Storage.Integer_Address;
            L, H : in Interfaces.C.double);
    pragma Import (C, fl_positioner_ybounds, "fl_positioner_ybounds");
    pragma Inline (fl_positioner_ybounds);

    procedure fl_positioner_ystep
           (P : in Storage.Integer_Address;
            A : in Interfaces.C.double);
    pragma Import (C, fl_positioner_ystep, "fl_positioner_ystep");
    pragma Inline (fl_positioner_ystep);

    function fl_positioner_get_yminimum
           (P : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_positioner_get_yminimum, "fl_positioner_get_yminimum");
    pragma Inline (fl_positioner_get_yminimum);

    procedure fl_positioner_set_yminimum
           (P : in Storage.Integer_Address;
            A : in Interfaces.C.double);
    pragma Import (C, fl_positioner_set_yminimum, "fl_positioner_set_yminimum");
    pragma Inline (fl_positioner_set_yminimum);

    function fl_positioner_get_ymaximum
           (P : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_positioner_get_ymaximum, "fl_positioner_get_ymaximum");
    pragma Inline (fl_positioner_get_ymaximum);

    procedure fl_positioner_set_ymaximum
           (P : in Storage.Integer_Address;
            A : in Interfaces.C.double);
    pragma Import (C, fl_positioner_set_ymaximum, "fl_positioner_set_ymaximum");
    pragma Inline (fl_positioner_set_ymaximum);

    function fl_positioner_get_yvalue
           (P : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_positioner_get_yvalue, "fl_positioner_get_yvalue");
    pragma Inline (fl_positioner_get_yvalue);

    function fl_positioner_set_yvalue
           (P : in Storage.Integer_Address;
            V : in Interfaces.C.double)
        return Interfaces.C.int;
    pragma Import (C, fl_positioner_set_yvalue, "fl_positioner_set_yvalue");
    pragma Inline (fl_positioner_set_yvalue);




    procedure fl_positioner_draw
           (P : in Storage.Integer_Address);
    pragma Import (C, fl_positioner_draw, "fl_positioner_draw");
    pragma Inline (fl_positioner_draw);

    procedure fl_positioner_draw2
           (P          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_positioner_draw2, "fl_positioner_draw2");
    pragma Inline (fl_positioner_draw2);

    function fl_positioner_handle
           (P : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_positioner_handle, "fl_positioner_handle");
    pragma Inline (fl_positioner_handle);

    function fl_positioner_handle2
           (P             : in Storage.Integer_Address;
            E, X, Y, W, H : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_positioner_handle2, "fl_positioner_handle2");
    pragma Inline (fl_positioner_handle2);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Positioner) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Positioner) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_positioner (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Positioner;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Positioner) is
    begin
        This.Draw_Ptr   := fl_positioner_draw'Address;
        This.Handle_Ptr := fl_positioner_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Positioner is
        begin
            return This : Positioner do
                This.Void_Ptr := new_fl_positioner
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

    procedure Get_Coords
           (This : in     Positioner;
            X, Y :    out Long_Float) is
    begin
        X := This.Get_Ecks;
        Y := This.Get_Why;
    end Get_Coords;


    procedure Set_Coords
           (This : in out Positioner;
            X, Y : in     Long_Float)
    is
        Result : Interfaces.C.int := fl_positioner_set_value
           (This.Void_Ptr,
            Interfaces.C.double (X),
            Interfaces.C.double (Y));
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error;
    end Set_Coords;


    function Set_Coords
           (This : in out Positioner;
            X, Y : in     Long_Float)
        return Boolean
    is
        Result : Interfaces.C.int := fl_positioner_set_value
           (This.Void_Ptr,
            Interfaces.C.double (X),
            Interfaces.C.double (Y));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error;
    end Set_Coords;




    procedure Set_Ecks_Bounds
           (This      : in out Positioner;
            Low, High : in     Long_Float) is
    begin
        fl_positioner_xbounds
           (This.Void_Ptr,
            Interfaces.C.double (Low),
            Interfaces.C.double (High));
    end Set_Ecks_Bounds;


    procedure Set_Ecks_Step
           (This  : in out Positioner;
            Value : in     Long_Float) is
    begin
        fl_positioner_xstep (This.Void_Ptr, Interfaces.C.double (Value));
    end Set_Ecks_Step;


    function Get_Ecks_Minimum
           (This : in Positioner)
        return Long_Float is
    begin
        return Long_Float (fl_positioner_get_xminimum (This.Void_Ptr));
    end Get_Ecks_Minimum;


    procedure Set_Ecks_Minimum
           (This  : in out Positioner;
            Value : in     Long_Float) is
    begin
        fl_positioner_set_xminimum (This.Void_Ptr, Interfaces.C.double (Value));
    end Set_Ecks_Minimum;


    function Get_Ecks_Maximum
           (This : in Positioner)
        return Long_Float is
    begin
        return Long_Float (fl_positioner_get_xmaximum (This.Void_Ptr));
    end Get_Ecks_Maximum;


    procedure Set_Ecks_Maximum
           (This  : in out Positioner;
            Value : in     Long_Float) is
    begin
        fl_positioner_set_xmaximum (This.Void_Ptr, Interfaces.C.double (Value));
    end Set_Ecks_Maximum;


    function Get_Ecks
           (This : in Positioner)
        return Long_Float is
    begin
        return Long_Float (fl_positioner_get_xvalue (This.Void_Ptr));
    end Get_Ecks;


    procedure Set_Ecks
           (This  : in out Positioner;
            Value : in     Long_Float)
    is
        Result : Interfaces.C.int := fl_positioner_set_xvalue
           (This.Void_Ptr,
            Interfaces.C.double (Value));
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error;
    end Set_Ecks;


    function Set_Ecks
           (This  : in out Positioner;
            Value : in     Long_Float)
        return Boolean
    is
        Result : Interfaces.C.int := fl_positioner_set_xvalue
           (This.Void_Ptr,
            Interfaces.C.double (Value));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error;
    end Set_Ecks;




    procedure Set_Why_Bounds
           (This      : in out Positioner;
            Low, High : in     Long_Float) is
    begin
        fl_positioner_ybounds
           (This.Void_Ptr,
            Interfaces.C.double (Low),
            Interfaces.C.double (High));
    end Set_Why_Bounds;


    procedure Set_Why_Step
           (This  : in out Positioner;
            Value : in     Long_Float) is
    begin
        fl_positioner_ystep (This.Void_Ptr, Interfaces.C.double (Value));
    end Set_Why_Step;


    function Get_Why_Minimum
           (This : in Positioner)
        return Long_Float is
    begin
        return Long_Float (fl_positioner_get_yminimum (This.Void_Ptr));
    end Get_Why_Minimum;


    procedure Set_Why_Minimum
           (This  : in out Positioner;
            Value : in     Long_Float) is
    begin
        fl_positioner_set_yminimum (This.Void_Ptr, Interfaces.C.double (Value));
    end Set_Why_Minimum;


    function Get_Why_Maximum
           (This : in Positioner)
        return Long_Float is
    begin
        return Long_Float (fl_positioner_get_ymaximum (This.Void_Ptr));
    end Get_Why_Maximum;


    procedure Set_Why_Maximum
           (This  : in out Positioner;
            Value : in     Long_Float) is
    begin
        fl_positioner_set_ymaximum (This.Void_Ptr, Interfaces.C.double (Value));
    end Set_Why_Maximum;


    function Get_Why
           (This : in Positioner)
        return Long_Float is
    begin
        return Long_Float (fl_positioner_get_yvalue (This.Void_Ptr));
    end Get_Why;


    procedure Set_Why
           (This  : in out Positioner;
            Value : in     Long_Float)
    is
        Result : Interfaces.C.int := fl_positioner_set_yvalue
           (This.Void_Ptr,
            Interfaces.C.double (Value));
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error;
    end Set_Why;


    function Set_Why
           (This  : in out Positioner;
            Value : in     Long_Float)
        return Boolean
    is
        Result : Interfaces.C.int := fl_positioner_set_yvalue
           (This.Void_Ptr,
            Interfaces.C.double (Value));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error;
    end Set_Why;




    procedure Draw
           (This : in out Positioner) is
    begin
        Widget (This).Draw;
    end Draw;


    procedure Draw
           (This       : in out Positioner;
            X, Y, W, H : in     Integer) is
    begin
        fl_positioner_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Draw;


    function Handle
           (This  : in out Positioner;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


    function Handle
           (This       : in out Positioner;
            Event      : in     Event_Kind;
            X, Y, W, H : in     Integer)
        return Event_Outcome is
    begin
        return Event_Outcome'Val (fl_positioner_handle2
           (This.Void_Ptr,
            Event_Kind'Pos (Event),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H)));
    exception
    when Constraint_Error => raise Internal_FLTK_Error;
    end Handle;


end FLTK.Widgets.Positioners;


