

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Containers.Vectors,
    FLTK.Box_Draw_Marshal,
    FLTK.Hook_Exceptions,
    FLTK.Label_Draw_Marshal,
    Interfaces.C.Strings,
    System.Address_To_Access_Conversions,
    FLTK.Static_Callback_Conversions;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Static is


    package Chk  renames Ada.Assertions;
    package Conv renames FLTK.Static_Callback_Conversions;




    -----------------
    --  Operators  --
    -----------------

    type File_Mode_Bitmask is mod 2 ** Interfaces.C.int'Size;

    function FMode_To_Bits is new
        Ada.Unchecked_Conversion (File_Mode, File_Mode_Bitmask);

    function Bits_To_FMode is new
        Ada.Unchecked_Conversion (File_Mode_Bitmask, File_Mode);


    function "+"
           (Left, Right : in File_Mode)
        return File_Mode is
    begin
        return Bits_To_FMode (FMode_To_Bits (Left) or FMode_To_Bits (Right));
    end "+";


    function "-"
           (Left, Right : in File_Mode)
        return File_Mode is
    begin
        return Bits_To_FMode (FMode_To_Bits (Left) and not FMode_To_Bits (Right));
    end "-";




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Command Line Arguments  --

    function fl_static_arg
           (C : in     Interfaces.C.int;
            V : in     Storage.Integer_Address;
            I : in out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_arg, "fl_static_arg");
    pragma Inline (fl_static_arg);

    procedure fl_static_args
           (C : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_static_args, "fl_static_args");
    pragma Inline (fl_static_args);

    function fl_static_args2
           (C : in     Interfaces.C.int;
            V : in     Storage.Integer_Address;
            I : in out Interfaces.C.int;
            H : in     Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_args2, "fl_static_args2");
    pragma Inline (fl_static_args2);




    --  Thread Notify  --

    function fl_static_add_awake_handler
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_add_awake_handler, "fl_static_add_awake_handler");
    pragma Inline (fl_static_add_awake_handler);

    function fl_static_get_awake_handler
           (H, F : out Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_awake_handler, "fl_static_get_awake_handler");
    pragma Inline (fl_static_get_awake_handler);

    function fl_static_awake2
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_awake2, "fl_static_awake2");
    pragma Inline (fl_static_awake2);

    procedure fl_static_awake
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_static_awake, "fl_static_awake");
    pragma Inline (fl_static_awake);




    --  Pre-Eventloop Callbacks  --

    procedure fl_static_add_check
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_check, "fl_static_add_check");
    pragma Inline (fl_static_add_check);

    function fl_static_has_check
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_has_check, "fl_static_has_check");
    pragma Inline (fl_static_has_check);

    procedure fl_static_remove_check
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_remove_check, "fl_static_remove_check");
    pragma Inline (fl_static_remove_check);




    --  Timer Callbacks  --

    procedure fl_static_add_timeout
           (S    : in Interfaces.C.double;
            H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_timeout, "fl_static_add_timeout");
    pragma Inline (fl_static_add_timeout);

    function fl_static_has_timeout
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_has_timeout, "fl_static_has_timeout");
    pragma Inline (fl_static_has_timeout);

    procedure fl_static_remove_timeout
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_remove_timeout, "fl_static_remove_timeout");
    pragma Inline (fl_static_remove_timeout);

    procedure fl_static_repeat_timeout
           (S    : in Interfaces.C.double;
            H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_repeat_timeout, "fl_static_repeat_timeout");
    pragma Inline (fl_static_repeat_timeout);




    --  Clipboard Callbacks  --

    procedure fl_static_add_clipboard_notify
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_clipboard_notify, "fl_static_add_clipboard_notify");
    pragma Inline (fl_static_add_clipboard_notify);

    procedure fl_static_remove_clipboard_notify
           (H : in Storage.Integer_Address);
    pragma Import (C, fl_static_remove_clipboard_notify, "fl_static_remove_clipboard_notify");
    pragma Inline (fl_static_remove_clipboard_notify);




    --  File Descriptor Waiting Callbacks  --

    procedure fl_static_add_fd
           (D    : in Interfaces.C.int;
            H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_fd, "fl_static_add_fd");
    pragma Inline (fl_static_add_fd);

    procedure fl_static_add_fd2
           (D, M : in Interfaces.C.int;
            H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_fd2, "fl_static_add_fd2");
    pragma Inline (fl_static_add_fd2);

    procedure fl_static_remove_fd
           (D : in Interfaces.C.int);
    pragma Import (C, fl_static_remove_fd, "fl_static_remove_fd");
    pragma Inline (fl_static_remove_fd);

    procedure fl_static_remove_fd2
           (D, M : in Interfaces.C.int);
    pragma Import (C, fl_static_remove_fd2, "fl_static_remove_fd2");
    pragma Inline (fl_static_remove_fd2);




    --  Idle Callbacks  --

    procedure fl_static_add_idle
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_idle, "fl_static_add_idle");
    pragma Inline (fl_static_add_idle);

    function fl_static_has_idle
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_has_idle, "fl_static_has_idle");
    pragma Inline (fl_static_has_idle);

    procedure fl_static_remove_idle
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_remove_idle, "fl_static_remove_idle");
    pragma Inline (fl_static_remove_idle);




    --  Custom Colors  --

    function fl_static_get_color2
           (C : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_static_get_color2, "fl_static_get_color2");
    pragma Inline (fl_static_get_color2);

    procedure fl_static_get_color
           (C       : in     Interfaces.C.unsigned;
            R, G, B :    out Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_get_color, "fl_static_get_color");
    pragma Inline (fl_static_get_color);

    procedure fl_static_set_color2
           (T, F : in Interfaces.C.unsigned);
    pragma Import (C, fl_static_set_color2, "fl_static_set_color2");
    pragma Inline (fl_static_set_color2);

    procedure fl_static_set_color
           (C       : in Interfaces.C.unsigned;
            R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_set_color, "fl_static_set_color");
    pragma Inline (fl_static_set_color);

    procedure fl_static_free_color
           (C : in Interfaces.C.unsigned;
            B : in Interfaces.C.int);
    pragma Import (C, fl_static_free_color, "fl_static_free_color");
    pragma Inline (fl_static_free_color);

    function fl_static_get_box_color
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_static_get_box_color, "fl_static_get_box_color");
    pragma Inline (fl_static_get_box_color);

    procedure fl_static_set_box_color
           (T : in Interfaces.C.unsigned);
    pragma Import (C, fl_static_set_box_color, "fl_static_set_box_color");
    pragma Inline (fl_static_set_box_color);

    procedure fl_static_foreground
           (R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_foreground, "fl_static_foreground");
    pragma Inline (fl_static_foreground);

    procedure fl_static_background
           (R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_background, "fl_static_background");
    pragma Inline (fl_static_background);

    procedure fl_static_background2
           (R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_background2, "fl_static_background2");
    pragma Inline (fl_static_background2);

    procedure fl_static_get_color3
           (C          : in     Interfaces.C.unsigned;
            R, G, B, A :    out Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_get_color3, "fl_static_get_color3");
    pragma Inline (fl_static_get_color3);

    procedure fl_static_set_color3
           (C          : in Interfaces.C.unsigned;
            R, G, B, A : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_set_color3, "fl_static_set_color3");
    pragma Inline (fl_static_set_color3);




    --  Custom Fonts  --

    function fl_static_get_font
           (K : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_static_get_font, "fl_static_get_font");
    pragma Inline (fl_static_get_font);

    function fl_static_get_font_name
           (K : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_static_get_font_name, "fl_static_get_font_name");
    pragma Inline (fl_static_get_font_name);

    procedure fl_static_set_font2
           (T : in Interfaces.C.int;
            S : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_static_set_font2, "fl_static_set_font2");
    pragma Inline (fl_static_set_font2);

    function fl_static_get_font_sizes
           (F : in     Interfaces.C.int;
            A :    out Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_font_sizes, "fl_static_get_font_sizes");
    pragma Inline (fl_static_get_font_sizes);

    function fl_static_font_size_array_get
           (A : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_font_size_array_get, "fl_static_font_size_array_get");
    pragma Inline (fl_static_font_size_array_get);

    function fl_static_set_fonts
        return Interfaces.C.int;
    pragma Import (C, fl_static_set_fonts, "fl_static_set_fonts");
    pragma Inline (fl_static_set_fonts);




    --  Box_Kind Attributes  --

    function fl_static_box_dh
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_box_dh, "fl_static_box_dh");
    pragma Inline (fl_static_box_dh);

    function fl_static_box_dw
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_box_dw, "fl_static_box_dw");
    pragma Inline (fl_static_box_dw);

    function fl_static_box_dx
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_box_dx, "fl_static_box_dx");
    pragma Inline (fl_static_box_dx);

    function fl_static_box_dy
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_box_dy, "fl_static_box_dy");
    pragma Inline (fl_static_box_dy);

    function fl_static_get_boxtype
           (T : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_static_get_boxtype, "fl_static_get_boxtype");
    pragma Inline (fl_static_get_boxtype);

    procedure fl_static_set_boxtype
           (T, F : in Interfaces.C.int);
    pragma Import (C, fl_static_set_boxtype, "fl_static_set_boxtype");
    pragma Inline (fl_static_set_boxtype);

    procedure fl_static_set_boxtype2
           (T              : in Interfaces.C.int;
            F              : in Storage.Integer_Address;
            DX, DY, DW, DH : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_set_boxtype2, "fl_static_set_boxtype2");
    pragma Inline (fl_static_set_boxtype2);

    function fl_static_draw_box_active
        return Interfaces.C.int;
    pragma Import (C, fl_static_draw_box_active, "fl_static_draw_box_active");
    pragma Inline (fl_static_draw_box_active);




    --  Label_Kind Attributes  --

    procedure fl_static_set_labeltype
           (K    : in Interfaces.C.int;
            D, M : in Storage.Integer_Address);
    pragma Import (C, fl_static_set_labeltype, "fl_static_set_labeltype");
    pragma Inline (fl_static_set_labeltype);




    --  Clipboard / Selection  --

    procedure fl_static_copy
           (T    : in Interfaces.C.char_array;
            L, K : in Interfaces.C.int);
    pragma Import (C, fl_static_copy, "fl_static_copy");
    pragma Inline (fl_static_copy);

    procedure fl_static_paste
           (R : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_static_paste, "fl_static_paste");
    pragma Inline (fl_static_paste);

    procedure fl_static_selection
           (O : in Storage.Integer_Address;
            T : in Interfaces.C.char_array;
            L : in Interfaces.C.int);
    pragma Import (C, fl_static_selection, "fl_static_selection");
    pragma Inline (fl_static_selection);

    function fl_static_clipboard_contains
           (K : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_static_clipboard_contains, "fl_static_clipboard_contains");
    pragma Inline (fl_static_clipboard_contains);




    --  Dragon Drop  --

    function fl_static_dnd
        return Interfaces.C.int;
    pragma Import (C, fl_static_dnd, "fl_static_dnd");
    pragma Inline (fl_static_dnd);

    function fl_static_get_dnd_text_ops
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_dnd_text_ops, "fl_static_get_dnd_text_ops");
    pragma Inline (fl_static_get_dnd_text_ops);

    procedure fl_static_set_dnd_text_ops
           (T : in Interfaces.C.int);
    pragma Import (C, fl_static_set_dnd_text_ops, "fl_static_set_dnd_text_ops");
    pragma Inline (fl_static_set_dnd_text_ops);




    --  Windows  --

    procedure fl_static_default_atclose
           (W, U : in Storage.Integer_Address);
    pragma Import (C, fl_static_default_atclose, "fl_static_default_atclose");
    pragma Inline (fl_static_default_atclose);

    function fl_static_get_first_window
        return Storage.Integer_Address;
    pragma Import (C, fl_static_get_first_window, "fl_static_get_first_window");
    pragma Inline (fl_static_get_first_window);

    procedure fl_static_set_first_window
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_static_set_first_window, "fl_static_set_first_window");
    pragma Inline (fl_static_set_first_window);

    function fl_static_next_window
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_static_next_window, "fl_static_next_window");
    pragma Inline (fl_static_next_window);

    function fl_static_modal
        return Storage.Integer_Address;
    pragma Import (C, fl_static_modal, "fl_static_modal");
    pragma Inline (fl_static_modal);




    --  Queue  --

    function fl_static_readqueue
        return Storage.Integer_Address;
    pragma Import (C, fl_static_readqueue, "fl_static_readqueue");
    pragma Inline (fl_static_readqueue);




    --  Schemes  --

    function fl_static_get_scheme
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_static_get_scheme, "fl_static_get_scheme");
    pragma Inline (fl_static_get_scheme);

    procedure fl_static_set_scheme
           (S : in Interfaces.C.char_array);
    pragma Import (C, fl_static_set_scheme, "fl_static_set_scheme");
    pragma Inline (fl_static_set_scheme);

    function fl_static_is_scheme
           (S : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_static_is_scheme, "fl_static_is_scheme");
    pragma Inline (fl_static_is_scheme);




    --  Library Options  --

    function fl_static_get_option
           (O : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_option, "fl_static_get_option");
    pragma Inline (fl_static_get_option);

    procedure fl_static_set_option
           (O, T : in Interfaces.C.int);
    pragma Import (C, fl_static_set_option, "fl_static_set_option");
    pragma Inline (fl_static_set_option);

    function fl_static_get_use_high_res_gl
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_use_high_res_gl, "fl_static_get_use_high_res_gl");
    pragma Inline (fl_static_get_use_high_res_gl);

    procedure fl_static_set_use_high_res_gl
           (V : in Interfaces.C.int);
    pragma Import (C, fl_static_set_use_high_res_gl, "fl_static_set_use_high_res_gl");
    pragma Inline (fl_static_set_use_high_res_gl);




    --  Scrollbars  --

    function fl_static_get_scrollbar_size
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_scrollbar_size, "fl_static_get_scrollbar_size");
    pragma Inline (fl_static_get_scrollbar_size);

    procedure fl_static_set_scrollbar_size
           (S : in Interfaces.C.int);
    pragma Import (C, fl_static_set_scrollbar_size, "fl_static_set_scrollbar_size");
    pragma Inline (fl_static_set_scrollbar_size);




    --  User Data  --

    package Widget_Convert is new System.Address_To_Access_Conversions
        (FLTK.Widgets.Widget'Class);
    package Window_Convert is new System.Address_To_Access_Conversions
        (FLTK.Widgets.Groups.Windows.Window'Class);

    function fl_widget_get_user_data
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_get_user_data, "fl_widget_get_user_data");




    ----------------------
    --  Callback Hooks  --
    ----------------------

    Current_Args_Handler : Args_Handler;

    function Args_Hook
           (C : in     Interfaces.C.int;
            V : in     Storage.Integer_Address;
            I : in out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Convention (C, Args_Hook);

    function Args_Hook
           (C : in     Interfaces.C.int;
            V : in     Storage.Integer_Address;
            I : in out Interfaces.C.int)
        return Interfaces.C.int
    is
        Result : Natural;
    begin
        pragma Assert (I < C and V /= Null_Pointer);
        Result := Current_Args_Handler (Positive (I));
        I := I + Interfaces.C.int (Result);
        return Interfaces.C.int (Result);
    exception
    when Constraint_Error =>
        Hook_Exceptions.Save_New
           (Internal_FLTK_Error'Identity,
            "Args_Handler callback was supplied unexpected int i value of " &
            Interfaces.C.int'Image (I));
        return 0;
    when Chk.Assertion_Error =>
        Hook_Exceptions.Save_New
           (Internal_FLTK_Error'Identity,
            "Args_Handler callback was supplied irregular argc and argv values of " &
            Interfaces.C.int'Image (C) & " and " & Storage.Integer_Address'Image (V));
        return 0;
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
        return 0;
    end Args_Hook;


    procedure Awake_Hook
           (U : in Storage.Integer_Address);
    pragma Convention (C, Awake_Hook);

    procedure Awake_Hook
           (U : in Storage.Integer_Address) is
    begin
        if U /= Null_Pointer then
            Conv.To_Awake_Access (U).all;
        end if;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Awake_Hook;


    procedure Timeout_Hook
           (U : in Storage.Integer_Address);
    pragma Convention (C, Timeout_Hook);

    procedure Timeout_Hook
           (U : in Storage.Integer_Address) is
    begin
        Conv.To_Timeout_Access (U).all;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Timeout_Hook;


    --  This is handled on the Ada side because otherwise there would be
    --  no way to specify which callback to remove in FLTK once one was
    --  added. This is because Fl::remove_clipboard_notify does not pay
    --  attention to the void * data. This hook is passed to FLTK only while
    --  at least one handler is registered, since on X11 without XFixes FLTK
    --  polls the clipboard owner twice a second for as long as any notify
    --  handler exists.
    package Clipboard_Notify_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Clipboard_Notify_Handler);

    Current_Clip_Notes : Clipboard_Notify_Vectors.Vector;

    procedure Clipboard_Notify_Hook
           (S : in Interfaces.C.int;
            U : in Storage.Integer_Address);
    pragma Convention (C, Clipboard_Notify_Hook);

    procedure Clipboard_Notify_Hook
           (S : in Interfaces.C.int;
            U : in Storage.Integer_Address) is
    begin
        pragma Assert (S in
            Buffer_Kind'Pos (Buffer_Kind'First) .. Buffer_Kind'Pos (Buffer_Kind'Last));
        for Call of Current_Clip_Notes loop
            Call.all (Buffer_Kind'Val (S));
        end loop;
    exception
    when Chk.Assertion_Error =>
        Hook_Exceptions.Save_New
           (Internal_FLTK_Error'Identity,
            "Clipboard_Notify_Hook was passed unexpected Buffer_Kind int value of " &
            Interfaces.C.int'Image (S));
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Clipboard_Notify_Hook;


    procedure FD_Hook
           (FD : in Interfaces.C.int;
            U  : in Storage.Integer_Address);
    pragma Convention (C, FD_Hook);

    procedure FD_Hook
           (FD : in Interfaces.C.int;
            U  : in Storage.Integer_Address) is
    begin
        Conv.To_File_Access (U).all (File_Descriptor (FD));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end FD_Hook;


    procedure Idle_Hook
           (U : in Storage.Integer_Address);
    pragma Convention (C, Idle_Hook);

    procedure Idle_Hook
           (U : in Storage.Integer_Address) is
    begin
        Conv.To_Idle_Access (U).all;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Idle_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out FLTK_Static_Final_Controller) is
    begin
        FLTK.Args_Marshal.Free_Argv (The_Argv);
        for Override of Font_Overrides loop
            Interfaces.C.Strings.Free (Override);
        end loop;
        if not Current_Clip_Notes.Is_Empty then
            fl_static_remove_clipboard_notify (Storage.To_Integer (Clipboard_Notify_Hook'Address));
        end if;
    end Finalize;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Command Line Arguments  --

    function Parse_Arg
           (Index : in Positive)
        return Natural
    is
        Count : Interfaces.C.int := Interfaces.C.int (Index);
    begin
        return Natural (fl_static_arg
           (The_Argv'Length,
            Storage.To_Integer (The_Argv (The_Argv'First)'Address),
            Count));
    end Parse_Arg;


    procedure Parse_Args is
    begin
        fl_static_args (The_Argv'Length, Storage.To_Integer (The_Argv (The_Argv'First)'Address));
    end Parse_Args;


    procedure Parse_Args
           (Count :    out Natural;
            Func  : in     Args_Handler := null)
    is
        My_Count : Interfaces.C.int := 1;
        Result   : Interfaces.C.int;
    begin
        Current_Args_Handler := Func;
        Result := fl_static_args2
           (The_Argv'Length,
            Storage.To_Integer (The_Argv (The_Argv'First)'Address),
            My_Count,
            (if Func = null then Null_Pointer else Storage.To_Integer (Args_Hook'Address)));
        Count := Integer (My_Count) - 1;
        if Result = 0 then
            raise Argument_Error with
                "Fl::args could not recognise switch at argument number " &
                Interfaces.C.int'Image (My_Count);
        else
            pragma Assert (Result > 0);
        end if;
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::args produced unexpected i parameter of " & Interfaces.C.int'Image (My_Count);
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl::args returned unexpected int value of " & Interfaces.C.int'Image (Result);
    end Parse_Args;




    --  Thread Notify  --

    procedure Add_Awake_Handler
           (Func : in Awake_Handler)
    is
        Result : constant Interfaces.C.int := fl_static_add_awake_handler
           (Storage.To_Integer (Awake_Hook'Address),
            Conv.To_Address (Func));
    begin
        pragma Assert (Result = 0);
    exception
    when Chk.Assertion_Error =>
        if Result = -1 then
            raise Tasking_Error with
                "Fl::add_awake_handler_ failed to register Awake_Handler callback";
        else
            raise Internal_FLTK_Error with
                "Fl::add_awake_handler_ returned unexpected int value of " &
                Interfaces.C.int'Image (Result);
        end if;
    end Add_Awake_Handler;


    function Get_Awake_Handler
        return Awake_Handler
    is
        Hook, Func : Storage.Integer_Address;
        Result : constant Interfaces.C.int := fl_static_get_awake_handler (Hook, Func);
    begin
        pragma Assert (Result = 0);
        return Conv.To_Awake_Access (Func);
    exception
    when Chk.Assertion_Error =>
        if Result = -1 then
            raise Tasking_Error with
                "Fl::get_awake_handler_ invoked without prior awake setup";
        else
            raise Internal_FLTK_Error with
                "Fl::get_awake_handler_ returned unexpected int value of " &
                Interfaces.C.int'Image (Result);
        end if;
    end Get_Awake_Handler;


    procedure Awake
           (Func : in Awake_Handler)
    is
        Result : constant Interfaces.C.int := fl_static_awake2
           (Storage.To_Integer (Awake_Hook'Address),
            Conv.To_Address (Func));
    begin
        pragma Assert (Result = 0);
    exception
    when Chk.Assertion_Error =>
        if Result = -1 then
            raise Tasking_Error with "Fl::awake failed to register Awake_Handler callback";
        else
            raise Internal_FLTK_Error with "Fl::awake returned unexpected int value of " &
                Interfaces.C.int'Image (Result);
        end if;
    end Awake;


    procedure Awake is
    begin
        fl_static_awake (Null_Pointer);
    end Awake;




    --  Pre-Eventloop Callbacks  --

    procedure Add_Check
           (Func : in not null Timeout_Handler) is
    begin
        fl_static_add_check
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Add_Check;


    function Has_Check
           (Func : in not null Timeout_Handler)
        return Boolean is
    begin
        return fl_static_has_check
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func))) /= 0;
    end Has_Check;


    procedure Remove_Check
           (Func : in not null Timeout_Handler) is
    begin
        fl_static_remove_check
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Remove_Check;




    --  Timer Callbacks  --

    procedure Add_Timeout
           (Seconds : in          Long_Float;
            Func    : in not null Timeout_Handler) is
    begin
        fl_static_add_timeout
           (Interfaces.C.double (Seconds),
            Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Add_Timeout;


    function Has_Timeout
           (Func : in not null Timeout_Handler)
        return Boolean is
    begin
        return fl_static_has_timeout
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func))) /= 0;
    end Has_Timeout;


    procedure Remove_Timeout
           (Func : in not null Timeout_Handler) is
    begin
        fl_static_remove_timeout
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Remove_Timeout;


    procedure Repeat_Timeout
           (Seconds : in          Long_Float;
            Func    : in not null Timeout_Handler) is
    begin
        fl_static_repeat_timeout
           (Interfaces.C.double (Seconds),
            Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Repeat_Timeout;




    --  Clipboard Callbacks  --

    procedure Add_Clipboard_Notify
           (Func : in not null Clipboard_Notify_Handler) is
    begin
        if Current_Clip_Notes.Is_Empty then
            fl_static_add_clipboard_notify
                (Storage.To_Integer (Clipboard_Notify_Hook'Address), Null_Pointer);
        end if;
        Current_Clip_Notes.Append (Func);
    end Add_Clipboard_Notify;


    procedure Remove_Clipboard_Notify
           (Func : in not null Clipboard_Notify_Handler) is
    begin
        for Index in reverse Current_Clip_Notes.First_Index .. Current_Clip_Notes.Last_Index loop
            if Current_Clip_Notes (Index) = Func then
                Current_Clip_Notes.Delete (Index);
                if Current_Clip_Notes.Is_Empty then
                    fl_static_remove_clipboard_notify
                        (Storage.To_Integer (Clipboard_Notify_Hook'Address));
                end if;
                return;
            end if;
        end loop;
    end Remove_Clipboard_Notify;




    --  File Descriptor Waiting Callbacks  --

    procedure Add_File_Descriptor
           (FD   : in          File_Descriptor;
            Func : in not null File_Handler) is
    begin
        fl_static_add_fd
           (Interfaces.C.int (FD),
            Storage.To_Integer (FD_Hook'Address),
            Conv.To_Address (Func));
    end Add_File_Descriptor;


    procedure Add_File_Descriptor
           (FD   : in          File_Descriptor;
            Mode : in          File_Mode;
            Func : in not null File_Handler) is
    begin
        fl_static_add_fd2
           (Interfaces.C.int (FD),
            FMode_To_Cint (Mode),
            Storage.To_Integer (FD_Hook'Address),
            Conv.To_Address (Func));
    end Add_File_Descriptor;


    procedure Remove_File_Descriptor
           (FD : in File_Descriptor) is
    begin
        fl_static_remove_fd (Interfaces.C.int (FD));
    end Remove_File_Descriptor;


    procedure Remove_File_Descriptor
           (FD   : in File_Descriptor;
            Mode : in File_Mode) is
    begin
        fl_static_remove_fd2 (Interfaces.C.int (FD), FMode_To_Cint (Mode));
    end Remove_File_Descriptor;




    --  Idle Callbacks  --

    procedure Add_Idle
           (Func : in not null Idle_Handler) is
    begin
        fl_static_add_idle
           (Storage.To_Integer (Idle_Hook'Address),
            Conv.To_Address (Idle_Handler'(Func)));
    end Add_Idle;


    function Has_Idle
           (Func : in not null Idle_Handler)
        return Boolean is
    begin
        return fl_static_has_idle
           (Storage.To_Integer (Idle_Hook'Address),
            Conv.To_Address (Idle_Handler'(Func))) /= 0;
    end Has_Idle;


    procedure Remove_Idle
           (Func : in not null Idle_Handler) is
    begin
        fl_static_remove_idle
           (Storage.To_Integer (Idle_Hook'Address),
            Conv.To_Address (Idle_Handler'(Func)));
    end Remove_Idle;




    --  Custom Colors  --

    function Get_Color
           (From : in Color)
        return Color is
    begin
        return Color (fl_static_get_color2 (Interfaces.C.unsigned (From)));
    end Get_Color;


    procedure Get_Color
           (From    : in     Color;
            R, G, B :    out Color_Component) is
    begin
        fl_static_get_color
           (Interfaces.C.unsigned (From),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Get_Color;


    procedure Set_Color
           (Target, Source : in Color) is
    begin
        fl_static_set_color2
           (Interfaces.C.unsigned (Target),
            Interfaces.C.unsigned (Source));
    end Set_Color;


    procedure Set_Color
           (Target  : in Color;
            R, G, B : in Color_Component) is
    begin
        fl_static_set_color
           (Interfaces.C.unsigned (Target),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Color;


    procedure Free_Color
           (Value   : in Color;
            Overlay : in Boolean := False) is
    begin
        fl_static_free_color
           (Interfaces.C.unsigned (Value),
            Boolean'Pos (Overlay));
    end Free_Color;


    function Get_Box_Color
           (Tone : in Color)
        return Color is
    begin
        return Color (fl_static_get_box_color (Interfaces.C.unsigned (Tone)));
    end Get_Box_Color;


    procedure Set_Box_Color
           (Tone : in Color) is
    begin
        fl_static_set_box_color (Interfaces.C.unsigned (Tone));
    end Set_Box_Color;


    procedure Set_Foreground
           (R, G, B : in Color_Component) is
    begin
        fl_static_foreground
           (Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Foreground;


    procedure Set_Background
           (R, G, B : in Color_Component) is
    begin
        fl_static_background
           (Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Background;


    procedure Set_Alt_Background
           (R, G, B : in Color_Component) is
    begin
        fl_static_background2
           (Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Alt_Background;


    procedure Get_Color
           (From       : in     Color;
            R, G, B, A :    out Color_Component) is
    begin
        fl_static_get_color3
           (Interfaces.C.unsigned (From),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B),
            Interfaces.C.unsigned_char (A));
    end Get_Color;


    procedure Set_Color
           (Target     : in Color;
            R, G, B, A : in Color_Component) is
    begin
        fl_static_set_color3
           (Interfaces.C.unsigned (Target),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B),
            Interfaces.C.unsigned_char (A));
    end Set_Color;




    --  Custom Fonts  --

    function Font_Image
           (Kind : in Font_Kind)
        return String is
    begin
        --  The shim gives "" for an empty slot, never null.
        return Interfaces.C.Strings.Value (fl_static_get_font (Font_Kind'Pos (Kind)));
    end Font_Image;


    function Font_Family_Image
           (Kind : in Font_Kind)
        return String is
    begin
        --  The shim gives "" for an empty slot, never null.
        return Interfaces.C.Strings.Value (fl_static_get_font_name (Font_Kind'Pos (Kind)));
    end Font_Family_Image;


    --  FLTK keeps the name pointer, and compares the next name with it
    --  (Fl_Cairo_Graphics_Driver.cxx:1158), so the old copy is freed only
    --  after FLTK holds the new one.  Copying a kind would share the
    --  source's pointer (fl_set_font.cxx:71), which a later change of the
    --  source frees, so the target gets its own copy of the name instead.

    procedure Set_Font_Kind
           (Target, Source : in Font_Kind) is
    begin
        Set_Font_Kind (Target, Font_Image (Source));
    end Set_Font_Kind;


    --  FLTK copies a name into fontname[128], and keeps its last byte for
    --  the font's type (Fl_Cairo_Graphics_Driver.cxx:1176-1182), so a name
    --  is cut to 126 bytes, before a UTF-8 character that would cross that
    --  (pofltk 130).
    Longest_Font_Name : constant := 126;

    procedure Set_Font_Kind
           (Target : in Font_Kind;
            Source : in String)
    is
        Old  : Interfaces.C.Strings.chars_ptr := Font_Overrides (Target);
        Last : Natural := Source'Last;
    begin
        if Source'Length > Longest_Font_Name then
            Last := Source'First + Longest_Font_Name - 1;
            while Last >= Source'First
                and then Character'Pos (Source (Last + 1)) in 16#80# .. 16#BF#
            loop
                Last := Last - 1;
            end loop;
        end if;
        Font_Overrides (Target) := Interfaces.C.Strings.New_String
            (Source (Source'First .. Last));
        fl_static_set_font2 (Font_Kind'Pos (Target), Font_Overrides (Target));
        Interfaces.C.Strings.Free (Old);
    end Set_Font_Kind;


    function Font_Sizes
           (Kind : in Font_Kind)
        return Font_Size_Array
    is
        Ptr : Storage.Integer_Address;
        Arr : Font_Size_Array
            (1 .. Integer (fl_static_get_font_sizes (Font_Kind'Pos (Kind), Ptr)));
    begin
        --  This array copying avoids any worry that the static buffer will be overwritten.
        for I in 1 .. Arr'Length loop
            Arr (I) := Font_Size (fl_static_font_size_array_get (Ptr, Interfaces.C.int (I)));
        end loop;
        return Arr;
    end Font_Sizes;


    procedure Setup_Fonts
           (How_Many_Set_Up : out Natural)
    is
        Result : constant Interfaces.C.int := fl_static_set_fonts;
    begin
        How_Many_Set_Up := Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::set_fonts returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Setup_Fonts;




    --  Box_Kind Attributes  --

    function Get_Box_Height_Offset
           (Kind : in Box_Kind)
        return Integer is
    begin
        return Integer (fl_static_box_dh (Box_Kind'Pos (Kind)));
    end Get_Box_Height_Offset;


    function Get_Box_Width_Offset
           (Kind : in Box_Kind)
        return Integer is
    begin
        return Integer (fl_static_box_dw (Box_Kind'Pos (Kind)));
    end Get_Box_Width_Offset;


    function Get_Box_X_Offset
           (Kind : in Box_Kind)
        return Integer is
    begin
        return Integer (fl_static_box_dx (Box_Kind'Pos (Kind)));
    end Get_Box_X_Offset;


    function Get_Box_Y_Offset
           (Kind : in Box_Kind)
        return Integer is
    begin
        return Integer (fl_static_box_dy (Box_Kind'Pos (Kind)));
    end Get_Box_Y_Offset;


    procedure Set_Box_Kind
           (To, From : in Box_Kind) is
    begin
        fl_static_set_boxtype (Box_Kind'Pos (To), Box_Kind'Pos (From));
    end Set_Box_Kind;


    function Draw_Box_Active
        return Boolean is
    begin
        return fl_static_draw_box_active /= 0;
    end Draw_Box_Active;


    function Get_Box_Draw_Function
           (Kind : in Box_Kind)
        return Box_Draw_Function is
    begin
        return FLTK.Box_Draw_Marshal.To_Ada (Kind, fl_static_get_boxtype (Box_Kind'Pos (Kind)));
    end Get_Box_Draw_Function;


    procedure Set_Box_Draw_Function
           (Kind               : in Box_Kind;
            Func               : in Box_Draw_Function;
            Offset_X, Offset_Y : in Byte_Integer := 0;
            Offset_W, Offset_H : in Byte_Integer := 0) is
    begin
        fl_static_set_boxtype2
           (Box_Kind'Pos (Kind),
            FLTK.Box_Draw_Marshal.To_C (Kind, Func),
            Interfaces.C.unsigned_char (Offset_X),
            Interfaces.C.unsigned_char (Offset_Y),
            Interfaces.C.unsigned_char (Offset_W),
            Interfaces.C.unsigned_char (Offset_H));
    end Set_Box_Draw_Function;




    --  Label_Kind Attributes  --

    procedure Set_Label_Kind
           (Target, Source : in Label_Kind) is
    begin
        --  As of FLTK 1.3.11 there is no definition given for this function
        --  so this is null to avoid linker errors.
        null;
    end Set_Label_Kind;


    procedure Set_Label_Draw_Function
           (Kind         : in Label_Kind;
            Draw_Func    : in Label_Draw_Function;
            Measure_Func : in Label_Measure_Function) is
    begin
        fl_static_set_labeltype
           (Label_Kind'Pos (Kind),
            FLTK.Label_Draw_Marshal.To_C (Kind, Draw_Func),
            FLTK.Label_Draw_Marshal.To_C (Kind, Measure_Func));
    end Set_Label_Draw_Function;




    --  Clipboard / Selection  --

    procedure Copy
           (Text : in String;
            Dest : in Buffer_Kind) is
    begin
        fl_static_copy
           (Interfaces.C.To_C (Text),
            Text'Length,
            Buffer_Kind'Pos (Dest));
    end Copy;


    procedure Paste
           (Receiver : in FLTK.Widgets.Widget'Class;
            Source   : in Buffer_Kind) is
    begin
        fl_static_paste
           (Wrapper (Receiver).Void_Ptr,
            Buffer_Kind'Pos (Source));
    end Paste;


    procedure Selection
           (Owner : in FLTK.Widgets.Widget'Class;
            Text  : in String) is
    begin
        fl_static_selection
           (Wrapper (Owner).Void_Ptr,
            Interfaces.C.To_C (Text),
            Text'Length);
    end Selection;


    function Clipboard_Contains
           (Kind : in String)
        return Boolean is
    begin
        return fl_static_clipboard_contains (Interfaces.C.To_C (Kind)) /= 0;
    end Clipboard_Contains;




    --  Dragon Drop  --

    procedure Drag_Drop_Start is
        Ignore : Interfaces.C.int := fl_static_dnd;
    begin
        null;
    end Drag_Drop_Start;


    function Get_Drag_Drop_Text_Support
        return Boolean is
    begin
        return fl_static_get_dnd_text_ops /= 0;
    end Get_Drag_Drop_Text_Support;


    procedure Set_Drag_Drop_Text_Support
           (To : in Boolean) is
    begin
        fl_static_set_dnd_text_ops (Boolean'Pos (To));
    end Set_Drag_Drop_Text_Support;




    --  Windows  --

    procedure Default_Window_Close
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        pragma Assert (Wrapper (Item).Void_Ptr /= Null_Pointer);
        fl_static_default_atclose
           (Wrapper (Item).Void_Ptr,
            fl_widget_get_user_data (Wrapper (Item).Void_Ptr));
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl::default_atclose received uninitialised widget";
    end Default_Window_Close;


    function Get_First_Window
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        First_Ptr : Storage.Integer_Address := fl_static_get_first_window;
        Actual_First : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        if First_Ptr /= Null_Pointer then
            First_Ptr := fl_widget_get_user_data (First_Ptr);
            pragma Assert (First_Ptr /= Null_Pointer);
            Actual_First := Window_Convert.To_Pointer (Storage.To_Address (First_Ptr));
        end if;
        return Actual_First;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::first_window did not have user_data reference back to Ada";
    end Get_First_Window;


    procedure Set_First_Window
           (To : in FLTK.Widgets.Groups.Windows.Window'Class) is
    begin
        fl_static_set_first_window (Wrapper (To).Void_Ptr);
    end Set_First_Window;


    function Get_Next_Window
           (From : in FLTK.Widgets.Groups.Windows.Window'Class)
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        Next_Ptr : Storage.Integer_Address := fl_static_next_window (Wrapper (From).Void_Ptr);
        Actual_Next : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        if Next_Ptr /= Null_Pointer then
            Next_Ptr := fl_widget_get_user_data (Next_Ptr);
            pragma Assert (Next_Ptr /= Null_Pointer);
            Actual_Next := Window_Convert.To_Pointer (Storage.To_Address (Next_Ptr));
        end if;
        return Actual_Next;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::next_window did not have user_data reference back to Ada";
    end Get_Next_Window;


    function Get_Top_Modal
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        Modal_Ptr : Storage.Integer_Address := fl_static_modal;
        Actual_Modal : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        if Modal_Ptr /= Null_Pointer then
            Modal_Ptr := fl_widget_get_user_data (Modal_Ptr);
            pragma Assert (Modal_Ptr /= Null_Pointer);
            Actual_Modal := Window_Convert.To_Pointer (Storage.To_Address (Modal_Ptr));
        end if;
        return Actual_Modal;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::modal did not have user_data reference back to Ada";
    end Get_Top_Modal;




    --  Queue  --

    function Read_Queue
        return access FLTK.Widgets.Widget'Class
    is
        Queue_Ptr : Storage.Integer_Address := fl_static_readqueue;
        Actual_Queue : access FLTK.Widgets.Widget'Class;
    begin
        if Queue_Ptr /= Null_Pointer then
            Queue_Ptr := fl_widget_get_user_data (Queue_Ptr);
            pragma Assert (Queue_Ptr /= Null_Pointer);
            Actual_Queue := Widget_Convert.To_Pointer (Storage.To_Address (Queue_Ptr));
        end if;
        return Actual_Queue;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::readqueue did not have user_data reference back to Ada";
    end Read_Queue;




    --  Schemes  --

    function Get_Scheme
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_static_get_scheme;
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Scheme;


    procedure Set_Scheme
           (To : in String) is
    begin
        --  A copy of the Scheme string is stored in FLTK
        fl_static_set_scheme (Interfaces.C.To_C (To));
    end Set_Scheme;


    function Is_Scheme
           (Scheme : in String)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_static_is_scheme (Interfaces.C.To_C (Scheme));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::is_scheme returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Is_Scheme;




    --  Library Options  --

    function Get_Option
           (Opt : in Option)
        return Boolean is
    begin
        return fl_static_get_option (Option'Pos (Opt)) /= 0;
    end Get_Option;


    procedure Set_Option
           (Opt : in Option;
            To  : in Boolean) is
    begin
        fl_static_set_option (Option'Pos (Opt), Boolean'Pos (To));
    end Set_Option;


    function Get_Use_High_Res_GL
        return Boolean is
    begin
        return fl_static_get_use_high_res_gl /= 0;
    end Get_Use_High_Res_GL;


    procedure Set_Use_High_Res_GL
           (To : in Boolean) is
    begin
        fl_static_set_use_high_res_gl (Boolean'Pos (To));
    end Set_Use_High_Res_GL;




    --  Scrollbars  --

    function Get_Default_Scrollbar_Size
        return Natural
    is
        Result : constant Interfaces.C.int := fl_static_get_scrollbar_size;
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::scrollbar_size returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Default_Scrollbar_Size;


    procedure Set_Default_Scrollbar_Size
           (To : in Natural) is
    begin
        fl_static_set_scrollbar_size (Interfaces.C.int (To));
    end Set_Default_Scrollbar_Size;


end FLTK.Static;


