

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Show_Argv,
    Interfaces.C;


package body FLTK.Widgets.Groups.Windows.Double is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_double_window
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_double_window, "new_fl_double_window");
    pragma Inline (new_fl_double_window);

    function new_fl_double_window2
           (X, Y : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_double_window2, "new_fl_double_window2");
    pragma Inline (new_fl_double_window2);

    procedure free_fl_double_window
           (W : in Storage.Integer_Address);
    pragma Import (C, free_fl_double_window, "free_fl_double_window");
    pragma Inline (free_fl_double_window);




    procedure fl_double_window_show
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_double_window_show, "fl_double_window_show");
    pragma Inline (fl_double_window_show);

    procedure fl_double_window_show2
           (W : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_double_window_show2, "fl_double_window_show2");
    pragma Inline (fl_double_window_show2);

    procedure fl_double_window_hide
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_double_window_hide, "fl_double_window_hide");
    pragma Inline (fl_double_window_hide);

    procedure fl_double_window_flush
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_double_window_flush, "fl_double_window_flush");
    pragma Inline (fl_double_window_flush);

    procedure fl_double_window_flush2
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int);
    pragma Import (C, fl_double_window_flush2, "fl_double_window_flush2");
    pragma Inline (fl_double_window_flush2);




    procedure fl_double_window_resize
           (DW         : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_double_window_resize, "fl_double_window_resize");
    pragma Inline (fl_double_window_resize);




    procedure fl_double_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_double_window_draw, "fl_double_window_draw");
    pragma Inline (fl_double_window_draw);

    function fl_double_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_double_window_handle, "fl_double_window_handle");
    pragma Inline (fl_double_window_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Double_Window) is
    begin
        Extra_Final (Window (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Double_Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_double_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Double_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Window (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Double_Window) is
    begin
        This.Draw_Ptr   := fl_double_window_draw'Address;
        This.Handle_Ptr := fl_double_window_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Double_Window is
        begin
            return This : Double_Window do
                This.Void_Ptr := new_fl_double_window
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
            return Double_Window is
        begin
            return This : Double_Window do
                This.Void_Ptr := new_fl_double_window2
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
           (This : in out Double_Window) is
    begin
        fl_double_window_show (This.Void_Ptr);
    end Show;


    procedure Show_With_Args
           (This : in out Double_Window) is
    begin
        FLTK.Show_Argv.Dispatch (fl_double_window_show2'Access, This.Void_Ptr);
    end Show_With_Args;


    procedure Hide
           (This : in out Double_Window) is
    begin
        fl_double_window_hide (This.Void_Ptr);
    end Hide;


    procedure Flush
           (This : in out Double_Window) is
    begin
        fl_double_window_flush (This.Void_Ptr);
    end Flush;


    procedure Flush_All
           (This : in out Double_Window) is
    begin
        fl_double_window_flush2 (This.Void_Ptr, 1);
    end Flush_All;




    procedure Resize
           (This       : in out Double_Window;
            X, Y, W, H : in     Integer) is
    begin
        fl_double_window_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


end FLTK.Widgets.Groups.Windows.Double;


