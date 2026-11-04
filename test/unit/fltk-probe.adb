

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.unsigned;


package body FLTK.Probe is


    package C renames Interfaces.C;
    package CS renames Interfaces.C.Strings;


    ------------------------
    --  Functions From C  --
    ------------------------

    function fl_probe_capture
           (W : in Storage.Integer_Address)
        return C.int;
    pragma Import (C, fl_probe_capture, "fl_probe_capture");

    function fl_probe_pixel
           (X, Y : in C.int)
        return C.int;
    pragma Import (C, fl_probe_pixel, "fl_probe_pixel");

    procedure fl_probe_release;
    pragma Import (C, fl_probe_release, "fl_probe_release");

    function fl_probe_shown_pixel
           (W    : in Storage.Integer_Address;
            X, Y : in C.int)
        return C.int;
    pragma Import (C, fl_probe_shown_pixel, "fl_probe_shown_pixel");

    function fl_probe_mouse
           (W                     : in Storage.Integer_Address;
            E, X, Y, B, S, Clicks : in C.int)
        return C.int;
    pragma Import (C, fl_probe_mouse, "fl_probe_mouse");

    function fl_probe_wheel
           (W              : in Storage.Integer_Address;
            X, Y, DX, DY   : in C.int)
        return C.int;
    pragma Import (C, fl_probe_wheel, "fl_probe_wheel");

    function fl_probe_key
           (E, K, S : in C.int;
            T       : in C.char_array)
        return C.int;
    pragma Import (C, fl_probe_key, "fl_probe_key");

    function fl_probe_shortcut
           (W    : in Storage.Integer_Address;
            K, S : in C.int;
            T    : in C.char_array)
        return C.int;
    pragma Import (C, fl_probe_shortcut, "fl_probe_shortcut");

    function fl_probe_handle_key
           (W       : in Storage.Integer_Address;
            E, K, S : in C.int;
            T       : in C.char_array)
        return C.int;
    pragma Import (C, fl_probe_handle_key, "fl_probe_handle_key");

    procedure fl_probe_set_key
           (K : in C.int;
            T : in C.char_array);
    pragma Import (C, fl_probe_set_key, "fl_probe_set_key");

    function fl_probe_modal
        return C.int;
    pragma Import (C, fl_probe_modal, "fl_probe_modal");

    function fl_probe_grabbed
        return C.int;
    pragma Import (C, fl_probe_grabbed, "fl_probe_grabbed");

    function fl_probe_modal_title
        return CS.chars_ptr;
    pragma Import (C, fl_probe_modal_title, "fl_probe_modal_title");

    function fl_probe_modal_h
        return C.int;
    pragma Import (C, fl_probe_modal_h, "fl_probe_modal_h");

    function fl_probe_modal_key
           (K, S : in C.int;
            T    : in C.char_array)
        return C.int;
    pragma Import (C, fl_probe_modal_key, "fl_probe_modal_key");

    function fl_probe_close_modal
        return C.int;
    pragma Import (C, fl_probe_close_modal, "fl_probe_close_modal");

    function fl_probe_has_label
           (T : in C.char_array)
        return C.int;
    pragma Import (C, fl_probe_has_label, "fl_probe_has_label");

    procedure fl_probe_printer_uses_gtk
           (On : in C.int);
    pragma Import (C, fl_probe_printer_uses_gtk, "fl_probe_printer_uses_gtk");

    function fl_probe_configured
           (F : in C.int)
        return C.int;
    pragma Import (C, fl_probe_configured, "fl_probe_configured");

    function fl_probe_on_wayland
        return C.int;
    pragma Import (C, fl_probe_on_wayland, "fl_probe_on_wayland");

    function fl_probe_shared_width
           (N : in C.char_array)
        return C.int;
    pragma Import (C, fl_probe_shared_width, "fl_probe_shared_width");

    procedure fl_probe_clipboard_notice
           (S : in C.int);
    pragma Import (C, fl_probe_clipboard_notice, "fl_probe_clipboard_notice");

    type FD_Pair is array (1 .. 2) of C.int;
    pragma Convention (C, FD_Pair);

    function fl_probe_pipe
           (FDs : out FD_Pair)
        return C.int;
    pragma Import (C, fl_probe_pipe, "fl_probe_pipe");

    function fl_probe_write
           (FD : in C.int;
            S  : in C.char_array;
            N  : in C.int)
        return C.int;
    pragma Import (C, fl_probe_write, "fl_probe_write");

    function fl_probe_read
           (FD  : in C.int;
            Buf : out C.char_array;
            N   : in C.int)
        return C.int;
    pragma Import (C, fl_probe_read, "fl_probe_read");

    procedure fl_probe_close
           (FD : in C.int);
    pragma Import (C, fl_probe_close, "fl_probe_close");

    procedure fl_probe_setenv
           (N, V : in C.char_array);
    pragma Import (C, fl_probe_setenv, "fl_probe_setenv");




    -------------------
    --  Conversions  --
    -------------------

    function Ptr
           (Item : in Wrapper'Class)
        return Storage.Integer_Address is
    begin
        if Item.Void_Ptr = Null_Pointer then
            raise Probe_Error with "the widget has no C++ object";
        end if;
        return Item.Void_Ptr;
    end Ptr;


    function Event_Number
           (Event : in Event_Kind)
        return C.int is
    begin
        return Event_Kind'Pos (Event);
    end Event_Number;


    function State_Bits
           (State : in Modifier)
        return C.int is
    begin
        return C.int (To_C (State));
    end State_Bits;


    function Key_Number
           (Code : in Keypress)
        return C.int is
    begin
        return C.int (To_C (Code));
    end Key_Number;


    --  FLTK's button number, 1 to 3 (or 4, 5), for FL_Button + n.
    function Button_Number
           (Button : in Mouse_Button)
        return C.int is
    begin
        case Button is
        when No_Button | Any_Button => return 0;
        when Left_Button            => return 1;
        when Middle_Button          => return 2;
        when Right_Button           => return 3;
        when Back_Button            => return 4;
        when Forward_Button         => return 5;
        end case;
    end Button_Number;


    function To_RGB
           (Value : in C.int)
        return RGB is
    begin
        return RGB (Value);
    end To_RGB;




    --------------
    --  Pixels  --
    --------------

    function To_RGB
           (R, G, B : in Natural)
        return RGB is
    begin
        if R > 255 or G > 255 or B > 255 then
            raise Constraint_Error with "a colour component is over 255";
        end if;
        return R * 16#1_0000# + G * 16#100# + B;
    end To_RGB;


    function Capture
           (Item : in FLTK.Widgets.Widget'Class)
        return Boolean
    is
        Result : Boolean;
    begin
        Result := fl_probe_capture (Ptr (Item)) /= 0;
        Hook_Exceptions.Reraise;
        return Result;
    end Capture;


    function Pixel
           (X, Y : in Integer)
        return RGB is
    begin
        return To_RGB (fl_probe_pixel (C.int (X), C.int (Y)));
    end Pixel;


    procedure Release is
    begin
        fl_probe_release;
    end Release;


    function Shown_Pixel
           (Item : in FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y : in Integer)
        return RGB
    is
        Result : RGB;
    begin
        Result := To_RGB (fl_probe_shown_pixel (Ptr (Item), C.int (X), C.int (Y)));
        Hook_Exceptions.Reraise;
        return Result;
    end Shown_Pixel;




    --------------
    --  Events  --
    --------------

    function Mouse
           (Win    : in FLTK.Widgets.Groups.Windows.Window'Class;
            Event  : in Event_Kind;
            X, Y   : in Integer;
            Button : in Mouse_Button := Left_Button;
            State  : in Modifier     := Mod_None;
            Clicks : in Natural      := 0)
        return Boolean
    is
        Result : Boolean;
        Bits : C.int := State_Bits (State);
    begin
        --  FLTK sets the button's state bit while it is down.
        if Event in Push | Drag and Button not in No_Button | Any_Button then
            Bits := Bits + C.int (To_C (Button));
        end if;
        Result := fl_probe_mouse
           (Ptr (Win), Event_Number (Event), C.int (X), C.int (Y),
            Button_Number (Button), Bits, C.int (Clicks)) /= 0;
        Hook_Exceptions.Reraise;
        return Result;
    end Mouse;


    function Wheel
           (Win    : in FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y   : in Integer;
            DX, DY : in Integer)
        return Boolean
    is
        Result : Boolean;
    begin
        Result := fl_probe_wheel
           (Ptr (Win), C.int (X), C.int (Y), C.int (DX), C.int (DY)) /= 0;
        Hook_Exceptions.Reraise;
        return Result;
    end Wheel;


    function Key
           (Event : in Event_Kind;
            Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean
    is
        Result : Boolean;
    begin
        Result := fl_probe_key
           (Event_Number (Event), Key_Number (Code), State_Bits (State), C.To_C (Text)) /= 0;
        Hook_Exceptions.Reraise;
        return Result;
    end Key;


    function Shortcut
           (Win   : in FLTK.Widgets.Groups.Windows.Window'Class;
            Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean
    is
        Result : Boolean;
    begin
        Result := fl_probe_shortcut
           (Ptr (Win), Key_Number (Code), State_Bits (State), C.To_C (Text)) /= 0;
        Hook_Exceptions.Reraise;
        return Result;
    end Shortcut;


    function Handle_Key
           (Win   : in FLTK.Widgets.Groups.Windows.Window'Class;
            Event : in Event_Kind;
            Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean
    is
        Result : Boolean;
    begin
        Result := fl_probe_handle_key
           (Ptr (Win), Event_Number (Event), Key_Number (Code),
            State_Bits (State), C.To_C (Text)) /= 0;
        Hook_Exceptions.Reraise;
        return Result;
    end Handle_Key;


    procedure Set_Key
           (Code : in Keypress;
            Text : in String := "") is
    begin
        fl_probe_set_key (Key_Number (Code), C.To_C (Text));
    end Set_Key;




    ---------------
    --  Dialogs  --
    ---------------

    function Modal
        return Boolean is
    begin
        return fl_probe_modal /= 0;
    end Modal;


    function Grabbed
        return Boolean is
    begin
        return fl_probe_grabbed /= 0;
    end Grabbed;


    function Modal_Title
        return String is
    begin
        return CS.Value (fl_probe_modal_title);
    end Modal_Title;


    function Modal_H
        return Natural is
    begin
        return Natural (fl_probe_modal_h);
    end Modal_H;


    function Modal_Key
           (Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean
    is
        Result : Boolean;
    begin
        Result := fl_probe_modal_key (Key_Number (Code), State_Bits (State), C.To_C (Text)) /= 0;
        Hook_Exceptions.Reraise;
        return Result;
    end Modal_Key;

    function Close_Modal
        return Boolean
    is
        Result : Boolean;
    begin
        Result := fl_probe_close_modal /= 0;
        Hook_Exceptions.Reraise;
        return Result;
    end Close_Modal;


    function Has_Label
           (Text : in String)
        return Boolean is
    begin
        return fl_probe_has_label (C.To_C (Text)) /= 0;
    end Has_Label;


    procedure Set_Printer_Uses_GTK
           (On : in Boolean) is
    begin
        fl_probe_printer_uses_gtk (Boolean'Pos (On));
    end Set_Printer_Uses_GTK;




    -----------------
    --  This FLTK  --
    -----------------

    function Has_SVG return Boolean is (fl_probe_configured (0) /= 0);
    function Has_Wayland return Boolean is (fl_probe_configured (1) /= 0);
    function Has_X11 return Boolean is (fl_probe_configured (2) /= 0);
    function Has_Cairo return Boolean is (fl_probe_configured (3) /= 0);
    function Has_Forms return Boolean is (fl_probe_configured (4) /= 0);


    function On_Wayland
        return Boolean is
    begin
        return fl_probe_on_wayland /= 0;
    end On_Wayland;


    function Shared_Width
           (Name : in String)
        return Natural is
    begin
        return Natural (fl_probe_shared_width (C.To_C (Name)));
    end Shared_Width;


    procedure Clipboard_Notice
           (Source : in Integer) is
    begin
        fl_probe_clipboard_notice (C.int (Source));
        Hook_Exceptions.Reraise;
    end Clipboard_Notice;




    -------------------
    --  The process  --
    -------------------

    procedure Make_Pipe
           (Read_End, Write_End : out File_Descriptor)
    is
        FDs : FD_Pair;
    begin
        if fl_probe_pipe (FDs) = 0 then
            raise Probe_Error with "pipe failed";
        end if;
        Read_End := File_Descriptor (FDs (1));
        Write_End := File_Descriptor (FDs (2));
    end Make_Pipe;


    function Write
           (FD   : in File_Descriptor;
            Text : in String)
        return Integer is
    begin
        return Integer (fl_probe_write
           (C.int (FD), C.To_C (Text, Append_Nul => False), Text'Length));
    end Write;


    function Read
           (FD  : in File_Descriptor;
            Max : in Positive := 256)
        return String
    is
        Buffer : C.char_array (1 .. C.size_t (Max));
        Got    : constant C.int := fl_probe_read (C.int (FD), Buffer, C.int (Max));
    begin
        if Got <= 0 then
            return "";
        end if;
        return C.To_Ada (Buffer (1 .. C.size_t (Got)), Trim_Nul => False);
    end Read;


    procedure Close
           (FD : in File_Descriptor) is
    begin
        fl_probe_close (C.int (FD));
    end Close;


    procedure Set_Env
           (Name, Value : in String) is
    begin
        fl_probe_setenv (C.To_C (Name), C.To_C (Value));
    end Set_Env;


end FLTK.Probe;

