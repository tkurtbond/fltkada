

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Show_Argv,
    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Help_Dialogs is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_help_dialog
        return Storage.Integer_Address;
    pragma Import (C, new_fl_help_dialog, "new_fl_help_dialog");
    pragma Inline (new_fl_help_dialog);

    procedure free_fl_help_dialog
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_help_dialog, "free_fl_help_dialog");
    pragma Inline (free_fl_help_dialog);




    --  Visibility  --

    procedure fl_help_dialog_show
           (D : in Storage.Integer_Address);
    pragma Import (C, fl_help_dialog_show, "fl_help_dialog_show");
    pragma Inline (fl_help_dialog_show);

    procedure fl_help_dialog_show2
           (D : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_help_dialog_show2, "fl_help_dialog_show2");
    pragma Inline (fl_help_dialog_show2);

    procedure fl_help_dialog_hide
           (D : in Storage.Integer_Address);
    pragma Import (C, fl_help_dialog_hide, "fl_help_dialog_hide");
    pragma Inline (fl_help_dialog_hide);

    function fl_help_dialog_visible
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_dialog_visible, "fl_help_dialog_visible");
    pragma Inline (fl_help_dialog_visible);




    --  Topline  --

    procedure fl_help_dialog_set_topline_number
           (D : in Storage.Integer_Address;
            N : in Interfaces.C.int);
    pragma Import (C, fl_help_dialog_set_topline_number, "fl_help_dialog_set_topline_number");
    pragma Inline (fl_help_dialog_set_topline_number);

    procedure fl_help_dialog_set_topline_target
           (D : in Storage.Integer_Address;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_help_dialog_set_topline_target, "fl_help_dialog_set_topline_target");
    pragma Inline (fl_help_dialog_set_topline_target);




    --  Content  --

    procedure fl_help_dialog_load
           (D : in Storage.Integer_Address;
            N : in Interfaces.C.char_array);
    pragma Import (C, fl_help_dialog_load, "fl_help_dialog_load");
    pragma Inline (fl_help_dialog_load);

    function fl_help_dialog_get_value
           (D : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_help_dialog_get_value, "fl_help_dialog_get_value");
    pragma Inline (fl_help_dialog_get_value);

    procedure fl_help_dialog_set_value
           (D : in Storage.Integer_Address;
            V : in Interfaces.C.char_array);
    pragma Import (C, fl_help_dialog_set_value, "fl_help_dialog_set_value");
    pragma Inline (fl_help_dialog_set_value);




    --  Settings  --

    function fl_help_dialog_get_textsize
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_dialog_get_textsize, "fl_help_dialog_get_textsize");
    pragma Inline (fl_help_dialog_get_textsize);

    procedure fl_help_dialog_set_textsize
           (D : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_help_dialog_set_textsize, "fl_help_dialog_set_textsize");
    pragma Inline (fl_help_dialog_set_textsize);




    --  Dimensions  --

    function fl_help_dialog_get_x
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_dialog_get_x, "fl_help_dialog_get_x");
    pragma Inline (fl_help_dialog_get_x);

    function fl_help_dialog_get_y
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_dialog_get_y, "fl_help_dialog_get_y");
    pragma Inline (fl_help_dialog_get_y);

    function fl_help_dialog_get_w
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_dialog_get_w, "fl_help_dialog_get_w");
    pragma Inline (fl_help_dialog_get_w);

    function fl_help_dialog_get_h
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_help_dialog_get_h, "fl_help_dialog_get_h");
    pragma Inline (fl_help_dialog_get_h);

    procedure fl_help_dialog_resize
           (D          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_help_dialog_resize, "fl_help_dialog_resize");
    pragma Inline (fl_help_dialog_resize);

    procedure fl_help_dialog_position
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_help_dialog_position, "fl_help_dialog_position");
    pragma Inline (fl_help_dialog_position);




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Help_Dialog) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_help_dialog (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
            return Help_Dialog is
        begin
            return This : Help_Dialog do
                This.Void_Ptr := new_fl_help_dialog;
            end return;
        end Create;


        function Create
               (X, Y, W, H : in Integer)
            return Help_Dialog is
        begin
            return This : Help_Dialog do
                This.Void_Ptr := new_fl_help_dialog;
                This.Resize (X, Y, W, H);
            end return;
        end Create;


        pragma Inline (Create);

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Visibility  --

    procedure Show
           (This : in out Help_Dialog) is
    begin
        fl_help_dialog_show (This.Void_Ptr);
    end Show;


    procedure Show_With_Args
           (This : in out Help_Dialog) is
    begin
        FLTK.Show_Argv.Dispatch (fl_help_dialog_show2'Access, This.Void_Ptr);
    end Show_With_Args;


    procedure Hide
           (This : in out Help_Dialog) is
    begin
        fl_help_dialog_hide (This.Void_Ptr);
    end Hide;


    function Is_Visible
           (This : in Help_Dialog)
        return Boolean is
    begin
        return fl_help_dialog_visible (This.Void_Ptr) = 1;
    end Is_Visible;




    --  Topline  --

    procedure Set_Topline_Number
           (This : in out Help_Dialog;
            Line : in     Positive) is
    begin
        fl_help_dialog_set_topline_number (This.Void_Ptr, Interfaces.C.int (Line) - 1);
    end Set_Topline_Number;


    procedure Set_Topline_Target
           (This  : in out Help_Dialog;
            Value : in     String) is
    begin
        fl_help_dialog_set_topline_target (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Topline_Target;




    --  Content  --

    procedure Load
           (This : in out Help_Dialog;
            Name : in     String) is
    begin
        fl_help_dialog_load (This.Void_Ptr, Interfaces.C.To_C (Name));
    end Load;


    function Get_Content
           (This : in Help_Dialog)
        return String
    is
        Raw_Chars : Interfaces.C.Strings.chars_ptr := fl_help_dialog_get_value (This.Void_Ptr);
        use type Interfaces.C.Strings.chars_ptr;
    begin
        if Raw_Chars = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Raw_Chars);
        end if;
    end Get_Content;


    procedure Set_Content
           (This  : in out Help_Dialog;
            Value : in     String) is
    begin
        fl_help_dialog_set_value (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Content;




    --  Settings  --

    function Get_Text_Size
           (This : in Help_Dialog)
        return Font_Size is
    begin
        return Font_Size (fl_help_dialog_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Help_Dialog;
            Size : in     Font_Size) is
    begin
        fl_help_dialog_set_textsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    --  Dimensions  --

    function Get_X
           (This : in Help_Dialog)
        return Integer is
    begin
        return Integer (fl_help_dialog_get_x (This.Void_Ptr));
    end Get_X;


    function Get_Y
           (This : in Help_Dialog)
        return Integer is
    begin
        return Integer (fl_help_dialog_get_y (This.Void_Ptr));
    end Get_Y;


    function Get_W
           (This : in Help_Dialog)
        return Integer is
    begin
        return Integer (fl_help_dialog_get_w (This.Void_Ptr));
    end Get_W;


    function Get_H
           (This : in Help_Dialog)
        return Integer is
    begin
        return Integer (fl_help_dialog_get_h (This.Void_Ptr));
    end Get_H;


    procedure Resize
           (This       : in out Help_Dialog;
            X, Y, W, H : in     Integer) is
    begin
        fl_help_dialog_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


    procedure Reposition
           (This : in out Help_Dialog;
            X, Y : in     Integer) is
    begin
        fl_help_dialog_position
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Reposition;


end FLTK.Help_Dialogs;


