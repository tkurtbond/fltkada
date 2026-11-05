

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Menus.Choices.Schemes is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_scheme_choice
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_scheme_choice, "new_fl_scheme_choice");
    pragma Inline (new_fl_scheme_choice);

    procedure free_fl_scheme_choice
           (C : in Storage.Integer_Address);
    pragma Import (C, free_fl_scheme_choice, "free_fl_scheme_choice");
    pragma Inline (free_fl_scheme_choice);




    --  Selection  --

    procedure fl_scheme_choice_init_value
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_scheme_choice_init_value, "fl_scheme_choice_init_value");
    pragma Inline (fl_scheme_choice_init_value);

    function fl_scheme_choice_switch
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_scheme_choice_switch, "fl_scheme_choice_switch");
    pragma Inline (fl_scheme_choice_switch);




    --  Drawing, Events  --

    procedure fl_scheme_choice_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_scheme_choice_draw, "fl_scheme_choice_draw");
    pragma Inline (fl_scheme_choice_draw);

    function fl_scheme_choice_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_scheme_choice_handle, "fl_scheme_choice_handle");
    pragma Inline (fl_scheme_choice_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Scheme_Choice) is
    begin
        Extra_Final (Choice (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Scheme_Choice) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_scheme_choice (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Scheme_Choice;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Choice (This), X, Y, W, H, Text);
        --  The C++ constructor already added one item per scheme
        This.Adjust_Item_Store;
    end Extra_Init;


    procedure Initialize
           (This : in out Scheme_Choice) is
    begin
        Initialize (Choice (This));
        This.Draw_Ptr   := fl_scheme_choice_draw'Address;
        This.Handle_Ptr := fl_scheme_choice_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Scheme_Choice is
        begin
            return This : Scheme_Choice do
                This.Void_Ptr := new_fl_scheme_choice
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
            return Scheme_Choice is
        begin
            return This : Scheme_Choice := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Selection  --

    procedure Init_Value
           (This : in out Scheme_Choice) is
    begin
        fl_scheme_choice_init_value (This.Void_Ptr);
    end Init_Value;


    procedure Switch_Scheme
           (This : in out Scheme_Choice)
    is
        Ignore : constant Interfaces.C.int := fl_scheme_choice_switch (This.Void_Ptr);
    begin
        null;
    end Switch_Scheme;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Scheme_Choice) is
    begin
        Choice (This).Draw;
    end Draw;


    function Handle
           (This  : in out Scheme_Choice;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Choice (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Menus.Choices.Schemes;


