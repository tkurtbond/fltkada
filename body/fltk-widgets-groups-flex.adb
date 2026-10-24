

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Flex is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_flex
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_flex, "new_fl_flex");
    pragma Inline (new_fl_flex);

    function new_fl_flex2
           (X, Y, W, H, D : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_flex2, "new_fl_flex2");
    pragma Inline (new_fl_flex2);

    function new_fl_flex3
           (W, H, D : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_flex3, "new_fl_flex3");
    pragma Inline (new_fl_flex3);

    function new_fl_flex4
           (D : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_flex4, "new_fl_flex4");
    pragma Inline (new_fl_flex4);

    procedure free_fl_flex
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_flex, "free_fl_flex");
    pragma Inline (free_fl_flex);




    --  Current, Layout  --

    procedure fl_flex_end
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_flex_end, "fl_flex_end");
    pragma Inline (fl_flex_end);

    procedure fl_flex_layout
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_flex_layout, "fl_flex_layout");
    pragma Inline (fl_flex_layout);

    function fl_flex_get_need_layout
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_flex_get_need_layout, "fl_flex_get_need_layout");
    pragma Inline (fl_flex_get_need_layout);

    procedure fl_flex_set_need_layout
           (F : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_flex_set_need_layout, "fl_flex_set_need_layout");
    pragma Inline (fl_flex_set_need_layout);




    --  Fixed Sizes  --

    procedure fl_flex_set_fixed
           (F, W : in Storage.Integer_Address;
            S    : in Interfaces.C.int);
    pragma Import (C, fl_flex_set_fixed, "fl_flex_set_fixed");
    pragma Inline (fl_flex_set_fixed);

    function fl_flex_is_fixed
           (F, W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_flex_is_fixed, "fl_flex_is_fixed");
    pragma Inline (fl_flex_is_fixed);




    --  Settings  --

    function fl_flex_get_margin
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_flex_get_margin, "fl_flex_get_margin");
    pragma Inline (fl_flex_get_margin);

    function fl_flex_get_margins
           (F          : in     Storage.Integer_Address;
            L, T, R, B :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_flex_get_margins, "fl_flex_get_margins");
    pragma Inline (fl_flex_get_margins);

    procedure fl_flex_set_margin
           (F    : in Storage.Integer_Address;
            M, G : in Interfaces.C.int);
    pragma Import (C, fl_flex_set_margin, "fl_flex_set_margin");
    pragma Inline (fl_flex_set_margin);

    procedure fl_flex_set_margins
           (F          : in Storage.Integer_Address;
            L, T, R, B : in Interfaces.C.int);
    pragma Import (C, fl_flex_set_margins, "fl_flex_set_margins");
    pragma Inline (fl_flex_set_margins);

    function fl_flex_get_gap
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_flex_get_gap, "fl_flex_get_gap");
    pragma Inline (fl_flex_get_gap);

    procedure fl_flex_set_gap
           (F : in Storage.Integer_Address;
            G : in Interfaces.C.int);
    pragma Import (C, fl_flex_set_gap, "fl_flex_set_gap");
    pragma Inline (fl_flex_set_gap);

    function fl_flex_get_spacing
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_flex_get_spacing, "fl_flex_get_spacing");
    pragma Inline (fl_flex_get_spacing);

    procedure fl_flex_set_spacing
           (F : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_flex_set_spacing, "fl_flex_set_spacing");
    pragma Inline (fl_flex_set_spacing);

    function fl_flex_horizontal
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_flex_horizontal, "fl_flex_horizontal");
    pragma Inline (fl_flex_horizontal);




    --  Drawing, Events  --

    procedure fl_flex_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_flex_draw, "fl_flex_draw");
    pragma Inline (fl_flex_draw);

    function fl_flex_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_flex_handle, "fl_flex_handle");
    pragma Inline (fl_flex_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Flex_Group) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Flex_Group) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_flex (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Flex_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Flex_Group) is
    begin
        This.Draw_Ptr   := fl_flex_draw'Address;
        This.Handle_Ptr := fl_flex_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Flex_Group is
        begin
            return This : Flex_Group do
                This.Void_Ptr := new_fl_flex
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
            return Flex_Group is
        begin
            return This : Flex_Group := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;


        function Create
               (X, Y, W, H : in Integer;
                Kind       : in Flex_Kind)
            return Flex_Group is
        begin
            return This : Flex_Group do
                This.Void_Ptr := new_fl_flex2
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Flex_Kind'Pos (Kind));
                Extra_Init (This, X, Y, W, H, "");
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Kind       : in     Flex_Kind)
            return Flex_Group is
        begin
            return This : Flex_Group := Create (X, Y, W, H, Kind) do
                Parent.Add (This);
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Kind : in Flex_Kind)
            return Flex_Group is
        begin
            return This : Flex_Group do
                This.Void_Ptr := new_fl_flex3
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Flex_Kind'Pos (Kind));
                Extra_Init (This, 0, 0, W, H, "");
            end return;
        end Create;


        function Create
               (Parent : in out Group'Class;
                W, H   : in     Integer;
                Kind   : in     Flex_Kind)
            return Flex_Group is
        begin
            return This : Flex_Group := Create (W, H, Kind) do
                Parent.Add (This);
            end return;
        end Create;


        function Create
               (Kind : in Flex_Kind)
            return Flex_Group is
        begin
            return This : Flex_Group do
                This.Void_Ptr := new_fl_flex4 (Flex_Kind'Pos (Kind));
                Extra_Init (This, 0, 0, 0, 0, "");
            end return;
        end Create;


        function Create
               (Parent : in out Group'Class;
                Kind   : in     Flex_Kind)
            return Flex_Group is
        begin
            return This : Flex_Group := Create (Kind) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Current  --

    procedure End_Current
           (This : in out Flex_Group) is
    begin
        fl_flex_end (This.Void_Ptr);
    end End_Current;




    --  Layout  --

    procedure Layout
           (This : in out Flex_Group) is
    begin
        fl_flex_layout (This.Void_Ptr);
    end Layout;


    function Get_Need_Layout
           (This : in Flex_Group)
        return Boolean is
    begin
        return fl_flex_get_need_layout (This.Void_Ptr) /= 0;
    end Get_Need_Layout;


    procedure Set_Need_Layout
           (This : in out Flex_Group;
            To   : in     Boolean := True) is
    begin
        fl_flex_set_need_layout (This.Void_Ptr, Boolean'Pos (To));
    end Set_Need_Layout;




    --  Fixed Sizes  --

    procedure Set_Fixed
           (This : in out Flex_Group;
            Item : in     Widget'Class;
            Size : in     Integer) is
    begin
        fl_flex_set_fixed (This.Void_Ptr, Item.Void_Ptr, Interfaces.C.int (Size));
    end Set_Fixed;


    function Is_Fixed
           (This : in Flex_Group;
            Item : in Widget'Class)
        return Boolean is
    begin
        return fl_flex_is_fixed (This.Void_Ptr, Item.Void_Ptr) /= 0;
    end Is_Fixed;




    --  Settings  --

    function Get_Kind
           (This : in Flex_Group)
        return Flex_Kind
    is
        Result : constant Interfaces.C.unsigned_char := fl_widget_get_type (This.Void_Ptr);
    begin
        return Flex_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Flex::type returned unexpected unsigned char value of " &
        Interfaces.C.unsigned_char'Image (Result);
    end Get_Kind;


    procedure Set_Kind
           (This : in out Flex_Group;
            Kind : in     Flex_Kind) is
    begin
        fl_widget_set_type (This.Void_Ptr, Flex_Kind'Pos (Kind));
    end Set_Kind;


    function Is_Horizontal
           (This : in Flex_Group)
        return Boolean is
    begin
        return fl_flex_horizontal (This.Void_Ptr) /= 0;
    end Is_Horizontal;


    function Get_Margin
           (This : in Flex_Group)
        return Integer is
    begin
        return Integer (fl_flex_get_margin (This.Void_Ptr));
    end Get_Margin;


    procedure Get_Margin
           (This                     : in     Flex_Group;
            Left, Top, Right, Bottom :    out Integer)
    is
        Ignore_Ret : Boolean;
    begin
        Ignore_Ret := This.Get_Margin (Left, Top, Right, Bottom);
    end Get_Margin;


    function Get_Margin
           (This                     : in     Flex_Group;
            Left, Top, Right, Bottom :    out Integer)
        return Boolean
    is
        L, T, R, B : Interfaces.C.int;
        Result     : constant Interfaces.C.int :=
            fl_flex_get_margins (This.Void_Ptr, L, T, R, B);
    begin
        Left   := Integer (L);
        Top    := Integer (T);
        Right  := Integer (R);
        Bottom := Integer (B);
        return Result /= 0;
    end Get_Margin;


    procedure Set_Margin
           (This : in out Flex_Group;
            To   : in     Integer) is
    begin
        fl_flex_set_margin (This.Void_Ptr, Interfaces.C.int (To), -1);
    end Set_Margin;


    procedure Set_Margin
           (This : in out Flex_Group;
            To   : in     Integer;
            Gap  : in     Integer) is
    begin
        fl_flex_set_margin (This.Void_Ptr, Interfaces.C.int (To), Interfaces.C.int (Gap));
    end Set_Margin;


    procedure Set_Margin
           (This                     : in out Flex_Group;
            Left, Top, Right, Bottom : in     Integer) is
    begin
        fl_flex_set_margins
           (This.Void_Ptr,
            Interfaces.C.int (Left),
            Interfaces.C.int (Top),
            Interfaces.C.int (Right),
            Interfaces.C.int (Bottom));
    end Set_Margin;


    function Get_Gap
           (This : in Flex_Group)
        return Integer is
    begin
        return Integer (fl_flex_get_gap (This.Void_Ptr));
    end Get_Gap;


    procedure Set_Gap
           (This : in out Flex_Group;
            To   : in     Integer) is
    begin
        fl_flex_set_gap (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Gap;


    function Get_Spacing
           (This : in Flex_Group)
        return Integer is
    begin
        return Integer (fl_flex_get_spacing (This.Void_Ptr));
    end Get_Spacing;


    procedure Set_Spacing
           (This : in out Flex_Group;
            To   : in     Integer) is
    begin
        fl_flex_set_spacing (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Spacing;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Flex_Group) is
    begin
        Group (This).Draw;
    end Draw;


    function Handle
           (This  : in out Flex_Group;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Flex;


