

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Groups.Windows.OpenGL.GLUT is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_glut_window
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_glut_window, "new_fl_glut_window");
    pragma Inline (new_fl_glut_window);

    function new_fl_glut_window2
           (W, H : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_glut_window2, "new_fl_glut_window2");
    pragma Inline (new_fl_glut_window2);

    procedure free_fl_glut_window
           (W : in Storage.Integer_Address);
    pragma Import (C, free_fl_glut_window, "free_fl_glut_window");
    pragma Inline (free_fl_glut_window);




    --  GLUT State  --

    function fl_glut_window_get_number
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_window_get_number, "fl_glut_window_get_number");
    pragma Inline (fl_glut_window_get_number);

    function fl_glut_window_get_menu
           (W : in Storage.Integer_Address;
            B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_window_get_menu, "fl_glut_window_get_menu");
    pragma Inline (fl_glut_window_get_menu);

    procedure fl_glut_window_set_menu
           (W    : in Storage.Integer_Address;
            B, M : in Interfaces.C.int);
    pragma Import (C, fl_glut_window_set_menu, "fl_glut_window_set_menu");
    pragma Inline (fl_glut_window_set_menu);




    --  Drawing, Events  --

    procedure fl_glut_window_make_current
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_glut_window_make_current, "fl_glut_window_make_current");
    pragma Inline (fl_glut_window_make_current);

    procedure fl_glut_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_glut_window_draw, "fl_glut_window_draw");
    pragma Inline (fl_glut_window_draw);

    function fl_glut_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_window_handle, "fl_glut_window_handle");
    pragma Inline (fl_glut_window_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Glut_Window) is
    begin
        Extra_Final (GL_Window (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Glut_Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_glut_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Glut_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (GL_Window (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Glut_Window) is
    begin
        This.Draw_Ptr   := fl_glut_window_draw'Address;
        This.Handle_Ptr := fl_glut_window_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Glut_Window is
        begin
            return This : Glut_Window do
                This.Void_Ptr := new_fl_glut_window
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
            return Glut_Window is
        begin
            return This : Glut_Window := Create (X, Y, W, H, Text) do
                Parent.Add (This);
                --  FLTK leaves a window made with a position visible only when it
                --  has a parent from the start, which here it only gets afterwards
                This.Set_Visible;
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Glut_Window is
        begin
            return This : Glut_Window do
                This.Void_Ptr := new_fl_glut_window2
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
            return Glut_Window is
        begin
            return This : Glut_Window := Create (W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  GLUT State  --

    function Get_Number
           (This : in Glut_Window)
        return FLTK.GLUT.Valid_Window_Number is
    begin
        return FLTK.GLUT.Valid_Window_Number (fl_glut_window_get_number (This.Void_Ptr));
    end Get_Number;


    function Get_Menu
           (This   : in Glut_Window;
            Button : in FLTK.GLUT.Menu_Button)
        return FLTK.GLUT.Menu_Number is
    begin
        return FLTK.GLUT.Menu_Number (fl_glut_window_get_menu
           (This.Void_Ptr, FLTK.GLUT.Mouse_Button_Index'Pos (Button)));
    end Get_Menu;


    procedure Set_Menu
           (This   : in out Glut_Window;
            Button : in     FLTK.GLUT.Menu_Button;
            Menu   : in     FLTK.GLUT.Menu_Number) is
    begin
        fl_glut_window_set_menu
           (This.Void_Ptr,
            FLTK.GLUT.Mouse_Button_Index'Pos (Button),
            Interfaces.C.int (Menu));
    end Set_Menu;




    --  Drawing, Events  --

    procedure Make_Current
           (This : in out Glut_Window) is
    begin
        fl_glut_window_make_current (This.Void_Ptr);
    end Make_Current;


    procedure Draw
           (This : in out Glut_Window) is
    begin
        GL_Window (This).Draw;
    end Draw;


    function Handle
           (This  : in out Glut_Window;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return GL_Window (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Windows.OpenGL.GLUT;


