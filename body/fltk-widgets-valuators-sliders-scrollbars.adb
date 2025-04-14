

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Sliders.Scrollbars is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_scrollbar
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_scrollbar, "new_fl_scrollbar");
    pragma Inline (new_fl_scrollbar);

    procedure free_fl_scrollbar
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_scrollbar, "free_fl_scrollbar");
    pragma Inline (free_fl_scrollbar);




    --  Line Position  --

    function fl_scrollbar_get_linesize
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_scrollbar_get_linesize, "fl_scrollbar_get_linesize");
    pragma Inline (fl_scrollbar_get_linesize);

    procedure fl_scrollbar_set_linesize
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_scrollbar_set_linesize, "fl_scrollbar_set_linesize");
    pragma Inline (fl_scrollbar_set_linesize);

    function fl_scrollbar_get_value
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_scrollbar_get_value, "fl_scrollbar_get_value");
    pragma Inline (fl_scrollbar_get_value);

    procedure fl_scrollbar_set_value
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_scrollbar_set_value, "fl_scrollbar_set_value");
    pragma Inline (fl_scrollbar_set_value);

    procedure fl_scrollbar_set_value2
           (S          : in Storage.Integer_Address;
            P, W, F, T : in Interfaces.C.int);
    pragma Import (C, fl_scrollbar_set_value2, "fl_scrollbar_set_value2");
    pragma Inline (fl_scrollbar_set_value2);




    --  Drawing, Events  --

    procedure fl_scrollbar_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_scrollbar_draw, "fl_scrollbar_draw");
    pragma Inline (fl_scrollbar_draw);

    function fl_scrollbar_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_scrollbar_handle, "fl_scrollbar_handle");
    pragma Inline (fl_scrollbar_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Scrollbar) is
    begin
        Extra_Final (Slider (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Scrollbar) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_scrollbar (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Radio signal successfully intercepted
    procedure scrollbar_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr);
    pragma Export (C, scrollbar_extra_init_hook, "scrollbar_extra_init_hook");

    procedure scrollbar_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr)
    is
        My_Scrollbar : Scrollbar;
        for My_Scrollbar'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Scrollbar);
    begin
        Extra_Init
           (My_Scrollbar,
            Integer (X), Integer (Y),
            Integer (W), Integer (H),
            Interfaces.C.Strings.Value (C_Str));
    end scrollbar_extra_init_hook;


    procedure Extra_Init
           (This       : in out Scrollbar;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Slider (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Scrollbar) is
    begin
        This.Draw_Ptr   := fl_scrollbar_draw'Address;
        This.Handle_Ptr := fl_scrollbar_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Scrollbar is
        begin
            return This : Scrollbar do
                This.Void_Ptr := new_fl_scrollbar
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
            return Scrollbar is
        begin
            return This : Scrollbar := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Line Position  --

    function Get_Line_Size
           (This : in Scrollbar)
        return Natural is
    begin
        return Natural (fl_scrollbar_get_linesize (This.Void_Ptr));
    end Get_Line_Size;


    procedure Set_Line_Size
           (This : in out Scrollbar;
            To   : in     Natural) is
    begin
        fl_scrollbar_set_linesize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Line_Size;


    function Get_Position
           (This : in Scrollbar)
        return Natural is
    begin
        return Natural (fl_scrollbar_get_value (This.Void_Ptr));
    end Get_Position;


    procedure Set_Position
           (This : in out Scrollbar;
            To   : in     Natural) is
    begin
        fl_scrollbar_set_value (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Position;


    procedure Set_All
           (This        : in out Scrollbar;
            Position    : in     Natural;
            Win_Size    : in     Natural;
            First_Line  : in     Natural;
            Total_Lines : in     Natural) is
    begin
        fl_scrollbar_set_value2
           (This.Void_Ptr,
            Interfaces.C.int (Position),
            Interfaces.C.int (Win_Size),
            Interfaces.C.int (First_Line),
            Interfaces.C.int (Total_Lines));
    end Set_All;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Scrollbar) is
    begin
        Slider (This).Draw;
    end Draw;


    function Handle
           (This  : in out Scrollbar;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Slider (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Valuators.Sliders.Scrollbars;


