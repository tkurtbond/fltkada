

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Groups.Windows.Double is


    procedure double_window_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, double_window_set_draw_hook, "double_window_set_draw_hook");
    pragma Inline (double_window_set_draw_hook);

    procedure double_window_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, double_window_set_handle_hook, "double_window_set_handle_hook");
    pragma Inline (double_window_set_handle_hook);




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

    procedure fl_double_window_hide
            (W : in Storage.Integer_Address);
    pragma Import (C, fl_double_window_hide, "fl_double_window_hide");
    pragma Inline (fl_double_window_hide);

    procedure fl_double_window_flush
            (W : in Storage.Integer_Address);
    pragma Import (C, fl_double_window_flush, "fl_double_window_flush");
    pragma Inline (fl_double_window_flush);




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




    procedure Finalize
           (This : in out Double_Window) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Double_Window'Class
        then
            This.Clear;
            free_fl_double_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Window (This));
    end Finalize;




    procedure Extra_Init
           (This       : in out Double_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Window (This), X, Y, W, H, Text);
    end Extra_Init;


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
                double_window_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                double_window_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
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
                double_window_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                double_window_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Show
           (This : in out Double_Window) is
    begin
        fl_double_window_show (This.Void_Ptr);
    end Show;


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




    procedure Draw
           (This : in out Double_Window) is
    begin
        fl_double_window_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Double_Window;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_double_window_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Groups.Windows.Double;

