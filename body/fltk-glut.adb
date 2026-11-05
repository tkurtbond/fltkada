

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Ada.Command_Line,
    Ada.Containers.Vectors,
    Ada.Finalization,
    Ada.Unchecked_Deallocation,
    FLTK.Hook_Exceptions,
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

    function fl_glut_destroy_window
           (Win : in Interfaces.C.int)
        return Interfaces.C.int;
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

    function fl_glut_window_alive
           (Win : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_window_alive, "fl_glut_window_alive");
    pragma Inline (fl_glut_window_alive);

    function fl_glut_window_ada
           (Win : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_window_ada, "fl_glut_window_ada");
    pragma Inline (fl_glut_window_ada);

    function fl_glut_has_room
        return Interfaces.C.int;
    pragma Import (C, fl_glut_has_room, "fl_glut_has_room");
    pragma Inline (fl_glut_has_room);

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
           (T : in Interfaces.C.char_array);
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

    function fl_glut_establish_overlay
        return Interfaces.C.int;
    pragma Import (C, fl_glut_establish_overlay, "fl_glut_establish_overlay");
    pragma Inline (fl_glut_establish_overlay);

    procedure fl_glut_remove_overlay;
    pragma Import (C, fl_glut_remove_overlay, "fl_glut_remove_overlay");
    pragma Inline (fl_glut_remove_overlay);

    function fl_glut_use_layer
           (L : in Interfaces.C.unsigned)
        return Interfaces.C.int;
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

    function fl_glut_menu_exists
           (Menu : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_menu_exists, "fl_glut_menu_exists");
    pragma Inline (fl_glut_menu_exists);

    function fl_glut_menu_room
        return Interfaces.C.int;
    pragma Import (C, fl_glut_menu_room, "fl_glut_menu_room");
    pragma Inline (fl_glut_menu_room);

    function fl_glut_menu_items
           (Menu : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_menu_items, "fl_glut_menu_items");
    pragma Inline (fl_glut_menu_items);

    function fl_glut_menu_used
           (Menu : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_menu_used, "fl_glut_menu_used");
    pragma Inline (fl_glut_menu_used);

    function fl_glut_get_menu
        return Interfaces.C.int;
    pragma Import (C, fl_glut_get_menu, "fl_glut_get_menu");
    pragma Inline (fl_glut_get_menu);

    procedure fl_glut_set_menu
           (M : in Interfaces.C.int);
    pragma Import (C, fl_glut_set_menu, "fl_glut_set_menu");
    pragma Inline (fl_glut_set_menu);

    procedure fl_glut_add_menu_entry
           (T : in Interfaces.C.char_array;
            V : in Interfaces.C.int);
    pragma Import (C, fl_glut_add_menu_entry, "fl_glut_add_menu_entry");
    pragma Inline (fl_glut_add_menu_entry);

    procedure fl_glut_add_sub_menu
           (T : in Interfaces.C.char_array;
            S : in Interfaces.C.int);
    pragma Import (C, fl_glut_add_sub_menu, "fl_glut_add_sub_menu");
    pragma Inline (fl_glut_add_sub_menu);

    procedure fl_glut_change_to_menu_entry
           (I : in Interfaces.C.int;
            T : in Interfaces.C.char_array;
            V : in Interfaces.C.int);
    pragma Import (C, fl_glut_change_to_menu_entry, "fl_glut_change_to_menu_entry");
    pragma Inline (fl_glut_change_to_menu_entry);

    procedure fl_glut_change_to_sub_menu
           (I : in Interfaces.C.int;
            T : in Interfaces.C.char_array;
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



    --  Fonts  --

    function fl_gl_ready
        return Interfaces.C.int;
    pragma Import (C, fl_gl_ready, "fl_gl_ready");
    pragma Inline (fl_gl_ready);

    procedure fl_glut_bitmap_draw
           (F : in Interfaces.C.int;
            S : in System.Address;
            N : in Interfaces.C.int);
    pragma Import (C, fl_glut_bitmap_draw, "fl_glut_bitmap_draw");
    pragma Inline (fl_glut_bitmap_draw);

    function fl_glut_bitmap_width
           (F, C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_bitmap_width, "fl_glut_bitmap_width");
    pragma Inline (fl_glut_bitmap_width);

    function fl_glut_bitmap_length
           (F : in Interfaces.C.int;
            S : in System.Address;
            N : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_bitmap_length, "fl_glut_bitmap_length");
    pragma Inline (fl_glut_bitmap_length);

    function fl_glut_bitmap_height
           (F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_bitmap_height, "fl_glut_bitmap_height");
    pragma Inline (fl_glut_bitmap_height);

    procedure fl_glut_stroke_character
           (F, C : in Interfaces.C.int);
    pragma Import (C, fl_glut_stroke_character, "fl_glut_stroke_character");
    pragma Inline (fl_glut_stroke_character);

    procedure fl_glut_stroke_string
           (F : in Interfaces.C.int;
            S : in System.Address;
            N : in Interfaces.C.int);
    pragma Import (C, fl_glut_stroke_string, "fl_glut_stroke_string");
    pragma Inline (fl_glut_stroke_string);

    function fl_glut_stroke_width
           (F, C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_stroke_width, "fl_glut_stroke_width");
    pragma Inline (fl_glut_stroke_width);

    function fl_glut_stroke_length
           (F : in Interfaces.C.int;
            S : in System.Address;
            N : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_stroke_length, "fl_glut_stroke_length");
    pragma Inline (fl_glut_stroke_length);

    function fl_glut_stroke_height
           (F : in Interfaces.C.int)
        return Interfaces.C.C_float;
    pragma Import (C, fl_glut_stroke_height, "fl_glut_stroke_height");
    pragma Inline (fl_glut_stroke_height);




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


    --  glutInit keeps pointers to argv's strings (initargv,
    --  glut_compatibility.cxx:204-206), so they live for the whole program
    type Argv_Access is access ICS.chars_ptr_array;

    procedure Free is new Ada.Unchecked_Deallocation (ICS.chars_ptr_array, Argv_Access);

    The_Argv : Argv_Access;
    The_Argc : Interfaces.C.int;


    --  GLUT keeps the texts of menu items (i->text = label,
    --  glut_compatibility.cxx:350, 358, 367, 376) and a window's icon title
    --  (iconlabel_ = mininame, Fl_Window.cxx:545) without copying them.  The
    --  shim keeps the copies (FLTKAda-BUGS.md 37, pofltk 112).

    package Text_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => ICS.chars_ptr,
        "="          => ICS."=");

    --  Every argv string Init has made.  glutInit takes FLTK's options out
    --  of argv (:207-211), so The_Argv no longer holds them all.
    Argv_Texts : Text_Vectors.Vector;


    --  Frees the texts at exit.  It is declared after them, so it is
    --  finalized before the vectors are.
    type Text_Final_Controller is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out Text_Final_Controller);

    Text_Cleanup : Text_Final_Controller;


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
    --  Texts  --
    -------------

    procedure Free_All
           (Texts : in out Text_Vectors.Vector) is
    begin
        for Text of Texts loop
            ICS.Free (Text);
        end loop;
        Texts.Clear;
    end Free_All;


    overriding procedure Finalize
           (This : in out Text_Final_Controller)
    is
        pragma Unreferenced (This);
    begin
        Free_All (Argv_Texts);
        Free (The_Argv);
    end Finalize;


    function Current_Menu
        return Menu_Number is
    begin
        return Menu_Number (fl_glut_get_menu);
    end Current_Menu;


    --  pofltk 112: GLUT follows a window or menu number without a look, so
    --  these check it first.

    procedure Check_Window
           (Number : in Valid_Window_Number) is
    begin
        if fl_glut_window_alive (Interfaces.C.int (Number)) = 0 then
            raise Constraint_Error with "no GLUT window" & Window_Number'Image (Number);
        end if;
    end Check_Window;


    --  The 32nd window would get the 31st's number (glut_compatibility.cxx:168).
    procedure Check_Window_Room is
    begin
        if fl_glut_has_room = 0 then
            raise Unsupported_Error with "GLUT has no window numbers left";
        end if;
    end Check_Window_Room;


    procedure Check_Menu
           (Number : in Menu_Number) is
    begin
        if fl_glut_menu_exists (Interfaces.C.int (Number)) = 0 then
            raise Constraint_Error with "no GLUT menu" & Menu_Number'Image (Number);
        end if;
    end Check_Menu;


    function Items_Of
           (Number : in Valid_Menu_Number)
        return Natural is
    begin
        return Natural (fl_glut_menu_items (Interfaces.C.int (Number)));
    end Items_Of;


    function Current_Valid_Menu
        return Valid_Menu_Number
    is
        Number : constant Menu_Number := Current_Menu;
    begin
        if Number = No_Menu then
            raise Program_Error with "no current GLUT menu";
        end if;
        return Number;
    end Current_Valid_Menu;


    --  A submenu item points at its submenu's array of items
    --  (glut_compatibility.cxx:359), which adding to the submenu, removing
    --  from it or destroying it frees.  Nor can a menu used as a submenu
    --  take a submenu, so that no menu is its own submenu, however deep.
    procedure Check_Unused
           (Number : in Valid_Menu_Number;
            Doing  : in String) is
    begin
        if fl_glut_menu_used (Interfaces.C.int (Number)) /= 0 then
            raise Program_Error with Doing & " a GLUT menu used as a submenu";
        end if;
    end Check_Unused;


    procedure Check_Submenu
           (Menu, Submenu : in Valid_Menu_Number) is
    begin
        Check_Menu (Submenu);
        if Submenu = Menu then
            raise Program_Error with "a GLUT menu as its own submenu";
        elsif Items_Of (Submenu) = 0 then
            --  An empty menu has no array, so the item would point at null
            raise Program_Error with "an empty GLUT menu as a submenu";
        end if;
    end Check_Submenu;


    procedure Check_Item
           (Menu : in Valid_Menu_Number;
            Item : in Positive) is
    begin
        if Item > Items_Of (Menu) then
            raise Constraint_Error with "GLUT menu" & Menu_Number'Image (Menu)
                & " has no item" & Integer'Image (Item);
        end if;
    end Check_Item;




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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Special_Hook;


    procedure Idle_Hook;
    pragma Convention (C, Idle_Hook);

    procedure Idle_Hook is
    begin
        if Idle_Callback /= null then
            Idle_Callback.all;
        end if;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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
        --  glutInit keeps the strings, not the array
        Free (The_Argv);
        The_Argv := new ICS.chars_ptr_array (0 .. IntC.size_t (ACom.Argument_Count) + 1);
        The_Argv (0) := ICS.New_String (ACom.Command_Name);
        for Index in Integer range 1 .. ACom.Argument_Count loop
            The_Argv (IntC.size_t (Index)) := ICS.New_String (ACom.Argument (Index));
        end loop;
        The_Argv (The_Argv'Last) := ICS.Null_Ptr;
        for Index in The_Argv'First .. The_Argv'Last - 1 loop
            Argv_Texts.Append (The_Argv (Index));
        end loop;
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
        Number : Valid_Window_Number;
    begin
        Check_Window_Room;
        Number := Valid_Window_Number (fl_glut_create_window (Interfaces.C.To_C (Title)));
        --  GLUT gives a new window only a number whose window is gone, such
        --  as a subwindow deleted with its parent
        Reset_Callbacks (Number);
        return Number;
    end Create_Window;


    function Create_Sub_Window
           (Parent     : in Valid_Window_Number;
            X, Y, W, H : in Integer)
        return Valid_Window_Number
    is
        Number : Valid_Window_Number;
    begin
        Check_Window (Parent);
        Check_Window_Room;
        Number := Valid_Window_Number
           (fl_glut_create_sub_window
               (Interfaces.C.int (Parent),
                Interfaces.C.int (X), Interfaces.C.int (Y),
                Interfaces.C.int (W), Interfaces.C.int (H)));
        Reset_Callbacks (Number);
        return Number;
    end Create_Sub_Window;


    procedure Destroy_Window
           (Number : in Valid_Window_Number) is
    begin
        Check_Window (Number);
        if fl_glut_window_ada (Interfaces.C.int (Number)) /= 0 then
            raise Program_Error with "Destroy_Window of a Glut_Window, which goes when finalized";
        elsif fl_glut_destroy_window (Interfaces.C.int (Number)) = 0 then
            raise Program_Error with "Destroy_Window of a window with a Glut_Window in it";
        end if;
        --  With its subwindows
        for Gone in Valid_Window_Number loop
            if fl_glut_window_alive (Interfaces.C.int (Gone)) = 0 then
                Reset_Callbacks (Gone);
            end if;
        end loop;
    end Destroy_Window;


    procedure Post_Redisplay is
    begin
        fl_glut_post_redisplay;
    end Post_Redisplay;


    procedure Post_Window_Redisplay
           (Number : in Valid_Window_Number) is
    begin
        Check_Window (Number);
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


    function Window_Exists
           (Number : in Window_Number)
        return Boolean is
    begin
        return fl_glut_window_alive (Interfaces.C.int (Number)) /= 0;
    end Window_Exists;


    procedure Set_Window
           (Number : in Valid_Window_Number) is
    begin
        Check_Window (Number);
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
        fl_glut_set_icon_title (Interfaces.C.To_C (Text));
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
        if fl_glut_establish_overlay = 0 then
            raise Program_Error with "Establish_Overlay on a GLUT window not shown";
        end if;
    end Establish_Overlay;


    procedure Remove_Overlay is
    begin
        fl_glut_remove_overlay;
    end Remove_Overlay;


    procedure Use_Layer
           (Layer : in Layer_Kind) is
    begin
        if fl_glut_use_layer (Layer_Kind'Pos (Layer)) = 0 then
            raise Program_Error with "Use_Layer (Overlay) on a GLUT window not shown";
        end if;
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

    function Create_Menu
           (Func : in not null Menu_Function)
        return Valid_Menu_Number
    is
        Number : Valid_Menu_Number;
    begin
        --  The 32nd menu would get the 31st's number (glut_compatibility.cxx:308)
        if fl_glut_menu_room = 0 then
            raise Unsupported_Error with "GLUT has no menu numbers left";
        end if;
        Number := Valid_Menu_Number (fl_glut_create_menu (Menu_Hook'Address));
        Menu_Table (Number) := Func;
        return Number;
    end Create_Menu;


    procedure Destroy_Menu
           (Number : in Valid_Menu_Number) is
    begin
        Check_Menu (Number);
        Check_Unused (Number, "Destroy_Menu of");
        fl_glut_destroy_menu (Interfaces.C.int (Number));
        Menu_Table (Number) := null;
    end Destroy_Menu;


    function Get_Menu
        return Menu_Number is
    begin
        return Current_Menu;
    end Get_Menu;


    function Menu_Exists
           (Number : in Menu_Number)
        return Boolean is
    begin
        return fl_glut_menu_exists (Interfaces.C.int (Number)) /= 0;
    end Menu_Exists;


    procedure Set_Menu
           (Number : in Valid_Menu_Number) is
    begin
        Check_Menu (Number);
        fl_glut_set_menu (Interfaces.C.int (Number));
    end Set_Menu;


    procedure Add_Menu_Entry
           (Label : in String;
            Value : in Integer)
    is
        Menu : constant Valid_Menu_Number := Current_Valid_Menu;
    begin
        Check_Unused (Menu, "Add_Menu_Entry to");
        fl_glut_add_menu_entry (Interfaces.C.To_C (Label), Interfaces.C.int (Value));
    end Add_Menu_Entry;


    procedure Add_Sub_Menu
           (Label   : in String;
            Submenu : in Valid_Menu_Number)
    is
        Menu : constant Valid_Menu_Number := Current_Valid_Menu;
    begin
        Check_Unused (Menu, "Add_Sub_Menu to");
        Check_Submenu (Menu, Submenu);
        fl_glut_add_sub_menu (Interfaces.C.To_C (Label), Interfaces.C.int (Submenu));
    end Add_Sub_Menu;


    procedure Change_To_Menu_Entry
           (Item  : in Positive;
            Label : in String;
            Value : in Integer)
    is
        Menu : constant Valid_Menu_Number := Current_Valid_Menu;
    begin
        Check_Item (Menu, Item);
        fl_glut_change_to_menu_entry
           (Interfaces.C.int (Item), Interfaces.C.To_C (Label), Interfaces.C.int (Value));
    end Change_To_Menu_Entry;


    procedure Change_To_Sub_Menu
           (Item    : in Positive;
            Label   : in String;
            Submenu : in Valid_Menu_Number)
    is
        Menu : constant Valid_Menu_Number := Current_Valid_Menu;
    begin
        Check_Item (Menu, Item);
        Check_Unused (Menu, "Change_To_Sub_Menu in");
        Check_Submenu (Menu, Submenu);
        fl_glut_change_to_sub_menu
           (Interfaces.C.int (Item), Interfaces.C.To_C (Label), Interfaces.C.int (Submenu));
    end Change_To_Sub_Menu;


    procedure Remove_Menu_Item
           (Item : in Positive)
    is
        Menu : constant Valid_Menu_Number := Current_Valid_Menu;
    begin
        Check_Unused (Menu, "Remove_Menu_Item from");
        Check_Item (Menu, Item);
        fl_glut_remove_menu_item (Interfaces.C.int (Item));
    end Remove_Menu_Item;


    procedure Attach_Menu
           (Button : in Menu_Button) is
    begin
        --  An empty menu has no array to pop up (domenu, glut_compatibility.cxx:298)
        if Items_Of (Current_Valid_Menu) = 0 then
            raise Program_Error with "Attach_Menu of an empty GLUT menu";
        end if;
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




    -------------
    --  Fonts  --
    -------------

    --  FL/gl.h's text calls, which the bitmap fonts are, and GL's drawing
    --  need a GL context (pofltk 111).
    procedure Check_Ready
           (Name : in String) is
    begin
        if fl_gl_ready = 0 then
            raise Program_Error with "GLUT." & Name & " needs a GL context: a shown GL window "
                & "current, as in a display function, or FLTK.Draw.OpenGL.Start";
        end if;
    end Check_Ready;


    function Font_Number
           (Font : in Bitmap_Font)
        return Interfaces.C.int is (Bitmap_Font'Pos (Font));

    function Font_Number
           (Font : in Stroke_Font)
        return Interfaces.C.int is (Stroke_Font'Pos (Font));


    procedure Bitmap_Character
           (Font : in Bitmap_Font;
            Item : in Character)
    is
        Code : constant Natural := Character'Pos (Item);
        Text : String (1 .. 2);
        Size : Positive := 1;
    begin
        Check_Ready ("Bitmap_Character");
        --  Latin-1 is the first 256 characters of Unicode, so in UTF-8 a
        --  character past 127 takes two bytes
        if Code < 16#80# then
            Text (1) := Item;
        else
            Text (1) := Character'Val (16#C0# + Code / 64);
            Text (2) := Character'Val (16#80# + Code mod 64);
            Size := 2;
        end if;
        fl_glut_bitmap_draw (Font_Number (Font), Text'Address, Interfaces.C.int (Size));
    end Bitmap_Character;


    procedure Bitmap_String
           (Font : in Bitmap_Font;
            Text : in String) is
    begin
        Check_Ready ("Bitmap_String");
        fl_glut_bitmap_draw (Font_Number (Font), Text'Address, Text'Length);
    end Bitmap_String;


    function Bitmap_Width
           (Font : in Bitmap_Font;
            Item : in Character)
        return Natural is
    begin
        Check_Ready ("Bitmap_Width");
        return Natural (fl_glut_bitmap_width (Font_Number (Font), Character'Pos (Item)));
    end Bitmap_Width;


    function Bitmap_Length
           (Font : in Bitmap_Font;
            Text : in String)
        return Natural is
    begin
        Check_Ready ("Bitmap_Length");
        return Natural (fl_glut_bitmap_length (Font_Number (Font), Text'Address, Text'Length));
    end Bitmap_Length;


    function Bitmap_Height
           (Font : in Bitmap_Font)
        return Natural is
    begin
        Check_Ready ("Bitmap_Height");
        return Natural (fl_glut_bitmap_height (Font_Number (Font)));
    end Bitmap_Height;


    procedure Stroke_Character
           (Font : in Stroke_Font;
            Item : in Character) is
    begin
        Check_Ready ("Stroke_Character");
        fl_glut_stroke_character (Font_Number (Font), Character'Pos (Item));
    end Stroke_Character;


    procedure Stroke_String
           (Font : in Stroke_Font;
            Text : in String) is
    begin
        Check_Ready ("Stroke_String");
        fl_glut_stroke_string (Font_Number (Font), Text'Address, Text'Length);
    end Stroke_String;


    function Stroke_Width
           (Font : in Stroke_Font;
            Item : in Character)
        return Natural is
    begin
        return Natural (fl_glut_stroke_width (Font_Number (Font), Character'Pos (Item)));
    end Stroke_Width;


    function Stroke_Length
           (Font : in Stroke_Font;
            Text : in String)
        return Natural is
    begin
        return Natural (fl_glut_stroke_length (Font_Number (Font), Text'Address, Text'Length));
    end Stroke_Length;


    function Stroke_Height
           (Font : in Stroke_Font)
        return Float is
    begin
        return Float (fl_glut_stroke_height (Font_Number (Font)));
    end Stroke_Height;




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


