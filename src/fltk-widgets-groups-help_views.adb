

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings,
    System.Address_To_Access_Conversions;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Help_Views is


    ------------------------
    --  Functions From C  --
    ------------------------

    procedure help_view_set_draw_hook
           (V, D : in Storage.Integer_Address);
    pragma Import (C, help_view_set_draw_hook, "help_view_set_draw_hook");
    pragma Inline (help_view_set_draw_hook);

    procedure help_view_set_handle_hook
           (V, H : in Storage.Integer_Address);
    pragma Import (C, help_view_set_handle_hook, "help_view_set_handle_hook");
    pragma Inline (help_view_set_handle_hook);




    function new_fl_help_view
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_help_view, "new_fl_help_view");
    pragma Inline (new_fl_help_view);

    procedure free_fl_help_view
           (V : in Storage.Integer_Address);
    pragma Import (C, free_fl_help_view, "free_fl_help_view");
    pragma Inline (free_fl_help_view);




    procedure fl_help_view_clear_selection
           (V : in Storage.Integer_Address);
    pragma Import (C, fl_help_view_clear_selection, "fl_help_view_clear_selection");
    pragma Inline (fl_help_view_clear_selection);

    procedure fl_help_view_select_all
           (V : in Storage.Integer_Address);
    pragma Import (C, fl_help_view_select_all, "fl_help_view_select_all");
    pragma Inline (fl_help_view_select_all);




    function fl_help_view_find
           (V : in Storage.Integer_Address;
            S : in Interfaces.C.char_array;
            P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_find, "fl_help_view_find");
    pragma Inline (fl_help_view_find);

    function fl_help_view_get_leftline
           (V : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_get_leftline, "fl_help_view_get_leftline");
    pragma Inline (fl_help_view_get_leftline);

    procedure fl_help_view_set_leftline
           (V : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_help_view_set_leftline, "fl_help_view_set_leftline");
    pragma Inline (fl_help_view_set_leftline);

    function fl_help_view_get_topline
           (V : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_get_topline, "fl_help_view_get_topline");
    pragma Inline (fl_help_view_get_topline);

    procedure fl_help_view_set_topline
           (V : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_help_view_set_topline, "fl_help_view_set_topline");
    pragma Inline (fl_help_view_set_topline);

    procedure fl_help_view_set_topline_target
           (V : in Storage.Integer_Address;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_help_view_set_topline_target, "fl_help_view_set_topline_target");
    pragma Inline (fl_help_view_set_topline_target);




    function fl_help_view_directory
           (V : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_help_view_directory, "fl_help_view_directory");
    pragma Inline (fl_help_view_directory);

    function fl_help_view_filename
           (V : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_help_view_filename, "fl_help_view_filename");
    pragma Inline (fl_help_view_filename);

    function fl_help_view_load
           (V : in Storage.Integer_Address;
            F : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_load, "fl_help_view_load");
    pragma Inline (fl_help_view_load);

    function fl_help_view_title
           (V : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_help_view_title, "fl_help_view_title");
    pragma Inline (fl_help_view_title);

    function fl_help_view_get_value
           (V : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_help_view_get_value, "fl_help_view_get_value");
    pragma Inline (fl_help_view_get_value);

    procedure fl_help_view_set_value
           (V : in Storage.Integer_Address;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_help_view_set_value, "fl_help_view_set_value");
    pragma Inline (fl_help_view_set_value);

    procedure fl_help_view_link
           (V, F : in Storage.Integer_Address);
    pragma Import (C, fl_help_view_link, "fl_help_view_link");
    pragma Inline (fl_help_view_link);




    function fl_help_view_get_scrollbar_size
           (V : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_get_scrollbar_size, "fl_help_view_get_scrollbar_size");
    pragma Inline (fl_help_view_get_scrollbar_size);

    procedure fl_help_view_set_scrollbar_size
           (V : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_help_view_set_scrollbar_size, "fl_help_view_set_scrollbar_size");
    pragma Inline (fl_help_view_set_scrollbar_size);

    function fl_help_view_get_size
           (V : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_get_size, "fl_help_view_get_size");
    pragma Inline (fl_help_view_get_size);

    procedure fl_help_view_set_size
           (V    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int);
    pragma Import (C, fl_help_view_set_size, "fl_help_view_set_size");
    pragma Inline (fl_help_view_set_size);

    function fl_help_view_get_textcolor
           (V : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_help_view_get_textcolor, "fl_help_view_get_textcolor");
    pragma Inline (fl_help_view_get_textcolor);

    procedure fl_help_view_set_textcolor
           (V : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_help_view_set_textcolor, "fl_help_view_set_textcolor");
    pragma Inline (fl_help_view_set_textcolor);

    function fl_help_view_get_textfont
           (V : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_get_textfont, "fl_help_view_get_textfont");
    pragma Inline (fl_help_view_get_textfont);

    procedure fl_help_view_set_textfont
           (V : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_help_view_set_textfont, "fl_help_view_set_textfont");
    pragma Inline (fl_help_view_set_textfont);

    function fl_help_view_get_textsize
           (V : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_get_textsize, "fl_help_view_get_textsize");
    pragma Inline (fl_help_view_get_textsize);

    procedure fl_help_view_set_textsize
           (V : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_help_view_set_textsize, "fl_help_view_set_textsize");
    pragma Inline (fl_help_view_set_textsize);




    procedure fl_help_view_draw
           (V : in Storage.Integer_Address);
    pragma Import (C, fl_help_view_draw, "fl_help_view_draw");
    pragma Inline (fl_help_view_draw);

    function fl_help_view_handle
           (V : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_help_view_handle, "fl_help_view_handle");
    pragma Inline (fl_help_view_handle);




    ----------------------
    --  Callback Hooks  --
    ----------------------

    package Help_View_Convert is new System.Address_To_Access_Conversions (Help_View'Class);

    function Link_Callback_Hook
           (V : in Storage.Integer_Address;
            S : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.Strings.chars_ptr;

    pragma Convention (C, Link_Callback_Hook);

    function Link_Callback_Hook
           (V : in Storage.Integer_Address;
            S : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.Strings.chars_ptr
    is
        Ada_Help_View : access Help_View'Class :=
            Help_View_Convert.To_Pointer (Storage.To_Address (fl_widget_get_user_data (V)));
    begin
        if Ada_Help_View.Zelda = null then
            return S;
        end if;
        Interfaces.C.Strings.Free (Ada_Help_View.Hilda);
        Ada_Help_View.Hilda := Interfaces.C.Strings.New_String
           (Ada_Help_View.Zelda (Ada_Help_View.all, Interfaces.C.Strings.Value (S)));
        if Interfaces.C.Strings.Value (Ada_Help_View.Hilda) = "" then
            return Interfaces.C.Strings.Null_Ptr;
        else
            return Ada_Help_View.Hilda;
        end if;
    end Link_Callback_Hook;




    -----------------------------------
    --  Controlled Type Subprograms  --
    -----------------------------------

    procedure Extra_Final
           (This : in out Help_View) is
    begin
        Interfaces.C.Strings.Free (This.Hilda);
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Help_View) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_help_view (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    ---------------------
    --  Help_View API  --
    ---------------------

    procedure Extra_Init
           (This       : in out Help_View;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Help_View is
        begin
            return This : Help_View do
                This.Void_Ptr := new_fl_help_view
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                help_view_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                help_view_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
                fl_help_view_link (This.Void_Ptr, Storage.To_Integer (Link_Callback_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Clear_Selection
           (This : in out Help_View) is
    begin
        fl_help_view_clear_selection (This.Void_Ptr);
    end Clear_Selection;


    procedure Select_All
           (This : in out Help_View) is
    begin
        fl_help_view_select_all (This.Void_Ptr);
    end Select_All;




    function Find
           (This : in Help_View;
            Item : in String;
            From : in Position := 1)
        return Extended_Position is
    begin
        return Extended_Position (fl_help_view_find
           (This.Void_Ptr,
            Interfaces.C.To_C (Item),
            Interfaces.C.int (From) - 1) + 1);
    end Find;


    function Get_Leftline_Pixel
           (This : in Help_View)
        return Natural is
    begin
        return Natural (fl_help_view_get_leftline (This.Void_Ptr));
    end Get_Leftline_Pixel;


    procedure Set_Leftline_Pixel
           (This  : in out Help_View;
            Value : in     Natural) is
    begin
        fl_help_view_set_leftline (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Leftline_Pixel;


    function Get_Topline_Pixel
           (This : in Help_View)
        return Natural is
    begin
        return Natural (fl_help_view_get_topline (This.Void_Ptr));
    end Get_Topline_Pixel;


    procedure Set_Topline_Pixel
           (This  : in out Help_View;
            Value : in     Natural) is
    begin
        fl_help_view_set_topline (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Topline_Pixel;


    procedure Set_Topline_Target
           (This  : in out Help_View;
            Value : in     String) is
    begin
        fl_help_view_set_topline_target (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Topline_Target;




    function Current_Directory
           (This : in Help_View)
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_help_view_directory (This.Void_Ptr));
    end Current_Directory;


    function Current_File
           (This : in Help_View)
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_help_view_filename (This.Void_Ptr));
    end Current_File;


    procedure Load
           (This : in out Help_View;
            Name : in     String)
    is
        Code : Interfaces.C.int := fl_help_view_load (This.Void_Ptr, Interfaces.C.To_C (Name));
    begin
        if Code = -1 then
            raise Load_Help_Error;
        elsif Code /= 0 then
            raise Internal_FLTK_Error;
        end if;
    end Load;


    function Document_Title
           (This : in Help_View)
        return String
    is
        Raw_Chars : Interfaces.C.Strings.chars_ptr := fl_help_view_title (This.Void_Ptr);
        use type Interfaces.C.Strings.chars_ptr;
    begin
        if Raw_Chars = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Raw_Chars);
        end if;
    end Document_Title;


    function Get_Content
           (This : in Help_View)
        return String
    is
        Raw_Chars : Interfaces.C.Strings.chars_ptr := fl_help_view_get_value (This.Void_Ptr);
        use type Interfaces.C.Strings.chars_ptr;
    begin
        if Raw_Chars = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Raw_Chars);
        end if;
    end Get_Content;


    procedure Set_Content
           (This  : in out Help_View;
            Value : in     String) is
    begin
        fl_help_view_set_value (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Content;


    procedure Set_Link_Callback
           (This : in out Help_View;
            Func : in     Link_Callback) is
    begin
        This.Zelda := Func;
    end Set_Link_Callback;




    function Get_Scrollbar_Size
           (This : in Help_View)
        return Natural is
    begin
        return Natural (fl_help_view_get_scrollbar_size (This.Void_Ptr));
    end Get_Scrollbar_Size;


    procedure Set_Scrollbar_Size
           (This  : in out Help_View;
            Value : in     Natural) is
    begin
        fl_help_view_set_scrollbar_size (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Scrollbar_Size;


    function Get_Size
           (This : in Help_View)
        return Integer is
    begin
        return Integer (fl_help_view_get_size (This.Void_Ptr));
    end Get_Size;


    procedure Resize
           (This : in out Help_View;
            W, H : in     Integer) is
    begin
        fl_help_view_set_size
           (This.Void_Ptr,
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


    function Get_Text_Color
           (This : in Help_View)
        return Color is
    begin
        return Color (fl_help_view_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This  : in out Help_View;
            Value : in     Color) is
    begin
        fl_help_view_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Help_View)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_help_view_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Help_View;
            Font : in     Font_Kind) is
    begin
        fl_help_view_set_textfont (This.Void_Ptr, Font_Kind'Pos (Font));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Help_View)
        return Font_Size is
    begin
        return Font_Size (fl_help_view_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Help_View;
            Size : in     Font_Size) is
    begin
        fl_help_view_set_textsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    procedure Draw
           (This : in out Help_View) is
    begin
        fl_help_view_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Help_View;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
           (fl_help_view_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Groups.Help_Views;


