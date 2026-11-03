

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Args_Marshal,
    FLTK.Hook_Exceptions,
    Interfaces.C;


package body FLTK.Widgets.Groups.Windows.Single is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_single_window
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_single_window, "new_fl_single_window");
    pragma Inline (new_fl_single_window);

    function new_fl_single_window2
           (W, H : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_single_window2, "new_fl_single_window2");
    pragma Inline (new_fl_single_window2);

    procedure free_fl_single_window
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_single_window, "free_fl_single_window");
    pragma Inline (free_fl_single_window);




    --  Visibility  --

    procedure fl_single_window_show
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_single_window_show, "fl_single_window_show");
    pragma Inline (fl_single_window_show);

    procedure fl_single_window_show2
           (S : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_single_window_show2, "fl_single_window_show2");
    pragma Inline (fl_single_window_show2);

    procedure fl_single_window_flush
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_single_window_flush, "fl_single_window_flush");
    pragma Inline (fl_single_window_flush);




    --  Current  --

    procedure fl_single_window_make_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_single_window_make_current, "fl_single_window_make_current");
    pragma Inline (fl_single_window_make_current);




    --  Drawing, Events  --

    procedure fl_single_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_single_window_draw, "fl_single_window_draw");
    pragma Inline (fl_single_window_draw);

    function fl_single_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_single_window_handle, "fl_single_window_handle");
    pragma Inline (fl_single_window_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Single_Window) is
    begin
        Extra_Final (Window (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Single_Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_single_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Single_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Window (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Single_Window) is
    begin
        This.Draw_Ptr   := fl_single_window_draw'Address;
        This.Handle_Ptr := fl_single_window_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Single_Window is
        begin
            return This : Single_Window do
                This.Void_Ptr := new_fl_single_window
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
            return Single_Window is
        begin
            return This : Single_Window := Create (X, Y, W, H, Text) do
                Parent.Add (This);
                --  FLTK leaves a window made with a position visible only when it
                --  has a parent from the start, which here it only gets afterwards
                This.Set_Visible;
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Single_Window is
        begin
            return This : Single_Window do
                This.Void_Ptr := new_fl_single_window2
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
            return Single_Window is
        begin
            return This : Single_Window := Create (W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Visibility  --

    procedure Show
           (This : in out Single_Window) is
    begin
        fl_single_window_show (This.Void_Ptr);
    end Show;


    procedure Show_With_Args
           (This : in out Single_Window) is
    begin
        FLTK.Args_Marshal.Dispatch (fl_single_window_show2'Access, This.Void_Ptr);
    end Show_With_Args;


    procedure Flush
           (This : in out Single_Window) is
    begin
        fl_single_window_flush (This.Void_Ptr);
        Hook_Exceptions.Reraise;
    end Flush;




    --  Current  --

    procedure Make_Current
           (This : in out Single_Window) is
    begin
        fl_single_window_make_current (This.Void_Ptr);
    end Make_Current;


end FLTK.Widgets.Groups.Windows.Single;


