

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    FLTK.Widgets.Groups,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Inputs is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_input
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_input, "new_fl_input");
    pragma Inline (new_fl_input);

    procedure free_fl_input
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_input, "free_fl_input");
    pragma Inline (free_fl_input);




    --  Clipboard  --

    function fl_input_copy
           (I : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_copy, "fl_input_copy");
    pragma Inline (fl_input_copy);

    function fl_input_cut
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_cut, "fl_input_cut");
    pragma Inline (fl_input_cut);

    function fl_input_cut2
           (I : in Storage.Integer_Address;
            B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_cut2, "fl_input_cut2");
    pragma Inline (fl_input_cut2);

    function fl_input_cut3
           (I    : in Storage.Integer_Address;
            A, B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_cut3, "fl_input_cut3");
    pragma Inline (fl_input_cut3);

    function fl_input_copy_cuts
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_copy_cuts, "fl_input_copy_cuts");
    pragma Inline (fl_input_copy_cuts);

    function fl_input_undo
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_undo, "fl_input_undo");
    pragma Inline (fl_input_undo);




    --  Readonly, Tabs, Wrap  --

    function fl_input_get_readonly
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_readonly, "fl_input_get_readonly");
    pragma Inline (fl_input_get_readonly);

    procedure fl_input_set_readonly
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_set_readonly, "fl_input_set_readonly");
    pragma Inline (fl_input_set_readonly);

    function fl_input_get_tab_nav
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_tab_nav, "fl_input_get_tab_nav");
    pragma Inline (fl_input_get_tab_nav);

    procedure fl_input_set_tab_nav
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_set_tab_nav, "fl_input_set_tab_nav");
    pragma Inline (fl_input_set_tab_nav);

    function fl_input_get_wrap
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_wrap, "fl_input_get_wrap");
    pragma Inline (fl_input_get_wrap);

    procedure fl_input_set_wrap
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_set_wrap, "fl_input_set_wrap");
    pragma Inline (fl_input_set_wrap);




    --  Shortcut, Input Position  --

    function fl_input_get_input_type
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_input_type, "fl_input_get_input_type");
    pragma Inline (fl_input_get_input_type);

    procedure fl_input_set_input_type
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_set_input_type, "fl_input_set_input_type");
    pragma Inline (fl_input_set_input_type);

    function fl_input_get_shortcut
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_shortcut, "fl_input_get_shortcut");
    pragma Inline (fl_input_get_shortcut);

    procedure fl_input_set_shortcut
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_set_shortcut, "fl_input_set_shortcut");
    pragma Inline (fl_input_set_shortcut);

    function fl_input_get_mark
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_mark, "fl_input_get_mark");
    pragma Inline (fl_input_get_mark);

    function fl_input_set_mark
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_set_mark, "fl_input_set_mark");
    pragma Inline (fl_input_set_mark);

    function fl_input_get_position
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_position, "fl_input_get_position");
    pragma Inline (fl_input_get_position);

    function fl_input_set_position
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_set_position, "fl_input_set_position");
    pragma Inline (fl_input_set_position);

    function fl_input_set_position2
           (I    : in Storage.Integer_Address;
            P, M : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_set_position2, "fl_input_set_position2");
    pragma Inline (fl_input_set_position2);




    --  Text Field  --

    function fl_input_index
           (I : in Storage.Integer_Address;
            P : in Interfaces.C.int)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_input_index, "fl_input_index");
    pragma Inline (fl_input_index);

    function fl_input_insert
           (I : in Storage.Integer_Address;
            S : in Interfaces.C.char_array;
            L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_insert, "fl_input_insert");
    pragma Inline (fl_input_insert);

    function fl_input_replace
           (I    : in Storage.Integer_Address;
            B, E : in Interfaces.C.int;
            S    : in Interfaces.C.char_array;
            L    : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_replace, "fl_input_replace");
    pragma Inline (fl_input_replace);

    function fl_input_set_value
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.char_array;
            L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_set_value, "fl_input_set_value");
    pragma Inline (fl_input_set_value);




    --  Input Size  --

    function fl_input_get_maximum_size
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_maximum_size, "fl_input_get_maximum_size");
    pragma Inline (fl_input_get_maximum_size);

    procedure fl_input_set_maximum_size
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_set_maximum_size, "fl_input_set_maximum_size");
    pragma Inline (fl_input_set_maximum_size);

    function fl_input_get_size
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_size, "fl_input_get_size");
    pragma Inline (fl_input_get_size);




    --  Cursors, Text Settings  --

    function fl_input_get_cursor_color
           (I : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_input_get_cursor_color, "fl_input_get_cursor_color");
    pragma Inline (fl_input_get_cursor_color);

    procedure fl_input_set_cursor_color
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_input_set_cursor_color, "fl_input_set_cursor_color");
    pragma Inline (fl_input_set_cursor_color);

    function fl_input_get_textcolor
           (I : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_input_get_textcolor, "fl_input_get_textcolor");
    pragma Inline (fl_input_get_textcolor);

    procedure fl_input_set_textcolor
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_input_set_textcolor, "fl_input_set_textcolor");
    pragma Inline (fl_input_set_textcolor);

    function fl_input_get_textfont
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_textfont, "fl_input_get_textfont");
    pragma Inline (fl_input_get_textfont);

    procedure fl_input_set_textfont
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_set_textfont, "fl_input_set_textfont");
    pragma Inline (fl_input_set_textfont);

    function fl_input_get_textsize
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_get_textsize, "fl_input_get_textsize");
    pragma Inline (fl_input_get_textsize);

    procedure fl_input_set_textsize
           (I : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_set_textsize, "fl_input_set_textsize");
    pragma Inline (fl_input_set_textsize);




    --  Dimensions  --

    procedure fl_input_set_size
           (I    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int);
    pragma Import (C, fl_input_set_size, "fl_input_set_size");
    pragma Inline (fl_input_set_size);

    procedure fl_input_resize
           (I          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_input_resize, "fl_input_resize");
    pragma Inline (fl_input_resize);




    --  Drawing, Events  --

    procedure fl_input_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_input_draw, "fl_input_draw");
    pragma Inline (fl_input_draw);

    function fl_input_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_handle, "fl_input_handle");
    pragma Inline (fl_input_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Input) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Input) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_input (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Input;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Input) is
    begin
        This.Draw_Ptr   := fl_input_draw'Address;
        This.Handle_Ptr := fl_input_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Input is
        begin
            return This : Input do
                This.Void_Ptr := new_fl_input
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
            return Input is
        begin
            return This : Input := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Clipboard  --

    procedure Copy
           (This        : in out Input;
            Destination : in     Clipboard_Kind := Cut_Paste_Board)
    is
        Result : constant Interfaces.C.int := fl_input_copy
            (This.Void_Ptr, Clipboard_Kind'Pos (Destination));
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Input_::copy returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Copy;


    function Copy
           (This        : in out Input;
            Destination : in     Clipboard_Kind := Cut_Paste_Board)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_input_copy
            (This.Void_Ptr, Clipboard_Kind'Pos (Destination));
    begin
        pragma Assert (Result in 0 .. 1);
        return Boolean'Val (Result);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Input_::copy returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Copy;


    procedure Cut
           (This : in out Input)
    is
        Ignore : constant Interfaces.C.int := fl_input_cut (This.Void_Ptr);
    begin
        null;
    end Cut;


    function Cut
           (This : in out Input)
        return Boolean is
    begin
        return fl_input_cut (This.Void_Ptr) /= 0;
    end Cut;


    procedure Cut
           (This      : in out Input;
            Num_Bytes : in     Integer)
    is
        Ignore : constant Interfaces.C.int := fl_input_cut2
           (This.Void_Ptr,
            Interfaces.C.int (Num_Bytes));
    begin
        null;
    end Cut;


    function Cut
           (This      : in out Input;
            Num_Bytes : in     Integer)
        return Boolean is
    begin
        return fl_input_cut2
           (This.Void_Ptr,
            Interfaces.C.int (Num_Bytes)) /= 0;
    end Cut;


    procedure Cut
           (This          : in out Input;
            Start, Finish : in     Integer)
    is
        Ignore : constant Interfaces.C.int := fl_input_cut3
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Finish));
    begin
        null;
    end Cut;


    function Cut
           (This          : in out Input;
            Start, Finish : in     Integer)
        return Boolean is
    begin
        return fl_input_cut3
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Finish)) /= 0;
    end Cut;


    procedure Copy_Cuts
           (This : in out Input)
    is
        Ignore : constant Interfaces.C.int := fl_input_copy_cuts (This.Void_Ptr);
    begin
        null;
    end Copy_Cuts;


    function Copy_Cuts
           (This : in out Input)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_input_copy_cuts (This.Void_Ptr);
    begin
        return Result /= 0;
    end Copy_Cuts;


    procedure Undo
           (This : in out Input)
    is
        Ignore : constant Interfaces.C.int := fl_input_undo (This.Void_Ptr);
    begin
        null;
    end Undo;


    function Undo
           (This : in out Input)
        return Boolean is
    begin
        return fl_input_undo (This.Void_Ptr) /= 0;
    end Undo;




    --  Readonly, Tabs, Wrap  --

    function Is_Readonly
           (This : in Input)
        return Boolean is
    begin
        return fl_input_get_readonly (This.Void_Ptr) /= 0;
    end Is_Readonly;


    procedure Set_Readonly
           (This : in out Input;
            To   : in     Boolean) is
    begin
        fl_input_set_readonly (This.Void_Ptr, Boolean'Pos (To));
    end Set_Readonly;


    function Is_Tab_Nav
           (This : in Input)
        return Boolean is
    begin
        return fl_input_get_tab_nav (This.Void_Ptr) /= 0;
    end Is_Tab_Nav;


    procedure Set_Tab_Nav
           (This : in out Input;
            To   : in     Boolean) is
    begin
        fl_input_set_tab_nav (This.Void_Ptr, Boolean'Pos (To));
    end Set_Tab_Nav;


    function Is_Wrap
           (This : in Input)
        return Boolean is
    begin
        return fl_input_get_wrap (This.Void_Ptr) /= 0;
    end Is_Wrap;


    procedure Set_Wrap
           (This : in out Input;
            To   : in     Boolean) is
    begin
        fl_input_set_wrap (This.Void_Ptr, Boolean'Pos (To));
    end Set_Wrap;




    --  Shortcut, Input Position  --

    function Get_Kind
           (This : in Input)
        return Input_Kind
    is
        C_Val : constant Interfaces.C.int := fl_input_get_input_type (This.Void_Ptr);
    begin
        for V in Input_Kind loop
            if Input_Kind_Values (V) = C_Val then
                return V;
            end if;
        end loop;
        return Normal_Field;
    end Get_Kind;


    function Get_Shortcut
           (This : in Input)
        return Key_Combo is
    begin
        return To_Ada (Interfaces.C.unsigned (fl_input_get_shortcut (This.Void_Ptr)));
    end Get_Shortcut;


    procedure Set_Shortcut
           (This : in out Input;
            To   : in     Key_Combo) is
    begin
        fl_input_set_shortcut (This.Void_Ptr, Interfaces.C.int (To_C (To)));
    end Set_Shortcut;


    function Get_Mark
           (This : in Input)
        return Natural is
    begin
        return Natural (fl_input_get_mark (This.Void_Ptr));
    end Get_Mark;


    procedure Set_Mark
           (This : in out Input;
            To   : in     Natural)
    is
        Ignore : constant Interfaces.C.int := fl_input_set_mark
           (This.Void_Ptr,
            Interfaces.C.int (To));
    begin
        null;
    end Set_Mark;


    function Set_Mark
           (This : in out Input;
            To   : in     Natural)
        return Boolean is
    begin
        return fl_input_set_mark
           (This.Void_Ptr,
            Interfaces.C.int (To)) /= 0;
    end Set_Mark;


    function Get_Position
           (This : in Input)
        return Natural is
    begin
        return Natural (fl_input_get_position (This.Void_Ptr));
    end Get_Position;


    procedure Set_Position
           (This : in out Input;
            To   : in     Natural)
    is
        Ignore : constant Interfaces.C.int := fl_input_set_position
           (This.Void_Ptr,
            Interfaces.C.int (To));
    begin
        null;
    end Set_Position;


    function Set_Position
           (This : in out Input;
            To   : in     Natural)
        return Boolean is
    begin
        return fl_input_set_position
           (This.Void_Ptr,
            Interfaces.C.int (To)) /= 0;
    end Set_Position;


    procedure Set_Position_Mark
           (This  : in out Input;
            Place : in     Natural;
            Mark  : in     Natural)
    is
        Ignore : constant Interfaces.C.int := fl_input_set_position2
           (This.Void_Ptr,
            Interfaces.C.int (Place),
            Interfaces.C.int (Mark));
    begin
        null;
    end Set_Position_Mark;


    function Set_Position_Mark
           (This  : in out Input;
            Place : in     Natural;
            Mark  : in     Natural)
        return Boolean is
    begin
        return fl_input_set_position2
           (This.Void_Ptr,
            Interfaces.C.int (Place),
            Interfaces.C.int (Mark)) /= 0;
    end Set_Position_Mark;




    --  Text Field  --

    function Index
           (This  : in Input;
            Place : in Integer)
        return Character is
    begin
        return Character'Val (fl_input_index (This.Void_Ptr, Interfaces.C.int (Place)));
    end Index;


    procedure Insert
           (This : in out Input;
            Str  : in     String)
    is
        Ignore : constant Interfaces.C.int := fl_input_insert
           (This.Void_Ptr,
            Interfaces.C.To_C (Str, False),
            Str'Length);
    begin
        null;
    end Insert;


    function Insert
           (This : in out Input;
            Str  : in     String)
        return Boolean is
    begin
        return fl_input_insert
           (This.Void_Ptr,
            Interfaces.C.To_C (Str, False),
            Str'Length) /= 0;
    end Insert;


    procedure Replace
           (This     : in out Input;
            From, To : in     Natural;
            New_Text : in     String)
    is
        Ignore : constant Interfaces.C.int := fl_input_replace
           (This.Void_Ptr,
            Interfaces.C.int (From),
            Interfaces.C.int (To),
            Interfaces.C.To_C (New_Text),
            New_Text'Length);
    begin
        null;
    end Replace;


    function Replace
           (This     : in out Input;
            From, To : in     Natural;
            New_Text : in     String)
        return Boolean is
    begin
        return fl_input_replace
           (This.Void_Ptr,
            Interfaces.C.int (From),
            Interfaces.C.int (To),
            Interfaces.C.To_C (New_Text, False),
            New_Text'Length) /= 0;
    end Replace;


    function Get_Value
           (This : in Input)
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_input_get_value (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            --  pointer to internal buffer only, so no Free required
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Value;


    procedure Set_Value
           (This : in out Input;
            To   : in     String)
    is
        Ignore : constant Interfaces.C.int := fl_input_set_value
            (This.Void_Ptr, Interfaces.C.To_C (To), To'Length);
    begin
        null;
    end Set_Value;


    function Set_Value
           (This : in out Input;
            To   : in     String)
        return Boolean is
    begin
        return fl_input_set_value
           (This.Void_Ptr,
            Interfaces.C.To_C (To, False),
            To'Length) /= 0;
    end Set_Value;




    --  Input Size  --

    function Get_Maximum_Size
           (This : in Input)
        return Natural is
    begin
        return Natural (fl_input_get_maximum_size (This.Void_Ptr));
    end Get_Maximum_Size;


    procedure Set_Maximum_Size
           (This : in out Input;
            To   : in     Natural) is
    begin
        fl_input_set_maximum_size (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Maximum_Size;


    function Size
           (This : in Input)
        return Natural is
    begin
        return Natural (fl_input_get_size (This.Void_Ptr));
    end Size;




    --  Cursors, Text Settings  --

    function Get_Cursor_Color
           (This : in Input)
        return Color is
    begin
        return Color (fl_input_get_cursor_color (This.Void_Ptr));
    end Get_Cursor_Color;


    procedure Set_Cursor_Color
           (This : in out Input;
            To   : in     Color) is
    begin
        fl_input_set_cursor_color (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Cursor_Color;


    function Get_Text_Color
           (This : in Input)
        return Color is
    begin
        return Color (fl_input_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Input;
            To   : in     Color) is
    begin
        fl_input_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Input)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_input_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Input;
            To   : in     Font_Kind) is
    begin
        fl_input_set_textfont (This.Void_Ptr, Font_Kind'Pos (To));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Input)
        return Font_Size is
    begin
        return Font_Size (fl_input_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Input;
            To   : in     Font_Size) is
    begin
        fl_input_set_textsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Text_Size;




    --  Dimensions  --

    procedure Resize
           (This : in out Input;
            W, H : in     Integer) is
    begin
        fl_input_set_size (This.Void_Ptr, Interfaces.C.int (W), Interfaces.C.int (H));
    end Resize;


    procedure Resize
           (This       : in out Input;
            X, Y, W, H : in     Integer) is
    begin
        fl_input_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --  Changing Input Type  --

    package body Extra is

        procedure Set_Kind
               (This : in out Input;
                To   : in     Input_Kind) is
        begin
            fl_input_set_input_type (This.Void_Ptr, Input_Kind_Values (To));
        end Set_Kind;

        pragma Inline (Set_Kind);

    end Extra;


end FLTK.Widgets.Inputs;


