

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.unsigned_char;


package body FLTK.Widgets.Groups.Scrolls is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_scroll
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_scroll, "new_fl_scroll");
    pragma Inline (new_fl_scroll);

    procedure free_fl_scroll
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_scroll, "free_fl_scroll");
    pragma Inline (free_fl_scroll);




    function fl_scroll_hscrollbar
           (S : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_scroll_hscrollbar, "fl_scroll_hscrollbar");
    pragma Inline (fl_scroll_hscrollbar);

    function fl_scroll_scrollbar
           (S : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_scroll_scrollbar, "fl_scroll_scrollbar");
    pragma Inline (fl_scroll_scrollbar);




    procedure fl_scroll_to
           (S    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_scroll_to, "fl_scroll_to");
    pragma Inline (fl_scroll_to);

    function fl_scroll_xposition
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_scroll_xposition, "fl_scroll_xposition");
    pragma Inline (fl_scroll_xposition);

    function fl_scroll_yposition
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_scroll_yposition, "fl_scroll_yposition");
    pragma Inline (fl_scroll_yposition);




    function fl_scroll_get_size
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_scroll_get_size, "fl_scroll_get_size");
    pragma Inline (fl_scroll_get_size);

    procedure fl_scroll_set_size
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_scroll_set_size, "fl_scroll_set_size");
    pragma Inline (fl_scroll_set_size);




    procedure fl_scroll_draw
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_scroll_draw, "fl_scroll_draw");
    pragma Inline (fl_scroll_draw);

    function fl_scroll_handle
           (S : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_scroll_handle, "fl_scroll_handle");
    pragma Inline (fl_scroll_handle);




    -------------------
    --  Destructors  --
    -------------------

    --  I used the FFI to bypass namespace rules and all I got was this lousy tshirt
    procedure scroll_extra_final_hook
           (Ada_Obj : in Storage.Integer_Address);
    pragma Export (C, scroll_extra_final_hook, "scroll_extra_final_hook");

    procedure scroll_extra_final_hook
           (Ada_Obj : in Storage.Integer_Address)
    is
        My_Scroll : Scroll;
        for My_Scroll'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Scroll);
    begin
        Extra_Final (My_Scroll);
    end scroll_extra_final_hook;


    --  It's the only way to be sure
    procedure fl_scrollbar_extra_final
           (Ada_Obj : in Storage.Integer_Address);
    pragma Import (C, fl_scrollbar_extra_final, "fl_scrollbar_extra_final");
    pragma Inline (fl_scrollbar_extra_final);


    procedure Extra_Final
           (This : in out Scroll) is
    begin
        fl_scrollbar_extra_final (Storage.To_Integer (This.Horizon'Address));
        fl_scrollbar_extra_final (Storage.To_Integer (This.Vertigo'Address));
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Scroll) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_scroll (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Quite right sir, stop the boat!
    procedure scroll_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr);
    pragma Export (C, scroll_extra_init_hook, "scroll_extra_init_hook");

    procedure scroll_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr)
    is
        My_Scroll : Scroll;
        for My_Scroll'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Scroll);
    begin
        Extra_Init
           (My_Scroll,
            Integer (X), Integer (Y),
            Integer (W), Integer (H),
            Interfaces.C.Strings.Value (C_Str));
    end scroll_extra_init_hook;


    --  Hold on, I know a shortcut
    procedure fl_scrollbar_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_scrollbar_extra_init, "fl_scrollbar_extra_init");
    pragma Inline (fl_scrollbar_extra_init);


    procedure Extra_Init
           (This       : in out Scroll;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Widget (This.Horizon).Void_Ptr := fl_scroll_hscrollbar (This.Void_Ptr);
        Widget (This.Horizon).Needs_Dealloc := False;
        fl_scrollbar_extra_init
           (Storage.To_Integer (This.Horizon'Address),
            Interfaces.C.int (This.Horizon.Get_X),
            Interfaces.C.int (This.Horizon.Get_Y),
            Interfaces.C.int (This.Horizon.Get_W),
            Interfaces.C.int (This.Horizon.Get_H),
            Interfaces.C.To_C (This.Horizon.Get_Label));
        Widget (This.Vertigo).Void_Ptr := fl_scroll_scrollbar (This.Void_Ptr);
        Widget (This.Vertigo).Needs_Dealloc := False;
        fl_scrollbar_extra_init
           (Storage.To_Integer (This.Vertigo'Address),
            Interfaces.C.int (This.Vertigo.Get_X),
            Interfaces.C.int (This.Vertigo.Get_Y),
            Interfaces.C.int (This.Vertigo.Get_W),
            Interfaces.C.int (This.Vertigo.Get_H),
            Interfaces.C.To_C (This.Vertigo.Get_Label));
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Scroll) is
    begin
        This.Draw_Ptr   := fl_scroll_draw'Address;
        This.Handle_Ptr := fl_scroll_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Scroll is
        begin
            return This : Scroll do
                This.Void_Ptr := new_fl_scroll
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Scroll is
        begin
            return This : Scroll := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    ------------------
    --  Attributes  --
    ------------------

    function H_Bar
           (This : in out Scroll)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference is
    begin
        return (Data => This.Horizon'Unchecked_Access);
    end H_Bar;


    function V_Bar
           (This : in out Scroll)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference is
    begin
        return (Data => This.Vertigo'Unchecked_Access);
    end V_Bar;




    -----------------------
    --  API Subprograms  --
    -----------------------

    procedure Clear
           (This : in out Scroll) is
    begin
        --  Can't use the actual clear method here because that would
        --  delete the widgets from memory, and the binding is meant to
        --  handle that, not the library.
        This.Remove (This.Horizon);
        This.Remove (This.Vertigo);
        Group (This).Clear;
        This.Add (This.Horizon);
        This.Add (This.Vertigo);
    end Clear;




    procedure Scroll_To
           (This : in out Scroll;
            X, Y : in     Integer) is
    begin
        fl_scroll_to (This.Void_Ptr, Interfaces.C.int (X), Interfaces.C.int (Y));
    end Scroll_To;


    function Get_Scroll_X
           (This : in Scroll)
        return Integer is
    begin
        return Integer (fl_scroll_xposition (This.Void_Ptr));
    end Get_Scroll_X;


    function Get_Scroll_Y
           (This : in Scroll)
        return Integer is
    begin
        return Integer (fl_scroll_yposition (This.Void_Ptr));
    end Get_Scroll_Y;




    function Get_Scrollbar_Size
           (This : in Scroll)
        return Integer is
    begin
        return Integer (fl_scroll_get_size (This.Void_Ptr));
    end Get_Scrollbar_Size;


    procedure Set_Scrollbar_Size
           (This : in out Scroll;
            To   : in     Integer) is
    begin
        fl_scroll_set_size (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Scrollbar_Size;


    function Get_Kind
           (This : in Scroll)
        return Scroll_Kind
    is
        Result : Interfaces.C.unsigned_char := fl_widget_get_type (This.Void_Ptr);
    begin
        return Scroll_Kind'Val (Result - 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Scroll::type returned unexpected unsigned char value of " &
        Interfaces.C.unsigned_char'Image (Result);
    end Get_Kind;


    procedure Set_Kind
           (This : in out Scroll;
            Mode : in     Scroll_Kind) is
    begin
        fl_widget_set_type (This.Void_Ptr, Scroll_Kind'Pos (Mode));
    end Set_Kind;




    procedure Draw
           (This : in out Scroll) is
    begin
        Group (This).Draw;
    end Draw;


    function Handle
           (This  : in out Scroll;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Scrolls;


