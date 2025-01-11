

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Clocks.Updated.Round is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_round_clock
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_round_clock, "new_fl_round_clock");
    pragma Inline (new_fl_round_clock);

    procedure free_fl_round_clock
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_round_clock, "free_fl_round_clock");
    pragma Inline (free_fl_round_clock);




    procedure fl_round_clock_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_round_clock_draw, "fl_round_clock_draw");
    pragma Inline (fl_round_clock_draw);

    function fl_round_clock_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_round_clock_handle, "fl_round_clock_handle");
    pragma Inline (fl_round_clock_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Round_Clock) is
    begin
        Extra_Final (Updated_Clock (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Round_Clock) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_round_clock (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Round_Clock;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Updated_Clock (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Round_Clock) is
    begin
        This.Draw_Ptr := fl_round_clock_draw'Address;
        This.Handle_Ptr := fl_round_clock_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Round_Clock is
        begin
            return This : Round_Clock do
                This.Void_Ptr := new_fl_round_clock
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;

    end Forge;


end FLTK.Widgets.Clocks.Updated.Round;


