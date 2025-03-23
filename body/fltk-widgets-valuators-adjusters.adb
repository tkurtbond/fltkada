

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Valuators.Adjusters is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_adjuster
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_adjuster, "new_fl_adjuster");
    pragma Inline (new_fl_adjuster);

    procedure free_fl_adjuster
           (A : in Storage.Integer_Address);
    pragma Import (C, free_fl_adjuster, "free_fl_adjuster");
    pragma Inline (free_fl_adjuster);




    --  Allow Outside Range  --

    function fl_adjuster_is_soft
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_adjuster_is_soft, "fl_adjuster_is_soft");
    pragma Inline (fl_adjuster_is_soft);

    procedure fl_adjuster_set_soft
           (A : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_adjuster_set_soft, "fl_adjuster_set_soft");
    pragma Inline (fl_adjuster_set_soft);




    --  Drawing, Events  --

    procedure fl_adjuster_value_damage
           (A : in Storage.Integer_Address);
    pragma Import (C, fl_adjuster_value_damage, "fl_adjuster_value_damage");
    pragma Inline (fl_adjuster_value_damage);

    procedure fl_adjuster_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_adjuster_draw, "fl_adjuster_draw");
    pragma Inline (fl_adjuster_draw);

    function fl_adjuster_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_adjuster_handle, "fl_adjuster_handle");
    pragma Inline (fl_adjuster_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Adjuster) is
    begin
        Extra_Final (Valuator (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Adjuster) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_adjuster (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Adjuster;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Valuator (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Adjuster) is
    begin
        This.Draw_Ptr   := fl_adjuster_draw'Address;
        This.Handle_Ptr := fl_adjuster_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Adjuster is
        begin
            return This : Adjuster do
                This.Void_Ptr := new_fl_adjuster
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
            return Adjuster is
        begin
            return This : Adjuster := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Allow Outside Range  --

    function Is_Soft
           (This : in Adjuster)
        return Boolean is
    begin
        return fl_adjuster_is_soft (This.Void_Ptr) /= 0;
    end Is_Soft;


    procedure Set_Soft
           (This : in out Adjuster;
            To   : in     Boolean) is
    begin
        fl_adjuster_set_soft (This.Void_Ptr, Boolean'Pos (To));
    end Set_Soft;




    --  Drawing, Events  --

    procedure Value_Damage
           (This : in out Adjuster) is
    begin
        fl_adjuster_value_damage (This.Void_Ptr);
    end Value_Damage;


    procedure Draw
           (This : in out Adjuster) is
    begin
        Valuator (This).Draw;
    end Draw;


    function Handle
           (This  : in out Adjuster;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Valuator (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Valuators.Adjusters;


