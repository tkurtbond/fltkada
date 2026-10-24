

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Ada.Command_Line,
    Ada.Unchecked_Deallocation,
    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.GLUT is


    package ACom renames Ada.Command_Line;
    package IntC renames Interfaces.C;
    package ICS  renames Interfaces.C.Strings;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Initialisation  --

    procedure fl_glut_init
           (Argc : in out Interfaces.C.int;
            Argv : in     System.Address);
    pragma Import (C, fl_glut_init, "fl_glut_init");

    procedure fl_glut_init_display_mode
           (M : in Display_Mode);
    pragma Import (C, fl_glut_init_display_mode, "fl_glut_init_display_mode");
    pragma Inline (fl_glut_init_display_mode);

    procedure fl_glut_init_window_position
           (X, Y : in Interfaces.C.int);
    pragma Import (C, fl_glut_init_window_position, "fl_glut_init_window_position");
    pragma Inline (fl_glut_init_window_position);

    procedure fl_glut_init_window_size
           (W, H : in Interfaces.C.int);
    pragma Import (C, fl_glut_init_window_size, "fl_glut_init_window_size");
    pragma Inline (fl_glut_init_window_size);

    procedure fl_glut_main_loop;
    pragma Import (C, fl_glut_main_loop, "fl_glut_main_loop");
    pragma Inline (fl_glut_main_loop);




    --  Windows  --

    function fl_glut_create_window
           (T : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_create_window, "fl_glut_create_window");
    pragma Inline (fl_glut_create_window);

    function fl_glut_create_sub_window
           (Win, X, Y, W, H : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_create_sub_window, "fl_glut_create_sub_window");
    pragma Inline (fl_glut_create_sub_window);

    procedure fl_glut_destroy_window
           (Win : in Interfaces.C.int);
    pragma Import (C, fl_glut_destroy_window, "fl_glut_destroy_window");
    pragma Inline (fl_glut_destroy_window);

    procedure fl_glut_post_redisplay;
    pragma Import (C, fl_glut_post_redisplay, "fl_glut_post_redisplay");
    pragma Inline (fl_glut_post_redisplay);

    procedure fl_glut_post_window_redisplay
           (Win : in Interfaces.C.int);
    pragma Import (C, fl_glut_post_window_redisplay, "fl_glut_post_window_redisplay");
    pragma Inline (fl_glut_post_window_redisplay);

    procedure fl_glut_swap_buffers;
    pragma Import (C, fl_glut_swap_buffers, "fl_glut_swap_buffers");
    pragma Inline (fl_glut_swap_buffers);

    function fl_glut_get_window
        return Interfaces.C.int;
    pragma Import (C, fl_glut_get_window, "fl_glut_get_window");
    pragma Inline (fl_glut_get_window);

    procedure fl_glut_set_window
           (Win : in Interfaces.C.int);
    pragma Import (C, fl_glut_set_window, "fl_glut_set_window");
    pragma Inline (fl_glut_set_window);




    --  Current Window Operations  --

    procedure fl_glut_set_window_title
           (T : in Interfaces.C.char_array);
    pragma Import (C, fl_glut_set_window_title, "fl_glut_set_window_title");
    pragma Inline (fl_glut_set_window_title);

    procedure fl_glut_set_icon_title
           (T : in ICS.chars_ptr);
    pragma Import (C, fl_glut_set_icon_title, "fl_glut_set_icon_title");
    pragma Inline (fl_glut_set_icon_title);

    procedure fl_glut_position_window
           (X, Y : in Interfaces.C.int);
    pragma Import (C, fl_glut_position_window, "fl_glut_position_window");
    pragma Inline (fl_glut_position_window);

    procedure fl_glut_reshape_window
           (W, H : in Interfaces.C.int);
    pragma Import (C, fl_glut_reshape_window, "fl_glut_reshape_window");
    pragma Inline (fl_glut_reshape_window);

    procedure fl_glut_pop_window;
    pragma Import (C, fl_glut_pop_window, "fl_glut_pop_window");
    pragma Inline (fl_glut_pop_window);

    procedure fl_glut_push_window;
    pragma Import (C, fl_glut_push_window, "fl_glut_push_window");
    pragma Inline (fl_glut_push_window);

    procedure fl_glut_iconify_window;
    pragma Import (C, fl_glut_iconify_window, "fl_glut_iconify_window");
    pragma Inline (fl_glut_iconify_window);

    procedure fl_glut_show_window;
    pragma Import (C, fl_glut_show_window, "fl_glut_show_window");
    pragma Inline (fl_glut_show_window);

    procedure fl_glut_hide_window;
    pragma Import (C, fl_glut_hide_window, "fl_glut_hide_window");
    pragma Inline (fl_glut_hide_window);

    procedure fl_glut_full_screen;
    pragma Import (C, fl_glut_full_screen, "fl_glut_full_screen");
    pragma Inline (fl_glut_full_screen);

    procedure fl_glut_set_cursor
           (C : in Interfaces.C.int);
    pragma Import (C, fl_glut_set_cursor, "fl_glut_set_cursor");
    pragma Inline (fl_glut_set_cursor);

    procedure fl_glut_warp_pointer
           (X, Y : in Interfaces.C.int);
    pragma Import (C, fl_glut_warp_pointer, "fl_glut_warp_pointer");
    pragma Inline (fl_glut_warp_pointer);




    --  Overlays  --

    procedure fl_glut_establish_overlay;
    pragma Import (C, fl_glut_establish_overlay, "fl_glut_establish_overlay");
    pragma Inline (fl_glut_establish_overlay);

    procedure fl_glut_remove_overlay;
    pragma Import (C, fl_glut_remove_overlay, "fl_glut_remove_overlay");
    pragma Inline (fl_glut_remove_overlay);

    procedure fl_glut_use_layer
           (L : in Interfaces.C.unsigned);
    pragma Import (C, fl_glut_use_layer, "fl_glut_use_layer");
    pragma Inline (fl_glut_use_layer);

    procedure fl_glut_post_overlay_redisplay;
    pragma Import (C, fl_glut_post_overlay_redisplay, "fl_glut_post_overlay_redisplay");
    pragma Inline (fl_glut_post_overlay_redisplay);

    procedure fl_glut_show_overlay;
    pragma Import (C, fl_glut_show_overlay, "fl_glut_show_overlay");
    pragma Inline (fl_glut_show_overlay);

    procedure fl_glut_hide_overlay;
    pragma Import (C, fl_glut_hide_overlay, "fl_glut_hide_overlay");
    pragma Inline (fl_glut_hide_overlay);




    --  Menus  --

    function fl_glut_create_menu
           (F : in System.Address)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_create_menu, "fl_glut_create_menu");
    pragma Inline (fl_glut_create_menu);

    procedure fl_glut_destroy_menu
           (M : in Interfaces.C.int);
    pragma Import (C, fl_glut_destroy_menu, "fl_glut_destroy_menu");
    pragma Inline (fl_glut_destroy_menu);

    function fl_glut_get_menu
        return Interfaces.C.int;
    pragma Import (C, fl_glut_get_menu, "fl_glut_get_menu");
    pragma Inline (fl_glut_get_menu);

    procedure fl_glut_set_menu
           (M : in Interfaces.C.int);
    pragma Import (C, fl_glut_set_menu, "fl_glut_set_menu");
    pragma Inline (fl_glut_set_menu);

    procedure fl_glut_add_menu_entry
           (T : in ICS.chars_ptr;
            V : in Interfaces.C.int);
    pragma Import (C, fl_glut_add_menu_entry, "fl_glut_add_menu_entry");
    pragma Inline (fl_glut_add_menu_entry);

    procedure fl_glut_add_sub_menu
           (T : in ICS.chars_ptr;
            S : in Interfaces.C.int);
    pragma Import (C, fl_glut_add_sub_menu, "fl_glut_add_sub_menu");
    pragma Inline (fl_glut_add_sub_menu);

    procedure fl_glut_change_to_menu_entry
           (I : in Interfaces.C.int;
            T : in ICS.chars_ptr;
            V : in Interfaces.C.int);
    pragma Import (C, fl_glut_change_to_menu_entry, "fl_glut_change_to_menu_entry");
    pragma Inline (fl_glut_change_to_menu_entry);

    procedure fl_glut_change_to_sub_menu
           (I : in Interfaces.C.int;
            T : in ICS.chars_ptr;
            S : in Interfaces.C.int);
    pragma Import (C, fl_glut_change_to_sub_menu, "fl_glut_change_to_sub_menu");
    pragma Inline (fl_glut_change_to_sub_menu);

    procedure fl_glut_remove_menu_item
           (I : in Interfaces.C.int);
    pragma Import (C, fl_glut_remove_menu_item, "fl_glut_remove_menu_item");
    pragma Inline (fl_glut_remove_menu_item);

    procedure fl_glut_attach_menu
           (B : in Interfaces.C.int);
    pragma Import (C, fl_glut_attach_menu, "fl_glut_attach_menu");
    pragma Inline (fl_glut_attach_menu);

    procedure fl_glut_detach_menu
           (B : in Interfaces.C.int);
    pragma Import (C, fl_glut_detach_menu, "fl_glut_detach_menu");
    pragma Inline (fl_glut_detach_menu);




    --  Callbacks  --

    procedure fl_glut_display_func
           (F : in System.Address);
    pragma Import (C, fl_glut_display_func, "fl_glut_display_func");
    pragma Inline (fl_glut_display_func);

    procedure fl_glut_reshape_func
           (F : in System.Address);
    pragma Import (C, fl_glut_reshape_func, "fl_glut_reshape_func");
    pragma Inline (fl_glut_reshape_func);

    procedure fl_glut_keyboard_func
           (F : in System.Address);
    pragma Import (C, fl_glut_keyboard_func, "fl_glut_keyboard_func");
    pragma Inline (fl_glut_keyboard_func);

    procedure fl_glut_mouse_func
           (F : in System.Address);
    pragma Import (C, fl_glut_mouse_func, "fl_glut_mouse_func");
    pragma Inline (fl_glut_mouse_func);

    procedure fl_glut_motion_func
           (F : in System.Address);
    pragma Import (C, fl_glut_motion_func, "fl_glut_motion_func");
    pragma Inline (fl_glut_motion_func);

    procedure fl_glut_passive_motion_func
           (F : in System.Address);
    pragma Import (C, fl_glut_passive_motion_func, "fl_glut_passive_motion_func");
    pragma Inline (fl_glut_passive_motion_func);

    procedure fl_glut_entry_func
           (F : in System.Address);
    pragma Import (C, fl_glut_entry_func, "fl_glut_entry_func");
    pragma Inline (fl_glut_entry_func);

    procedure fl_glut_visibility_func
           (F : in System.Address);
    pragma Import (C, fl_glut_visibility_func, "fl_glut_visibility_func");
    pragma Inline (fl_glut_visibility_func);

    procedure fl_glut_special_func
           (F : in System.Address);
    pragma Import (C, fl_glut_special_func, "fl_glut_special_func");
    pragma Inline (fl_glut_special_func);

    procedure fl_glut_overlay_display_func
           (F : in System.Address);
    pragma Import (C, fl_glut_overlay_display_func, "fl_glut_overlay_display_func");
    pragma Inline (fl_glut_overlay_display_func);

    procedure fl_glut_idle_func
           (F : in System.Address);
    pragma Import (C, fl_glut_idle_func, "fl_glut_idle_func");
    pragma Inline (fl_glut_idle_func);

    procedure fl_glut_timer_func
           (M : in Interfaces.C.unsigned;
            F : in System.Address;
            D : in System.Address);
    pragma Import (C, fl_glut_timer_func, "fl_glut_timer_func");
    pragma Inline (fl_glut_timer_func);

    procedure fl_glut_menu_state_func
           (F : in System.Address);
    pragma Import (C, fl_glut_menu_state_func, "fl_glut_menu_state_func");
    pragma Inline (fl_glut_menu_state_func);

    procedure fl_glut_menu_status_func
           (F : in System.Address);
    pragma Import (C, fl_glut_menu_status_func, "fl_glut_menu_status_func");
    pragma Inline (fl_glut_menu_status_func);




    --  Queries  --

    function fl_glut_get
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_get, "fl_glut_get");
    pragma Inline (fl_glut_get);

    function fl_glut_device_get
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_device_get, "fl_glut_device_get");
    pragma Inline (fl_glut_device_get);

    function fl_glut_layer_get
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_layer_get, "fl_glut_layer_get");
    pragma Inline (fl_glut_layer_get);

    function fl_glut_get_modifiers
        return Interfaces.C.int;
    pragma Import (C, fl_glut_get_modifiers, "fl_glut_get_modifiers");
    pragma Inline (fl_glut_get_modifiers);

    function fl_glut_extension_supported
           (N : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_extension_supported, "fl_glut_extension_supported");
    pragma Inline (fl_glut_extension_supported);

    function fl_glut_get_proc_address
           (N : in Interfaces.C.char_array)
        return System.Address;
    pragma Import (C, fl_glut_get_proc_address, "fl_glut_get_proc_address");
    pragma Inline (fl_glut_get_proc_address);




    ----------------------
    --  Callback State  --
    ----------------------

    --  GLUT callbacks carry no user data, so the Ada access values are kept
    --  here, indexed by window or menu number, and found again by the hooks
    --  below from glutGetWindow / glutGetMenu, which FLTK sets before it
    --  calls back.

    type Window_Callbacks is record
        Display         : Display_Function;
        Reshape         : Reshape_Function;
        Keyboard        : Keyboard_Function;
        Mouse           : Mouse_Function;
        Motion          : Motion_Function;
        Passive_Motion  : Motion_Function;
        Entering        : Entry_Function;
        Visibility      : Visibility_Function;
        Special         : Special_Function;
        Overlay_Display : Display_Function;
    end record;

    Window_Table : array (Valid_Window_Number) of Window_Callbacks;

    Menu_Table : array (Valid_Menu_Number) of Menu_Function;

    Idle_Callback        : Idle_Function;
    Menu_State_Callback  : Menu_State_Function;
    Menu_Status_Callback : Menu_Status_Function;


    type Timer_Closure is record
        Func  : Timer_Function;
        Value : Integer;
    end record;

    type Timer_Closure_Access is access Timer_Closure;

    procedure Free is new Ada.Unchecked_Deallocation (Timer_Closure, Timer_Closure_Access);


    --  glutInit keeps pointers into argv, so it lives for the whole program
    type Argv_Access is access ICS.chars_ptr_array;

    The_Argv : Argv_Access;
    The_Argc : Interfaces.C.int;


    Cursor_Codes : constant array (Cursor_Kind) of Interfaces.C.int :=
       (Right_Arrow_Cursor         => 2,
        Left_Arrow_Cursor          => 67,
        Info_Cursor                => 31,
        Destroy_Cursor             => 45,
        Help_Cursor                => 47,
        Cycle_Cursor               => 26,
        Spray_Cursor               => 63,
        Wait_Cursor                => 76,
        Text_Cursor                => 77,
        Crosshair_Cursor           => 66,
        Up_Down_Cursor             => 78,
        Left_Right_Cursor          => 79,
        Top_Side_Cursor            => 70,
        Bottom_Side_Cursor         => 9,
        Left_Side_Cursor           => 36,
        Right_Side_Cursor          => 49,
        Top_Left_Corner_Cursor     => 68,
        Top_Right_Corner_Cursor    => 69,
        Bottom_Right_Corner_Cursor => 8,
        Bottom_Left_Corner_Cursor  => 7,
        Inherit_Cursor             => 0,
        None_Cursor                => 255,
        Full_Crosshair_Cursor      => 66);




    -------------
    --  Hooks  --
    -------------

    function Current_Window
        return Window_Number
    is
        Number : constant Interfaces.C.int := fl_glut_get_window;
    begin
        if Number in 1 .. Interfaces.C.int (Window_Number'Last) then
            return Window_Number (Number);
        else
            return No_Window;
        end if;
    end Current_Window;


    procedure Display_Hook;
    pragma Convention (C, Display_Hook);

    procedure Display_Hook
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Display /= null then
            Window_Table (Number).Display.all;
        end if;
    end Display_Hook;


    procedure Overlay_Display_Hook;
    pragma Convention (C, Overlay_Display_Hook);

    procedure Overlay_Display_Hook
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Overlay_Display /= null then
            Window_Table (Number).Overlay_Display.all;
        end if;
    end Overlay_Display_Hook;


    procedure Reshape_Hook
           (W, H : in Interfaces.C.int);
    pragma Convention (C, Reshape_Hook);

    procedure Reshape_Hook
           (W, H : in Interfaces.C.int)
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Reshape /= null then
            Window_Table (Number).Reshape (Integer (W), Integer (H));
        end if;
    end Reshape_Hook;


    procedure Keyboard_Hook
           (Key  : in Interfaces.C.unsigned_char;
            X, Y : in Interfaces.C.int);
    pragma Convention (C, Keyboard_Hook);

    procedure Keyboard_Hook
           (Key  : in Interfaces.C.unsigned_char;
            X, Y : in Interfaces.C.int)
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Keyboard /= null then
            Window_Table (Number).Keyboard
               (Character'Val (Key), Integer (X), Integer (Y));
        end if;
    end Keyboard_Hook;


    procedure Mouse_Hook
           (B, S, X, Y : in Interfaces.C.int);
    pragma Convention (C, Mouse_Hook);

    procedure Mouse_Hook
           (B, S, X, Y : in Interfaces.C.int)
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Mouse /= null
            and then B in 0 .. Mouse_Button_Index'Pos (Mouse_Button_Index'Last)
            and then S in 0 .. 1
        then
            Window_Table (Number).Mouse
               (Mouse_Button_Index'Val (B), Button_State'Val (S), Integer (X), Integer (Y));
        end if;
    end Mouse_Hook;


    procedure Motion_Hook
           (X, Y : in Interfaces.C.int);
    pragma Convention (C, Motion_Hook);

    procedure Motion_Hook
           (X, Y : in Interfaces.C.int)
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Motion /= null then
            Window_Table (Number).Motion (Integer (X), Integer (Y));
        end if;
    end Motion_Hook;


    procedure Passive_Motion_Hook
           (X, Y : in Interfaces.C.int);
    pragma Convention (C, Passive_Motion_Hook);

    procedure Passive_Motion_Hook
           (X, Y : in Interfaces.C.int)
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Passive_Motion /= null then
            Window_Table (Number).Passive_Motion (Integer (X), Integer (Y));
        end if;
    end Passive_Motion_Hook;


    procedure Entry_Hook
           (S : in Interfaces.C.int);
    pragma Convention (C, Entry_Hook);

    procedure Entry_Hook
           (S : in Interfaces.C.int)
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Entering /= null
            and then S in 0 .. 1
        then
            Window_Table (Number).Entering (Entry_State'Val (S));
        end if;
    end Entry_Hook;


    procedure Visibility_Hook
           (S : in Interfaces.C.int);
    pragma Convention (C, Visibility_Hook);

    procedure Visibility_Hook
           (S : in Interfaces.C.int)
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Visibility /= null
            and then S in 0 .. 1
        then
            Window_Table (Number).Visibility (Visibility_State'Val (S));
        end if;
    end Visibility_Hook;


    procedure Special_Hook
           (K, X, Y : in Interfaces.C.int);
    pragma Convention (C, Special_Hook);

    procedure Special_Hook
           (K, X, Y : in Interfaces.C.int)
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number /= No_Window and then Window_Table (Number).Special /= null then
            Window_Table (Number).Special (Special_Key (K), Integer (X), Integer (Y));
        end if;
    end Special_Hook;


    procedure Idle_Hook;
    pragma Convention (C, Idle_Hook);

    procedure Idle_Hook is
    begin
        if Idle_Callback /= null then
            Idle_Callback.all;
        end if;
    end Idle_Hook;


    procedure Timer_Hook
           (Data : in Timer_Closure_Access);
    pragma Convention (C, Timer_Hook);

    procedure Timer_Hook
           (Data : in Timer_Closure_Access)
    is
        Closure : Timer_Closure_Access := Data;
    begin
        Closure.Func (Closure.Value);
        Free (Closure);
    end Timer_Hook;


    procedure Menu_Hook
           (V : in Interfaces.C.int);
    pragma Convention (C, Menu_Hook);

    procedure Menu_Hook
           (V : in Interfaces.C.int)
    is
        Number : constant Interfaces.C.int := fl_glut_get_menu;
    begin
        if Number in 1 .. Interfaces.C.int (Menu_Number'Last)
            and then Menu_Table (Menu_Number (Number)) /= null
        then
            Menu_Table (Menu_Number (Number)) (Integer (V));
        end if;
    end Menu_Hook;


    procedure Menu_State_Hook
           (S : in Interfaces.C.int);
    pragma Convention (C, Menu_State_Hook);

    procedure Menu_State_Hook
           (S : in Interfaces.C.int) is
    begin
        if Menu_State_Callback /= null and then S in 0 .. 1 then
            Menu_State_Callback (Menu_State'Val (S));
        end if;
    end Menu_State_Hook;


    procedure Menu_Status_Hook
           (S, X, Y : in Interfaces.C.int);
    pragma Convention (C, Menu_Status_Hook);

    procedure Menu_Status_Hook
           (S, X, Y : in Interfaces.C.int) is
    begin
        if Menu_Status_Callback /= null and then S in 0 .. 1 then
            Menu_Status_Callback (Menu_State'Val (S), Integer (X), Integer (Y));
        end if;
    end Menu_Status_Hook;


    function Hook_Or_Null
           (Is_Set : in Boolean;
            Hook   : in System.Address)
        return System.Address is
    begin
        if Is_Set then
            return Hook;
        else
            return System.Null_Address;
        end if;
    end Hook_Or_Null;




    ----------------------
    --  Initialisation  --
    ----------------------

    procedure Init is
    begin
        The_Argv := new ICS.chars_ptr_array (0 .. IntC.size_t (ACom.Argument_Count) + 1);
        The_Argv (0) := ICS.New_String (ACom.Command_Name);
        for Index in Integer range 1 .. ACom.Argument_Count loop
            The_Argv (IntC.size_t (Index)) := ICS.New_String (ACom.Argument (Index));
        end loop;
        The_Argv (The_Argv'Last) := ICS.Null_Ptr;
        The_Argc := Interfaces.C.int (ACom.Argument_Count) + 1;
        fl_glut_init (The_Argc, The_Argv (The_Argv'First)'Address);
    end Init;


    procedure Init_Display_Mode
           (Mode : in Display_Mode) is
    begin
        fl_glut_init_display_mode (Mode);
    end Init_Display_Mode;


    procedure Init_Window_Position
           (X, Y : in Integer) is
    begin
        fl_glut_init_window_position (Interfaces.C.int (X), Interfaces.C.int (Y));
    end Init_Window_Position;


    procedure Init_Window_Size
           (W, H : in Integer) is
    begin
        fl_glut_init_window_size (Interfaces.C.int (W), Interfaces.C.int (H));
    end Init_Window_Size;


    procedure Main_Loop is
    begin
        fl_glut_main_loop;
    end Main_Loop;




    ---------------
    --  Windows  --
    ---------------

    procedure Reset_Callbacks
           (Number : in Valid_Window_Number) is
    begin
        Window_Table (Number) := (others => <>);
    end Reset_Callbacks;


    function Create_Window
           (Title : in String)
        return Valid_Window_Number
    is
        Number : constant Valid_Window_Number :=
            Valid_Window_Number (fl_glut_create_window (Interfaces.C.To_C (Title)));
    begin
        Reset_Callbacks (Number);
        return Number;
    end Create_Window;


    function Create_Sub_Window
           (Parent     : in Valid_Window_Number;
            X, Y, W, H : in Integer)
        return Valid_Window_Number
    is
        Number : constant Valid_Window_Number := Valid_Window_Number
           (fl_glut_create_sub_window
               (Interfaces.C.int (Parent),
                Interfaces.C.int (X), Interfaces.C.int (Y),
                Interfaces.C.int (W), Interfaces.C.int (H)));
    begin
        Reset_Callbacks (Number);
        return Number;
    end Create_Sub_Window;


    procedure Destroy_Window
           (Number : in Valid_Window_Number) is
    begin
        fl_glut_destroy_window (Interfaces.C.int (Number));
        Reset_Callbacks (Number);
    end Destroy_Window;


    procedure Post_Redisplay is
    begin
        fl_glut_post_redisplay;
    end Post_Redisplay;


    procedure Post_Window_Redisplay
           (Number : in Valid_Window_Number) is
    begin
        fl_glut_post_window_redisplay (Interfaces.C.int (Number));
    end Post_Window_Redisplay;


    procedure Swap_Buffers is
    begin
        fl_glut_swap_buffers;
    end Swap_Buffers;


    function Get_Window
        return Window_Number is
    begin
        return Current_Window;
    end Get_Window;


    procedure Set_Window
           (Number : in Valid_Window_Number) is
    begin
        fl_glut_set_window (Interfaces.C.int (Number));
    end Set_Window;




    ---------------------------------
    --  Current Window Operations  --
    ---------------------------------

    procedure Set_Window_Title
           (Text : in String) is
    begin
        fl_glut_set_window_title (Interfaces.C.To_C (Text));
    end Set_Window_Title;


    procedure Set_Icon_Title
           (Text : in String) is
    begin
        --  FLTK keeps the pointer, so this string is never freed
        fl_glut_set_icon_title (ICS.New_String (Text));
    end Set_Icon_Title;


    procedure Position_Window
           (X, Y : in Integer) is
    begin
        fl_glut_position_window (Interfaces.C.int (X), Interfaces.C.int (Y));
    end Position_Window;


    procedure Reshape_Window
           (W, H : in Integer) is
    begin
        fl_glut_reshape_window (Interfaces.C.int (W), Interfaces.C.int (H));
    end Reshape_Window;


    procedure Pop_Window is
    begin
        fl_glut_pop_window;
    end Pop_Window;


    procedure Push_Window is
    begin
        fl_glut_push_window;
    end Push_Window;


    procedure Iconify_Window is
    begin
        fl_glut_iconify_window;
    end Iconify_Window;


    procedure Show_Window is
    begin
        fl_glut_show_window;
    end Show_Window;


    procedure Hide_Window is
    begin
        fl_glut_hide_window;
    end Hide_Window;


    procedure Full_Screen is
    begin
        fl_glut_full_screen;
    end Full_Screen;


    procedure Set_Cursor
           (Kind : in Cursor_Kind) is
    begin
        fl_glut_set_cursor (Cursor_Codes (Kind));
    end Set_Cursor;


    procedure Warp_Pointer
           (X, Y : in Integer) is
    begin
        fl_glut_warp_pointer (Interfaces.C.int (X), Interfaces.C.int (Y));
    end Warp_Pointer;




    ----------------
    --  Overlays  --
    ----------------

    procedure Establish_Overlay is
    begin
        fl_glut_establish_overlay;
    end Establish_Overlay;


    procedure Remove_Overlay is
    begin
        fl_glut_remove_overlay;
    end Remove_Overlay;


    procedure Use_Layer
           (Layer : in Layer_Kind) is
    begin
        fl_glut_use_layer (Layer_Kind'Pos (Layer));
    end Use_Layer;


    procedure Post_Overlay_Redisplay is
    begin
        fl_glut_post_overlay_redisplay;
    end Post_Overlay_Redisplay;


    procedure Show_Overlay is
    begin
        fl_glut_show_overlay;
    end Show_Overlay;


    procedure Hide_Overlay is
    begin
        fl_glut_hide_overlay;
    end Hide_Overlay;




    -------------
    --  Menus  --
    -------------

    --  glutAddMenuEntry and friends keep the label pointer without copying
    --  it, so menu labels are allocated here and never freed.

    function Create_Menu
           (Func : in not null Menu_Function)
        return Valid_Menu_Number
    is
        Number : constant Valid_Menu_Number :=
            Valid_Menu_Number (fl_glut_create_menu (Menu_Hook'Address));
    begin
        Menu_Table (Number) := Func;
        return Number;
    end Create_Menu;


    procedure Destroy_Menu
           (Number : in Valid_Menu_Number) is
    begin
        fl_glut_destroy_menu (Interfaces.C.int (Number));
        Menu_Table (Number) := null;
    end Destroy_Menu;


    function Get_Menu
        return Menu_Number is
    begin
        return Menu_Number (fl_glut_get_menu);
    end Get_Menu;


    procedure Set_Menu
           (Number : in Valid_Menu_Number) is
    begin
        fl_glut_set_menu (Interfaces.C.int (Number));
    end Set_Menu;


    procedure Add_Menu_Entry
           (Label : in String;
            Value : in Integer) is
    begin
        fl_glut_add_menu_entry (ICS.New_String (Label), Interfaces.C.int (Value));
    end Add_Menu_Entry;


    procedure Add_Sub_Menu
           (Label   : in String;
            Submenu : in Valid_Menu_Number) is
    begin
        fl_glut_add_sub_menu (ICS.New_String (Label), Interfaces.C.int (Submenu));
    end Add_Sub_Menu;


    procedure Change_To_Menu_Entry
           (Item  : in Positive;
            Label : in String;
            Value : in Integer) is
    begin
        fl_glut_change_to_menu_entry
           (Interfaces.C.int (Item), ICS.New_String (Label), Interfaces.C.int (Value));
    end Change_To_Menu_Entry;


    procedure Change_To_Sub_Menu
           (Item    : in Positive;
            Label   : in String;
            Submenu : in Valid_Menu_Number) is
    begin
        fl_glut_change_to_sub_menu
           (Interfaces.C.int (Item), ICS.New_String (Label), Interfaces.C.int (Submenu));
    end Change_To_Sub_Menu;


    procedure Remove_Menu_Item
           (Item : in Positive) is
    begin
        fl_glut_remove_menu_item (Interfaces.C.int (Item));
    end Remove_Menu_Item;


    procedure Attach_Menu
           (Button : in Menu_Button) is
    begin
        fl_glut_attach_menu (Mouse_Button_Index'Pos (Button));
    end Attach_Menu;


    procedure Detach_Menu
           (Button : in Menu_Button) is
    begin
        fl_glut_detach_menu (Mouse_Button_Index'Pos (Button));
    end Detach_Menu;




    ----------------------------------------
    --  Callbacks For the Current Window  --
    ----------------------------------------

    function Current_Valid_Window
        return Valid_Window_Number
    is
        Number : constant Window_Number := Current_Window;
    begin
        if Number = No_Window then
            raise Program_Error with "no current GLUT window";
        end if;
        return Number;
    end Current_Valid_Window;


    procedure Display_Func
           (Func : in not null Display_Function) is
    begin
        Window_Table (Current_Valid_Window).Display := Func;
        fl_glut_display_func (Display_Hook'Address);
    end Display_Func;


    procedure Reshape_Func
           (Func : in not null Reshape_Function) is
    begin
        Window_Table (Current_Valid_Window).Reshape := Func;
        fl_glut_reshape_func (Reshape_Hook'Address);
    end Reshape_Func;


    procedure Keyboard_Func
           (Func : in Keyboard_Function) is
    begin
        Window_Table (Current_Valid_Window).Keyboard := Func;
        fl_glut_keyboard_func (Hook_Or_Null (Func /= null, Keyboard_Hook'Address));
    end Keyboard_Func;


    procedure Mouse_Func
           (Func : in Mouse_Function) is
    begin
        Window_Table (Current_Valid_Window).Mouse := Func;
        fl_glut_mouse_func (Hook_Or_Null (Func /= null, Mouse_Hook'Address));
    end Mouse_Func;


    procedure Motion_Func
           (Func : in Motion_Function) is
    begin
        Window_Table (Current_Valid_Window).Motion := Func;
        fl_glut_motion_func (Hook_Or_Null (Func /= null, Motion_Hook'Address));
    end Motion_Func;


    procedure Passive_Motion_Func
           (Func : in Motion_Function) is
    begin
        Window_Table (Current_Valid_Window).Passive_Motion := Func;
        fl_glut_passive_motion_func
           (Hook_Or_Null (Func /= null, Passive_Motion_Hook'Address));
    end Passive_Motion_Func;


    procedure Entry_Func
           (Func : in Entry_Function) is
    begin
        Window_Table (Current_Valid_Window).Entering := Func;
        fl_glut_entry_func (Hook_Or_Null (Func /= null, Entry_Hook'Address));
    end Entry_Func;


    procedure Visibility_Func
           (Func : in Visibility_Function) is
    begin
        Window_Table (Current_Valid_Window).Visibility := Func;
        fl_glut_visibility_func (Hook_Or_Null (Func /= null, Visibility_Hook'Address));
    end Visibility_Func;


    procedure Special_Func
           (Func : in Special_Function) is
    begin
        Window_Table (Current_Valid_Window).Special := Func;
        fl_glut_special_func (Hook_Or_Null (Func /= null, Special_Hook'Address));
    end Special_Func;


    procedure Overlay_Display_Func
           (Func : in not null Display_Function) is
    begin
        Window_Table (Current_Valid_Window).Overlay_Display := Func;
        fl_glut_overlay_display_func (Overlay_Display_Hook'Address);
    end Overlay_Display_Func;




    ------------------------
    --  Global Callbacks  --
    ------------------------

    procedure Idle_Func
           (Func : in Idle_Function) is
    begin
        Idle_Callback := Func;
        fl_glut_idle_func (Hook_Or_Null (Func /= null, Idle_Hook'Address));
    end Idle_Func;


    procedure Timer_Func
           (Milliseconds : in Natural;
            Func         : in not null Timer_Function;
            Value        : in Integer)
    is
        Closure : constant Timer_Closure_Access := new Timer_Closure'(Func, Value);
    begin
        fl_glut_timer_func
           (Interfaces.C.unsigned (Milliseconds), Timer_Hook'Address, Closure.all'Address);
    end Timer_Func;


    procedure Menu_State_Func
           (Func : in Menu_State_Function) is
    begin
        Menu_State_Callback := Func;
        fl_glut_menu_state_func (Hook_Or_Null (Func /= null, Menu_State_Hook'Address));
    end Menu_State_Func;


    procedure Menu_Status_Func
           (Func : in Menu_Status_Function) is
    begin
        Menu_Status_Callback := Func;
        fl_glut_menu_status_func (Hook_Or_Null (Func /= null, Menu_Status_Hook'Address));
    end Menu_Status_Func;




    ---------------------
    --  State Queries  --
    ---------------------

    function Get
           (Query : in State_Query)
        return Integer is
    begin
        return Integer (fl_glut_get (State_Query'Enum_Rep (Query)));
    end Get;


    function Device_Get
           (Query : in Device_Query)
        return Integer is
    begin
        return Integer (fl_glut_device_get (Device_Query'Enum_Rep (Query)));
    end Device_Get;


    function Layer_Get
           (Query : in Layer_Query)
        return Integer is
    begin
        return Integer (fl_glut_layer_get (Layer_Query'Enum_Rep (Query)));
    end Layer_Get;


    function Get_Modifiers
        return Modifier is
    begin
        --  glutGetModifiers returns the Fl::event_state() bits, which To_Ada
        --  shifts down into a Modifier
        return To_Ada (Interfaces.C.unsigned (fl_glut_get_modifiers));
    end Get_Modifiers;


    function Extension_Supported
           (Name : in String)
        return Boolean is
    begin
        return fl_glut_extension_supported (Interfaces.C.To_C (Name)) /= 0;
    end Extension_Supported;


    function Get_Proc_Address
           (Name : in String)
        return System.Address is
    begin
        return fl_glut_get_proc_address (Interfaces.C.To_C (Name));
    end Get_Proc_Address;


end FLTK.GLUT;


