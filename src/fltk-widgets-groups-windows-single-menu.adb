

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;

use type

    Interfaces.C.unsigned;


package body FLTK.Widgets.Groups.Windows.Single.Menu is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_menu_window
           (X, Y, W, H : in Interfaces.C.int;
            Label      : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_menu_window, "new_fl_menu_window");
    pragma Inline (new_fl_menu_window);

    function new_fl_menu_window2
           (W, H : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_menu_window2, "new_fl_menu_window2");
    pragma Inline (new_fl_menu_window2);

    procedure free_fl_menu_window
           (M : in Storage.Integer_Address);
    pragma Import (C, free_fl_menu_window, "free_fl_menu_window");
    pragma Inline (free_fl_menu_window);




    procedure fl_menu_window_show
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_menu_window_show, "fl_menu_window_show");
    pragma Inline (fl_menu_window_show);

    procedure fl_menu_window_hide
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_menu_window_hide, "fl_menu_window_hide");
    pragma Inline (fl_menu_window_hide);

    procedure fl_menu_window_flush
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_menu_window_flush, "fl_menu_window_flush");
    pragma Inline (fl_menu_window_flush);




    procedure fl_menu_window_set_overlay
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_menu_window_set_overlay, "fl_menu_window_set_overlay");
    pragma Inline (fl_menu_window_set_overlay);

    procedure fl_menu_window_clear_overlay
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_menu_window_clear_overlay, "fl_menu_window_clear_overlay");
    pragma Inline (fl_menu_window_clear_overlay);

    function fl_menu_window_overlay
           (M : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_menu_window_overlay, "fl_menu_window_overlay");
    pragma Inline (fl_menu_window_overlay);




    procedure fl_menu_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_menu_window_draw, "fl_menu_window_draw");
    pragma Inline (fl_menu_window_draw);

    function fl_menu_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_window_handle, "fl_menu_window_handle");
    pragma Inline (fl_menu_window_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Menu_Window) is
    begin
        Extra_Final (Single_Window (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Menu_Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_menu_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Menu_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Single_Window (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Menu_Window) is
    begin
        This.Draw_Ptr   := fl_menu_window_draw'Address;
        This.Handle_Ptr := fl_menu_window_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Menu_Window is
        begin
            return This : Menu_Window do
                This.Void_Ptr := new_fl_menu_window
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Menu_Window is
        begin
            return This : Menu_Window do
                This.Void_Ptr := new_fl_menu_window2
                       (Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, Text);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    procedure Show
           (This : in out Menu_Window) is
    begin
        fl_menu_window_show (This.Void_Ptr);
    end Show;


    procedure Hide
           (This : in out Menu_Window) is
    begin
        fl_menu_window_hide (This.Void_Ptr);
    end Hide;


    procedure Flush
           (This : in out Menu_Window) is
    begin
        fl_menu_window_flush (This.Void_Ptr);
    end Flush;




    function Is_Overlay
           (This : in Menu_Window)
        return Boolean is
    begin
        return fl_menu_window_overlay (This.Void_Ptr) /= 0;
    end Is_Overlay;


    procedure Set_Overlay
           (This  : in out Menu_Window;
            Value : in     Boolean) is
    begin
        if Value then
            fl_menu_window_set_overlay (This.Void_Ptr);
        else
            fl_menu_window_clear_overlay (This.Void_Ptr);
        end if;
    end Set_Overlay;


end FLTK.Widgets.Groups.Windows.Single.Menu;


