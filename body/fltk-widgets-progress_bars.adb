

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Progress_Bars is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_progress
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_progress, "new_fl_progress");
    pragma Inline (new_fl_progress);

    procedure free_fl_progress
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_progress, "free_fl_progress");
    pragma Inline (free_fl_progress);




    --  Values  --

    function fl_progress_get_minimum
           (P : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_progress_get_minimum, "fl_progress_get_minimum");
    pragma Inline (fl_progress_get_minimum);

    procedure fl_progress_set_minimum
           (P : in Storage.Integer_Address;
            T : in Interfaces.C.C_float);
    pragma Import (C, fl_progress_set_minimum, "fl_progress_set_minimum");
    pragma Inline (fl_progress_set_minimum);

    function fl_progress_get_maximum
           (P : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_progress_get_maximum, "fl_progress_get_maximum");
    pragma Inline (fl_progress_get_maximum);

    procedure fl_progress_set_maximum
           (P : in Storage.Integer_Address;
            T : in Interfaces.C.C_float);
    pragma Import (C, fl_progress_set_maximum, "fl_progress_set_maximum");
    pragma Inline (fl_progress_set_maximum);

    function fl_progress_get_value
           (P : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_progress_get_value, "fl_progress_get_value");
    pragma Inline (fl_progress_get_value);

    procedure fl_progress_set_value
           (P : in Storage.Integer_Address;
            T : in Interfaces.C.C_float);
    pragma Import (C, fl_progress_set_value, "fl_progress_set_value");
    pragma Inline (fl_progress_set_value);




    --  Drawing, Events  --

    procedure fl_progress_draw
           (P : in Storage.Integer_Address);
    pragma Import (C, fl_progress_draw, "fl_progress_draw");
    pragma Inline (fl_progress_draw);

    function fl_progress_handle
           (P : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_progress_handle, "fl_progress_handle");
    pragma Inline (fl_progress_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Progress_Bar) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Progress_Bar) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_progress (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Progress_Bar;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Progress_Bar) is
    begin
        This.Draw_Ptr := fl_progress_draw'Address;
        This.Handle_Ptr := fl_progress_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Progress_Bar is
        begin
            return This : Progress_Bar do
                This.Void_Ptr := new_fl_progress
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
            return Progress_Bar is
        begin
            return This : Progress_Bar := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Values  --

    function Get_Minimum
           (This : in Progress_Bar)
        return Float is
    begin
        return Float (fl_progress_get_minimum (This.Void_Ptr));
    end Get_Minimum;


    procedure Set_Minimum
           (This : in out Progress_Bar;
            To   : in     Float) is
    begin
        fl_progress_set_minimum (This.Void_Ptr, Interfaces.C.C_float (To));
    end Set_Minimum;


    function Get_Maximum
           (This : in Progress_Bar)
        return Float is
    begin
        return Float (fl_progress_get_maximum (This.Void_Ptr));
    end Get_Maximum;


    procedure Set_Maximum
           (This : in out Progress_Bar;
            To   : in     Float) is
    begin
        fl_progress_set_maximum (This.Void_Ptr, Interfaces.C.C_float (To));
    end Set_Maximum;


    function Get_Value
           (This : in Progress_Bar)
        return Float is
    begin
        return Float (fl_progress_get_value (This.Void_Ptr));
    end Get_Value;


    procedure Set_Value
           (This : in out Progress_Bar;
            To   : in     Float) is
    begin
        fl_progress_set_value (This.Void_Ptr, Interfaces.C.C_float (To));
    end Set_Value;




    --  Drawing  --

    procedure Draw
           (This : in out Progress_Bar) is
    begin
        Widget (This).Draw;
    end Draw;


end FLTK.Widgets.Progress_Bars;


