

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Ada.Finalization,
    Ada.Unchecked_Deallocation,
    Interfaces.C;

use type

    Interfaces.C.int;


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




    --  GLUT Windows  --

    function fl_glut_window_alive
           (N : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_window_alive, "fl_glut_window_alive");
    pragma Inline (fl_glut_window_alive);

    function fl_glut_window_pointer
           (N : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_glut_window_pointer, "fl_glut_window_pointer");
    pragma Inline (fl_glut_window_pointer);

    function fl_glut_get_window
        return Interfaces.C.int;
    pragma Import (C, fl_glut_get_window, "fl_glut_get_window");
    pragma Inline (fl_glut_get_window);

    function fl_widget_get_user_data
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_get_user_data, "fl_widget_get_user_data");
    pragma Inline (fl_widget_get_user_data);

    procedure fl_widget_set_user_data
           (W, D : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_user_data, "fl_widget_set_user_data");
    pragma Inline (fl_widget_set_user_data);




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

    function fl_glut_has_room
        return Interfaces.C.int;
    pragma Import (C, fl_glut_has_room, "fl_glut_has_room");
    pragma Inline (fl_glut_has_room);

    function fl_glut_menu_exists
           (Menu : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_menu_exists, "fl_glut_menu_exists");
    pragma Inline (fl_glut_menu_exists);

    function fl_glut_menu_items
           (Menu : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_glut_menu_items, "fl_glut_menu_items");
    pragma Inline (fl_glut_menu_items);




    --  Drawing, Events  --

    function fl_glut_window_make_current
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
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


    --  The 32nd window would get the 31st's number (glut_compatibility.cxx:168,
    --  pofltk 112).
    procedure Check_Room is
    begin
        if fl_glut_has_room = 0 then
            raise Unsupported_Error with "GLUT has no window numbers left";
        end if;
    end Check_Room;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Glut_Window is
        begin
            Check_Room;
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
            Check_Room;
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

    --  GLUT Windows  --

    type Glut_Window_Access is access Glut_Window;

    type Glut_Class_Access is access all Glut_Window'Class;

    procedure Free is new Ada.Unchecked_Deallocation (Glut_Window, Glut_Window_Access);

    --  The Ada objects Window_Of made, by window number.  One whose window
    --  has gone is freed when another is made for its number, or at the end
    --  of the program.
    Wrapped : array (FLTK.GLUT.Valid_Window_Number) of Glut_Window_Access;

    function Address_Of
           (Item : not null access Glut_Window'Class)
        return Storage.Integer_Address is
    begin
        return Storage.To_Integer
           (Widget_Convert.To_Address (Widget_Convert.Object_Pointer (Item)));
    end Address_Of;

    --  Frees a wrapper whose window may have gone, without following its
    --  pointer, unless its window is still there with it as its Ada object.
    procedure Let_Go
           (Number : in FLTK.GLUT.Valid_Window_Number)
    is
        Old : Glut_Window_Access renames Wrapped (Number);
        Now : Storage.Integer_Address;
    begin
        if Old = null then
            return;
        end if;
        Now := fl_glut_window_pointer (Interfaces.C.int (Number));
        if Now /= Null_Pointer and then Now = Old.Void_Ptr
            and then fl_widget_get_user_data (Now) = Address_Of (Old)
        then
            fl_widget_set_user_data (Now, Null_Pointer);
        else
            Old.Void_Ptr := Null_Pointer;
        end if;
        Free (Old);
    end Let_Go;

    type Sentinel is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out Sentinel);

    overriding procedure Finalize
           (This : in out Sentinel)
    is
        pragma Unreferenced (This);
    begin
        for Number in Wrapped'Range loop
            Let_Go (Number);
        end loop;
    end Finalize;

    Wrapped_Sentinel : Sentinel;
    pragma Unreferenced (Wrapped_Sentinel);


    function Window_Of
           (Number : in FLTK.GLUT.Valid_Window_Number)
        return Glut_Window_Reference
    is
        Place : constant Storage.Integer_Address :=
            fl_glut_window_pointer (Interfaces.C.int (Number));
        Ada_Object : Storage.Integer_Address;
    begin
        if Place = Null_Pointer or else fl_glut_window_alive (Interfaces.C.int (Number)) = 0 then
            raise Constraint_Error with "no GLUT window" & FLTK.GLUT.Window_Number'Image (Number);
        end if;
        Ada_Object := fl_widget_get_user_data (Place);
        if Ada_Object /= Null_Pointer then
            --  Forge's, or the one made before; one made before for another
            --  window with this number has gone with it
            if Wrapped (Number) /= null and then Address_Of (Wrapped (Number)) /= Ada_Object then
                Let_Go (Number);
            end if;
            return (Data => Glut_Class_Access
               (Widget_Convert.To_Pointer (Storage.To_Address (Ada_Object))));
        end if;
        Let_Go (Number);
        Wrapped (Number) := new Glut_Window;
        Wrapped (Number).Void_Ptr := Place;
        Wrapped (Number).Needs_Dealloc := False;
        --  Not Extra_Init, which would end the window's group and set its
        --  label
        fl_widget_set_user_data (Place, Address_Of (Wrapped (Number)));
        return (Data => Wrapped (Number));
    end Window_Of;


    function Current_Window
        return Glut_Window_Reference
    is
        Number : constant Interfaces.C.int := fl_glut_get_window;
    begin
        if Number = 0 then
            raise Constraint_Error with "no current GLUT window";
        end if;
        return Window_Of (FLTK.GLUT.Valid_Window_Number (Number));
    end Current_Window;




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
            Menu   : in     FLTK.GLUT.Menu_Number)
    is
        use type FLTK.GLUT.Menu_Number;
    begin
        --  A button on a menu that doesn't exist, or has no items, pops up a
        --  null pointer (domenu, glut_compatibility.cxx:298, pofltk 112)
        if Menu /= FLTK.GLUT.No_Menu then
            if fl_glut_menu_exists (Interfaces.C.int (Menu)) = 0 then
                raise Constraint_Error with "no GLUT menu" & FLTK.GLUT.Menu_Number'Image (Menu);
            elsif fl_glut_menu_items (Interfaces.C.int (Menu)) = 0 then
                raise Program_Error with "Set_Menu of an empty GLUT menu";
            end if;
        end if;
        fl_glut_window_set_menu
           (This.Void_Ptr,
            FLTK.GLUT.Mouse_Button_Index'Pos (Button),
            Interfaces.C.int (Menu));
    end Set_Menu;




    --  Drawing, Events  --

    procedure Make_Current
           (This : in out Glut_Window) is
    begin
        if fl_glut_window_make_current (This.Void_Ptr) = 0 then
            raise Program_Error with "Make_Current on a Glut_Window not shown";
        end if;
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


