

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Asks is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Functions From C  --
    ------------------------

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
    end File_Chooser_Callback_Hook;




    ---------------
    --  Cleanup  --
    ---------------

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




    ------------------
    --  Attributes  --
    ------------------

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




    ----------------------
    --  Common Dialogs  --
    ----------------------

    procedure Alert
           (Message : String) is
    begin
        fl_ask_alert (Interfaces.C.To_C (Message));
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
        Result : Interfaces.C.int := fl_ask_choice
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.Null_Ptr,
            Interfaces.C.Strings.Null_Ptr);
    begin
        return Choice_Result'Val (Result);
    end Choice;


    function Choice
           (Message, Button1, Button2 : in String)
        return Choice_Result
    is
        Str2 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button2);
        Result : Interfaces.C.int := fl_ask_choice
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.To_Chars_Ptr (Str2'Unchecked_Access),
            Interfaces.C.Strings.Null_Ptr);
    begin
        return Choice_Result'Val (Result);
    end Choice;


    function Choice
           (Message, Button1, Button2, Button3 : in String)
        return Choice_Result
    is
        Str2 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button2);
        Str3 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button3);
        Result : Interfaces.C.int := fl_ask_choice
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.To_Chars_Ptr (Str2'Unchecked_Access),
            Interfaces.C.Strings.To_Chars_Ptr (Str3'Unchecked_Access));
    begin
        return Choice_Result'Val (Result);
    end Choice;


    function Extended_Choice
           (Message, Button1 : in String)
        return Extended_Choice_Result
    is
        Result : Interfaces.C.int := fl_ask_choice_n
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.Null_Ptr,
            Interfaces.C.Strings.Null_Ptr);
    begin
        pragma Assert (Result in -3 .. 2);
        return Extended_Choice_Result'Val (Result mod 6);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error;
    end Extended_Choice;


    function Extended_Choice
           (Message, Button1, Button2 : in String)
        return Extended_Choice_Result
    is
        Str2 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button2);
        Result : Interfaces.C.int := fl_ask_choice_n
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.To_Chars_Ptr (Str2'Unchecked_Access),
            Interfaces.C.Strings.Null_Ptr);
    begin
        pragma Assert (Result in -3 .. 2);
        return Extended_Choice_Result'Val (Result mod 6);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error;
    end Extended_Choice;


    function Extended_Choice
           (Message, Button1, Button2, Button3 : in String)
        return Extended_Choice_Result
    is
        Str2 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button2);
        Str3 : aliased Interfaces.C.char_array := Interfaces.C.To_C (Button3);
        Result : Interfaces.C.int := fl_ask_choice_n
           (Interfaces.C.To_C (Message),
            Interfaces.C.To_C (Button1),
            Interfaces.C.Strings.To_Chars_Ptr (Str2'Unchecked_Access),
            Interfaces.C.Strings.To_Chars_Ptr (Str3'Unchecked_Access));
    begin
        pragma Assert (Result in -3 .. 2);
        return Extended_Choice_Result'Val (Result mod 6);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error;
    end Extended_Choice;


    function Text_Input
           (Message : in String;
            Default : in String := "")
        return String
    is
        Result : Interfaces.C.Strings.chars_ptr := fl_ask_input
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Default));
    begin
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
    end Message_Box;


    function Password
           (Message : in String;
            Default : in String := "")
        return String
    is
        Result : Interfaces.C.Strings.chars_ptr := fl_ask_password
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Default));
    begin
        --  Result does not need dealloc
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Password;




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
        M : Interfaces.C.int := FLTK.Widgets.Groups.Color_Choosers.Color_Mode'Pos (Mode);
        Result : Interfaces.C.int := fl_ask_color_chooser
            (Interfaces.C.To_C (Title), C_R, C_G, C_B, M);
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
    when Chk.Assertion_Error => raise Internal_FLTK_Error;
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
        M : Interfaces.C.int := FLTK.Widgets.Groups.Color_Choosers.Color_Mode'Pos (Mode);
        Result : Interfaces.C.int := fl_ask_color_chooser2
               (Interfaces.C.To_C (Title), C_R, C_G, C_B, M);
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
    when Chk.Assertion_Error => raise Internal_FLTK_Error;
    end Color_Chooser;


    function Dir_Chooser
           (Message, Default : in String;
            Relative         : in Boolean := False)
        return String
    is
        Result : Interfaces.C.Strings.chars_ptr := fl_ask_dir_chooser
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Default),
                Boolean'Pos (Relative));
    begin
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
        Result : Interfaces.C.Strings.chars_ptr := fl_ask_file_chooser
               (Interfaces.C.To_C (Message),
                Interfaces.C.To_C (Filter_Pattern),
                Interfaces.C.To_C (Default),
                Boolean'Pos (Relative));
    begin
        --  Result does not need dealloc
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
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


    procedure Set_Message_Font
           (Font : in Font_Kind;
            Size : in Font_Size) is
    begin
        fl_ask_message_font (Font_Kind'Pos (Font), Interfaces.C.int (Size));
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




begin


    Wrapper (Icon_Box).Void_Ptr := fl_ask_message_icon;
    Wrapper (Icon_Box).Needs_Dealloc := False;

    fl_ask_file_chooser_callback (Storage.To_Integer (File_Chooser_Callback_Hook'Address));


end FLTK.Asks;

