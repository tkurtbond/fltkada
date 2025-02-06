

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Unchecked_Deallocation,
    FLTK.Images,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Groups.Browsers.Textline is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Errors  --

    function get_error_message
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, get_error_message, "get_error_message");
    pragma Inline (get_error_message);




    --  Allocation  --

    function new_fl_browser
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_browser, "new_fl_browser");
    pragma Inline (new_fl_browser);

    procedure free_fl_browser
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_browser, "free_fl_browser");
    pragma Inline (free_fl_browser);




    --  Lines  --

    procedure fl_browser_add
           (B : in Storage.Integer_Address;
            T : in Interfaces.C.char_array;
            D : in Storage.Integer_Address);
    pragma Import (C, fl_browser_add, "fl_browser_add");
    pragma Inline (fl_browser_add);

    procedure fl_browser_insert
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int;
            T : in Interfaces.C.char_array;
            D : in Storage.Integer_Address);
    pragma Import (C, fl_browser_insert, "fl_browser_insert");
    pragma Inline (fl_browser_insert);

    procedure fl_browser_move
           (B    : in Storage.Integer_Address;
            T, F : in Interfaces.C.int);
    pragma Import (C, fl_browser_move, "fl_browser_move");
    pragma Inline (fl_browser_move);

    procedure fl_browser_swap
           (B    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_browser_swap, "fl_browser_swap");
    pragma Inline (fl_browser_swap);

    procedure fl_browser_remove
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_browser_remove, "fl_browser_remove");
    pragma Inline (fl_browser_remove);

    procedure fl_browser_clear
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_browser_clear, "fl_browser_clear");
    pragma Inline (fl_browser_clear);

    function fl_browser_size
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_size, "fl_browser_size");
    pragma Inline (fl_browser_size);




    --  Text Loading  --

    function fl_browser_load
           (B : in Storage.Integer_Address;
            F : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_load, "fl_browser_load");
    pragma Inline (fl_browser_load);

    function fl_browser_get_text
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_browser_get_text, "fl_browser_get_text");
    pragma Inline (fl_browser_get_text);

    procedure fl_browser_set_text
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_browser_set_text, "fl_browser_set_text");
    pragma Inline (fl_browser_set_text);

    function fl_browser_get_textsize
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_get_textsize, "fl_browser_get_textsize");
    pragma Inline (fl_browser_get_textsize);

    procedure fl_browser_set_textsize
           (B : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_browser_set_textsize, "fl_browser_set_textsize");
    pragma Inline (fl_browser_set_textsize);




    --  Columns, Formatting  --

    function fl_browser_get_column_char
           (B : in Storage.Integer_Address)
        return Interfaces.C.char;
    pragma Import (C, fl_browser_get_column_char, "fl_browser_get_column_char");
    pragma Inline (fl_browser_get_column_char);

    procedure fl_browser_set_column_char
           (B : in Storage.Integer_Address;
            C : in Interfaces.C.char);
    pragma Import (C, fl_browser_set_column_char, "fl_browser_set_column_char");
    pragma Inline (fl_browser_set_column_char);

    procedure fl_browser_set_column_widths
           (B, W : in Storage.Integer_Address);
    pragma Import (C, fl_browser_set_column_widths, "fl_browser_set_column_widths");
    pragma Inline (fl_browser_set_column_widths);

    function fl_browser_get_format_char
           (B : in Storage.Integer_Address)
        return Interfaces.C.char;
    pragma Import (C, fl_browser_get_format_char, "fl_browser_get_format_char");
    pragma Inline (fl_browser_get_format_char);

    procedure fl_browser_set_format_char
           (B : in Storage.Integer_Address;
            C : in Interfaces.C.char);
    pragma Import (C, fl_browser_set_format_char, "fl_browser_set_format_char");
    pragma Inline (fl_browser_set_format_char);




    --  Line Positions  --

    function fl_browser_get_topline
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_get_topline, "fl_browser_get_topline");
    pragma Inline (fl_browser_get_topline);

    procedure fl_browser_set_topline
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_browser_set_topline, "fl_browser_set_topline");
    pragma Inline (fl_browser_set_topline);

    procedure fl_browser_middleline
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_browser_middleline, "fl_browser_middleline");
    pragma Inline (fl_browser_middleline);

    procedure fl_browser_bottomline
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_browser_bottomline, "fl_browser_bottomline");
    pragma Inline (fl_browser_bottomline);

    procedure fl_browser_lineposition
           (B    : in Storage.Integer_Address;
            L, P : in Interfaces.C.int);
    pragma Import (C, fl_browser_lineposition, "fl_browser_lineposition");
    pragma Inline (fl_browser_lineposition);




    --  Selection  --

    function fl_browser_select
           (B    : in Storage.Integer_Address;
            L, V : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_select, "fl_browser_select");
    pragma Inline (fl_browser_select);

    function fl_browser_selected
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_selected, "fl_browser_selected");
    pragma Inline (fl_browser_selected);

    function fl_browser_value
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_value, "fl_browser_value");
    pragma Inline (fl_browser_value);




    --  Visibility  --

    function fl_browser_visible
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_visible, "fl_browser_visible");
    pragma Inline (fl_browser_visible);

    procedure fl_browser_make_visible
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_browser_make_visible, "fl_browser_make_visible");
    pragma Inline (fl_browser_make_visible);

    function fl_browser_displayed
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_displayed, "fl_browser_displayed");
    pragma Inline (fl_browser_displayed);

    procedure fl_browser_show_line
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_browser_show_line, "fl_browser_show_line");
    pragma Inline (fl_browser_show_line);

    procedure fl_browser_hide_line
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_browser_hide_line, "fl_browser_hide_line");
    pragma Inline (fl_browser_hide_line);

    procedure fl_browser_show
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_browser_show, "fl_browser_show");
    pragma Inline (fl_browser_show);

    procedure fl_browser_hide
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_browser_hide, "fl_browser_hide");
    pragma Inline (fl_browser_hide);




    --  Dimensions  --

    procedure fl_browser_set_size
           (B    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int);
    pragma Import (C, fl_browser_set_size, "fl_browser_set_size");
    pragma Inline (fl_browser_set_size);




    --  Icons  --

    procedure fl_browser_set_icon
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int;
            C : in Storage.Integer_Address);
    pragma Import (C, fl_browser_set_icon, "fl_browser_set_icon");
    pragma Inline (fl_browser_set_icon);

    procedure fl_browser_remove_icon
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_browser_remove_icon, "fl_browser_remove_icon");
    pragma Inline (fl_browser_remove_icon);




    --  Item Implementation  --

    function fl_browser_item_width
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_item_width, "fl_browser_item_width");
    pragma Inline (fl_browser_item_width);

    function fl_browser_item_height
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_item_height, "fl_browser_item_height");
    pragma Inline (fl_browser_item_height);

    function fl_browser_item_first
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_browser_item_first, "fl_browser_item_first");
    pragma Inline (fl_browser_item_first);

    function fl_browser_item_last
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_browser_item_last, "fl_browser_item_last");
    pragma Inline (fl_browser_item_last);

    function fl_browser_item_next
           (B, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_browser_item_next, "fl_browser_item_next");
    pragma Inline (fl_browser_item_next);

    function fl_browser_item_prev
           (B, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_browser_item_prev, "fl_browser_item_prev");
    pragma Inline (fl_browser_item_prev);

    function fl_browser_item_at
           (B : in Storage.Integer_Address;
            N : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_browser_item_at, "fl_browser_item_at");
    pragma Inline (fl_browser_item_at);

    procedure fl_browser_item_select
           (B, I : in Storage.Integer_Address;
            V    : in Interfaces.C.int);
    pragma Import (C, fl_browser_item_select, "fl_browser_item_select");
    pragma Inline (fl_browser_item_select);

    function fl_browser_item_selected
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_item_selected, "fl_browser_item_selected");
    pragma Inline (fl_browser_item_selected);

    procedure fl_browser_item_swap
           (B, X, Y : in Storage.Integer_Address);
    pragma Import (C, fl_browser_item_swap, "fl_browser_item_swap");
    pragma Inline (fl_browser_item_swap);

    function fl_browser_item_text
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_browser_item_text, "fl_browser_item_text");
    pragma Inline (fl_browser_item_text);

    procedure fl_browser_item_draw
           (B, I       : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_browser_item_draw, "fl_browser_item_draw");
    pragma Inline (fl_browser_item_draw);




    --  List Implementation  --

    function fl_browser_full_width
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_full_width, "fl_browser_full_width");
    pragma Inline (fl_browser_full_width);

    function fl_browser_full_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_full_height, "fl_browser_full_height");
    pragma Inline (fl_browser_full_height);

    function fl_browser_incr_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_incr_height, "fl_browser_incr_height");
    pragma Inline (fl_browser_incr_height);

    function fl_browser_item_quick_height
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_item_quick_height, "fl_browser_item_quick_height");
    pragma Inline (fl_browser_item_quick_height);




    --  Line Numbers  --

    function fl_browser_lineno
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_lineno, "fl_browser_lineno");
    pragma Inline (fl_browser_lineno);




    --  Drawing, Events  --

    procedure fl_browser_draw
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_browser_draw, "fl_browser_draw");
    pragma Inline (fl_browser_draw);

    function fl_browser_handle
           (B : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_browser_handle, "fl_browser_handle");
    pragma Inline (fl_browser_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Free is new Ada.Unchecked_Deallocation
       (Object => C_Col_Widths,
        Name   => C_Col_Widths_Access);

    procedure Free is new Ada.Unchecked_Deallocation
       (Object => FLTK.Images.Image'Class,
        Name   => Image_Access);


    procedure Extra_Final
           (This : in out Textline_Browser) is
    begin
        Free (This.Columns);
        for Icon_Ptr of This.Icons loop
            Free (Icon_Ptr);
        end loop;
        Extra_Final (Browser (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Textline_Browser) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_browser (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Textline_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Browser (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Textline_Browser) is
    begin
        This.Item_Override_Ptrs :=
           (Item_Width_Ptr    => fl_browser_item_width'Address,
            Item_Height_Ptr   => fl_browser_item_height'Address,
            Item_First_Ptr    => fl_browser_item_first'Address,
            Item_Last_Ptr     => fl_browser_item_last'Address,
            Item_Next_Ptr     => fl_browser_item_next'Address,
            Item_Previous_Ptr => fl_browser_item_prev'Address,
            Item_At_Ptr       => fl_browser_item_at'Address,
            Item_Select_Ptr   => fl_browser_item_select'Address,
            Item_Selected_Ptr => fl_browser_item_selected'Address,
            Item_Swap_Ptr     => fl_browser_item_swap'Address,
            Item_Text_Ptr     => fl_browser_item_text'Address,
            Item_Draw_Ptr     => fl_browser_item_draw'Address);
        This.Wide_High_Ptrs :=
           (Full_List_Width_Ptr     => fl_browser_full_width'Address,
            Full_List_Height_Ptr    => fl_browser_full_height'Address,
            Average_Item_Height_Ptr => fl_browser_incr_height'Address,
            Item_Quick_Height_Ptr   => fl_browser_item_quick_height'Address);
        This.Draw_Ptr := fl_browser_draw'Address;
        This.Handle_Ptr := fl_browser_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Textline_Browser is
        begin
            return This : Textline_Browser do
                This.Void_Ptr := new_fl_browser
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
            return Textline_Browser is
        begin
            return This : Textline_Browser := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Lines  --

    procedure Add
           (This : in out Textline_Browser;
            Text : in     String) is
    begin
        fl_browser_add
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Null_Pointer);
    end Add;


    procedure Insert
           (This  : in out Textline_Browser;
            Above : in     Positive;
            Text  : in     String) is
    begin
        fl_browser_insert
           (This.Void_Ptr,
            Interfaces.C.int (Above),
            Interfaces.C.To_C (Text),
            Null_Pointer);
    end Insert;


    procedure Move
           (This     : in out Textline_Browser;
            From, To : in     Positive) is
    begin
        fl_browser_move
           (This.Void_Ptr,
            Interfaces.C.int (To),
            Interfaces.C.int (From));
    end Move;


    procedure Swap
           (This : in out Textline_Browser;
            A, B : in     Positive) is
    begin
        fl_browser_swap
           (This.Void_Ptr,
            Interfaces.C.int (A),
            Interfaces.C.int (B));
    end Swap;


    procedure Remove
           (This : in out Textline_Browser;
            Line : in     Positive) is
    begin
        fl_browser_remove
           (This.Void_Ptr,
            Interfaces.C.int (Line));
    end Remove;


    procedure Clear
           (This : in out Textline_Browser) is
    begin
        fl_browser_clear (This.Void_Ptr);
    end Clear;


    function Number_Of_Lines
           (This : in Textline_Browser)
        return Natural is
    begin
        return Natural (fl_browser_size (This.Void_Ptr));
    end Number_Of_Lines;




    --  Text Loading  --

    procedure Load
           (This : in out Textline_Browser;
            File : in     String)
    is
        Msg  : Interfaces.C.Strings.chars_ptr;
        Code : Interfaces.C.int := fl_browser_load (This.Void_Ptr, Interfaces.C.To_C (File));
    begin
        if Code = 0 then
            Msg := get_error_message;
            if Msg = Interfaces.C.Strings.Null_Ptr then
                raise Browser_Load_Error;
            else
                raise Browser_Load_Error with Interfaces.C.Strings.Value (Msg);
            end if;
        else
            pragma Assert (Code = 1);
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser::load returned unexpected int value of " & Interfaces.C.int'Image (Code);
    end Load;


    function Get_Line_Text
           (This : in Textline_Browser;
            Line : in Positive)
        return String
    is
        Ptr : Interfaces.C.Strings.chars_ptr := fl_browser_get_text
           (This.Void_Ptr,
            Interfaces.C.int (Line));
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Line_Text;


    procedure Set_Line_Text
           (This : in out Textline_Browser;
            Line : in     Positive;
            Text : in     String) is
    begin
        fl_browser_set_text
           (This.Void_Ptr,
            Interfaces.C.int (Line),
            Interfaces.C.To_C (Text));
    end Set_Line_Text;


    function Get_Text_Size
           (This : in Textline_Browser)
        return Font_Size is
    begin
        return Font_Size (fl_browser_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Textline_Browser;
            Size : in     Font_Size) is
    begin
        fl_browser_set_textsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    --  Columns, Formatting  --

    function Get_Column_Character
           (This : in Textline_Browser)
        return Character is
    begin
        return Interfaces.C.To_Ada (fl_browser_get_column_char (This.Void_Ptr));
    end Get_Column_Character;


    procedure Set_Column_Character
           (This  : in out Textline_Browser;
            Value : in     Character) is
    begin
        fl_browser_set_column_char (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Column_Character;


    function Get_Column_Widths
           (This : in Textline_Browser)
        return Column_Widths is
    begin
        if This.Columns = null then
            return Result : Column_Widths (1 .. 0);
        else
            return Result : Column_Widths (This.Columns'First .. This.Columns'Last - 1) do
                for Index in Result'Range loop
                    Result (Index) := Integer (This.Columns (Index));
                end loop;
            end return;
        end if;
    end Get_Column_Widths;


    procedure Set_Column_Widths
           (This   : in out Textline_Browser;
            Widths : in     Column_Widths) is
    begin
        Free (This.Columns);
        This.Columns := new C_Col_Widths (1 .. Widths'Length + 1);
        for Index in This.Columns'Range loop
            This.Columns (Index) := Interfaces.C.int (Widths (Widths'First + Index - 1));
        end loop;
        This.Columns (This.Columns'Last) := 0;
        fl_browser_set_column_widths (This.Void_Ptr, Storage.To_Integer (This.Columns.all'Address));
    end Set_Column_Widths;


    function Get_Format_Character
           (This : in Textline_Browser)
        return Character is
    begin
        return Interfaces.C.To_Ada (fl_browser_get_format_char (This.Void_Ptr));
    end Get_Format_Character;


    procedure Set_Format_Character
           (This  : in out Textline_Browser;
            Value : in     Character) is
    begin
        fl_browser_set_format_char (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Format_Character;




    --  Line Positions  --

    function Get_Top_Line
           (This : in Textline_Browser)
        return Positive is
    begin
        return Positive (fl_browser_get_topline (This.Void_Ptr));
    end Get_Top_Line;


    procedure Set_Top_Line
           (This : in out Textline_Browser;
            Line : in     Positive) is
    begin
        fl_browser_set_topline (This.Void_Ptr, Interfaces.C.int (Line));
    end Set_Top_Line;


    procedure Set_Middle_Line
           (This : in out Textline_Browser;
            Line : in     Positive) is
    begin
        fl_browser_middleline (This.Void_Ptr, Interfaces.C.int (Line));
    end Set_Middle_Line;


    procedure Set_Bottom_Line
           (This : in out Textline_Browser;
            Line : in     Positive) is
    begin
        fl_browser_bottomline (This.Void_Ptr, Interfaces.C.int (Line));
    end Set_Bottom_Line;


    procedure Set_Line_Position
           (This  : in out Textline_Browser;
            Line  : in     Positive;
            Place : in     Line_Position) is
    begin
        fl_browser_lineposition (This.Void_Ptr, Interfaces.C.int (Line), Line_Position'Pos (Place));
    end Set_Line_Position;




    --  Selection  --

    function Set_Select
           (This  : in out Textline_Browser;
            Line  : in     Positive;
            State : in     Boolean := True)
        return Boolean
    is
        Code : Interfaces.C.int := fl_browser_select
           (This.Void_Ptr,
            Interfaces.C.int (Line),
            Boolean'Pos (State));
    begin
        pragma Assert (Code in 0 .. 1);
        return Boolean'Val (Code);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser::select returned unexpected int value of " & Interfaces.C.int'Image (Code);
    end Set_Select;


    procedure Set_Select
           (This  : in out Textline_Browser;
            Line  : in     Positive;
            State : in     Boolean := True)
    is
        Code : Interfaces.C.int := fl_browser_select
           (This.Void_Ptr,
            Interfaces.C.int (Line),
            Boolean'Pos (State));
    begin
        pragma Assert (Code in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser::select returned unexpected int value of " & Interfaces.C.int'Image (Code);
    end Set_Select;


    function Is_Selected
           (This : in Textline_Browser;
            Line : in Positive)
        return Boolean
    is
        Code : Interfaces.C.int := fl_browser_selected
           (This.Void_Ptr,
            Interfaces.C.int (Line));
    begin
        pragma Assert (Code in 0 .. 1);
        return Boolean'Val (Code);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser::selected returned unexpected int value of " & Interfaces.C.int'Image (Code);
    end Is_Selected;


    function Selected_Index
           (This : in Textline_Browser)
        return Natural is
    begin
        return Natural (fl_browser_value (This.Void_Ptr));
    end Selected_Index;




    --  Visibility  --

    function Is_Visible
           (This : in Textline_Browser;
            Line : in Positive)
        return Boolean is
    begin
        return fl_browser_visible (This.Void_Ptr, Interfaces.C.int (Line)) /= 0;
    end Is_Visible;


    procedure Make_Visible
           (This : in out Textline_Browser;
            Line : in     Positive) is
    begin
        fl_browser_make_visible (This.Void_Ptr, Interfaces.C.int (Line));
    end Make_Visible;


    function Is_Displayed
           (This : in Textline_Browser;
            Line : in Positive)
        return Boolean
    is
        Code : Interfaces.C.int := fl_browser_displayed
           (This.Void_Ptr,
            Interfaces.C.int (Line));
    begin
        pragma Assert (Code in 0 .. 1);
        return Boolean'Val (Code);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser::displayed returned unexpected int value of " & Interfaces.C.int'Image (Code);
    end Is_Displayed;


    procedure Show_Line
           (This : in out Textline_Browser;
            Line : in     Positive) is
    begin
        fl_browser_show_line (This.Void_Ptr, Interfaces.C.int (Line));
    end Show_Line;


    procedure Hide_Line
           (This : in out Textline_Browser;
            Line : in     Positive) is
    begin
        fl_browser_hide_line (This.Void_Ptr, Interfaces.C.int (Line));
    end Hide_Line;


    procedure Show
           (This : in out Textline_Browser) is
    begin
        fl_browser_show (This.Void_Ptr);
    end Show;


    procedure Hide
           (This : in out Textline_Browser) is
    begin
        fl_browser_hide (This.Void_Ptr);
    end Hide;




    --  Dimensions  --

    procedure Resize
           (This : in out Textline_Browser;
            W, H : in     Integer) is
    begin
        fl_browser_set_size
           (This.Void_Ptr,
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --  Icons  --

    function Has_Icon
           (This : in Textline_Browser;
            Line : in Positive)
        return Boolean is
    begin
        return Line <= This.Icons.Last_Index and then This.Icons.Element (Line) /= null;
    end Has_Icon;


    function Get_Icon
           (This : in Textline_Browser;
            Line : in Positive)
        return FLTK.Images.Image_Reference is
    begin
        return Ref : FLTK.Images.Image_Reference (Data => This.Icons.Element (Line));
    end Get_Icon;


    procedure Set_Icon
           (This : in out Textline_Browser;
            Line : in     Positive;
            Icon : in     FLTK.Images.Image'Class) is
    begin
        fl_browser_set_icon (This.Void_Ptr, Interfaces.C.int (Line), Wrapper (Icon).Void_Ptr);
        if Line > This.Icons.Last_Index then
            This.Icons.Append (null, Ada.Containers.Count_Type (Line - This.Icons.Last_Index - 1));
            This.Icons.Append (new FLTK.Images.Image);
            Wrapper (This.Icons.Element (Line).all).Needs_Dealloc := False;
        elsif This.Icons.Element (Line) = null then
            This.Icons.Replace_Element (Line, new FLTK.Images.Image);
            Wrapper (This.Icons.Element (Line).all).Needs_Dealloc := False;
        end if;
        Wrapper (This.Icons.Element (Line).all).Void_Ptr := Wrapper (Icon).Void_Ptr;
    end Set_Icon;


    procedure Remove_Icon
           (This : in out Textline_Browser;
            Line : in     Positive)
    is
        Ptr : Image_Access;
    begin
        fl_browser_remove_icon (This.Void_Ptr, Interfaces.C.int (Line));
        if Line <= This.Icons.Last_Index then
            Ptr := This.Icons.Element (Line);
            Free (Ptr);
            This.Icons.Replace_Element (Line, null);
        end if;
    end Remove_Icon;




    --  List Implementation  --

    function Full_List_Height
           (This : in Textline_Browser)
        return Integer is
    begin
        return Browser (This).Full_List_Height;
    end Full_List_Height;


    function Average_Item_Height
           (This : in Textline_Browser)
        return Integer is
    begin
        return Browser (This).Average_Item_Height;
    end Average_Item_Height;




    --  Item Implementation  --

    function Item_Width
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Integer
    is
        function my_item_width
               (B, I : in Storage.Integer_Address)
            return Interfaces.C.int;
        for my_item_width'Address use This.Item_Override_Ptrs (Item_Width_Ptr);
        pragma Import (Ada, my_item_width);
    begin
        return Integer (my_item_width (This.Void_Ptr, Cursor_To_Address (Item)));
    end Item_Width;


    function Item_Height
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Integer
    is
        function my_item_height
               (B, I : in Storage.Integer_Address)
            return Interfaces.C.int;
        for my_item_height'Address use This.Item_Override_Ptrs (Item_Height_Ptr);
        pragma Import (Ada, my_item_height);
    begin
        return Integer (my_item_height (This.Void_Ptr, Cursor_To_Address (Item)));
    end Item_Height;


    function Item_First
           (This : in Textline_Browser)
        return Item_Cursor
    is
        function my_item_first
               (B : in Storage.Integer_Address)
            return Storage.Integer_Address;
        for my_item_first'Address use This.Item_Override_Ptrs (Item_First_Ptr);
        pragma Import (Ada, my_item_first);
    begin
        return Address_To_Cursor (my_item_first (This.Void_Ptr));
    end Item_First;


    function Item_Last
           (This : in Textline_Browser)
        return Item_Cursor
    is
        function my_item_last
               (B : in Storage.Integer_Address)
            return Storage.Integer_Address;
        for my_item_last'Address use This.Item_Override_Ptrs (Item_Last_Ptr);
        pragma Import (Ada, my_item_last);
    begin
        return Address_To_Cursor (my_item_last (This.Void_Ptr));
    end Item_Last;


    function Item_Next
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Item_Cursor
    is
        function my_item_next
               (B, I : in Storage.Integer_Address)
            return Storage.Integer_Address;
        for my_item_next'Address use This.Item_Override_Ptrs (Item_Next_Ptr);
        pragma Import (Ada, my_item_next);
    begin
        return Address_To_Cursor (my_item_next (This.Void_Ptr, Cursor_To_Address (Item)));
    end Item_Next;


    function Item_Previous
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Item_Cursor
    is
        function my_item_prev
               (B, I : in Storage.Integer_Address)
            return Storage.Integer_Address;
        for my_item_prev'Address use This.Item_Override_Ptrs (Item_Previous_Ptr);
        pragma Import (Ada, my_item_prev);
    begin
        return Address_To_Cursor (my_item_prev (This.Void_Ptr, Cursor_To_Address (Item)));
    end Item_Previous;


    function Item_At
           (This  : in Textline_Browser;
            Index : in Positive)
        return Item_Cursor
    is
        function my_item_at
               (B : in Storage.Integer_Address;
                N : in Interfaces.C.int)
            return Storage.Integer_Address;
        for my_item_at'Address use This.Item_Override_Ptrs (Item_At_Ptr);
        pragma Import (Ada, my_item_at);
    begin
        return Address_To_Cursor (my_item_at (This.Void_Ptr, Interfaces.C.int (Index)));
    end Item_At;


    procedure Item_Select
           (This  : in out Textline_Browser;
            Item  : in     Item_Cursor;
            State : in     Boolean := True)
    is
        procedure my_item_select
               (B, I : in Storage.Integer_Address;
                V    : in Interfaces.C.int);
        for my_item_select'Address use This.Item_Override_Ptrs (Item_Select_Ptr);
        pragma Import (Ada, my_item_select);
    begin
        my_item_select (This.Void_Ptr, Cursor_To_Address (Item), Boolean'Pos (State));
    end Item_Select;


    function Item_Selected
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Boolean
    is
        function my_item_selected
               (B, I : in Storage.Integer_Address)
            return Interfaces.C.int;
        for my_item_selected'Address use This.Item_Override_Ptrs (Item_Selected_Ptr);
        pragma Import (Ada, my_item_selected);
        Code : Interfaces.C.int := my_item_selected (This.Void_Ptr, Cursor_To_Address (Item));
    begin
        pragma Assert (Code in 0 .. 1);
        return Boolean'Val (Code);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Dispatched item_selected function returned unexpected int value of " &
        Interfaces.C.int'Image (Code);
    end Item_Selected;


    procedure Item_Swap
           (This : in out Textline_Browser;
            A, B : in     Item_Cursor)
    is
        procedure my_item_swap
               (B, X, Y : in Storage.Integer_Address);
        for my_item_swap'Address use This.Item_Override_Ptrs (Item_Swap_Ptr);
        pragma Import (Ada, my_item_swap);
    begin
        my_item_swap (This.Void_Ptr, Cursor_To_Address (A), Cursor_To_Address (B));
    end Item_Swap;


    function Item_Text
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return String
    is
        function my_item_text
               (B, I : in Storage.Integer_Address)
            return Interfaces.C.Strings.chars_ptr;
        for my_item_text'Address use This.Item_Override_Ptrs (Item_Text_Ptr);
        pragma Import (Ada, my_item_text);
    begin
        return Interfaces.C.Strings.Value (my_item_text (This.Void_Ptr, Cursor_To_Address (Item)));
    end Item_Text;


    procedure Item_Draw
           (This       : in Textline_Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer)
    is
        procedure my_item_draw
               (B, I       : in Storage.Integer_Address;
                X, Y, W, H : in Interfaces.C.int);
        for my_item_draw'Address use This.Item_Override_Ptrs (Item_Draw_Ptr);
        pragma Import (Ada, my_item_draw);
    begin
        my_item_draw
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Item_Draw;




    --  Line Numbers  --

    function Line_Number
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Natural is
    begin
        return Natural (fl_browser_lineno (This.Void_Ptr, Cursor_To_Address (Item)));
    end Line_Number;


end FLTK.Widgets.Groups.Browsers.Textline;


