

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C,
    System;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Menus.Choices is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_choice
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_choice, "new_fl_choice");
    pragma Inline (new_fl_choice);

    procedure free_fl_choice
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_choice, "free_fl_choice");
    pragma Inline (free_fl_choice);




    function fl_choice_value
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_choice_value, "fl_choice_value");
    pragma Inline (fl_choice_value);

    function fl_choice_set_value
           (M, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_choice_set_value, "fl_choice_set_value");
    pragma Inline (fl_choice_set_value);

    function fl_choice_set_value2
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_choice_set_value2, "fl_choice_set_value2");
    pragma Inline (fl_choice_set_value2);




    procedure fl_choice_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_choice_draw, "fl_choice_draw");
    pragma Inline (fl_choice_draw);

    function fl_choice_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_choice_handle, "fl_choice_handle");
    pragma Inline (fl_choice_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Choice) is
    begin
        Extra_Final (Menu (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Choice) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_choice (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Choice;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Menu (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Choice) is
    begin
        This.Draw_Ptr := fl_choice_draw'Address;
        This.Handle_Ptr := fl_choice_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Choice is
        begin
            return This : Choice do
                This.Void_Ptr := new_fl_choice
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

    function Chosen_Index
           (This : in Choice)
        return Extended_Index is
    begin
        return Extended_Index (fl_choice_value (This.Void_Ptr) + 1);
    end Chosen_Index;


    procedure Set_Chosen
           (This : in out Choice;
            Item : in     FLTK.Menu_Items.Menu_Item)
    is
        Ignore_Ret : Interfaces.C.int;
    begin
        Ignore_Ret := fl_choice_set_value (This.Void_Ptr, Wrapper (Item).Void_Ptr);
    end Set_Chosen;


    function Set_Chosen
           (This : in out Choice;
            Item : in     FLTK.Menu_Items.Menu_Item)
        return Boolean is
    begin
        return fl_choice_set_value (This.Void_Ptr, Wrapper (Item).Void_Ptr) /= 0;
    end Set_Chosen;


    procedure Set_Chosen
           (This  : in out Choice;
            Place : in     Index)
    is
        Ignore_Ret : Interfaces.C.int;
    begin
        Ignore_Ret := fl_choice_set_value2 (This.Void_Ptr, Interfaces.C.int (Place) - 1);
    end Set_Chosen;


    function Set_Chosen
           (This  : in out Choice;
            Place : in     Index)
        return Boolean is
    begin
        return fl_choice_set_value2 (This.Void_Ptr, Interfaces.C.int (Place) - 1) /= 0;
    end Set_Chosen;




    procedure Draw
           (This : in out Choice) is
    begin
        Menu (This).Draw;
    end Draw;


    function Handle
           (This  : in out Choice;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Menu (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Menus.Choices;


