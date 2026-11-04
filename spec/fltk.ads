

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Finalization,
    System;

private with

    Ada.Unchecked_Conversion,
    Interfaces.C.Strings,
    System.Storage_Elements;


package FLTK is


    --  Ugly implementation detail, never use this.
    --  This is necessary so things like Text_Buffers and
    --  Widgets can talk to each other behind the binding.
    type Wrapper is new Ada.Finalization.Limited_Controlled with private;

    function Is_Valid
           (Object : in Wrapper)
        return Boolean;

    --  If this is ever raised it means FLTK has returned a value or otherwise
    --  acted in a way that the binding really did not expect.
    Internal_FLTK_Error : exception;

    --  Raised when this FLTK, or the back end it is running on, can't do
    --  what was asked: for example, an FLTK built without SVG support, or
    --  a call that only works on X11 made under Wayland.  Each subprogram
    --  that raises it says so in its own comment.
    Unsupported_Error : exception;

    --  Text buffers for marshalling purposes will be this size.
    Buffer_Size : constant Natural := 1024;

    --  For image data arrays.
    type Size_Type is mod 2 ** System.Word_Size;
    subtype Positive_Size is Size_Type range 1 .. Size_Type'Last;




    --  Color  --

    --  Values scale from A/Black to X/White.
    type Greyscale is new Character range 'A' .. 'X';

    type Color is mod 2**32;

    type Color_Component is mod 256;
    type Color_Component_Array is array (Positive_Size range <>) of aliased Color_Component;

    subtype Blend is Float range 0.0 .. 1.0;

    function RGB_Color
           (Light : in Greyscale)
        return Color;

    function RGB_Color
           (Light : in Color_Component)
        return Color;

    function RGB_Color
           (R, G, B : in Color_Component)
        return Color;

    function Color_Cube
           (R, G, B : in Color_Component)
        return Color;

    function Grey_Ramp
           (Light : in Greyscale)
        return Color;

    function Grey_Ramp
           (Light : in Color_Component)
        return Color;

    function Darker
           (Tone : in Color)
        return Color;

    function Lighter
           (Tone : in Color)
        return Color;

    function Contrast
           (Fore, Back : in Color)
        return Color;

    function Inactive
           (Tone : in Color)
        return Color;

    function Color_Average
           (Tone1, Tone2 : in Color;
            Weight       : in Blend := 0.5)
        return Color;

    --  Examples of RGB colors without the above function
    --  The lowest byte has to be 00 for the color to be RGB
    RGB_Red_Color   : constant Color := 16#ff000000#;
    RGB_Green_Color : constant Color := 16#00ff0000#;
    RGB_Blue_Color  : constant Color := 16#0000ff00#;
    RGB_White_Color : constant Color := 16#ffffff00#;

    --  Standard colors used in widgets
    Foreground_Color  : constant Color := 0;
    Background2_Color : constant Color := 7;
    Inactive_Color    : constant Color := 8;
    Selection_Color   : constant Color := 15;

    --  X allocation area
    Free_Color : constant Color := 16;

    --  Standard boxtype colors
    Grey0_Color      : constant Color := 32;
    Dark3_Color      : constant Color := 39;
    Dark2_Color      : constant Color := 45;
    Dark1_Color      : constant Color := 47;
    Background_Color : constant Color := 49;
    Light1_Color     : constant Color := 50;
    Light2_Color     : constant Color := 52;
    Light3_Color     : constant Color := 54;

    --  Color cube colors
    Black_Color        : constant Color := 56;
    Red_Color          : constant Color := 88;
    Green_Color        : constant Color := 63;
    Yellow_Color       : constant Color := 95;
    Blue_Color         : constant Color := 216;
    Magenta_Color      : constant Color := 248;
    Cyan_Color         : constant Color := 223;
    Dark_Red_Color     : constant Color := 72;
    Dark_Green_Color   : constant Color := 60;
    Dark_Yellow_Color  : constant Color := 76;
    Dark_Blue_Color    : constant Color := 136;
    Dark_Magenta_Color : constant Color := 152;
    Dark_Cyan_Color    : constant Color := 140;
    White_Color        : constant Color := 255;




    --  Alignment  --

    --  This should be a bitmask, except there are magic values...
    type Alignment is private;

    function "+" (Left, Right : in Alignment) return Alignment;
    function "-" (Left, Right : in Alignment) return Alignment;

    Align_Center             : constant Alignment;
    Align_Top                : constant Alignment;
    Align_Bottom             : constant Alignment;
    Align_Left               : constant Alignment;
    Align_Right              : constant Alignment;
    Align_Inside             : constant Alignment;
    Align_Text_Over_Image    : constant Alignment;
    Align_Image_Over_Text    : constant Alignment;
    Align_Clip               : constant Alignment;
    Align_Wrap               : constant Alignment;
    Align_Image_Next_To_Text : constant Alignment;
    Align_Text_Next_To_Image : constant Alignment;
    Align_Image_Backdrop     : constant Alignment;
    Align_Top_Left           : constant Alignment;
    Align_Top_Right          : constant Alignment;
    Align_Bottom_Left        : constant Alignment;
    Align_Bottom_Right       : constant Alignment;
    Align_Left_Top           : constant Alignment;
    Align_Right_Top          : constant Alignment;
    Align_Left_Bottom        : constant Alignment;
    Align_Right_Bottom       : constant Alignment;
    Align_Nowrap             : constant Alignment;
    Align_All_Position       : constant Alignment;
    Align_All_Image          : constant Alignment;




    --  Mouse Cursors  --

    type Mouse_Cursor_Kind is
       (Default_Mouse,
        Arrow_Mouse,
        Crosshair_Mouse,
        Wait_Mouse,
        Insert_Mouse,
        Hand_Mouse,
        Help_Mouse,
        Move_Mouse,
        NS_Mouse,
        WE_Mouse,
        NWSE_Mouse,
        NESW_Mouse,
        N_Mouse,
        NE_Mouse,
        E_Mouse,
        SE_Mouse,
        S_Mouse,
        SW_Mouse,
        W_Mouse,
        NW_Mouse,
        None_Mouse)
    with Default_Value => Default_Mouse;




    --  Keyboard and Mouse Input  --

    type Keypress is private;
    subtype Pressable_Key is Character range Character'Val (32) .. Character'Val (126);

    function Press (Key : in Pressable_Key) return Keypress;

    --  Keys on the numeric keypad, and the character each one stands for
    --  when NumLock is on, such as '7' for the key also marked Home.
    function Is_Keypad (Key : in Keypress) return Boolean;
    function Keypad_Character (Key : in Keypress) return Character
        with Pre => Is_Keypad (Key);

    Enter_Key        : constant Keypress;
    Keypad_Enter_Key : constant Keypress;
    Backspace_Key    : constant Keypress;
    Insert_Key       : constant Keypress;
    Delete_Key       : constant Keypress;
    Home_Key         : constant Keypress;
    End_Key          : constant Keypress;
    Page_Down_Key    : constant Keypress;
    Page_Up_Key      : constant Keypress;
    Down_Key         : constant Keypress;
    Left_Key         : constant Keypress;
    Right_Key        : constant Keypress;
    Up_Key           : constant Keypress;
    Escape_Key       : constant Keypress;
    Tab_Key          : constant Keypress;


    type Mouse_Button is
       (No_Button,
        Left_Button,
        Middle_Button,
        Right_Button,
        Back_Button,
        Forward_Button,
        Any_Button);


    type Key_Combo is private;

    function Press (Key : in Pressable_Key) return Key_Combo;
    function Press (Key : in Keypress) return Key_Combo;
    function Press (Key : in Mouse_Button) return Key_Combo;

    No_Key : constant Key_Combo;


    type Modifier is private;

    function "+" (Left, Right : in Modifier) return Modifier;
    function "+" (Left : in Modifier; Right : in Pressable_Key) return Key_Combo;
    function "+" (Left : in Modifier; Right : in Keypress) return Key_Combo;
    function "+" (Left : in Modifier; Right : in Mouse_Button) return Key_Combo;
    function "+" (Left : in Modifier; Right : in Key_Combo) return Key_Combo;

    Mod_None        : constant Modifier;
    Mod_Shift       : constant Modifier;
    Mod_Caps_Lock   : constant Modifier;
    Mod_Ctrl        : constant Modifier;
    Mod_Alt         : constant Modifier;
    Mod_Num_Lock    : constant Modifier;
    Mod_Meta        : constant Modifier;
    Mod_Scroll_Lock : constant Modifier;
    Mod_Command     : constant Modifier;




    --  Box Types  --

    --  Every kind draws as itself.  FLTK draws the round, shadow, oval,
    --  plastic, GTK+, gleam and oxy kinds as an up, border or flat box until
    --  they are defined, and FLTKAda defines them when it starts (pofltk 8).
    type Box_Kind is
       (No_Box,
        Flat_Box,
        Up_Box,
        Down_Box,
        Up_Frame,
        Down_Frame,
        Thin_Up_Box,
        Thin_Down_Box,
        Thin_Up_Frame,
        Thin_Down_Frame,
        Engraved_Box,
        Embossed_Box,
        Engraved_Frame,
        Embossed_Frame,
        Border_Box,
        Shadow_Box,
        Border_Frame,
        Shadow_Frame,
        Rounded_Box,
        RShadow_Box,
        Rounded_Frame,
        RFlat_Box,
        Round_Up_Box,
        Round_Down_Box,
        Diamond_Up_Box,
        Diamond_Down_Box,
        Oval_Box,
        OShadow_Box,
        Oval_Frame,
        OFlat_Box,
        Plastic_Up_Box,
        Plastic_Down_Box,
        Plastic_Up_Frame,
        Plastic_Down_Frame,
        Plastic_Thin_Up_Box,
        Plastic_Thin_Down_Box,
        Plastic_Round_Up_Box,
        Plastic_Round_Down_Box,
        Gtk_Up_Box,
        Gtk_Down_Box,
        Gtk_Up_Frame,
        Gtk_Down_Frame,
        Gtk_Thin_Up_Box,
        Gtk_Thin_Down_Box,
        Gtk_Thin_Up_Frame,
        Gtk_Thin_Down_Frame,
        Gtk_Round_Up_Box,
        Gtk_Round_Down_Box,
        Gleam_Up_Box,
        Gleam_Down_Box,
        Gleam_Up_Frame,
        Gleam_Down_Frame,
        Gleam_Thin_Up_Box,
        Gleam_Thin_Down_Box,
        Gleam_Round_Up_Box,
        Gleam_Round_Down_Box,
        Oxy_Up_Box,
        Oxy_Down_Box,
        Oxy_Up_Frame,
        Oxy_Down_Frame,
        Oxy_Thin_Up_Box,
        Oxy_Thin_Down_Box,
        Oxy_Thin_Up_Frame,
        Oxy_Thin_Down_Frame,
        Oxy_Round_Up_Box,
        Oxy_Round_Down_Box,
        Oxy_Button_Up_Box,
        Oxy_Button_Down_Box,
        Free_Box);

    function Filled
           (Box : in Box_Kind)
        return Box_Kind;

    function Frame
           (Box : in Box_Kind)
        return Box_Kind;

    function Down
           (Box : in Box_Kind)
        return Box_Kind;




    --  Fonts  --

    type Font_Kind is
       (Helvetica,
        Helvetica_Bold,
        Helvetica_Italic,
        Helvetica_Bold_Italic,
        Courier,
        Courier_Bold,
        Courier_Italic,
        Courier_Bold_Italic,
        Times,
        Times_Bold,
        Times_Italic,
        Times_Bold_Italic,
        Symbol,
        Monospace,
        Monospace_Bold,
        Zapf_Dingbats,
        Free_Font);

    type Font_Size is new Natural;
    Normal_Size : constant Font_Size := 14;

    type Font_Size_Array is array (Positive range <>) of Font_Size;




    --  Label Types  --

    --  Shadow, Engraved and Embossed are defined when FLTKAda starts, and
    --  draw as themselves (pofltk 8).  Multi, Icon and Image are not, and
    --  draw nothing: for them FLTK reads the label text as a pointer.
    type Label_Kind is
       (Normal_Label,
        No_Label,
        Shadow_Label,
        Engraved_Label,
        Embossed_Label,
        Multi_Label,
        Icon_Label,
        Image_Label,
        Free_Label);




    --  Events  --

    type Event_Kind is
       (No_Event,
        Push,
        Release,
        Enter,
        Leave,
        Drag,
        Focus,
        Unfocus,
        Keydown,
        Keyup,
        Close,
        Move,
        Shortcut,
        Deactivate,
        Activate,
        Hide,
        Show,
        Paste,
        Selection_Clear,
        Mouse_Wheel,
        DnD_Enter,
        DnD_Drag,
        DnD_Leave,
        DnD_Release,
        Screen_Config_Changed,
        Fullscreen,
        Zoom_Gesture,
        Zoom_Event);

    type Event_Outcome is (Not_Handled, Handled);




    --  Callback Flags  --

    type Callback_Flag is record
        Changed   : Boolean := False;
        Interact  : Boolean := False;
        Release   : Boolean := False;
        Enter_Key : Boolean := False;
    end record;

    function "+" (Left, Right : in Callback_Flag) return Callback_Flag;
    function "-" (Left, Right : in Callback_Flag) return Callback_Flag;

    Call_Never            : constant Callback_Flag;
    When_Changed          : constant Callback_Flag;
    When_Interact         : constant Callback_Flag;
    When_Release          : constant Callback_Flag;
    When_Release_Always   : constant Callback_Flag;
    When_Enter_Key        : constant Callback_Flag;
    When_Enter_Key_Always : constant Callback_Flag;




    --  Menu Flags  --

    --  It's easier to have this here rather than in Menu_Items for visibility reasons.

    type Menu_Flag is record
        Inactive  : Boolean := False;
        Toggle    : Boolean := False;
        Value     : Boolean := False;
        Radio     : Boolean := False;
        Invisible : Boolean := False;
        Submenu   : Boolean := False;
        Divider   : Boolean := False;
    end record;

    function "+" (Left, Right : in Menu_Flag) return Menu_Flag;
    function "-" (Left, Right : in Menu_Flag) return Menu_Flag;

    Flag_Normal    : constant Menu_Flag;
    Flag_Inactive  : constant Menu_Flag;
    Flag_Toggle    : constant Menu_Flag;
    Flag_Value     : constant Menu_Flag;
    Flag_Radio     : constant Menu_Flag;
    Flag_Invisible : constant Menu_Flag;
    Flag_Submenu   : constant Menu_Flag;
    Flag_Divider   : constant Menu_Flag;




    --  Damage Bits  --

    type Damage_Mask is record
        Child   : Boolean := False;
        Expose  : Boolean := False;
        Scroll  : Boolean := False;
        Overlay : Boolean := False;
        User_1  : Boolean := False;
        User_2  : Boolean := False;
        Full    : Boolean := False;
    end record;

    function "+" (Left, Right : in Damage_Mask) return Damage_Mask;
    function "-" (Left, Right : in Damage_Mask) return Damage_Mask;

    Damage_None    : constant Damage_Mask;
    Damage_Child   : constant Damage_Mask;
    Damage_Expose  : constant Damage_Mask;
    Damage_Scroll  : constant Damage_Mask;
    Damage_Overlay : constant Damage_Mask;
    Damage_User_1  : constant Damage_Mask;
    Damage_User_2  : constant Damage_Mask;
    Damage_Full    : constant Damage_Mask;




    --  Clipboard Attributes  --

    Clipboard_Image      : constant String;
    Clipboard_Plain_Text : constant String;




    --  Versioning  --

    type Version_Number is new Natural;

    function ABI_Check
           (ABI_Ver : in Version_Number)
        return Boolean;

    function ABI_Version
        return Version_Number;

    function API_Version
        return Version_Number;

    function Version
        return Version_Number;




    --  Event Loop  --

    procedure Check;

    function Check
        return Boolean;

    function Ready
        return Boolean;

    function Wait
        return Integer;

    function Wait
           (Seconds : in Long_Float)
        return Long_Float;

    function Run
        return Integer;


private


    package Storage renames System.Storage_Elements;
    use type Interfaces.C.size_t, Storage.Integer_Address;


    Null_Pointer : constant Storage.Integer_Address := Storage.To_Integer (System.Null_Address);


    pragma Linker_Options ("-lfltk");
    pragma Linker_Options ("-lfltk_images");
    pragma Linker_Options ("-lfltk_gl");


    function c_pointer_size
        return Interfaces.C.size_t;
    pragma Import (C, c_pointer_size, "c_pointer_size");

    --  If this fails then we are on an architecture that for whatever reason
    --  has significant problems interfacing between C and Ada
    pragma Assert
       (c_pointer_size * Interfaces.C.CHAR_BIT = Storage.Integer_Address'Size,
        "Size of C void pointers and size of Ada address values do not match");




    --  Note: This has to be Limited because otherwise the various init subprograms
    --  wouldn't work, the widget callbacks wouldn't work, deallocation would be
    --  a mess, really just all sorts of problems.
    type Wrapper is new Ada.Finalization.Limited_Controlled with record
        Void_Ptr      : Storage.Integer_Address := Null_Pointer;
        Needs_Dealloc : Boolean                 := True;
    end record;




    for Color_Component_Array'Component_Size use Interfaces.C.CHAR_BIT;
    pragma Convention (C, Color_Component_Array);




    --  Default value here is Align_Center
    type Alignment is mod 2 ** 16
    with Default_Value => 0;

    for Alignment'Size use 16;

    pragma Import (C, Align_Center,             "fl_align_center");
    pragma Import (C, Align_Top,                "fl_align_top");
    pragma Import (C, Align_Bottom,             "fl_align_bottom");
    pragma Import (C, Align_Left,               "fl_align_left");
    pragma Import (C, Align_Right,              "fl_align_right");
    pragma Import (C, Align_Inside,             "fl_align_inside");
    pragma Import (C, Align_Text_Over_Image,    "fl_align_text_over_image");
    pragma Import (C, Align_Image_Over_Text,    "fl_align_image_over_text");
    pragma Import (C, Align_Clip,               "fl_align_clip");
    pragma Import (C, Align_Wrap,               "fl_align_wrap");
    pragma Import (C, Align_Image_Next_To_Text, "fl_align_image_next_to_text");
    pragma Import (C, Align_Text_Next_To_Image, "fl_align_text_next_to_image");
    pragma Import (C, Align_Image_Backdrop,     "fl_align_image_backdrop");
    pragma Import (C, Align_Top_Left,           "fl_align_top_left");
    pragma Import (C, Align_Top_Right,          "fl_align_top_right");
    pragma Import (C, Align_Bottom_Left,        "fl_align_bottom_left");
    pragma Import (C, Align_Bottom_Right,       "fl_align_bottom_right");
    pragma Import (C, Align_Left_Top,           "fl_align_left_top");
    pragma Import (C, Align_Right_Top,          "fl_align_right_top");
    pragma Import (C, Align_Left_Bottom,        "fl_align_left_bottom");
    pragma Import (C, Align_Right_Bottom,       "fl_align_right_bottom");
    pragma Import (C, Align_Nowrap,             "fl_align_nowrap");
    pragma Import (C, Align_All_Position,       "fl_align_all_position");
    pragma Import (C, Align_All_Image,          "fl_align_all_image");




    --  What delightful magic numbers FLTK cursors are!
    --  (These correspond to the enum found in Enumerations.H)
    Cursor_Values : array (Mouse_Cursor_Kind) of Interfaces.C.int :=
       (Default_Mouse   => 0,
        Arrow_Mouse     => 35,
        Crosshair_Mouse => 66,
        Wait_Mouse      => 76,
        Insert_Mouse    => 77,
        Hand_Mouse      => 31,
        Help_Mouse      => 47,
        Move_Mouse      => 27,
        NS_Mouse        => 78,
        WE_Mouse        => 79,
        NWSE_Mouse      => 80,
        NESW_Mouse      => 81,
        N_Mouse         => 70,
        NE_Mouse        => 69,
        E_Mouse         => 49,
        SE_Mouse        => 8,
        S_Mouse         => 9,
        SW_Mouse        => 7,
        W_Mouse         => 36,
        NW_Mouse        => 68,
        None_Mouse      => 255);




    type Keypress is new Interfaces.Unsigned_16;
    type Modifier is new Interfaces.Unsigned_16;

    type Key_Combo is record
        Modcode   : Modifier;
        Keycode   : Keypress;
        Mousecode : Mouse_Button;
    end record;

    function To_C
           (Key : in Key_Combo)
        return Interfaces.C.unsigned;

    function To_Ada
           (Key : in Interfaces.C.unsigned)
        return Key_Combo;

    function To_C
           (Key : in Keypress)
        return Interfaces.C.unsigned;

    function To_Ada
           (Key : in Interfaces.C.unsigned)
        return Keypress;

    function To_C
           (Modi : in Modifier)
        return Interfaces.C.unsigned;

    function To_Ada
           (Modi : in Interfaces.C.unsigned)
        return Modifier;

    function To_C
           (Button : in Mouse_Button)
        return Interfaces.C.unsigned;

    function To_Ada
           (Button : in Interfaces.C.unsigned)
        return Mouse_Button;

    --  these values designed to align with FLTK enumeration types
    Mod_None        : constant Modifier := 2#00000000#;
    Mod_Shift       : constant Modifier := 2#00000001#;
    Mod_Caps_Lock   : constant Modifier := 2#00000010#;
    Mod_Ctrl        : constant Modifier := 2#00000100#;
    Mod_Alt         : constant Modifier := 2#00001000#;
    Mod_Num_Lock    : constant Modifier := 2#00010000#;
    --  Missing                            2#00100000#;
    Mod_Meta        : constant Modifier := 2#01000000#;
    Mod_Scroll_Lock : constant Modifier := 2#10000000#;

    --  If this is Apple then Mod_Meta, otherwise Mod_Ctrl
    pragma Import (C, Mod_Command, "fl_mod_command");

    No_Key : constant Key_Combo := (Modcode => Mod_None, Keycode => 0, Mousecode => No_Button);

    --  these values correspond to constants defined in FLTK Enumerations.H
    Enter_Key        : constant Keypress := 16#ff0d#;
    Keypad_Enter_Key : constant Keypress := 16#ff8d#;
    Backspace_Key    : constant Keypress := 16#ff08#;
    Insert_Key       : constant Keypress := 16#ff63#;
    Delete_Key       : constant Keypress := 16#ffff#;
    Home_Key         : constant Keypress := 16#ff50#;
    End_Key          : constant Keypress := 16#ff57#;
    Page_Down_Key    : constant Keypress := 16#ff56#;
    Page_Up_Key      : constant Keypress := 16#ff55#;
    Down_Key         : constant Keypress := 16#ff54#;
    Left_Key         : constant Keypress := 16#ff51#;
    Right_Key        : constant Keypress := 16#ff53#;
    Up_Key           : constant Keypress := 16#ff52#;
    Escape_Key       : constant Keypress := 16#ff1b#;
    Tab_Key          : constant Keypress := 16#ff09#;




    for Callback_Flag use record
        Changed   at 0 range 0 .. 0;
        Interact  at 0 range 1 .. 1;
        Release   at 0 range 2 .. 2;
        Enter_Key at 0 range 3 .. 3;
    end record;

    for Callback_Flag'Size use Interfaces.C.unsigned_char'Size;

    Call_Never     : constant Callback_Flag := (others => False);
    When_Changed   : constant Callback_Flag := (Changed   => True, others => False);
    When_Interact  : constant Callback_Flag := (Interact  => True, others => False);
    When_Release   : constant Callback_Flag := (Release   => True, others => False);
    When_Enter_Key : constant Callback_Flag := (Enter_Key => True, others => False);

    When_Release_Always   : constant Callback_Flag :=
        (Release   => True, Interact => True, others => False);
    When_Enter_Key_Always : constant Callback_Flag :=
        (Enter_Key => True, Interact => True, others => False);

    function Flag_To_UChar is new
        Ada.Unchecked_Conversion (Callback_Flag, Interfaces.C.unsigned_char);

    function UChar_To_Flag is new
        Ada.Unchecked_Conversion (Interfaces.C.unsigned_char, Callback_Flag);




    for Menu_Flag use record
        Inactive  at 0 range 0 .. 0;
        Toggle    at 0 range 1 .. 1;
        Value     at 0 range 2 .. 2;
        Radio     at 0 range 3 .. 3;
        Invisible at 0 range 4 .. 4;
        --  Submenu_Pointer unused
        Submenu   at 0 range 6 .. 6;
        Divider   at 0 range 7 .. 7;
    end record;

    for Menu_Flag'Size use Interfaces.C.int'Size;

    Flag_Normal    : constant Menu_Flag := (others => False);
    Flag_Inactive  : constant Menu_Flag := (Inactive  => True, others => False);
    Flag_Toggle    : constant Menu_Flag := (Toggle    => True, others => False);
    Flag_Value     : constant Menu_Flag := (Value     => True, others => False);
    Flag_Radio     : constant Menu_Flag := (Radio     => True, others => False);
    Flag_Invisible : constant Menu_Flag := (Invisible => True, others => False);
    --  Flag_Submenu_Pointer unused
    Flag_Submenu   : constant Menu_Flag := (Submenu   => True, others => False);
    Flag_Divider   : constant Menu_Flag := (Divider   => True, others => False);

    function MFlag_To_Cint is new
        Ada.Unchecked_Conversion (Menu_Flag, Interfaces.C.int);

    function Cint_To_MFlag is new
        Ada.Unchecked_Conversion (Interfaces.C.int, Menu_Flag);




    for Damage_Mask use record
        Child   at 0 range 0 .. 0;
        Expose  at 0 range 1 .. 1;
        Scroll  at 0 range 2 .. 2;
        Overlay at 0 range 3 .. 3;
        User_1  at 0 range 4 .. 4;
        User_2  at 0 range 5 .. 5;
        --  bit 6 missing
        Full    at 0 range 7 .. 7;
    end record;

    for Damage_Mask'Size use Interfaces.C.unsigned_char'Size;

    Damage_None    : constant Damage_Mask := (others  => False);
    Damage_Child   : constant Damage_Mask := (Child   => True, others => False);
    Damage_Expose  : constant Damage_Mask := (Expose  => True, others => False);
    Damage_Scroll  : constant Damage_Mask := (Scroll  => True, others => False);
    Damage_Overlay : constant Damage_Mask := (Overlay => True, others => False);
    Damage_User_1  : constant Damage_Mask := (User_1  => True, others => False);
    Damage_User_2  : constant Damage_Mask := (User_2  => True, others => False);
    Damage_Full    : constant Damage_Mask := (Full    => True, others => False);

    function Mask_To_UChar is new
        Ada.Unchecked_Conversion (Damage_Mask, Interfaces.C.unsigned_char);

    function UChar_To_Mask is new
        Ada.Unchecked_Conversion (Interfaces.C.unsigned_char, Damage_Mask);




    clip_image_char_ptr : Interfaces.C.Strings.chars_ptr;
    pragma Import (C, clip_image_char_ptr, "fl_clip_image_char_ptr");

    clip_plain_text_char_ptr : Interfaces.C.Strings.chars_ptr;
    pragma Import (C, clip_plain_text_char_ptr, "fl_clip_plain_text_char_ptr");

    Clipboard_Image      : constant String := Interfaces.C.Strings.Value (clip_image_char_ptr);
    Clipboard_Plain_Text : constant String := Interfaces.C.Strings.Value (clip_plain_text_char_ptr);




    pragma Inline (RGB_Color);
    pragma Inline (Color_Cube);
    pragma Inline (Grey_Ramp);
    pragma Inline (Darker);
    pragma Inline (Lighter);
    pragma Inline (Contrast);
    pragma Inline (Inactive);
    pragma Inline (Color_Average);

    pragma Inline (Filled);
    pragma Inline (Frame);
    pragma Inline (Down);

    pragma Inline (ABI_Check);
    pragma Inline (ABI_Version);
    pragma Inline (API_Version);
    pragma Inline (Version);

    pragma Inline (Check);
    pragma Inline (Ready);
    pragma Inline (Wait);
    pragma Inline (Run);


end FLTK;


