

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Groups.Browsers.Textline.File is


    ------------------------
    --  Functions From C  --
    ------------------------

    function get_error_message
           return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, get_error_message, "get_error_message");
    pragma Inline (get_error_message);

    function filename_dname
           (L : in Storage.Integer_Address;
            N : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, filename_dname, "filename_dname");
    pragma Inline (filename_dname);




    function new_fl_file_browser
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_file_browser, "new_fl_file_browser");
    pragma Inline (new_fl_file_browser);

    procedure free_fl_file_browser
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_file_browser, "free_fl_file_browser");
    pragma Inline (free_fl_file_browser);




    function fl_file_browser_load
           (B : in Storage.Integer_Address;
            D : in Interfaces.C.char_array;
            S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_load, "fl_file_browser_load");
    pragma Inline (fl_file_browser_load);




    function fl_file_browser_get_filetype
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_get_filetype, "fl_file_browser_get_filetype");
    pragma Inline (fl_file_browser_get_filetype);

    procedure fl_file_browser_set_filetype
           (B : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_file_browser_set_filetype, "fl_file_browser_set_filetype");
    pragma Inline (fl_file_browser_set_filetype);

    function fl_file_browser_get_filter
           (B : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_browser_get_filter, "fl_file_browser_get_filter");
    pragma Inline (fl_file_browser_get_filter);

    procedure fl_file_browser_set_filter
           (B : in Storage.Integer_Address;
            F : in Interfaces.C.char_array);
    pragma Import (C, fl_file_browser_set_filter, "fl_file_browser_set_filter");
    pragma Inline (fl_file_browser_set_filter);

    function fl_file_browser_get_iconsize
           (B : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_file_browser_get_iconsize, "fl_file_browser_get_iconsize");
    pragma Inline (fl_file_browser_get_iconsize);

    procedure fl_file_browser_set_iconsize
           (B : in Storage.Integer_Address;
            I : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_file_browser_set_iconsize, "fl_file_browser_set_iconsize");
    pragma Inline (fl_file_browser_set_iconsize);

    function fl_file_browser_get_textsize
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_get_textsize, "fl_file_browser_get_textsize");
    pragma Inline (fl_file_browser_get_textsize);

    procedure fl_file_browser_set_textsize
           (B : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_file_browser_set_textsize, "fl_file_browser_set_textsize");
    pragma Inline (fl_file_browser_set_textsize);




    function fl_file_browser_item_width
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_item_width, "fl_file_browser_item_width");
    pragma Inline (fl_file_browser_item_width);

    function fl_file_browser_item_height
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_item_height, "fl_file_browser_item_height");
    pragma Inline (fl_file_browser_item_height);

    function fl_file_browser_item_first
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_browser_item_first, "fl_file_browser_item_first");
    pragma Inline (fl_file_browser_item_first);

    function fl_file_browser_item_last
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_browser_item_last, "fl_file_browser_item_last");
    pragma Inline (fl_file_browser_item_last);

    function fl_file_browser_item_next
           (B, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_browser_item_next, "fl_file_browser_item_next");
    pragma Inline (fl_file_browser_item_next);

    function fl_file_browser_item_prev
           (B, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_browser_item_prev, "fl_file_browser_item_prev");
    pragma Inline (fl_file_browser_item_prev);

    function fl_file_browser_item_at
           (B : in Storage.Integer_Address;
            N : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_browser_item_at, "fl_file_browser_item_at");
    pragma Inline (fl_file_browser_item_at);

    procedure fl_file_browser_item_select
           (B, I : in Storage.Integer_Address;
            V    : in Interfaces.C.int);
    pragma Import (C, fl_file_browser_item_select, "fl_file_browser_item_select");
    pragma Inline (fl_file_browser_item_select);

    function fl_file_browser_item_selected
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_item_selected, "fl_file_browser_item_selected");
    pragma Inline (fl_file_browser_item_selected);

    procedure fl_file_browser_item_swap
           (B, X, Y : in Storage.Integer_Address);
    pragma Import (C, fl_file_browser_item_swap, "fl_file_browser_item_swap");
    pragma Inline (fl_file_browser_item_swap);

    function fl_file_browser_item_text
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_browser_item_text, "fl_file_browser_item_text");
    pragma Inline (fl_file_browser_item_text);

    procedure fl_file_browser_item_draw
           (B, I       : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_file_browser_item_draw, "fl_file_browser_item_draw");
    pragma Inline (fl_file_browser_item_draw);




    function fl_file_browser_full_width
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_full_width, "fl_file_browser_full_width");
    pragma Inline (fl_file_browser_full_width);

    function fl_file_browser_full_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_full_height, "fl_file_browser_full_height");
    pragma Inline (fl_file_browser_full_height);

    function fl_file_browser_incr_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_incr_height, "fl_file_browser_incr_height");
    pragma Inline (fl_file_browser_incr_height);

    function fl_file_browser_item_quick_height
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_item_quick_height, "fl_file_browser_item_quick_height");
    pragma Inline (fl_file_browser_item_quick_height);




    procedure fl_file_browser_draw
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_file_browser_draw, "fl_file_browser_draw");
    pragma Inline (fl_file_browser_draw);

    function fl_file_browser_handle
           (B : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_file_browser_handle, "fl_file_browser_handle");
    pragma Inline (fl_file_browser_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out File_Browser) is
    begin
        Extra_Final (Textline_Browser (This));
    end Extra_Final;


    procedure Finalize
           (This : in out File_Browser) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_file_browser (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out File_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Textline_Browser (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out File_Browser) is
    begin
        This.Item_Override_Ptrs :=
           (Item_Width_Ptr    => fl_file_browser_item_width'Address,
            Item_Height_Ptr   => fl_file_browser_item_height'Address,
            Item_First_Ptr    => fl_file_browser_item_first'Address,
            Item_Last_Ptr     => fl_file_browser_item_last'Address,
            Item_Next_Ptr     => fl_file_browser_item_next'Address,
            Item_Previous_Ptr => fl_file_browser_item_prev'Address,
            Item_At_Ptr       => fl_file_browser_item_at'Address,
            Item_Select_Ptr   => fl_file_browser_item_select'Address,
            Item_Selected_Ptr => fl_file_browser_item_selected'Address,
            Item_Swap_Ptr     => fl_file_browser_item_swap'Address,
            Item_Text_Ptr     => fl_file_browser_item_text'Address,
            Item_Draw_Ptr     => fl_file_browser_item_draw'Address);
        This.Wide_High_Ptrs :=
           (Full_List_Width_Ptr     => fl_file_browser_full_width'Address,
            Full_List_Height_Ptr    => fl_file_browser_full_height'Address,
            Average_Item_Height_Ptr => fl_file_browser_incr_height'Address,
            Item_Quick_Height_Ptr   => fl_file_browser_item_quick_height'Address);
        This.Draw_Ptr   := fl_file_browser_draw'Address;
        This.Handle_Ptr := fl_file_browser_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return File_Browser is
        begin
            return This : File_Browser do
                This.Void_Ptr := new_fl_file_browser
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

    Current_Sort : FLTK.Filenames.Compare_Function;

    function Compare_Hook
           (DA, DB : in Storage.Integer_Address)
        return Interfaces.C.int;

    pragma Convention (C, Compare_Hook);

    function Compare_Hook
           (DA, DB : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Result : FLTK.Filenames.Comparison := Current_Sort
           (Interfaces.C.Strings.Value (filename_dname (DA, 0)),
            Interfaces.C.Strings.Value (filename_dname (DB, 0)));
    begin
        return FLTK.Filenames.Comparison'Pos (Result) - 1;
    end Compare_Hook;


    function Load
           (This : in out File_Browser;
            Dir  : in     String;
            Sort : in not null FLTK.Filenames.Compare_Function :=
                FLTK.Filenames.Numeric_Sort'Access)
        return Natural
    is
        Msg  : Interfaces.C.Strings.chars_ptr;
        Code : Interfaces.C.int;
    begin
        Current_Sort := Sort;
        Code := fl_file_browser_load
           (This.Void_Ptr,
            Interfaces.C.To_C (Dir),
            Storage.To_Integer (Compare_Hook'Address));
        if Code = 0 then
            Msg := get_error_message;
            if Msg /= Interfaces.C.Strings.Null_Ptr then
                raise Browser_Load_Error with Interfaces.C.Strings.Value (Msg);
            end if;
        end if;
        return Natural (Code);
    end Load;


    procedure Load
           (This : in out File_Browser;
            Dir  : in     String;
            Sort : in not null FLTK.Filenames.Compare_Function :=
                FLTK.Filenames.Numeric_Sort'Access)
    is
        Result : Natural := This.Load (Dir, Sort);
    begin
        null;
    end Load;




    function Get_File_Kind
           (This : in File_Browser)
        return File_Kind
    is
        Code : Interfaces.C.int := fl_file_browser_get_filetype (This.Void_Ptr);
    begin
        if Code not in File_Kind'Pos (File_Kind'First) .. File_Kind'Pos (File_Kind'Last) then
            raise Internal_FLTK_Error;
        end if;
        return File_Kind'Val (Code);
    end Get_File_Kind;


    procedure Set_File_Kind
           (This  : in out File_Browser;
            Value : in     File_Kind) is
    begin
        fl_file_browser_set_filetype (This.Void_Ptr, File_Kind'Pos (Value));
    end Set_File_Kind;


    function Get_Filter
           (This : in File_Browser)
        return String
    is
        Result : Interfaces.C.Strings.chars_ptr := fl_file_browser_get_filter (This.Void_Ptr);
    begin
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Get_Filter;


    procedure Set_Filter
           (This  : in out File_Browser;
            Value : in     String) is
    begin
        fl_file_browser_set_filter (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Filter;


    function Get_Icon_Size
           (This : in File_Browser)
        return Icon_Size is
    begin
        return Icon_Size (fl_file_browser_get_iconsize (This.Void_Ptr));
    end Get_Icon_Size;


    procedure Set_Icon_Size
           (This  : in out File_Browser;
            Value : in     Icon_Size) is
    begin
        fl_file_browser_set_iconsize (This.Void_Ptr, Interfaces.C.unsigned_char (Value));
    end Set_Icon_Size;


    function Get_Text_Size
           (This : in File_Browser)
        return Font_Size is
    begin
        return Font_Size (fl_file_browser_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out File_Browser;
            Size : in     Font_Size) is
    begin
        fl_file_browser_set_textsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    function Full_List_Height
           (This : in File_Browser)
        return Integer is
    begin
        return Textline_Browser (This).Full_List_Height;
    end Full_List_Height;


    function Average_Item_Height
           (This : in File_Browser)
        return Integer is
    begin
        return Textline_Browser (This).Average_Item_Height;
    end Average_Item_Height;




    function Item_Width
           (This : in File_Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return Textline_Browser (This).Item_Width (Item);
    end Item_Width;


    function Item_Height
           (This : in File_Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return Textline_Browser (This).Item_Height (Item);
    end Item_Height;


    procedure Item_Draw
           (This       : in File_Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer) is
    begin
        Textline_Browser (This).Item_Draw (Item, X, Y, W, H);
    end Item_Draw;


end FLTK.Widgets.Groups.Browsers.Textline.File;


