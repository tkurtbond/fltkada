

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C,
    System.Address_To_Access_Conversions;


package body FLTK.Widgets.Groups.Windows.Double.Cairo is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_cairo_window
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_cairo_window, "new_fl_cairo_window");
    pragma Inline (new_fl_cairo_window);

    function new_fl_cairo_window2
           (W, H : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_cairo_window2, "new_fl_cairo_window2");
    pragma Inline (new_fl_cairo_window2);

    function new_fl_cairo_window3
           (W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_cairo_window3, "new_fl_cairo_window3");
    pragma Inline (new_fl_cairo_window3);

    procedure free_fl_cairo_window
           (W : in Storage.Integer_Address);
    pragma Import (C, free_fl_cairo_window, "free_fl_cairo_window");
    pragma Inline (free_fl_cairo_window);




    procedure fl_cairo_window_set_draw_cb
           (W, F : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_window_set_draw_cb, "fl_cairo_window_set_draw_cb");
    pragma Inline (fl_cairo_window_set_draw_cb);




    procedure fl_cairo_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_window_draw, "fl_cairo_window_draw");
    pragma Inline (fl_cairo_window_draw);

    function fl_cairo_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_cairo_window_handle, "fl_cairo_window_handle");
    pragma Inline (fl_cairo_window_handle);




    ----------------------
    --  Callback Hooks  --
    ----------------------

    package Cairo_Convert is new System.Address_To_Access_Conversions (Cairo_Window'Class);


    procedure Cairo_Draw_Hook
           (C_Addr, Cairo_Addr : in Storage.Integer_Address);

    pragma Convention (C, Cairo_Draw_Hook);

    procedure Cairo_Draw_Hook
           (C_Addr, Cairo_Addr : in Storage.Integer_Address)
    is
        Ada_Addr : System.Address :=
            Storage.To_Address (fl_widget_get_user_data (C_Addr));
        Ada_Object : access Cairo_Window'Class :=
            Cairo_Convert.To_Pointer (Ada_Addr);
    begin
        if Ada_Object.My_Func /= null then
            Ada_Object.My_Func (Cairo_Window (Ada_Object.all), Storage.To_Address (Cairo_Addr));
        end if;
    end Cairo_Draw_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Cairo_Window) is
    begin
        Extra_Final (Double_Window (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Cairo_Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_cairo_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Cairo_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        fl_cairo_window_set_draw_cb (This.Void_Ptr, Storage.To_Integer (Cairo_Draw_Hook'Address));
        Extra_Init (Double_Window (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Cairo_Window is
        begin
            return This : Cairo_Window do
                This.Void_Ptr := new_fl_cairo_window
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
            return Cairo_Window is
        begin
            return This : Cairo_Window do
                This.Void_Ptr := new_fl_cairo_window2
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, Text);
            end return;
        end Create;


        function Create
               (W, H : in Integer)
            return Cairo_Window is
        begin
            return This : Cairo_Window do
                This.Void_Ptr := new_fl_cairo_window3
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H));
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, This.Get_Label);
            end return;
        end Create;

    end Forge;




    ------------------------
    --  Cairo Window API  --
    ------------------------

    procedure Set_Cairo_Draw
           (This : in out Cairo_Window;
            Func : in     Cairo_Callback) is
    begin
        This.My_Func := Func;
    end Set_Cairo_Draw;




    procedure Draw
           (This : in out Cairo_Window) is
    begin
        fl_cairo_window_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Cairo_Window;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
           (fl_cairo_window_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Groups.Windows.Double.Cairo;


