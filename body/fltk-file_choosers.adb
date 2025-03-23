

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Interfaces.C.Strings,
    System.Address_To_Access_Conversions;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.File_Choosers is


    package Chk renames Ada.Assertions;

    package File_Chooser_Convert is new System.Address_To_Access_Conversions (File_Chooser'Class);
    package Widget_Convert       is new System.Address_To_Access_Conversions (Widgets.Widget'Class);




    ------------------------
    --  Functions From C  --
    ------------------------

    --  User Data  --

    function fl_widget_get_user_data
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_get_user_data, "fl_widget_get_user_data");
    pragma Inline (fl_widget_get_user_data);

    --  procedure fl_widget_set_user_data
    --         (W, D : in Storage.Integer_Address);
    --  pragma Import (C, fl_widget_set_user_data, "fl_widget_set_user_data");
    --  pragma Inline (fl_widget_set_user_data);

    --  function fl_file_chooser_get_user_data
    --         (F : in Storage.Integer_Address)
    --      return Storage.Integer_Address;
    --  pragma Import (C, fl_file_chooser_get_user_data, "fl_file_chooser_get_user_data");
    --  pragma Inline (fl_file_chooser_get_user_data);

    procedure fl_file_chooser_set_user_data
           (F, U : in Storage.Integer_Address);
    pragma Import (C, fl_file_chooser_set_user_data, "fl_file_chooser_set_user_data");
    pragma Inline (fl_file_chooser_set_user_data);




    --  Sorting  --

    procedure file_chooser_setup_sort_hook;
    pragma Import (C, file_chooser_setup_sort_hook, "file_chooser_setup_sort_hook");
    pragma Inline (file_chooser_setup_sort_hook);




    --  Allocation  --

    function new_fl_file_chooser
           (N, P : in Interfaces.C.char_array;
            K    : in Interfaces.C.int;
            T    : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_file_chooser, "new_fl_file_chooser");
    pragma Inline (new_fl_file_chooser);

    procedure free_fl_file_chooser
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_file_chooser, "free_fl_file_chooser");
    pragma Inline (free_fl_file_chooser);




    --  Buttons  --

    function fl_file_chooser_newbutton
           (F : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_chooser_newbutton, "fl_file_chooser_newbutton");
    pragma Inline (fl_file_chooser_newbutton);

    function fl_file_chooser_previewbutton
           (F : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_chooser_previewbutton, "fl_file_chooser_previewbutton");
    pragma Inline (fl_file_chooser_previewbutton);

    function fl_file_chooser_showhiddenbutton
           (F : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_chooser_showhiddenbutton, "fl_file_chooser_showhiddenbutton");
    pragma Inline (fl_file_chooser_showhiddenbutton);




    --  Static Labels  --

    function fl_file_chooser_get_add_favorites_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_add_favorites_label,
        "fl_file_chooser_get_add_favorites_label");
    pragma Inline (fl_file_chooser_get_add_favorites_label);

    procedure fl_file_chooser_set_add_favorites_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_add_favorites_label,
        "fl_file_chooser_set_add_favorites_label");
    pragma Inline (fl_file_chooser_set_add_favorites_label);

    function fl_file_chooser_get_all_files_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_all_files_label, "fl_file_chooser_get_all_files_label");
    pragma Inline (fl_file_chooser_get_all_files_label);

    procedure fl_file_chooser_set_all_files_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_all_files_label, "fl_file_chooser_set_all_files_label");
    pragma Inline (fl_file_chooser_set_all_files_label);

    function fl_file_chooser_get_custom_filter_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_custom_filter_label,
        "fl_file_chooser_get_custom_filter_label");
    pragma Inline (fl_file_chooser_get_custom_filter_label);

    procedure fl_file_chooser_set_custom_filter_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_custom_filter_label,
        "fl_file_chooser_set_custom_filter_label");
    pragma Inline (fl_file_chooser_set_custom_filter_label);

    function fl_file_chooser_get_existing_file_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_existing_file_label,
        "fl_file_chooser_get_existing_file_label");
    pragma Inline (fl_file_chooser_get_existing_file_label);

    procedure fl_file_chooser_set_existing_file_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_existing_file_label,
        "fl_file_chooser_set_existing_file_label");
    pragma Inline (fl_file_chooser_set_existing_file_label);

    function fl_file_chooser_get_favorites_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_favorites_label, "fl_file_chooser_get_favorites_label");
    pragma Inline (fl_file_chooser_get_favorites_label);

    procedure fl_file_chooser_set_favorites_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_favorites_label, "fl_file_chooser_set_favorites_label");
    pragma Inline (fl_file_chooser_set_favorites_label);

    function fl_file_chooser_get_filename_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_filename_label, "fl_file_chooser_get_filename_label");
    pragma Inline (fl_file_chooser_get_filename_label);

    procedure fl_file_chooser_set_filename_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_filename_label, "fl_file_chooser_set_filename_label");
    pragma Inline (fl_file_chooser_set_filename_label);

    function fl_file_chooser_get_filesystems_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_filesystems_label,
        "fl_file_chooser_get_filesystems_label");
    pragma Inline (fl_file_chooser_get_filesystems_label);

    procedure fl_file_chooser_set_filesystems_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_filesystems_label,
        "fl_file_chooser_set_filesystems_label");
    pragma Inline (fl_file_chooser_set_filesystems_label);

    function fl_file_chooser_get_hidden_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_hidden_label, "fl_file_chooser_get_hidden_label");
    pragma Inline (fl_file_chooser_get_hidden_label);

    procedure fl_file_chooser_set_hidden_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_hidden_label, "fl_file_chooser_set_hidden_label");
    pragma Inline (fl_file_chooser_set_hidden_label);

    function fl_file_chooser_get_manage_favorites_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_manage_favorites_label,
        "fl_file_chooser_get_manage_favorites_label");
    pragma Inline (fl_file_chooser_get_manage_favorites_label);

    procedure fl_file_chooser_set_manage_favorites_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_manage_favorites_label,
        "fl_file_chooser_set_manage_favorites_label");
    pragma Inline (fl_file_chooser_set_manage_favorites_label);

    function fl_file_chooser_get_new_directory_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_new_directory_label,
        "fl_file_chooser_get_new_directory_label");
    pragma Inline (fl_file_chooser_get_new_directory_label);

    procedure fl_file_chooser_set_new_directory_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_new_directory_label,
        "fl_file_chooser_set_new_directory_label");
    pragma Inline (fl_file_chooser_set_new_directory_label);

    function fl_file_chooser_get_new_directory_tooltip
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_new_directory_tooltip,
        "fl_file_chooser_get_new_directory_tooltip");
    pragma Inline (fl_file_chooser_get_new_directory_tooltip);

    procedure fl_file_chooser_set_new_directory_tooltip
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_new_directory_tooltip,
        "fl_file_chooser_set_new_directory_tooltip");
    pragma Inline (fl_file_chooser_set_new_directory_tooltip);

    function fl_file_chooser_get_preview_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_preview_label, "fl_file_chooser_get_preview_label");
    pragma Inline (fl_file_chooser_get_preview_label);

    procedure fl_file_chooser_set_preview_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_preview_label, "fl_file_chooser_set_preview_label");
    pragma Inline (fl_file_chooser_set_preview_label);

    function fl_file_chooser_get_save_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_save_label, "fl_file_chooser_get_save_label");
    pragma Inline (fl_file_chooser_get_save_label);

    procedure fl_file_chooser_set_save_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_save_label, "fl_file_chooser_set_save_label");
    pragma Inline (fl_file_chooser_set_save_label);

    function fl_file_chooser_get_show_label
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_show_label, "fl_file_chooser_get_show_label");
    pragma Inline (fl_file_chooser_get_show_label);

    procedure fl_file_chooser_set_show_label
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_show_label, "fl_file_chooser_set_show_label");
    pragma Inline (fl_file_chooser_set_show_label);




    --  Callback and Extra  --

    function fl_file_chooser_add_extra
           (F, W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_chooser_add_extra, "fl_file_chooser_add_extra");
    pragma Inline (fl_file_chooser_add_extra);

    procedure fl_file_chooser_callback
           (F, C, U : in Storage.Integer_Address);
    pragma Import (C, fl_file_chooser_callback, "fl_file_chooser_callback");
    pragma Inline (fl_file_chooser_callback);




    --  Settings  --

    function fl_file_chooser_get_color
           (F : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_file_chooser_get_color, "fl_file_chooser_get_color");
    pragma Inline (fl_file_chooser_get_color);

    procedure fl_file_chooser_set_color
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.unsigned);
    pragma Import (C, fl_file_chooser_set_color, "fl_file_chooser_set_color");
    pragma Inline (fl_file_chooser_set_color);

    function fl_file_chooser_get_iconsize
           (F : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_file_chooser_get_iconsize, "fl_file_chooser_get_iconsize");
    pragma Inline (fl_file_chooser_get_iconsize);

    procedure fl_file_chooser_set_iconsize
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_file_chooser_set_iconsize, "fl_file_chooser_set_iconsize");
    pragma Inline (fl_file_chooser_set_iconsize);

    function fl_file_chooser_get_label
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_label, "fl_file_chooser_get_label");
    pragma Inline (fl_file_chooser_get_label);

    procedure fl_file_chooser_set_label
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_label, "fl_file_chooser_set_label");
    pragma Inline (fl_file_chooser_set_label);

    function fl_file_chooser_get_ok_label
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_ok_label, "fl_file_chooser_get_ok_label");
    pragma Inline (fl_file_chooser_get_ok_label);

    procedure fl_file_chooser_set_ok_label
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_ok_label, "fl_file_chooser_set_ok_label");
    pragma Inline (fl_file_chooser_set_ok_label);

    function fl_file_chooser_get_preview
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_chooser_get_preview, "fl_file_chooser_get_preview");
    pragma Inline (fl_file_chooser_get_preview);

    procedure fl_file_chooser_set_preview
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_file_chooser_set_preview, "fl_file_chooser_set_preview");
    pragma Inline (fl_file_chooser_set_preview);

    function fl_file_chooser_get_textcolor
           (F : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_file_chooser_get_textcolor, "fl_file_chooser_get_textcolor");
    pragma Inline (fl_file_chooser_get_textcolor);

    procedure fl_file_chooser_set_textcolor
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.unsigned);
    pragma Import (C, fl_file_chooser_set_textcolor, "fl_file_chooser_set_textcolor");
    pragma Inline (fl_file_chooser_set_textcolor);

    function fl_file_chooser_get_textfont
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_chooser_get_textfont, "fl_file_chooser_get_textfont");
    pragma Inline (fl_file_chooser_get_textfont);

    procedure fl_file_chooser_set_textfont
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_file_chooser_set_textfont, "fl_file_chooser_set_textfont");
    pragma Inline (fl_file_chooser_set_textfont);

    function fl_file_chooser_get_textsize
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_chooser_get_textsize, "fl_file_chooser_get_textsize");
    pragma Inline (fl_file_chooser_get_textsize);

    procedure fl_file_chooser_set_textsize
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_file_chooser_set_textsize, "fl_file_chooser_set_textsize");
    pragma Inline (fl_file_chooser_set_textsize);

    function fl_file_chooser_get_type
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_chooser_get_type, "fl_file_chooser_get_type");
    pragma Inline (fl_file_chooser_get_type);

    procedure fl_file_chooser_set_type
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_file_chooser_set_type, "fl_file_chooser_set_type");
    pragma Inline (fl_file_chooser_set_type);




    --  File Selection  --

    function fl_file_chooser_count
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_chooser_count, "fl_file_chooser_count");
    pragma Inline (fl_file_chooser_count);

    function fl_file_chooser_get_directory
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_directory, "fl_file_chooser_get_directory");
    pragma Inline (fl_file_chooser_get_directory);

    procedure fl_file_chooser_set_directory
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_directory, "fl_file_chooser_set_directory");
    pragma Inline (fl_file_chooser_set_directory);

    function fl_file_chooser_get_filter
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_filter, "fl_file_chooser_get_filter");
    pragma Inline (fl_file_chooser_get_filter);

    procedure fl_file_chooser_set_filter
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_file_chooser_set_filter, "fl_file_chooser_set_filter");
    pragma Inline (fl_file_chooser_set_filter);

    function fl_file_chooser_get_filter_value
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_chooser_get_filter_value, "fl_file_chooser_get_filter_value");
    pragma Inline (fl_file_chooser_get_filter_value);

    procedure fl_file_chooser_set_filter_value
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_file_chooser_set_filter_value, "fl_file_chooser_set_filter_value");
    pragma Inline (fl_file_chooser_set_filter_value);

    procedure fl_file_chooser_rescan
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_file_chooser_rescan, "fl_file_chooser_rescan");
    pragma Inline (fl_file_chooser_rescan);

    procedure fl_file_chooser_rescan_keep_filename
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_file_chooser_rescan_keep_filename, "fl_file_chooser_rescan_keep_filename");
    pragma Inline (fl_file_chooser_rescan_keep_filename);

    function fl_file_chooser_get_value
           (F : in Storage.Integer_Address;
            N : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_chooser_get_value, "fl_file_chooser_get_value");
    pragma Inline (fl_file_chooser_get_value);

    procedure fl_file_chooser_set_value
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.char_array);
    pragma Import (C, fl_file_chooser_set_value, "fl_file_chooser_set_value");
    pragma Inline (fl_file_chooser_set_value);




    --  Visibility  --

    procedure fl_file_chooser_show
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_file_chooser_show, "fl_file_chooser_show");
    pragma Inline (fl_file_chooser_show);

    procedure fl_file_chooser_hide
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_file_chooser_hide, "fl_file_chooser_hide");
    pragma Inline (fl_file_chooser_hide);

    function fl_file_chooser_shown
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_chooser_shown, "fl_file_chooser_shown");
    pragma Inline (fl_file_chooser_shown);

    function fl_file_chooser_visible
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_chooser_visible, "fl_file_chooser_visible");
    pragma Inline (fl_file_chooser_visible);




    ----------------------
    --  Callback Hooks  --
    ----------------------

    function File_Chooser_Sort_Hook
           (A, B : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.int;

    pragma Export (C, File_Chooser_Sort_Hook, "file_chooser_sort_hook");

    function File_Chooser_Sort_Hook
           (A, B : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.int is
    begin
        return Filenames.Comparison'Pos (Sort_Method
           (Interfaces.C.Strings.Value (A),
            Interfaces.C.Strings.Value (B))) - 1;
    end File_Chooser_Sort_Hook;


    procedure File_Chooser_Callback_Hook
           (Ignore, User_Data : in Storage.Integer_Address);
    pragma Convention (C, File_Chooser_Callback_Hook);

    procedure File_Chooser_Callback_Hook
           (Ignore, User_Data : in Storage.Integer_Address)
    is
        Ada_Obj : constant access File_Chooser'Class :=
            File_Chooser_Convert.To_Pointer (Storage.To_Address (User_Data));
    begin
        if Ada_Obj.My_Callback /= null then
            Ada_Obj.My_Callback (Ada_Obj.all);
        end if;
    end File_Chooser_Callback_Hook;




    -------------------
    --  Destructors  --
    -------------------

    --  Releasing carrier pigeon
    procedure fl_button_extra_final
           (Ada_Obj : in Storage.Integer_Address);
    pragma Import (C, fl_button_extra_final, "fl_button_extra_final");
    pragma Inline (fl_button_extra_final);


    --  Entering wormhole
    procedure fl_check_button_extra_final
           (Ada_Obj : in Storage.Integer_Address);
    pragma Import (C, fl_check_button_extra_final, "fl_check_button_extra_final");
    pragma Inline (fl_check_button_extra_final);


    procedure Extra_Final
           (This : in out File_Chooser)
    is
        use Interfaces.C.Strings;
    begin
        fl_button_extra_final (Storage.To_Integer (This.New_Butt'Address));
        fl_check_button_extra_final (Storage.To_Integer (This.Preview_Butt'Address));
        fl_check_button_extra_final (Storage.To_Integer (This.Hidden_Butt'Address));
        Free (This.My_Label);
        Free (This.My_OK_Label);
    end Extra_Final;


    procedure Finalize
           (This : in out File_Chooser) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_file_chooser (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;


    procedure Finalize
           (This : in out File_Chooser_Final_Controller)
    is
        use Interfaces.C.Strings;
    begin
        Free (Add_Favorites_Label);
        Free (All_Files_Label);
        Free (Custom_Filter_Label);
        Free (Existing_File_Label);
        Free (Favorites_Label);
        Free (Filename_Label);
        Free (Filesystems_Label);
        Free (Hidden_Label);
        Free (Manage_Favorites_Label);
        Free (New_Directory_Label);
        Free (New_Directory_Tooltip);
        Free (Preview_Label);
        Free (Save_Label);
        Free (Show_Label);
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Bypassing border checkpoints
    procedure fl_button_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_button_extra_init, "fl_button_extra_init");
    pragma Inline (fl_button_extra_init);


    --  Refracting off language boundaries
    procedure fl_check_button_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_check_button_extra_init, "fl_check_button_extra_init");
    pragma Inline (fl_check_button_extra_init);


    procedure Extra_Init
           (This : in out File_Chooser) is
    begin
        Wrapper (This.New_Butt).Void_Ptr := fl_file_chooser_newbutton (This.Void_Ptr);
        Wrapper (This.New_Butt).Needs_Dealloc := False;
        fl_button_extra_init
           (Storage.To_Integer (This.New_Butt'Address),
            Interfaces.C.int (This.New_Butt.Get_X),
            Interfaces.C.int (This.New_Butt.Get_Y),
            Interfaces.C.int (This.New_Butt.Get_W),
            Interfaces.C.int (This.New_Butt.Get_H),
            Interfaces.C.To_C (This.New_Butt.Get_Label));

        Wrapper (This.Preview_Butt).Void_Ptr := fl_file_chooser_previewbutton (This.Void_Ptr);
        Wrapper (This.Preview_Butt).Needs_Dealloc := False;
        fl_check_button_extra_init
           (Storage.To_Integer (This.Preview_Butt'Address),
            Interfaces.C.int (This.Preview_Butt.Get_X),
            Interfaces.C.int (This.Preview_Butt.Get_Y),
            Interfaces.C.int (This.Preview_Butt.Get_W),
            Interfaces.C.int (This.Preview_Butt.Get_H),
            Interfaces.C.To_C (This.Preview_Butt.Get_Label));

        Wrapper (This.Hidden_Butt).Void_Ptr := fl_file_chooser_showhiddenbutton (This.Void_Ptr);
        Wrapper (This.Hidden_Butt).Needs_Dealloc := False;
        fl_check_button_extra_init
           (Storage.To_Integer (This.Hidden_Butt'Address),
            Interfaces.C.int (This.Hidden_Butt.Get_X),
            Interfaces.C.int (This.Hidden_Butt.Get_Y),
            Interfaces.C.int (This.Hidden_Butt.Get_W),
            Interfaces.C.int (This.Hidden_Butt.Get_H),
            Interfaces.C.To_C (This.Hidden_Butt.Get_Label));

        fl_file_chooser_set_user_data
           (This.Void_Ptr,
            Storage.To_Integer (This'Address));
        fl_file_chooser_callback
           (This.Void_Ptr,
            Storage.To_Integer (File_Chooser_Callback_Hook'Address),
            Storage.To_Integer (This'Address));
    end Extra_Init;


    package body Forge is

        function Create
               (Title    : in String;
                Pattern  : in String;
                Pathname : in String;
                Kind     : in Chooser_Kind := Single)
            return File_Chooser is
        begin
            return This : File_Chooser do
                This.Void_Ptr := new_fl_file_chooser
                   (Interfaces.C.To_C (Pathname),
                    Interfaces.C.To_C (Pattern),
                    Chooser_Kind'Pos (Kind),
                    Interfaces.C.To_C (Title));
                Extra_Init (This);
            end return;
        end Create;

    end Forge;




    ------------------
    --  Attributes  --
    ------------------

    --  Buttons  --

    function New_Button
           (This : in out File_Chooser)
        return FLTK.Widgets.Buttons.Button_Reference is
    begin
        return (Data => This.New_Butt'Unchecked_Access);
    end New_Button;


    function Preview_Button
           (This : in out File_Chooser)
        return FLTK.Widgets.Buttons.Light.Check.Check_Button_Reference is
    begin
        return (Data => This.Preview_Butt'Unchecked_Access);
    end Preview_Button;


    function Show_Hidden_Button
           (This : in out File_Chooser)
        return FLTK.Widgets.Buttons.Light.Check.Check_Button_Reference is
    begin
        return (Data => This.Hidden_Butt'Unchecked_Access);
    end Show_Hidden_Button;




    -------------------------
    --  Static Attributes  --
    -------------------------

    --  Static Labels  --

    function Get_Add_Favorites_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_add_favorites_label);
    end Get_Add_Favorites_Label;


    procedure Set_Add_Favorites_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Add_Favorites_Label);
        Add_Favorites_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_add_favorites_label (Add_Favorites_Label);
    end Set_Add_Favorites_Label;


    function Get_All_Files_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_all_files_label);
    end Get_All_Files_Label;


    procedure Set_All_Files_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (All_Files_Label);
        All_Files_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_all_files_label (All_Files_Label);
    end Set_All_Files_Label;


    function Get_Custom_Filter_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_custom_filter_label);
    end Get_Custom_Filter_Label;


    procedure Set_Custom_Filter_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Custom_Filter_Label);
        Custom_Filter_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_custom_filter_label (Custom_Filter_Label);
    end Set_Custom_Filter_Label;


    function Get_Existing_File_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_existing_file_label);
    end Get_Existing_File_Label;


    procedure Set_Existing_File_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Existing_File_Label);
        Existing_File_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_existing_file_label (Existing_File_Label);
    end Set_Existing_File_Label;


    function Get_Favorites_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_favorites_label);
    end Get_Favorites_Label;


    procedure Set_Favorites_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Favorites_Label);
        Favorites_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_favorites_label (Favorites_Label);
    end Set_Favorites_Label;


    function Get_Filename_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_filename_label);
    end Get_Filename_Label;


    procedure Set_Filename_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Filename_Label);
        Filename_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_filename_label (Filename_Label);
    end Set_Filename_Label;


    function Get_Filesystems_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_filesystems_label);
    end Get_Filesystems_Label;


    procedure Set_Filesystems_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Filesystems_Label);
        Filesystems_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_filesystems_label (Filesystems_Label);
    end Set_Filesystems_Label;


    function Get_Hidden_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_hidden_label);
    end Get_Hidden_Label;


    procedure Set_Hidden_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Hidden_Label);
        Hidden_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_hidden_label (Hidden_Label);
    end Set_Hidden_Label;


    function Get_Manage_Favorites_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_manage_favorites_label);
    end Get_Manage_Favorites_Label;


    procedure Set_Manage_Favorites_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Manage_Favorites_Label);
        Manage_Favorites_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_manage_favorites_label (Manage_Favorites_Label);
    end Set_Manage_Favorites_Label;


    function Get_New_Directory_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_new_directory_label);
    end Get_New_Directory_Label;


    procedure Set_New_Directory_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (New_Directory_Label);
        New_Directory_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_new_directory_label (New_Directory_Label);
    end Set_New_Directory_Label;


    function Get_New_Directory_Tooltip
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_new_directory_tooltip);
    end Get_New_Directory_Tooltip;


    procedure Set_New_Directory_Tooltip
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (New_Directory_Tooltip);
        New_Directory_Tooltip := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_new_directory_tooltip (New_Directory_Tooltip);
    end Set_New_Directory_Tooltip;


    function Get_Preview_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_preview_label);
    end Get_Preview_Label;


    procedure Set_Preview_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Preview_Label);
        Preview_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_preview_label (Preview_Label);
    end Set_Preview_Label;


    function Get_Save_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_save_label);
    end Get_Save_Label;


    procedure Set_Save_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Save_Label);
        Save_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_save_label (Save_Label);
    end Set_Save_Label;


    function Get_Show_Label
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_show_label);
    end Get_Show_Label;

    procedure Set_Show_Label
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Show_Label);
        Show_Label := Interfaces.C.Strings.New_String (Value);
        fl_file_chooser_set_show_label (Show_Label);
    end Set_Show_Label;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Callback and Extra  --

    procedure Add_Extra
           (This : in out File_Chooser;
            Item : in out Widgets.Widget'Class)
    is
        Ignore : Storage.Integer_Address :=
            fl_file_chooser_add_extra (This.Void_Ptr, Wrapper (Item).Void_Ptr);
    begin
        null;
    end Add_Extra;


    procedure Remove_Extra
           (This : in out File_Chooser)
    is
        Ignore : Storage.Integer_Address := fl_file_chooser_add_extra (This.Void_Ptr, Null_Pointer);
    begin
        null;
    end Remove_Extra;


    function Eject_Extra
           (This : in out File_Chooser;
            Item : in out Widgets.Widget'Class)
        return access Widgets.Widget'Class
    is
        C_Addr : Storage.Integer_Address :=
            fl_file_chooser_add_extra (This.Void_Ptr, Wrapper (Item).Void_Ptr);
        Ada_Obj : access Widgets.Widget'Class;
    begin
        if C_Addr /= Null_Pointer then
            C_Addr := fl_widget_get_user_data (C_Addr);
            pragma Assert (C_Addr /= Null_Pointer);
            Ada_Obj := Widget_Convert.To_Pointer (Storage.To_Address (C_Addr));
        end if;
        return Ada_Obj;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_File_Chooser::add_extra returned Widget with no user_data reference back to Ada";
    end Eject_Extra;


    procedure Set_Callback
           (This : in out File_Chooser;
            Func : in     Chooser_Callback) is
    begin
        This.My_Callback := Func;
    end Set_Callback;




    --  Settings  --

    function Get_Background_Color
           (This : in File_Chooser)
        return Color is
    begin
        return Color (fl_file_chooser_get_color (This.Void_Ptr));
    end Get_Background_Color;


    procedure Set_Background_Color
           (This  : in out File_Chooser;
            Value : in     Color) is
    begin
        fl_file_chooser_set_color (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Set_Background_Color;


    function Get_Icon_Size
           (This : in File_Chooser)
        return Icon_Size is
    begin
        return Icon_Size (fl_file_chooser_get_iconsize (This.Void_Ptr));
    end Get_Icon_Size;


    procedure Set_Icon_Size
           (This  : in out File_Chooser;
            Value : in     Icon_Size) is
    begin
        fl_file_chooser_set_iconsize (This.Void_Ptr, Interfaces.C.unsigned_char (Value));
    end Set_Icon_Size;


    function Get_Label
           (This : in File_Chooser)
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_label (This.Void_Ptr));
    end Get_Label;


    procedure Set_Label
           (This : in out File_Chooser;
            Text : in     String) is
    begin
        Interfaces.C.Strings.Free (This.My_Label);
        This.My_Label := Interfaces.C.Strings.New_String (Text);
        fl_file_chooser_set_label (This.Void_Ptr, This.My_Label);
    end Set_Label;


    function Get_OK_Label
           (This : in File_Chooser)
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_file_chooser_get_ok_label (This.Void_Ptr));
    end Get_OK_Label;


    procedure Set_OK_Label
           (This : in out File_Chooser;
            Text : in     String) is
    begin
        Interfaces.C.Strings.Free (This.My_OK_Label);
        This.My_OK_Label := Interfaces.C.Strings.New_String (Text);
        fl_file_chooser_set_ok_label (This.Void_Ptr, This.My_OK_Label);
    end Set_OK_Label;


    function Has_Preview
           (This : in File_Chooser)
        return Boolean
    is
        Ret : constant Interfaces.C.int := fl_file_chooser_get_preview (This.Void_Ptr);
    begin
        pragma Assert (Ret in 0 .. 1);
        return Boolean'Val (Ret);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_File_Chooser::preview returned unexpected int value of " &
        Interfaces.C.int'Image (Ret);
    end Has_Preview;


    procedure Set_Preview
           (This  : in out File_Chooser;
            Value : in     Boolean) is
    begin
        fl_file_chooser_set_preview (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Preview;


    function Get_Text_Color
           (This : in File_Chooser)
        return Color is
    begin
        return Color (fl_file_chooser_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This  : in out File_Chooser;
            Value : in     Color) is
    begin
        fl_file_chooser_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in File_Chooser)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_file_chooser_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out File_Chooser;
            Font : in     Font_Kind) is
    begin
        fl_file_chooser_set_textfont (This.Void_Ptr, Font_Kind'Pos (Font));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in File_Chooser)
        return Font_Size is
    begin
        return Font_Size (fl_file_chooser_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out File_Chooser;
            Size : in     Font_Size) is
    begin
        fl_file_chooser_set_textsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;


    function Get_Kind
           (This : in File_Chooser)
        return Chooser_Kind
    is
        Ret : constant Interfaces.C.int := fl_file_chooser_get_type (This.Void_Ptr);
    begin
        pragma Assert (Ret in 0 .. Chooser_Kind'Pos (Chooser_Kind'Last));
        return Chooser_Kind'Val (Ret);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_File_Chooser::type returned unexpected int value of " &
        Interfaces.C.int'Image (Ret);
    end Get_Kind;


    procedure Set_Kind
           (This : in out File_Chooser;
            Kind : in     Chooser_Kind) is
    begin
        fl_file_chooser_set_type (This.Void_Ptr, Chooser_Kind'Pos (Kind));
    end Set_Kind;




    --  File Selection  --

    function Number_Selected
           (This : in File_Chooser)
        return Natural is
    begin
        return Natural (fl_file_chooser_count (This.Void_Ptr));
    end Number_Selected;


    function Get_Directory
           (This : in File_Chooser)
        return String
    is
        C_Ptr : constant Interfaces.C.Strings.chars_ptr :=
            fl_file_chooser_get_directory (This.Void_Ptr);
    begin
        if C_Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (C_Ptr);
        end if;
    end Get_Directory;


    procedure Set_Directory
           (This  : in out File_Chooser;
            Value : in     String)
    is
        use Interfaces.C;
        C_Arr : aliased char_array := To_C (Value);
    begin
        if Value = "" then
            fl_file_chooser_set_directory (This.Void_Ptr, Strings.Null_Ptr);
        else
            fl_file_chooser_set_directory
               (This.Void_Ptr,
                Strings.To_Chars_Ptr (C_Arr'Unchecked_Access));
        end if;
    end Set_Directory;


    function Get_Filter
           (This : in File_Chooser)
        return String
    is
        C_Ptr : constant Interfaces.C.Strings.chars_ptr :=
            fl_file_chooser_get_filter (This.Void_Ptr);
    begin
        if C_Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (C_Ptr);
        end if;
    end Get_Filter;


    procedure Set_Filter
           (This  : in out File_Chooser;
            Value : in     String)
    is
        use Interfaces.C;
        C_Arr : aliased char_array := To_C (Value);
    begin
        if Value = "" then
            fl_file_chooser_set_filter (This.Void_Ptr, Strings.Null_Ptr);
        else
            fl_file_chooser_set_filter
               (This.Void_Ptr,
                Strings.To_Chars_Ptr (C_Arr'Unchecked_Access));
        end if;
    end Set_Filter;


    function Get_Filter_Index
           (This : in File_Chooser)
        return Positive is
    begin
        return Positive (fl_file_chooser_get_filter_value (This.Void_Ptr) + 1);
    end Get_Filter_Index;


    procedure Set_Filter_Index
           (This  : in out File_Chooser;
            Value : in     Positive) is
    begin
        fl_file_chooser_set_filter_value (This.Void_Ptr, Interfaces.C.int (Value) - 1);
    end Set_Filter_Index;


    procedure Rescan
           (This : in out File_Chooser) is
    begin
        fl_file_chooser_rescan (This.Void_Ptr);
    end Rescan;


    procedure Rescan_Keep_Filename
           (This : in out File_Chooser) is
    begin
        fl_file_chooser_rescan_keep_filename (This.Void_Ptr);
    end Rescan_Keep_Filename;


    function Get_Selected
           (This  : in File_Chooser;
            Index : in Positive := 1)
        return String
    is
        C_Ptr : constant Interfaces.C.Strings.chars_ptr :=
            fl_file_chooser_get_value (This.Void_Ptr, Interfaces.C.int (Index));
    begin
        if C_Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (C_Ptr);
        end if;
    end Get_Selected;


    procedure Set_Selected
           (This  : in out File_Chooser;
            Value : in     String) is
    begin
        fl_file_chooser_set_value (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Selected;




    --  Visibility  --

    procedure Show
           (This : in out File_Chooser) is
    begin
        fl_file_chooser_show (This.Void_Ptr);
    end Show;


    procedure Hide
           (This : in out File_Chooser) is
    begin
        fl_file_chooser_hide (This.Void_Ptr);
    end Hide;


    function Is_Shown
           (This : in File_Chooser)
        return Boolean is
    begin
        return fl_file_chooser_shown (This.Void_Ptr) /= 0;
    end Is_Shown;


    function Is_Visible
           (This : in File_Chooser)
        return Boolean is
    begin
        return fl_file_chooser_visible (This.Void_Ptr) /= 0;
    end Is_Visible;


begin

    file_chooser_setup_sort_hook;

end FLTK.File_Choosers;


