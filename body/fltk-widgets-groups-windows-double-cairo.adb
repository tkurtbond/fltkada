

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Hook_Exceptions,
    Interfaces.C,
    System.Address_To_Access_Conversions;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Windows.Double.Cairo is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_cairo_window
           (W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_cairo_window, "new_fl_cairo_window");
    pragma Inline (new_fl_cairo_window);

    procedure free_fl_cairo_window
           (W : in Storage.Integer_Address);
    pragma Import (C, free_fl_cairo_window, "free_fl_cairo_window");
    pragma Inline (free_fl_cairo_window);




    --  Cairo Callback  --

    function fl_cairo_window_supported
        return Interfaces.C.int;
    pragma Import (C, fl_cairo_window_supported, "fl_cairo_window_supported");
    pragma Inline (fl_cairo_window_supported);

    procedure fl_cairo_window_set_draw_cb
           (W, F : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_window_set_draw_cb, "fl_cairo_window_set_draw_cb");
    pragma Inline (fl_cairo_window_set_draw_cb);




    --  Drawing, Events  --

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
        Ada_Addr : constant System.Address :=
            Storage.To_Address (fl_widget_get_user_data (C_Addr));
        Ada_Object : constant access Cairo_Window'Class :=
            Cairo_Convert.To_Pointer (Ada_Addr);
    begin
        --  Checked here, and not by a handler around the call, so that the
        --  program's own exceptions aren't taken for FLTK's (FLTKAda-BUGS.md 45).
        if Ada_Object = null then
            Hook_Exceptions.Save_New
               (Internal_FLTK_Error'Identity,
                "Fl_Cairo_Window draw hook received Widget with no user_data reference " &
                "back to Ada");
            return;
        end if;
        if Ada_Object.My_Func /= null then
            Ada_Object.My_Func (Cairo_Window (Ada_Object.all), Storage.To_Address (Cairo_Addr));
        end if;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
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


    procedure Initialize
           (This : in out Cairo_Window) is
    begin
        This.Draw_Ptr := fl_cairo_window_draw'Address;
        This.Handle_Ptr := fl_cairo_window_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Cairo_Window is
        begin
            return This : Cairo_Window do
                This.Void_Ptr := new_fl_cairo_window
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H));
                This.Reposition (X, Y);
                This.Set_Label (Text);
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Cairo_Window is
        begin
            return This : Cairo_Window := Create (X, Y, W, H, Text) do
                Parent.Add (This);
                --  FLTK leaves a window made with a position visible only when it
                --  has a parent from the start, which here it only gets afterwards
                This.Set_Visible;
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Text : in String)
            return Cairo_Window is
        begin
            return This : Cairo_Window do
                This.Void_Ptr := new_fl_cairo_window
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H));
                This.Set_Label (Text);
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent : in out Group'Class;
                W, H   : in     Integer;
                Text   : in     String)
            return Cairo_Window is
        begin
            return This : Cairo_Window := Create (W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;


        function Create
               (W, H : in Integer)
            return Cairo_Window is
        begin
            return This : Cairo_Window do
                This.Void_Ptr := new_fl_cairo_window
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H));
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, This.Get_Label);
            end return;
        end Create;


        function Create
               (Parent : in out Group'Class;
                W, H   : in     Integer)
            return Cairo_Window is
        begin
            return This : Cairo_Window := Create (W, H) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Cairo Callback  --

    function Is_Supported
        return Boolean is
    begin
        return fl_cairo_window_supported /= 0;
    end Is_Supported;


    procedure Set_Cairo_Draw
           (This : in out Cairo_Window;
            Func : in     Cairo_Callback) is
    begin
        if not Is_Supported then
            raise Unsupported_Error with "this FLTK was built without Cairo";
        end if;
        This.My_Func := Func;
    end Set_Cairo_Draw;




    --  Drawing  --

    procedure Draw
           (This : in out Cairo_Window) is
    begin
        Double_Window (This).Draw;
    end Draw;


end FLTK.Widgets.Groups.Windows.Double.Cairo;


