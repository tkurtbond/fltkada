

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Characters.Latin_1,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.unsigned_char;


package body FLTK.Widgets.Groups.Scrolls is


    package Latin renames Ada.Characters.Latin_1;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

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




    --  Attributes  --

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




    --  Scrolling  --

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




    --  Scrollbar Settings  --

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

    function fl_scroll_get_scrollbar_align
           (S : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_scroll_get_scrollbar_align, "fl_scroll_get_scrollbar_align");
    pragma Inline (fl_scroll_get_scrollbar_align);

    procedure fl_scroll_set_scrollbar_align
           (S : in Storage.Integer_Address;
            A : in Interfaces.C.unsigned);
    pragma Import (C, fl_scroll_set_scrollbar_align, "fl_scroll_set_scrollbar_align");
    pragma Inline (fl_scroll_set_scrollbar_align);

    function fl_scroll_set_fit_width
           (S  : in Storage.Integer_Address;
            On : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_scroll_set_fit_width, "fl_scroll_set_fit_width");
    pragma Inline (fl_scroll_set_fit_width);

    function fl_scroll_get_fit_width
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_scroll_get_fit_width, "fl_scroll_get_fit_width");
    pragma Inline (fl_scroll_get_fit_width);




    --  Dimensions  --

    procedure fl_scroll_resize
           (S          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_scroll_resize, "fl_scroll_resize");
    pragma Inline (fl_scroll_resize);

    procedure fl_scroll_recalc_scrollbars
           (Addr                                : in     Storage.Integer_Address;
            CB_X, CB_Y, CB_W, CB_H              :    out Interfaces.C.int;
            IB_X, IB_Y, IB_W, IB_H              :    out Interfaces.C.int;
            IC_X, IC_Y, IC_W, IC_H              :    out Interfaces.C.int;
            CH_Need, CV_Need                    :    out Interfaces.C.int;
            HS_X,    HS_Y,     HS_W,     HS_H   :    out Interfaces.C.int;
            HS_Size, HS_Total, HS_First, HS_Pos :    out Interfaces.C.int;
            VS_X,    VS_Y,     VS_W,     VS_H   :    out Interfaces.C.int;
            VS_Size, VS_Total, VS_First, VS_Pos :    out Interfaces.C.int;
            SSize                               :    out Interfaces.C.int);
    pragma Import (C, fl_scroll_recalc_scrollbars, "fl_scroll_recalc_scrollbars");
    pragma Inline (fl_scroll_recalc_scrollbars);




    --  Drawing, Events  --

    procedure fl_scroll_bbox
           (S          : in     Storage.Integer_Address;
            X, Y, W, H :    out Interfaces.C.int);
    pragma Import (C, fl_scroll_bbox, "fl_scroll_bbox");
    pragma Inline (fl_scroll_bbox);

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

    procedure Extra_Final
           (This : in out Scroll) is
    begin
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
        Mark      : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        My_Scroll : Scroll;
        for My_Scroll'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Scroll);
    begin
        Extra_Init
           (My_Scroll,
            Integer (X), Integer (Y),
            Integer (W), Integer (H),
            Interfaces.C.Strings.Value (C_Str));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
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




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Attributes  --

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




    --  Contents  --

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




    --  Scrolling  --

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




    --  Scrollbar Settings  --

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


    function Get_Scrollbar_Alignment
           (This : in Scroll)
        return Alignment is
    begin
        return Alignment (fl_scroll_get_scrollbar_align (This.Void_Ptr));
    end Get_Scrollbar_Alignment;


    procedure Set_Scrollbar_Alignment
           (This : in out Scroll;
            To   : in     Alignment) is
    begin
        fl_scroll_set_scrollbar_align (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Scrollbar_Alignment;


    procedure Set_Fit_Width
           (This : in out Scroll;
            To   : in     Boolean) is
    begin
        if fl_scroll_set_fit_width (This.Void_Ptr, Boolean'Pos (To)) = 0 then
            raise Program_Error with "a table's own Scroll can't fit its children";
        end if;
    end Set_Fit_Width;


    function Is_Fitting_Width
           (This : in Scroll)
        return Boolean is
    begin
        return fl_scroll_get_fit_width (This.Void_Ptr) /= 0;
    end Is_Fitting_Width;


    function Get_Kind
           (This : in Scroll)
        return Scroll_Kind
    is
        Result : constant Interfaces.C.unsigned_char := fl_widget_get_type (This.Void_Ptr);
    begin
        return Scroll_Kind'Val (Result);
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




    --  Dimensions  --

    procedure Resize
           (This       : in out Scroll;
            X, Y, W, H : in     Integer) is
    begin
        fl_scroll_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


    procedure Recalculate_Scrollbars
           (This : in     Scroll;
            Data :    out Scroll_Info)
    is
        C_Scroll_Size,
        C_H_Need,       C_V_Need,
        C_H_Data_Size,  C_V_Data_Size,
        C_H_Data_Total, C_V_Data_Total : Interfaces.C.int;
    begin
        fl_scroll_recalc_scrollbars
           (This.Void_Ptr,

            --  child LRTB region that will be reworked into XYWH in C++
            Interfaces.C.int (Data.Child_Box.X), Interfaces.C.int (Data.Child_Box.Y),
            Interfaces.C.int (Data.Child_Box.W), Interfaces.C.int (Data.Child_Box.H),

            --  innerbox XYWH region
            Interfaces.C.int (Data.Inner_Ex.X), Interfaces.C.int (Data.Inner_Ex.Y),
            Interfaces.C.int (Data.Inner_Ex.W), Interfaces.C.int (Data.Inner_Ex.H),

            --  innerchild XYWH region
            Interfaces.C.int (Data.Inner_Inc.X), Interfaces.C.int (Data.Inner_Inc.Y),
            Interfaces.C.int (Data.Inner_Inc.W), Interfaces.C.int (Data.Inner_Inc.H),

            --  raw hneeded/vneeded values to be converted into Booleans
            C_H_Need, C_V_Need,

            --  hscroll data
            Interfaces.C.int (Data.H_Data.X), Interfaces.C.int (Data.H_Data.Y),
            Interfaces.C.int (Data.H_Data.W), Interfaces.C.int (Data.H_Data.H),
            C_H_Data_Size, C_H_Data_Total,
            Interfaces.C.int (Data.H_Data.First), Interfaces.C.int (Data.H_Data.Position),

            --  vscroll data
            Interfaces.C.int (Data.V_Data.X), Interfaces.C.int (Data.V_Data.Y),
            Interfaces.C.int (Data.V_Data.W), Interfaces.C.int (Data.V_Data.H),
            C_V_Data_Size, C_V_Data_Total,
            Interfaces.C.int (Data.V_Data.First), Interfaces.C.int (Data.V_Data.Position),

            --  scrollsize
            C_Scroll_Size);

        Data.H_Needed := C_H_Need /= 0;
        Data.V_Needed := C_V_Need /= 0;
        Data.H_Data.Size  := Natural (C_H_Data_Size);
        Data.H_Data.Total := Natural (C_H_Data_Total);
        Data.V_Data.Size  := Natural (C_V_Data_Size);
        Data.V_Data.Total := Natural (C_V_Data_Total);
        Data.Scroll_Size  := Natural (C_Scroll_Size);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Scroll::recalc_scrollbars returned unexpected int values of " & Latin.LF &
        Latin.HT & "hscroll.size = "  & Interfaces.C.int'Image (C_H_Data_Size)  & Latin.LF &
        Latin.HT & "hscroll.total = " & Interfaces.C.int'Image (C_H_Data_Total) & Latin.LF &
        Latin.HT & "vscroll.size = "  & Interfaces.C.int'Image (C_V_Data_Size)  & Latin.LF &
        Latin.HT & "vscroll.total = " & Interfaces.C.int'Image (C_V_Data_Total) & Latin.LF &
        Latin.HT & "scrollsize = "    & Interfaces.C.int'Image (C_Scroll_Size);
    end Recalculate_Scrollbars;




    --  Drawing, Events  --

    procedure Bounding_Box
           (This       : in     Scroll;
            X, Y, W, H :    out Integer) is
    begin
        fl_scroll_bbox
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Bounding_Box;


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


