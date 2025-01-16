

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Counters is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_counter
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_counter, "new_fl_counter");
    pragma Inline (new_fl_counter);

    procedure free_fl_counter
           (A : in Storage.Integer_Address);
    pragma Import (C, free_fl_counter, "free_fl_counter");
    pragma Inline (free_fl_counter);




    function fl_counter_get_step
           (C : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_counter_get_step, "fl_counter_get_step");
    pragma Inline (fl_counter_get_step);

    procedure fl_counter_set_step_top
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.double);
    pragma Import (C, fl_counter_set_step_top, "fl_counter_set_step_top");
    pragma Inline (fl_counter_set_step_top);

    procedure fl_counter_set_lstep
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.double);
    pragma Import (C, fl_counter_set_lstep, "fl_counter_set_lstep");
    pragma Inline (fl_counter_set_lstep);

    procedure fl_counter_set_step_both
           (C    : in Storage.Integer_Address;
            S, L : in Interfaces.C.double);
    pragma Import (C, fl_counter_set_step_both, "fl_counter_set_step_both");
    pragma Inline (fl_counter_set_step_both);




    function fl_counter_get_textcolor
           (C : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_counter_get_textcolor, "fl_counter_get_textcolor");
    pragma Inline (fl_counter_get_textcolor);

    procedure fl_counter_set_textcolor
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_counter_set_textcolor, "fl_counter_set_textcolor");
    pragma Inline (fl_counter_set_textcolor);

    function fl_counter_get_textfont
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_counter_get_textfont, "fl_counter_get_textfont");
    pragma Inline (fl_counter_get_textfont);

    procedure fl_counter_set_textfont
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_counter_set_textfont, "fl_counter_set_textfont");
    pragma Inline (fl_counter_set_textfont);

    function fl_counter_get_textsize
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_counter_get_textsize, "fl_counter_get_textsize");
    pragma Inline (fl_counter_get_textsize);

    procedure fl_counter_set_textsize
           (C : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_counter_set_textsize, "fl_counter_set_textsize");
    pragma Inline (fl_counter_set_textsize);




    procedure fl_counter_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_counter_draw, "fl_counter_draw");
    pragma Inline (fl_counter_draw);

    function fl_counter_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_counter_handle, "fl_counter_handle");
    pragma Inline (fl_counter_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Counter) is
    begin
        Extra_Final (Valuator (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Counter) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_counter (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Counter;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Valuator (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Counter) is
    begin
        This.Draw_Ptr   := fl_counter_draw'Address;
        This.Handle_Ptr := fl_counter_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Counter is
        begin
            return This : Counter do
                This.Void_Ptr := new_fl_counter
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
            return Counter is
        begin
            return This : Counter := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Get_Step
           (This : in Counter)
        return Long_Float is
    begin
        return Long_Float (fl_counter_get_step (This.Void_Ptr));
    end Get_Step;


    procedure Set_Step_Top
           (This : in out Counter;
            To   : in     Long_Float) is
    begin
        fl_counter_set_step_top (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Step_Top;


    function Get_Long_Step
           (This : in Counter)
        return Long_Float is
    begin
        return This.Long_Step;
    end Get_Long_Step;


    procedure Set_Long_Step
           (This : in out Counter;
            To   : in     Long_Float) is
    begin
        This.Long_Step := To;
        fl_counter_set_lstep (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Long_Step;


    procedure Set_Step_Both
           (This        : in out Counter;
            Short, Long : in     Long_Float) is
    begin
        fl_counter_set_step_both
           (This.Void_Ptr,
            Interfaces.C.double (Short),
            Interfaces.C.double (Long));
    end Set_Step_Both;




    function Get_Text_Color
           (This : in Counter)
        return Color is
    begin
        return Color (fl_counter_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Counter;
            To   : in     Color) is
    begin
        fl_counter_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Counter)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_counter_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Counter;
            To   : in     Font_Kind) is
    begin
        fl_counter_set_textfont (This.Void_Ptr, Font_Kind'Pos (To));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Counter)
        return Font_Size is
    begin
        return Font_Size (fl_counter_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Counter;
            To   : in     Font_Size) is
    begin
        fl_counter_set_textsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Text_Size;




    procedure Draw
           (This : in out Counter) is
    begin
        Valuator (This).Draw;
    end Draw;


    function Handle
           (This  : in out Counter;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Valuator (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Valuators.Counters;


