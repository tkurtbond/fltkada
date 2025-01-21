

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Rollers is


    ------------------------
    --  Functions From C  --
    ------------------------

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


end FLTK.Widgets.Valuators.Rollers;


