

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr,
    Interfaces.C.size_t,
    Interfaces.C.unsigned,
    Interfaces.C.unsigned_char;


package body FLTK is


    ------------------------
    --  Constants From C  --
    ------------------------

    --  Color  --

    fl_enum_num_red : constant Interfaces.C.int;
    pragma Import (C, fl_enum_num_red, "fl_enum_num_red");

    fl_enum_num_green : constant Interfaces.C.int;
    pragma Import (C, fl_enum_num_green, "fl_enum_num_green");

    fl_enum_num_blue : constant Interfaces.C.int;
    pragma Import (C, fl_enum_num_blue, "fl_enum_num_blue");

    fl_enum_num_gray : constant Interfaces.C.int;
    pragma Import (C, fl_enum_num_gray, "fl_enum_num_gray");




    --  Keyboard and Mouse Input  --

    fl_enum_button1 : constant Interfaces.C.unsigned;
    pragma Import (C, fl_enum_button1, "fl_enum_button1");

    fl_enum_button2 : constant Interfaces.C.unsigned;
    pragma Import (C, fl_enum_button2, "fl_enum_button2");

    fl_enum_button3 : constant Interfaces.C.unsigned;
    pragma Import (C, fl_enum_button3, "fl_enum_button3");

    fl_enum_button4 : constant Interfaces.C.unsigned;
    pragma Import (C, fl_enum_button4, "fl_enum_button4");

    fl_enum_button5 : constant Interfaces.C.unsigned;
    pragma Import (C, fl_enum_button5, "fl_enum_button5");

    fl_enum_buttons : constant Interfaces.C.unsigned;
    pragma Import (C, fl_enum_buttons, "fl_enum_buttons");




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Enumerations.H  --

    --  Color  --

    function fl_enum_rgb_color2
           (L : in Interfaces.C.unsigned_char)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_rgb_color2, "fl_enum_rgb_color2");
    pragma Inline (fl_enum_rgb_color2);

    function fl_enum_rgb_color
           (R, G, B : in Interfaces.C.unsigned_char)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_rgb_color, "fl_enum_rgb_color");
    pragma Inline (fl_enum_rgb_color);

    function fl_enum_color_cube
           (R, G, B : in Interfaces.C.int)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_color_cube, "fl_enum_color_cube");
    pragma Inline (fl_enum_color_cube);

    function fl_enum_gray_ramp
           (L : in Interfaces.C.int)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_gray_ramp, "fl_enum_gray_ramp");
    pragma Inline (fl_enum_gray_ramp);

    function fl_enum_darker
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_darker, "fl_enum_darker");
    pragma Inline (fl_enum_darker);

    function fl_enum_lighter
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_lighter, "fl_enum_lighter");
    pragma Inline (fl_enum_lighter);

    function fl_enum_contrast
           (F, B : in Interfaces.C.unsigned;
            C, S : in Interfaces.C.int)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_contrast, "fl_enum_contrast");
    pragma Inline (fl_enum_contrast);

    function fl_enum_lightness
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.double;
    pragma Import (C, fl_enum_lightness, "fl_enum_lightness");
    pragma Inline (fl_enum_lightness);

    function fl_enum_luminance
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.double;
    pragma Import (C, fl_enum_luminance, "fl_enum_luminance");
    pragma Inline (fl_enum_luminance);

    function fl_enum_inactive
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_inactive, "fl_enum_inactive");
    pragma Inline (fl_enum_inactive);

    function fl_get_normal_size
        return Interfaces.C.int;
    pragma Import (C, fl_get_normal_size, "fl_get_normal_size");
    pragma Inline (fl_get_normal_size);

    procedure fl_set_normal_size
           (S : in Interfaces.C.int);
    pragma Import (C, fl_set_normal_size, "fl_set_normal_size");
    pragma Inline (fl_set_normal_size);

    function fl_enum_color_average
           (T1, T2 : in Interfaces.C.unsigned;
            W      : in Interfaces.C.C_float)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_enum_color_average, "fl_enum_color_average");
    pragma Inline (fl_enum_color_average);




    --  Box Types  --

    function fl_enum_box
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_enum_box, "fl_enum_box");
    pragma Inline (fl_enum_box);

    function fl_enum_frame
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_enum_frame, "fl_enum_frame");
    pragma Inline (fl_enum_frame);

    function fl_enum_down
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_enum_down, "fl_enum_down");
    pragma Inline (fl_enum_down);




    --  names.h  --

    function fl_names_event
           (E : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_names_event, "fl_names_event");
    pragma Inline (fl_names_event);

    function fl_names_font
           (F : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_names_font, "fl_names_font");
    pragma Inline (fl_names_font);

    function fl_names_reason
           (R : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_names_reason, "fl_names_reason");
    pragma Inline (fl_names_reason);




    --  Fl.H  --

    --  Versioning  --

    function fl_abi_check
           (V : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_abi_check, "fl_abi_check");
    pragma Inline (fl_abi_check);

    function fl_abi_version
        return Interfaces.C.int;
    pragma Import (C, fl_abi_version, "fl_abi_version");
    pragma Inline (fl_abi_version);

    function fl_api_version
        return Interfaces.C.int;
    pragma Import (C, fl_api_version, "fl_api_version");
    pragma Inline (fl_api_version);

    function fl_version
        return Interfaces.C.double;
    pragma Import (C, fl_version, "fl_version");
    pragma Inline (fl_version);

    function fl_built_version
        return Interfaces.C.double;
    pragma Import (C, fl_built_version, "fl_built_version");
    pragma Inline (fl_built_version);

    function fl_built_api_version
        return Interfaces.C.int;
    pragma Import (C, fl_built_api_version, "fl_built_api_version");
    pragma Inline (fl_built_api_version);

    function fl_built_abi_version
        return Interfaces.C.int;
    pragma Import (C, fl_built_abi_version, "fl_built_abi_version");
    pragma Inline (fl_built_abi_version);




    --  Event Loop  --

    function fl_check
        return Interfaces.C.int;
    pragma Import (C, fl_check, "fl_check");
    pragma Inline (fl_check);

    function fl_ready
        return Interfaces.C.int;
    pragma Import (C, fl_ready, "fl_ready");
    pragma Inline (fl_ready);

    function fl_wait
        return Interfaces.C.int;
    pragma Import (C, fl_wait, "fl_wait");
    pragma Inline (fl_wait);

    function fl_wait2
           (S : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_wait2, "fl_wait2");
    pragma Inline (fl_wait2);




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Implementation Details  --

    function Is_Valid
           (Object : in Wrapper)
        return Boolean is
    begin
        return Object.Void_Ptr /= Null_Pointer;
    end Is_Valid;




    --  Color  --

    function RGB_Color
           (Light : in Greyscale)
        return Color is
    begin
        case Light is
        when 'A' .. 'W' => return Color (fl_enum_rgb_color2
            ((Greyscale'Pos (Light) - Greyscale'Pos (Greyscale'First)) * 11));
        when 'X' => return Color (fl_enum_rgb_color2 (255));
        end case;
    end RGB_Color;


    function RGB_Color
           (Light : in Color_Component)
        return Color is
    begin
        return Color (fl_enum_rgb_color2 (Interfaces.C.unsigned_char (Light)));
    end RGB_Color;


    function RGB_Color
           (R, G, B : in Color_Component)
        return Color is
    begin
        return Color (fl_enum_rgb_color
           (Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B)));
    end RGB_Color;


    function Color_Cube
           (R, G, B : in Color_Component)
        return Color is
    begin
        return Color (fl_enum_color_cube
           (Interfaces.C.int (Float'Rounding (Float (R) * Float (fl_enum_num_red   - 1) / 255.0)),
            Interfaces.C.int (Float'Rounding (Float (G) * Float (fl_enum_num_green - 1) / 255.0)),
            Interfaces.C.int (Float'Rounding (Float (B) * Float (fl_enum_num_blue  - 1) / 255.0))));
    end Color_Cube;


    function Grey_Ramp
           (Light : in Greyscale)
        return Color is
    begin
        return Color (fl_enum_gray_ramp (Greyscale'Pos (Light) - Greyscale'Pos (Greyscale'First)));
    end Grey_Ramp;


    function Grey_Ramp
           (Light : in Color_Component)
        return Color is
    begin
        return Color (fl_enum_gray_ramp (Interfaces.C.int
            (Float'Rounding (Float (Light) * Float (fl_enum_num_gray - 1) / 255.0))));
    end Grey_Ramp;


    function Darker
           (Tone : in Color)
        return Color is
    begin
        return Color (fl_enum_darker (Interfaces.C.unsigned (Tone)));
    end Darker;


    function Lighter
           (Tone : in Color)
        return Color is
    begin
        return Color (fl_enum_lighter (Interfaces.C.unsigned (Tone)));
    end Lighter;


    function Contrast
           (Fore, Back    : in Color;
            Context, Size : in Integer := 0)
        return Color is
    begin
        return Color (fl_enum_contrast
           (Interfaces.C.unsigned (Fore),
            Interfaces.C.unsigned (Back),
            Interfaces.C.int (Context),
            Interfaces.C.int (Size)));
    end Contrast;


    function Lightness
           (Tone : in Color)
        return Long_Float is
    begin
        return Long_Float (fl_enum_lightness (Interfaces.C.unsigned (Tone)));
    end Lightness;


    function Luminance
           (Tone : in Color)
        return Long_Float is
    begin
        return Long_Float (fl_enum_luminance (Interfaces.C.unsigned (Tone)));
    end Luminance;


    function Inactive
           (Tone : in Color)
        return Color is
    begin
        return Color (fl_enum_inactive (Interfaces.C.unsigned (Tone)));
    end Inactive;


    function Color_Average
           (Tone1, Tone2 : in Color;
            Weight       : in Blend := 0.5)
        return Color is
    begin
        return Color (fl_enum_color_average
           (Interfaces.C.unsigned (Tone1),
            Interfaces.C.unsigned (Tone2),
            Interfaces.C.C_float (Weight)));
    end Color_Average;


    function Get_Normal_Size
        return Font_Size is
    begin
        return Font_Size (fl_get_normal_size);
    end Get_Normal_Size;


    procedure Set_Normal_Size
           (To : in Font_Size) is
    begin
        fl_set_normal_size (Interfaces.C.int (To));
    end Set_Normal_Size;




    --  Alignment  --

    function "+"
           (Left, Right : in Alignment)
        return Alignment is
    begin
        return Left or Right;
    end "+";


    function "-"
           (Left, Right : in Alignment)
        return Alignment is
    begin
        return Left and not Right;
    end "-";




    --  Keyboard and Mouse Input  --

    function Press
           (Key : in Pressable_Key)
        return Keypress is
    begin
        return Character'Pos (Key);
    end Press;


    function Character_Key
           (Item : in Wide_Character)
        return Keypress is
    begin
        return Wide_Character'Pos (Item);
    end Character_Key;


    function Is_Keypad
           (Key : in Keypress)
        return Boolean is
    begin
        return Key in 16#ff80# .. 16#ffbd#;
    end Is_Keypad;


    function Keypad_Character
           (Key : in Keypress)
        return Character is
    begin
        return Character'Val (Key - 16#ff80#);
    end Keypad_Character;


    function Function_Key
           (Number : in Function_Key_Number)
        return Keypress is
    begin
        return 16#ffbd# + Keypress (Number);
    end Function_Key;


    function Is_Function_Key
           (Key : in Keypress)
        return Boolean is
    begin
        return Key in 16#ffbe# .. 16#ffe0#;
    end Is_Function_Key;


    function Function_Number
           (Key : in Keypress)
        return Function_Key_Number is
    begin
        return Function_Key_Number (Key - 16#ffbd#);
    end Function_Number;


    function Press
           (Key : Pressable_Key)
        return Key_Combo is
    begin
        return This : Key_Combo do
            This.Modcode := Mod_None;
            This.Keycode := Character'Pos (Key);
            This.Mousecode := No_Button;
        end return;
    end Press;


    function Press
           (Key : in Keypress)
        return Key_Combo is
    begin
        return This : Key_Combo do
            This.Modcode := Mod_None;
            This.Keycode := Key;
            This.Mousecode := No_Button;
        end return;
    end Press;


    function Press
           (Key : in Mouse_Button)
        return Key_Combo is
    begin
        return This : Key_Combo do
            This.Modcode := Mod_None;
            This.Keycode := 0;
            This.Mousecode := Key;
        end return;
    end Press;




    function "+"
           (Left, Right : in Modifier)
        return Modifier is
    begin
        return Left or Right;
    end "+";


    function "+"
           (Left  : in Modifier;
            Right : in Pressable_Key)
        return Key_Combo is
    begin
        return This : Key_Combo do
            This.Modcode := Left;
            This.Keycode := Character'Pos (Right);
            This.Mousecode := No_Button;
        end return;
    end "+";


    function "+"
           (Left : in Modifier;
            Right : in Keypress)
        return Key_Combo is
    begin
        return This : Key_Combo do
            This.Modcode := Left;
            This.Keycode := Right;
            This.Mousecode := No_Button;
        end return;
    end "+";


    function "+"
           (Left : in Modifier;
            Right : in Mouse_Button)
        return Key_Combo is
    begin
        return This : Key_Combo do
            This.Modcode := Left;
            This.Keycode := 0;
            This.Mousecode := Right;
        end return;
    end "+";


    function "+"
           (Left  : in Modifier;
            Right : in Key_Combo)
        return Key_Combo is
    begin
        return This : Key_Combo do
            This.Modcode := Left or Right.Modcode;
            This.Keycode := Right.Keycode;
            This.Mousecode := Right.Mousecode;
        end return;
    end "+";




    function fl_static_font_end
        return Interfaces.C.int;
    pragma Import (C, fl_static_font_end, "fl_static_font_end");
    pragma Inline (fl_static_font_end);

    function To_C
           (Font : in Font_Kind)
        return Interfaces.C.int is
    begin
        if Font >= Font_Kind (fl_static_font_end) then
            raise Constraint_Error with "font" & Font_Kind'Image (Font)
                & " is past the last," & Interfaces.C.int'Image (fl_static_font_end - 1);
        end if;
        return Interfaces.C.int (Font);
    end To_C;


    function To_C
           (Key : in Key_Combo)
        return Interfaces.C.unsigned is
    begin
        return To_C (Key.Modcode) + To_C (Key.Keycode) + To_C (Key.Mousecode);
    end To_C;


    function To_Ada
           (Key : in Interfaces.C.unsigned)
        return Key_Combo is
    begin
        return Result : Key_Combo do
            Result.Modcode := To_Ada (Key);
            Result.Keycode := To_Ada (Key);
            --  Only the mouse button bits, FL_BUTTONS (FLTKAda-BUGS.md 72).
            Result.Mousecode := To_Ada (Key and 16#1F00_0000#);
        end return;
    end To_Ada;


    function To_C
           (Key : in Keypress)
        return Interfaces.C.unsigned is
    begin
        return Interfaces.C.unsigned (Key);
    end To_C;


    function To_Ada
           (Key : in Interfaces.C.unsigned)
        return Keypress is
    begin
        return Keypress (Key mod 65536);
    end To_Ada;


    function To_C
           (Modi : in Modifier)
        return Interfaces.C.unsigned is
    begin
        return Interfaces.C.unsigned (Modi) * 65536;
    end To_C;


    function To_Ada
           (Modi : in Interfaces.C.unsigned)
        return Modifier is
    begin
        return Modifier ((Modi / 65536) mod 256);
    end To_Ada;


    function To_C
           (Button : in Mouse_Button)
        return Interfaces.C.unsigned is
    begin
        case Button is
        when No_Button      => return 0;
        when Left_Button    => return fl_enum_button1;
        when Middle_Button  => return fl_enum_button2;
        when Right_Button   => return fl_enum_button3;
        when Back_Button    => return fl_enum_button4;
        when Forward_Button => return fl_enum_button5;
        when Any_Button     => return fl_enum_buttons;
        end case;
    end To_C;


    function To_Ada
           (Button : in Interfaces.C.unsigned)
        return Mouse_Button is
    begin
        if Button = 0 then
            return No_Button;
        elsif Button = fl_enum_button1 then
            return Left_Button;
        elsif Button = fl_enum_button2 then
            return Middle_Button;
        elsif Button = fl_enum_button3 then
            return Right_Button;
        elsif Button = fl_enum_button4 then
            return Back_Button;
        elsif Button = fl_enum_button5 then
            return Forward_Button;
        elsif Button = fl_enum_buttons then
            return Any_Button;
        else
            raise Constraint_Error;
        end if;
    end To_Ada;




    --  Box Types  --

    function Filled
           (Box : in Box_Kind)
        return Box_Kind
    is
        Result : constant Interfaces.C.int := fl_enum_box (Box_Kind'Pos (Box));
    begin
        return Box_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "fl_box in Enumerations.H returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Filled;


    function Frame
           (Box : in Box_Kind)
        return Box_Kind
    is
        Result : constant Interfaces.C.int := fl_enum_frame (Box_Kind'Pos (Box));
    begin
        return Box_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "fl_frame in Enumerations.H returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Frame;


    function Down
           (Box : in Box_Kind)
        return Box_Kind
    is
        Result : constant Interfaces.C.int := fl_enum_down (Box_Kind'Pos (Box));
    begin
        return Box_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "fl_down in Enumerations.H returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Down;




    --  Callback Flags  --

    type Callback_Bitmask is mod 2 ** Interfaces.C.unsigned_char'Size;

    function CFlag_To_Bits is new
        Ada.Unchecked_Conversion (Callback_Flag, Callback_Bitmask);

    function Bits_To_CFlag is new
        Ada.Unchecked_Conversion (Callback_Bitmask, Callback_Flag);


    function "+"
           (Left, Right : in Callback_Flag)
        return Callback_Flag is
    begin
        return Bits_To_CFlag (CFlag_To_Bits (Left) or CFlag_To_Bits (Right));
    end "+";


    function "-"
           (Left, Right : in Callback_Flag)
        return Callback_Flag is
    begin
        return Bits_To_CFlag (CFlag_To_Bits (Left) and not CFlag_To_Bits (Right));
    end "-";




    --  Menu Flags  --

    type Menu_Bitmask is mod 2 ** Interfaces.C.int'Size;

    function MFlag_To_Bits is new
        Ada.Unchecked_Conversion (Menu_Flag, Menu_Bitmask);

    function Bits_To_MFlag is new
        Ada.Unchecked_Conversion (Menu_Bitmask, Menu_Flag);


    function "+"
           (Left, Right : in Menu_Flag)
        return Menu_Flag is
    begin
        return Bits_To_MFlag (MFlag_To_Bits (Left) or MFlag_To_Bits (Right));
    end "+";


    function "-"
           (Left, Right : in Menu_Flag)
        return Menu_Flag is
    begin
        return Bits_To_MFlag (MFlag_To_Bits (Left) and not MFlag_To_Bits (Right));
    end "-";




    --  Damage Bits  --

    type Damage_Bitmask is mod 2 ** Interfaces.C.unsigned_char'Size;

    function Damage_To_Bits is new
        Ada.Unchecked_Conversion (Damage_Mask, Damage_Bitmask);

    function Bits_To_Damage is new
        Ada.Unchecked_Conversion (Damage_Bitmask, Damage_Mask);


    function "+"
           (Left, Right : in Damage_Mask)
        return Damage_Mask is
    begin
        return Bits_To_Damage (Damage_To_Bits (Left) or Damage_To_Bits (Right));
    end "+";


    function "-"
           (Left, Right : in Damage_Mask)
        return Damage_Mask is
    begin
        return Bits_To_Damage (Damage_To_Bits (Left) and not Damage_To_Bits (Right));
    end "-";




    --  Names  --

    function Name_Or_Empty
           (Name : in Interfaces.C.Strings.chars_ptr)
        return String is
    begin
        if Name = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Name);
        end if;
    end Name_Or_Empty;


    function Event_Name
           (Event : in Event_Kind)
        return String is
    begin
        return Name_Or_Empty (fl_names_event (Event_Kind'Pos (Event)));
    end Event_Name;


    function Font_Constant_Name
           (Font : in Font_Kind)
        return String is
    begin
        return Name_Or_Empty (fl_names_font (Interfaces.C.int (Font)));
    end Font_Constant_Name;


    function Reason_Name
           (Reason : in Callback_Reason)
        return String is
    begin
        return Name_Or_Empty (fl_names_reason (Interfaces.C.int (Reason)));
    end Reason_Name;




    --  Versioning  --

    function Built_Version
        return Long_Float is
    begin
        return Long_Float (fl_built_version);
    end Built_Version;


    function Built_API_Version
        return Version_Number is
    begin
        return Version_Number (fl_built_api_version);
    end Built_API_Version;


    function Built_ABI_Version
        return Version_Number is
    begin
        return Version_Number (fl_built_abi_version);
    end Built_ABI_Version;


    function ABI_Check
           (ABI_Ver : in Version_Number := Built_ABI_Version)
        return Boolean is
    begin
        return fl_abi_check (Interfaces.C.int (ABI_Ver)) /= 0;
    end ABI_Check;


    function ABI_Version
        return Version_Number is
    begin
        return Version_Number (fl_abi_version);
    end ABI_Version;


    function API_Version
        return Version_Number is
    begin
        return Version_Number (fl_api_version);
    end API_Version;


    function Version
        return Long_Float is
    begin
        return Long_Float (fl_version);
    end Version;




    --  Event Loop  --

    procedure Check
    is
        Ignore : Interfaces.C.int := fl_check;
    begin
        Hook_Exceptions.Reraise;
    end Check;


    function Check
        return Boolean is
        Result : constant Boolean := fl_check /= 0;
    begin
        Hook_Exceptions.Reraise;
        return Result;
    end Check;


    function Ready
        return Boolean is
    begin
        return fl_ready /= 0;
    end Ready;


    function Wait
        return Integer is
        Result : constant Integer := Integer (fl_wait);
    begin
        Hook_Exceptions.Reraise;
        return Result;
    end Wait;


    function Wait
           (Seconds : in Long_Float)
        return Long_Float is
        Result : constant Long_Float :=
            Long_Float (fl_wait2 (Interfaces.C.double (Seconds)));
    begin
        Hook_Exceptions.Reraise;
        return Result;
    end Wait;


    --  Fl::run is "while (Fl_X::first) wait(FOREVER); return 0;" (Fl.cxx:651-654),
    --  and Fl::wait () returns Fl_X::first != 0 (Fl.cxx:672-676).  Run is that
    --  loop here, so that an exception kept from a hook is raised again after
    --  the wait it was raised in, not when the last window closes.
    function Run
        return Integer is
    begin
        while fl_wait /= 0 loop
            Hook_Exceptions.Reraise;
        end loop;
        Hook_Exceptions.Reraise;
        return 0;
    end Run;




    -------------------
    --  Elaboration  --
    -------------------

    function fl_rgb_image_get_max_size
        return Interfaces.C.size_t;
    pragma Import (C, fl_rgb_image_get_max_size, "fl_rgb_image_get_max_size");

    procedure fl_rgb_image_set_max_size
           (V : in Interfaces.C.size_t);
    pragma Import (C, fl_rgb_image_set_max_size, "fl_rgb_image_set_max_size");

    procedure fl_define_box_and_label_types;
    pragma Import (C, fl_define_box_and_label_types, "fl_define_box_and_label_types");

    procedure fl_shared_image_add_pnm_handler;
    pragma Import (C, fl_shared_image_add_pnm_handler, "fl_shared_image_add_pnm_handler");


begin

    --  FLTK's loaders size an image's array as an int, w () * h () * d ()
    --  (Fl_PNG_Image.cxx:218, Fl_JPEG_Image.cxx:324, Fl_PNM_Image.cxx:139,
    --  Fl_BMP_Image.cxx:285), after checking the size against max_size, which
    --  is unlimited by default (Fl_Image.cxx:335).  A file that claims more
    --  than int'Last bytes overflows the product, and new throws.  With
    --  max_size at most int'Last, the check refuses it (FLTK-issues.md, F7).
    if fl_rgb_image_get_max_size > Interfaces.C.size_t (Interfaces.C.int'Last) then
        fl_rgb_image_set_max_size (Interfaces.C.size_t (Interfaces.C.int'Last));
    end if;

    --  Box and label types such as Round_Up_Box and Shadow_Label draw as a
    --  stand-in until FLTK's fl_define_FL_* functions are called for them
    --  (pofltk 8).  Multi_Label, Icon_Label and Image_Label stay undefined,
    --  since FLTK would read a plain text label as a pointer for them.
    fl_define_box_and_label_types;

    --  A shared image of a binary PNM with a maxval under 255 is scaled,
    --  by a handler that comes before fl_register_images' (pofltk 45).
    fl_shared_image_add_pnm_handler;

end FLTK;


