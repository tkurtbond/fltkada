

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Asks is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Static Attributes  --

    function fl_ask_get_cancel
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_get_cancel, "fl_ask_get_cancel");
    pragma Inline (fl_ask_get_cancel);

    procedure fl_ask_set_cancel
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_ask_set_cancel, "fl_ask_set_cancel");
    pragma Inline (fl_ask_set_cancel);

    function fl_ask_get_close
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_get_close, "fl_ask_get_close");
    pragma Inline (fl_ask_get_close);

    procedure fl_ask_set_close
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_ask_set_close, "fl_ask_set_close");
    pragma Inline (fl_ask_set_close);

    function fl_ask_get_no
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_get_no, "fl_ask_get_no");
    pragma Inline (fl_ask_get_no);

    procedure fl_ask_set_no
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_ask_set_no, "fl_ask_set_no");
    pragma Inline (fl_ask_set_no);

    function fl_ask_get_ok
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_get_ok, "fl_ask_get_ok");
    pragma Inline (fl_ask_get_ok);

    procedure fl_ask_set_ok
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_ask_set_ok, "fl_ask_set_ok");
    pragma Inline (fl_ask_set_ok);

    function fl_ask_get_yes
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_get_yes, "fl_ask_get_yes");
    pragma Inline (fl_ask_get_yes);

    procedure fl_ask_set_yes
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_ask_set_yes, "fl_ask_set_yes");
    pragma Inline (fl_ask_set_yes);




    --  Simple Messages  --

    procedure fl_ask_alert
           (M : in Interfaces.C.char_array);
    pragma Import (C, fl_ask_alert, "fl_ask_alert");
    pragma Inline (fl_ask_alert);

    procedure fl_ask_beep
           (B : in Interfaces.C.int);
    pragma Import (C, fl_ask_beep, "fl_ask_beep");
    pragma Inline (fl_ask_beep);

    function fl_ask_choice
           (M, A : in Interfaces.C.char_array;
            B, C : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.int;
    pragma Import (C, fl_ask_choice, "fl_ask_choice");
    pragma Inline (fl_ask_choice);

    function fl_ask_choice_n
           (M, A : in Interfaces.C.char_array;
            B, C : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.int;
    pragma Import (C, fl_ask_choice_n, "fl_ask_choice_n");
    pragma Inline (fl_ask_choice_n);

    function fl_ask_input
           (M, D : in Interfaces.C.char_array)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_input, "fl_ask_input");
    pragma Inline (fl_ask_input);

    procedure fl_ask_message
           (M : in Interfaces.C.char_array);
    pragma Import (C, fl_ask_message, "fl_ask_message");
    pragma Inline (fl_ask_message);

    function fl_ask_password
           (M, D : in Interfaces.C.char_array)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_password, "fl_ask_password");
    pragma Inline (fl_ask_password);




    --  Choosers  --

    function fl_ask_color_chooser
           (N       : in     Interfaces.C.char_array;
            R, G, B : in out Interfaces.C.double;
            M       : in     Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_ask_color_chooser, "fl_ask_color_chooser");
    pragma Inline (fl_ask_color_chooser);

    function fl_ask_color_chooser2
           (N       : in     Interfaces.C.char_array;
            R, G, B : in out Interfaces.C.unsigned_char;
            M       : in     Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_ask_color_chooser2, "fl_ask_color_chooser2");
    pragma Inline (fl_ask_color_chooser2);

    function fl_ask_show_colormap
           (H : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_ask_show_colormap, "fl_ask_show_colormap");
    pragma Inline (fl_ask_show_colormap);

    function fl_ask_dir_chooser
           (M, D : in Interfaces.C.char_array;
            R    : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_dir_chooser, "fl_ask_dir_chooser");
    pragma Inline (fl_ask_dir_chooser);

    function fl_ask_file_chooser
           (M, P, D : in Interfaces.C.char_array;
            R       : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_ask_file_chooser, "fl_ask_file_chooser");
    pragma Inline (fl_ask_file_chooser);

    procedure fl_ask_file_chooser_callback
           (CB : in Storage.Integer_Address);
    pragma Import (C, fl_ask_file_chooser_callback, "fl_ask_file_chooser_callback");
    pragma Inline (fl_ask_file_chooser_callback);

    procedure fl_ask_file_chooser_ok_label
           (L : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_ask_file_chooser_ok_label, "fl_ask_file_chooser_ok_label");
    pragma Inline (fl_ask_file_chooser_ok_label);




    --  Settings  --

    function fl_ask_get_message_hotspot
        return Interfaces.C.int;
    pragma Import (C, fl_ask_get_message_hotspot, "fl_ask_get_message_hotspot");
    pragma Inline (fl_ask_get_message_hotspot);

    procedure fl_ask_set_message_hotspot
           (V : in Interfaces.C.int);
    pragma Import (C, fl_ask_set_message_hotspot, "fl_ask_set_message_hotspot");
    pragma Inline (fl_ask_set_message_hotspot);

    procedure fl_ask_message_font
           (F, S : in Interfaces.C.int);
    pragma Import (C, fl_ask_message_font, "fl_ask_message_font");
    pragma Inline (fl_ask_message_font);

    function fl_ask_get_message_font
        return Interfaces.C.int;
    pragma Import (C, fl_ask_get_message_font, "fl_ask_get_message_font");
    pragma Inline (fl_ask_get_message_font);

    function fl_ask_get_message_size
        return Interfaces.C.int;
    pragma Import (C, fl_ask_get_message_size, "fl_ask_get_message_size");
    pragma Inline (fl_ask_get_message_size);

    function fl_ask_message_icon
        return Storage.Integer_Address;
    pragma Import (C, fl_ask_message_icon, "fl_ask_message_icon");
    pragma Inline (fl_ask_message_icon);

    procedure fl_ask_message_title
           (T : in Interfaces.C.char_array);
    pragma Import (C, fl_ask_message_title, "fl_ask_message_title");
    pragma Inline (fl_ask_message_title);

    procedure fl_ask_message_title_default
           (T : in Interfaces.C.char_array);
    pragma Import (C, fl_ask_message_title_default, "fl_ask_message_title_default");
    pragma Inline (fl_ask_message_title_default);

    procedure fl_ask_message_icon_label
           (T : in Interfaces.C.char_array);
    pragma Import (C, fl_ask_message_icon_label, "fl_ask_message_icon_label");
    pragma Inline (fl_ask_message_icon_label);

    procedure fl_ask_message_icon_label_default
           (T : in Interfaces.C.char_array);
    pragma Import (C, fl_ask_message_icon_label_default, "fl_ask_message_icon_label_default");
    pragma Inline (fl_ask_message_icon_label_default);

    procedure fl_ask_set_message_position
           (X, Y, C : in Interfaces.C.int);
    pragma Import (C, fl_ask_set_message_position, "fl_ask_set_message_position");
    pragma Inline (fl_ask_set_message_position);

    procedure fl_ask_set_message_position_over
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_ask_set_message_position_over, "fl_ask_set_message_position_over");
    pragma Inline (fl_ask_set_message_position_over);

    function fl_ask_get_message_position
           (X, Y : out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_ask_get_message_position, "fl_ask_get_message_position");
    pragma Inline (fl_ask_get_message_position);




    ---------------------
    --  Callback Hook  --
    ---------------------

    procedure File_Chooser_Callback_Hook
           (C_Str : in Interfaces.C.Strings.chars_ptr);

    pragma Convention (C, File_Chooser_Callback_Hook);

    procedure File_Chooser_Callback_Hook
           (C_Str : in Interfaces.C.Strings.chars_ptr) is
    begin
        if Chooser_Func /= null then
            Chooser_Func (Interfaces.C.Strings.Value (C_Str));
        end if;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end File_Chooser_Callback_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Dialog_String_Final_Controller)
    is
        use Interfaces.C.Strings;
    begin
        Free (Cancel_Str);
        Free (Close_Str);
        Free (No_Str);
        Free (OK_Str);
        Free (Yes_Str);
        Free (Chooser_OK_Str);
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  You can get out of a hole by digging deeper, right?
    procedure fl_box_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_box_extra_init, "fl_box_extra_init");
    pragma Inline (fl_box_extra_init);




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Static Attributes  --

    function Get_Cancel_String
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_ask_get_cancel);
    end Get_Cancel_String;


    procedure Set_Cancel_String
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Cancel_Str);
        Cancel_Str := Interfaces.C.Strings.New_String (Value);
        fl_ask_set_cancel (Cancel_Str);
    end Set_Cancel_String;


    function Get_Close_String
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_ask_get_close);
    end Get_Close_String;


    procedure Set_Close_String
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Close_Str);
        Close_Str := Interfaces.C.Strings.New_String (Value);
        fl_ask_set_close (Close_Str);
    end Set_Close_String;


    function Get_No_String
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_ask_get_no);
    end Get_No_String;


    procedure Set_No_String
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (No_Str);
        No_Str := Interfaces.C.Strings.New_String (Value);
        fl_ask_set_no (No_Str);
    end Set_No_String;


    function Get_OK_String
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_ask_get_ok);
    end Get_OK_String;


    procedure Set_OK_String
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (OK_Str);
        OK_Str := Interfaces.C.Strings.New_String (Value);
        fl_ask_set_ok (OK_Str);
    end Set_OK_String;


    function Get_Yes_String
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_ask_get_yes);
    end Get_Yes_String;


    procedure Set_Yes_String
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Yes_Str);
        Yes_Str := Interfaces.C.Strings.New_String (Value);
        fl_ask_set_yes (Yes_Str);
    end Set_Yes_String;




    --  Simple Messages  --

    procedure Alert
           (Message : String) is
    begin
        fl_ask_alert (Interfaces.C.To_C (Message));
        Hook_Exceptions.Reraise;
    end Alert;


    procedure Beep
           (Kind : in Beep_Kind := Default_Beep) is
    begin
        fl_ask_beep (Beep_Kind'Pos (Kind));
    end Beep;


    function Choice
           (Message, Button1 : in String)
        return Choice_Result
    is
        Result : constant Interfaces.C.int := fl_ask_choice
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.Null_Ptr,
            Interfaces.C.Strings.Null_Ptr);
    begin
        Hook_Exceptions.Reraise;
        begin
            return Choice_Result'Val (Result);
        exception
        when Constraint_Error => raise Internal_FLTK_Error with
            "fl_choice returned unexpected int value of " &
            Interfaces.C.int'Image (Result);
        end;
    end Choice;


    function Choice
           (Message, Button1, Button2 : in String)
        return Choice_Result
    is
        Str2 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button2);
        Result : constant Interfaces.C.int := fl_ask_choice
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.To_Chars_Ptr (Str2'Unchecked_Access),
            Interfaces.C.Strings.Null_Ptr);
    begin
        Hook_Exceptions.Reraise;
        begin
            return Choice_Result'Val (Result);
        exception
        when Constraint_Error => raise Internal_FLTK_Error with
            "fl_choice returned unexpected int value of " &
            Interfaces.C.int'Image (Result);
        end;
    end Choice;


    function Choice
           (Message, Button1, Button2, Button3 : in String)
        return Choice_Result
    is
        Str2 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button2);
        Str3 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button3);
        Result : constant Interfaces.C.int := fl_ask_choice
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.To_Chars_Ptr (Str2'Unchecked_Access),
            Interfaces.C.Strings.To_Chars_Ptr (Str3'Unchecked_Access));
    begin
        Hook_Exceptions.Reraise;
        begin
            return Choice_Result'Val (Result);
        exception
        when Constraint_Error => raise Internal_FLTK_Error with
            "fl_choice returned unexpected int value of " &
            Interfaces.C.int'Image (Result);
        end;
    end Choice;


    function Extended_Choice
           (Message, Button1 : in String)
        return Extended_Choice_Result
    is
        Result : constant Interfaces.C.int := fl_ask_choice_n
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.Null_Ptr,
            Interfaces.C.Strings.Null_Ptr);
    begin
        Hook_Exceptions.Reraise;
        begin
            pragma Assert (Result in -3 .. 2);
            return Extended_Choice_Result'Val (Result mod 6);
        exception
        when Chk.Assertion_Error => raise Internal_FLTK_Error with
            "fl_choice_n returned unexpected int value of " &
            Interfaces.C.int'Image (Result);
        end;
    end Extended_Choice;


    function Extended_Choice
           (Message, Button1, Button2 : in String)
        return Extended_Choice_Result
    is
        Str2 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button2);
        Result : constant Interfaces.C.int := fl_ask_choice_n
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.To_Chars_Ptr (Str2'Unchecked_Access),
            Interfaces.C.Strings.Null_Ptr);
    begin
        Hook_Exceptions.Reraise;
        begin
            pragma Assert (Result in -3 .. 2);
            return Extended_Choice_Result'Val (Result mod 6);
        exception
        when Chk.Assertion_Error => raise Internal_FLTK_Error with
            "fl_choice_n returned unexpected int value of " &
            Interfaces.C.int'Image (Result);
        end;
    end Extended_Choice;


    function Extended_Choice
           (Message, Button1, Button2, Button3 : in String)
        return Extended_Choice_Result
    is
        Str2 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button2);
        Str3 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button3);
        Result : constant Interfaces.C.int := fl_ask_choice_n
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.To_Chars_Ptr (Str2'Unchecked_Access),
            Interfaces.C.Strings.To_Chars_Ptr (Str3'Unchecked_Access));
    begin
        Hook_Exceptions.Reraise;
        begin
            pragma Assert (Result in -3 .. 2);
            return Extended_Choice_Result'Val (Result mod 6);
        exception
        when Chk.Assertion_Error => raise Internal_FLTK_Error with
            "fl_choice_n returned unexpected int value of " &
            Interfaces.C.int'Image (Result);
        end;
    end Extended_Choice;


    function Text_Input
           (Message : in String;
            Default : in String := "")
        return String
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_ask_input
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Default));
    begin
        Hook_Exceptions.Reraise;
        --  Result does not need dealloc
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Text_Input;


    procedure Message_Box
           (Message : in String) is
    begin
        fl_ask_message (Interfaces.C.To_C (Message));
        Hook_Exceptions.Reraise;
    end Message_Box;


    function Password
           (Message : in String;
            Default : in String := "")
        return String
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_ask_password
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Default));
    begin
        Hook_Exceptions.Reraise;
        --  Result does not need dealloc
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Password;


    --  Confirm, with Answer set to the text FLTK gave, or Cancel for none.
    function To_Answer
           (Result : in     Interfaces.C.Strings.chars_ptr;
            Answer : in out Ada.Strings.Unbounded.Unbounded_String)
        return Confirm_Result is
    begin
        if Result = Interfaces.C.Strings.Null_Ptr then
            return Cancel;
        end if;
        Answer := Ada.Strings.Unbounded.To_Unbounded_String (Interfaces.C.Strings.Value (Result));
        return Confirm;
    end To_Answer;


    function Text_Input
           (Message : in     String;
            Answer  : in out Ada.Strings.Unbounded.Unbounded_String)
        return Confirm_Result
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_ask_input
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Ada.Strings.Unbounded.To_String (Answer)));
    begin
        Hook_Exceptions.Reraise;
        --  Result does not need dealloc
        return To_Answer (Result, Answer);
    end Text_Input;


    function Password
           (Message : in     String;
            Answer  : in out Ada.Strings.Unbounded.Unbounded_String)
        return Confirm_Result
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_ask_password
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Ada.Strings.Unbounded.To_String (Answer)));
    begin
        Hook_Exceptions.Reraise;
        --  Result does not need dealloc
        return To_Answer (Result, Answer);
    end Password;




    --  Choosers  --

    function Color_Chooser
           (Title   : in     String;
            R, G, B : in out RGB_Float;
            Mode    : in     FLTK.Widgets.Groups.Color_Choosers.Color_Mode :=
                FLTK.Widgets.Groups.Color_Choosers.RGB)
        return Confirm_Result
    is
        C_R : Interfaces.C.double := Interfaces.C.double (R);
        C_G : Interfaces.C.double := Interfaces.C.double (G);
        C_B : Interfaces.C.double := Interfaces.C.double (B);
        M : constant Interfaces.C.int := FLTK.Widgets.Groups.Color_Choosers.Color_Mode'Pos (Mode);
        Result : constant Interfaces.C.int := fl_ask_color_chooser
            (Interfaces.C.To_C (Title), C_R, C_G, C_B, M);
    begin
        Hook_Exceptions.Reraise;
        begin
            if Result = 1 then
                R := RGB_Float (C_R);
                G := RGB_Float (C_G);
                B := RGB_Float (C_B);
                return Confirm;
            else
                pragma Assert (Result = 0);
                return Cancel;
            end if;
        exception
        when Chk.Assertion_Error => raise Internal_FLTK_Error with
            "fl_color_chooser returned unexpected int value of " &
            Interfaces.C.int'Image (Result);
        end;
    end Color_Chooser;


    function Color_Chooser
           (Title   : in     String;
            R, G, B : in out RGB_Int;
            Mode    : in     FLTK.Widgets.Groups.Color_Choosers.Color_Mode :=
                FLTK.Widgets.Groups.Color_Choosers.RGB)
        return Confirm_Result
    is
        C_R : Interfaces.C.unsigned_char := Interfaces.C.unsigned_char (R);
        C_G : Interfaces.C.unsigned_char := Interfaces.C.unsigned_char (G);
        C_B : Interfaces.C.unsigned_char := Interfaces.C.unsigned_char (B);
        M : constant Interfaces.C.int := FLTK.Widgets.Groups.Color_Choosers.Color_Mode'Pos (Mode);
        Result : constant Interfaces.C.int := fl_ask_color_chooser2
               (Interfaces.C.To_C (Title), C_R, C_G, C_B, M);
    begin
        Hook_Exceptions.Reraise;
        begin
            if Result = 1 then
                R := RGB_Int (C_R);
                G := RGB_Int (C_G);
                B := RGB_Int (C_B);
                return Confirm;
            else
                pragma Assert (Result = 0);
                return Cancel;
            end if;
        exception
        when Chk.Assertion_Error => raise Internal_FLTK_Error with
            "fl_color_chooser returned unexpected int value of " &
            Interfaces.C.int'Image (Result);
        end;
    end Color_Chooser;


    function Show_Colormap
           (Old_Hue : in Color)
        return Color
    is
        Result : constant Color :=
            Color (fl_ask_show_colormap (Interfaces.C.unsigned (Old_Hue)));
    begin
        Hook_Exceptions.Reraise;
        return Result;
    end Show_Colormap;


    function Dir_Chooser
           (Message, Default : in String;
            Relative         : in Boolean := False)
        return String
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_ask_dir_chooser
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Default),
                Boolean'Pos (Relative));
    begin
        Hook_Exceptions.Reraise;
        --  Result does not need dealloc
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Dir_Chooser;


    function File_Chooser
           (Message, Filter_Pattern, Default : in String;
            Relative                         : in Boolean := False)
        return String
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_ask_file_chooser
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Filter_Pattern),
                Interfaces.C.To_C (Default),
                Boolean'Pos (Relative));
    begin
        Hook_Exceptions.Reraise;
        --  Result does not need dealloc
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end File_Chooser;


    function Dir_Chooser
           (Message  : in     String;
            Answer   : in out Ada.Strings.Unbounded.Unbounded_String;
            Relative : in     Boolean := False)
        return Confirm_Result
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_ask_dir_chooser
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Ada.Strings.Unbounded.To_String (Answer)),
                Boolean'Pos (Relative));
    begin
        Hook_Exceptions.Reraise;
        --  Result does not need dealloc
        return To_Answer (Result, Answer);
    end Dir_Chooser;


    function File_Chooser
           (Message, Filter_Pattern : in     String;
            Answer                  : in out Ada.Strings.Unbounded.Unbounded_String;
            Relative                : in     Boolean := False)
        return Confirm_Result
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_ask_file_chooser
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Filter_Pattern),
                Interfaces.C.To_C (Ada.Strings.Unbounded.To_String (Answer)),
                Boolean'Pos (Relative));
    begin
        Hook_Exceptions.Reraise;
        --  Result does not need dealloc
        return To_Answer (Result, Answer);
    end File_Chooser;


    procedure Set_File_Chooser_Callback
           (Func : in File_Chooser_Callback) is
    begin
        Chooser_Func := Func;
    end Set_File_Chooser_Callback;


    procedure Set_File_Chooser_OK_String
           (Value : in String) is
    begin
        Interfaces.C.Strings.Free (Chooser_OK_Str);
        Chooser_OK_Str := Interfaces.C.Strings.New_String (Value);
        fl_ask_file_chooser_ok_label (Chooser_OK_Str);
    end Set_File_Chooser_OK_String;




    --  Settings  --

    function Get_Message_Hotspot
        return Boolean is
    begin
        return fl_ask_get_message_hotspot /= 0;
    end Get_Message_Hotspot;


    procedure Set_Message_Hotspot
           (To : in Boolean) is
    begin
        fl_ask_set_message_hotspot (Boolean'Pos (To));
    end Set_Message_Hotspot;


    function Get_Message_Font
        return Font_Kind is
    begin
        return Font_Kind (fl_ask_get_message_font);
    end Get_Message_Font;


    function Get_Message_Size
        return Font_Size is
    begin
        return Font_Size (fl_ask_get_message_size);
    end Get_Message_Size;


    procedure Set_Message_Font
           (Font : in Font_Kind;
            Size : in Font_Size) is
    begin
        fl_ask_message_font (To_C (Font), Interfaces.C.int (Size));
    end Set_Message_Font;


    function Get_Message_Icon
        return FLTK.Widgets.Boxes.Box_Reference is
    begin
        return (Data => Icon_Box'Access);
    end Get_Message_Icon;


    procedure Set_Message_Title
           (To : in String) is
    begin
        fl_ask_message_title (Interfaces.C.To_C (To));
    end Set_Message_Title;


    procedure Set_Message_Title_Default
           (To : in String) is
    begin
        fl_ask_message_title_default (Interfaces.C.To_C (To));
    end Set_Message_Title_Default;


    procedure Set_Message_Icon_Label
           (To : in String) is
    begin
        fl_ask_message_icon_label (Interfaces.C.To_C (To));
    end Set_Message_Icon_Label;


    procedure Set_Message_Icon_Label_Default
           (To : in String) is
    begin
        fl_ask_message_icon_label_default (Interfaces.C.To_C (To));
    end Set_Message_Icon_Label_Default;


    procedure Set_Message_Position
           (X, Y     : in Integer;
            Centered : in Boolean := False) is
    begin
        fl_ask_set_message_position
           (Interfaces.C.int (X), Interfaces.C.int (Y), Boolean'Pos (Centered));
    end Set_Message_Position;


    procedure Set_Message_Position_Over
           (Item : in FLTK.Widgets.Widget'Class) is
    begin
        if Wrapper (Item).Void_Ptr = Null_Pointer then
            raise Program_Error with "Set_Message_Position_Over given a widget with no FLTK object";
        end if;
        fl_ask_set_message_position_over (Wrapper (Item).Void_Ptr);
    end Set_Message_Position_Over;


    procedure Get_Message_Position
           (X, Y : out Integer;
            Kind : out Message_Position_Kind)
    is
        C_X, C_Y : Interfaces.C.int;
        Result   : constant Interfaces.C.int := fl_ask_get_message_position (C_X, C_Y);
    begin
        if Result not in 0 .. 2 then
            raise Internal_FLTK_Error with
                "fl_message_position returned unknown kind " & Interfaces.C.int'Image (Result);
        end if;
        X := Integer (C_X);
        Y := Integer (C_Y);
        Kind := Message_Position_Kind'Val (Result);
    end Get_Message_Position;


begin


    Wrapper (Icon_Box).Void_Ptr := fl_ask_message_icon;
    Wrapper (Icon_Box).Needs_Dealloc := False;
    fl_box_extra_init
       (Storage.To_Integer (Icon_Box'Address),
        Interfaces.C.int (Icon_Box.Get_X),
        Interfaces.C.int (Icon_Box.Get_Y),
        Interfaces.C.int (Icon_Box.Get_W),
        Interfaces.C.int (Icon_Box.Get_H),
        Interfaces.C.To_C (Icon_Box.Get_Label));


    fl_ask_file_chooser_callback (Storage.To_Integer (File_Chooser_Callback_Hook'Address));


end FLTK.Asks;


