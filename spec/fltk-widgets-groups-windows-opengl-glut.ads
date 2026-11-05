

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Binding of Fl_Glut_Window, the window class behind FLTK's GLUT emulation.
--  Windows made by FLTK.GLUT.Create_Window and Create_Sub_Window are of this
--  class too, and are owned by FLTK.  Window_Of gives the Ada object for
--  any GLUT window.


with

    FLTK.GLUT;


package FLTK.Widgets.Groups.Windows.OpenGL.GLUT is


    type Glut_Window is new GL_Window with private;

    type Glut_Window_Reference (Data : not null access Glut_Window'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Glut_Window;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Glut_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Glut_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Glut_Window;

    end Forge;




    --  GLUT Windows  --

    --  The Ada object for GLUT window Number: the one Forge made, or for a
    --  window FLTK.GLUT made, one made for it the first time it is asked
    --  for, which is the same each time after.  Once FLTK.GLUT has
    --  destroyed the window, a reference to that one is not to be used; it
    --  is freed when Window_Of next gives a window with that number, or at
    --  exit.  Raises Constraint_Error if there is no window Number, or it
    --  is being destroyed.
    function Window_Of
           (Number : in FLTK.GLUT.Valid_Window_Number)
        return Glut_Window_Reference;

    --  The current GLUT window, FLTK's glut_window, as Window_Of gives it.
    --  Raises Constraint_Error if there is none.
    function Current_Window
        return Glut_Window_Reference;




    --  GLUT State  --

    function Get_Number
           (This : in Glut_Window)
        return FLTK.GLUT.Valid_Window_Number;

    function Get_Menu
           (This   : in Glut_Window;
            Button : in FLTK.GLUT.Menu_Button)
        return FLTK.GLUT.Menu_Number;

    procedure Set_Menu
           (This   : in out Glut_Window;
            Button : in     FLTK.GLUT.Menu_Button;
            Menu   : in     FLTK.GLUT.Menu_Number);




    --  Drawing, Events  --

    --  Also makes this the current GLUT window.  Raises Program_Error if
    --  the window is not shown (pofltk 111).
    procedure Make_Current
           (This : in out Glut_Window);

    procedure Draw
           (This : in out Glut_Window);

    function Handle
           (This  : in out Glut_Window;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Glut_Window is new GL_Window with null record;

    overriding procedure Initialize
           (This : in out Glut_Window);

    overriding procedure Finalize
           (This : in out Glut_Window);

    procedure Extra_Init
           (This       : in out Glut_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Glut_Window)
    with Inline;


    pragma Inline (Get_Number);
    pragma Inline (Get_Menu);
    pragma Inline (Set_Menu);

    pragma Inline (Make_Current);
    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Windows.OpenGL.GLUT;


