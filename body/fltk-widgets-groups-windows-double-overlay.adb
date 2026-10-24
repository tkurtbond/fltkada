

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Args_Marshal,
    Interfaces.C,
    System.Address_To_Access_Conversions;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Windows.Double.Overlay is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_overlay_window
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_overlay_window, "new_fl_overlay_window");
    pragma Inline (new_fl_overlay_window);

    function new_fl_overlay_window2
           (W, H : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_overlay_window2, "new_fl_overlay_window2");
    pragma Inline (new_fl_overlay_window2);

    procedure free_fl_overlay_window
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_overlay_window, "free_fl_overlay_window");
    pragma Inline (free_fl_overlay_window);




    --  Visibility  --

    procedure fl_overlay_window_show
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_overlay_window_show, "fl_overlay_window_show");
    pragma Inline (fl_overlay_window_show);

    procedure fl_overlay_window_show2
           (W : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_overlay_window_show2, "fl_overlay_window_show2");
    pragma Inline (fl_overlay_window_show2);

    procedure fl_overlay_window_hide
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_overlay_window_hide, "fl_overlay_window_hide");
    pragma Inline (fl_overlay_window_hide);

    procedure fl_overlay_window_flush
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_overlay_window_flush, "fl_overlay_window_flush");
    pragma Inline (fl_overlay_window_flush);




    --  Settings  --

    function fl_overlay_window_can_do_overlay
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_overlay_window_can_do_overlay, "fl_overlay_window_can_do_overlay");
    pragma Inline (fl_overlay_window_can_do_overlay);

    procedure fl_overlay_window_resize
           (OW         : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_overlay_window_resize, "fl_overlay_window_resize");
    pragma Inline (fl_overlay_window_resize);




    --  Drawing, Events  --

    procedure fl_overlay_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_overlay_window_draw, "fl_overlay_window_draw");
    pragma Inline (fl_overlay_window_draw);

    procedure fl_overlay_window_redraw_overlay
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_overlay_window_redraw_overlay, "fl_overlay_window_redraw_overlay");
    pragma Inline (fl_overlay_window_redraw_overlay);

    function fl_overlay_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_overlay_window_handle, "fl_overlay_window_handle");
    pragma Inline (fl_overlay_window_handle);




    ----------------------
    --  Exported Hooks  --
    ----------------------

    package Over_Convert is new System.Address_To_Access_Conversions (Overlay_Window'Class);

    procedure Overlay_Window_Draw_Overlay_Hook
           (U : in Storage.Integer_Address);
    pragma Export (C, Overlay_Window_Draw_Overlay_Hook, "overlay_window_draw_overlay_hook");

    procedure Overlay_Window_Draw_Overlay_Hook
           (U : in Storage.Integer_Address)
    is
        Overlay_Widget : constant access Overlay_Window'Class :=
            Over_Convert.To_Pointer (Storage.To_Address (U));
    begin
        Overlay_Widget.Draw_Overlay;
    end Overlay_Window_Draw_Overlay_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Overlay_Window) is
    begin
        Extra_Final (Double_Window (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Overlay_Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_overlay_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Overlay_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Double_Window (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Overlay_Window) is
    begin
        This.Draw_Ptr   := fl_overlay_window_draw'Address;
        This.Handle_Ptr := fl_overlay_window_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Overlay_Window is
        begin
            return This : Overlay_Window do
                This.Void_Ptr := new_fl_overlay_window
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Overlay_Window is
        begin
            return This : Overlay_Window := Create (X, Y, W, H, Text) do
                Parent.Add (This);
                --  FLTK leaves a window made with a position visible only when it
                --  has a parent from the start, which here it only gets afterwards
                This.Set_Visible;
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Overlay_Window is
        begin
            return This : Overlay_Window do
                This.Void_Ptr := new_fl_overlay_window2
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent : in out Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Overlay_Window is
        begin
            return This : Overlay_Window := Create (W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Visibility  --

    procedure Show
           (This : in out Overlay_Window) is
    begin
        fl_overlay_window_show (This.Void_Ptr);
    end Show;


    procedure Show_With_Args
           (This : in out Overlay_Window) is
    begin
        FLTK.Args_Marshal.Dispatch (fl_overlay_window_show2'Access, This.Void_Ptr);
    end Show_With_Args;


    procedure Hide
           (This : in out Overlay_Window) is
    begin
        fl_overlay_window_hide (This.Void_Ptr);
    end Hide;


    procedure Flush
           (This : in out Overlay_Window) is
    begin
        fl_overlay_window_flush (This.Void_Ptr);
    end Flush;




    --  Settings  --

    function Can_Do_Overlay
           (This : in Overlay_Window)
        return Boolean is
    begin
        return fl_overlay_window_can_do_overlay (This.Void_Ptr) /= 0;
    end Can_Do_Overlay;


    procedure Resize
           (This       : in out Overlay_Window;
            X, Y, W, H : in     Integer) is
    begin
        fl_overlay_window_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --  Drawing, Events  --

    procedure Draw_Overlay
           (This : in out Overlay_Window) is
    begin
        raise Program_Error with "You must override Draw_Overlay";
    end Draw_Overlay;


    procedure Redraw_Overlay
           (This : in out Overlay_Window) is
    begin
        fl_overlay_window_redraw_overlay (This.Void_Ptr);
    end Redraw_Overlay;


end FLTK.Widgets.Groups.Windows.Double.Overlay;


