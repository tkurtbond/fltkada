

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Clocks.Updated is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_clock
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_clock, "new_fl_clock");
    pragma Inline (new_fl_clock);

    function new_fl_clock2
           (K          : in Interfaces.C.unsigned_char;
            X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_clock2, "new_fl_clock2");
    pragma Inline (new_fl_clock2);

    procedure free_fl_clock
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_clock, "free_fl_clock");
    pragma Inline (free_fl_clock);




    procedure fl_clock_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_clock_draw, "fl_clock_draw");
    pragma Inline (fl_clock_draw);

    function fl_clock_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_clock_handle, "fl_clock_handle");
    pragma Inline (fl_clock_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Updated_Clock) is
    begin
        Extra_Final (Clock (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Updated_Clock) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_clock (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Updated_Clock;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Clock (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Updated_Clock) is
    begin
        This.Draw_Ptr   := fl_clock_draw'Address;
        This.Handle_Ptr := fl_clock_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Updated_Clock is
        begin
            return This : Updated_Clock do
                This.Void_Ptr := new_fl_clock
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
            return Updated_Clock is
        begin
            return This : Updated_Clock := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;


        function Create
               (Kind       : in Box_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Updated_Clock is
        begin
            return This : Updated_Clock do
                This.Void_Ptr := new_fl_clock2
                       (Box_Kind'Pos (Kind),
                        Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                Kind       : in     Box_Kind;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Updated_Clock is
        begin
            return This : Updated_Clock := Create (Kind, X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Handle
           (This  : in out Updated_Clock;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Clock (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Clocks.Updated;


