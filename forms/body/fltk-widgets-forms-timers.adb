

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Groups,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Forms.Timers is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_timer
           (K, X, Y, W, H : in Interfaces.C.int;
            Text          : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_timer, "new_fl_timer");
    pragma Inline (new_fl_timer);

    procedure free_fl_timer
           (T : in Storage.Integer_Address);
    pragma Import (C, free_fl_timer, "free_fl_timer");
    pragma Inline (free_fl_timer);




    --  Time  --

    function fl_timer_get_value
           (T : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_timer_get_value, "fl_timer_get_value");
    pragma Inline (fl_timer_get_value);

    procedure fl_timer_set_value
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.double);
    pragma Import (C, fl_timer_set_value, "fl_timer_set_value");
    pragma Inline (fl_timer_set_value);

    function fl_timer_counts_up
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_timer_counts_up, "fl_timer_counts_up");
    pragma Inline (fl_timer_counts_up);

    procedure fl_timer_set_counts_up
           (T : in Storage.Integer_Address;
            U : in Interfaces.C.int);
    pragma Import (C, fl_timer_set_counts_up, "fl_timer_set_counts_up");
    pragma Inline (fl_timer_set_counts_up);

    function fl_timer_is_suspended
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_timer_is_suspended, "fl_timer_is_suspended");
    pragma Inline (fl_timer_is_suspended);

    procedure fl_timer_set_suspended
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_timer_set_suspended, "fl_timer_set_suspended");
    pragma Inline (fl_timer_set_suspended);




    --  Drawing, Events  --

    procedure fl_timer_draw
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_timer_draw, "fl_timer_draw");
    pragma Inline (fl_timer_draw);

    function fl_timer_handle
           (T : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_timer_handle, "fl_timer_handle");
    pragma Inline (fl_timer_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Timer) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Timer) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_timer (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Timer;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Timer) is
    begin
        This.Draw_Ptr   := fl_timer_draw'Address;
        This.Handle_Ptr := fl_timer_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (Kind       : in Timer_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Timer is
        begin
            return This : Timer do
                This.Void_Ptr := new_fl_timer
                   (Timer_Kind'Pos (Kind),
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
                Kind       : in     Timer_Kind;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Timer is
        begin
            return This : Timer := Create (Kind, X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Time  --

    function Get_Value
           (This : in Timer)
        return Long_Float is
    begin
        return Long_Float (fl_timer_get_value (This.Void_Ptr));
    end Get_Value;


    procedure Set_Value
           (This  : in out Timer;
            Value : in     Long_Float) is
    begin
        fl_timer_set_value (This.Void_Ptr, Interfaces.C.double (Value));
    end Set_Value;


    function Counts_Up
           (This : in Timer)
        return Boolean is
    begin
        return fl_timer_counts_up (This.Void_Ptr) /= 0;
    end Counts_Up;


    procedure Set_Counts_Up
           (This  : in out Timer;
            Value : in     Boolean) is
    begin
        fl_timer_set_counts_up (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Counts_Up;


    function Is_Suspended
           (This : in Timer)
        return Boolean is
    begin
        return fl_timer_is_suspended (This.Void_Ptr) /= 0;
    end Is_Suspended;


    procedure Set_Suspended
           (This  : in out Timer;
            Value : in     Boolean) is
    begin
        fl_timer_set_suspended (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Suspended;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Timer) is
    begin
        Widget (This).Draw;
    end Draw;


    function Handle
           (This  : in out Timer;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Forms.Timers;


