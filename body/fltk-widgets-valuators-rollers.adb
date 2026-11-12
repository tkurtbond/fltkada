

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups;


package body FLTK.Widgets.Valuators.Rollers is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_roller
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_roller, "new_fl_roller");
    pragma Inline (new_fl_roller);

    procedure free_fl_roller
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_roller, "free_fl_roller");
    pragma Inline (free_fl_roller);




    --  Drawing, Events  --

    procedure fl_roller_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_roller_draw, "fl_roller_draw");
    pragma Inline (fl_roller_draw);

    function fl_roller_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_roller_handle, "fl_roller_handle");
    pragma Inline (fl_roller_handle);




    --  Roller Type  --

    function fl_widget_get_type
           (R : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_widget_get_type, "fl_widget_get_type");
    pragma Inline (fl_widget_get_type);

    procedure fl_widget_set_type
           (R : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_set_type, "fl_widget_set_type");
    pragma Inline (fl_widget_set_type);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Roller) is
    begin
        Extra_Final (Valuator (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Roller) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_roller (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Roller;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Valuator (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Roller) is
    begin
        This.Draw_Ptr   := fl_roller_draw'Address;
        This.Handle_Ptr := fl_roller_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Roller is
        begin
            return This : Roller do
                This.Void_Ptr := new_fl_roller
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
            return Roller is
        begin
            return This : Roller := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Drawing, Events  --

    procedure Draw
           (This : in out Roller) is
    begin
        Valuator (This).Draw;
    end Draw;


    function Handle
           (This  : in out Roller;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Valuator (This).Handle (Event);
    end Handle;




    --  Roller Type  --

    function Get_Kind
           (This : in Roller)
        return Roller_Kind
    is
        Result : constant Interfaces.C.unsigned_char := fl_widget_get_type (This.Void_Ptr);
    begin
        return Roller_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Roller::type returned unexpected unsigned char value of " &
        Interfaces.C.unsigned_char'Image (Result);
    end Get_Kind;


    procedure Set_Kind
           (This : in out Roller;
            To   : in     Roller_Kind) is
    begin
        fl_widget_set_type (This.Void_Ptr, Roller_Kind'Pos (To));
    end Set_Kind;


end FLTK.Widgets.Valuators.Rollers;


