--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/fullscreen.cxx: a GL polygon, as in shape, with buttons
--  that turn the window's border, full screen, maximizing and full screen
--  across every screen on and off, and a list of the screens.  With -2
--  the polygon has a window of its own; -f starts full screen.  Guided by
--  pofltk's Fullscreen.Mod.


with

    Ada.Command_Line,
    Ada.Numerics.Long_Elementary_Functions,
    Ada.Strings.Fixed,
    Ada.Text_IO,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Buttons.Light,
    FLTK.Widgets.Groups.Browsers.Textline,
    FLTK.Widgets.Groups.Windows.OpenGL,
    FLTK.Widgets.Groups.Windows.Single,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Valuators.Sliders.Horizontal,
    GL1,
    GNAT.OS_Lib;

use

    Ada.Numerics.Long_Elementary_Functions,
    GL1;

use type

    FLTK.Static.Timeout_Handler;


function Fullscreen
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Lit renames FLTK.Widgets.Buttons.Light;
    package Brw renames FLTK.Widgets.Groups.Browsers.Textline;
    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package Sgl renames FLTK.Widgets.Groups.Windows.Single;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package HS  renames FLTK.Widgets.Valuators.Sliders.Horizontal;

    package Err renames Ada.Text_IO;


    Number_Of_Buttons : constant := 9;  --  NUMB


    --  N as printf's "%d".
    function Int
           (N : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (N'Image, Ada.Strings.Left);
    end Int;

    --  X as printf's "%.<Places>f".
    function Fixed
           (X      : in Float;
            Places : in Natural)
        return String
    is
        Scale   : constant Long_Float := 10.0 ** Places;
        Rounded : constant Long_Long_Integer :=
            Long_Long_Integer (Long_Float'Floor (abs Long_Float (X) * Scale + 0.5));
        Whole   : constant String := Int (Integer (Rounded / Long_Long_Integer (Scale)));
        Part    : constant String :=
            Int (Integer (Rounded mod Long_Long_Integer (Scale)) + Integer (Scale));
        Sign    : constant String := (if X < 0.0 and Rounded /= 0 then "-" else "");
    begin
        if Places = 0 then
            return Sign & Whole;
        else
            return Sign & Whole & "." & Part (Part'First + 1 .. Part'Last);
        end if;
    end Fixed;


    type Shape_Window is new OGL.GL_Window with record
        Sides : Positive := 3;
    end record;

    overriding procedure Draw
           (This : in out Shape_Window);

    procedure Draw
           (This : in out Shape_Window)
    is
        Ang : Long_Float;
    begin
        if not This.Get_Valid then
            This.Set_Valid (True);
            glLoadIdentity;
            glViewport (0, 0, GLsizei (This.Pixel_W), GLsizei (This.Pixel_H));
        end if;
        glClear (GL_COLOR_BUFFER_BIT);
        glColor3f (0.5, 0.6, 0.7);
        glBegin (GL_POLYGON);
        for J in 0 .. This.Sides - 1 loop
            Ang := Long_Float (J) * 2.0 * Ada.Numerics.Pi / Long_Float (This.Sides);
            glVertex3f (GLfloat (Cos (Ang)), GLfloat (Sin (Ang)), 0.0);
        end loop;
        glEnd;
    end Draw;


    --  After_Resize sets the full screen and maximize buttons from the
    --  window that has them, once the window manager has had its say.
    type Fullscreen_Window is new Sgl.Single_Window with record
        After_Resize : FLTK.Static.Timeout_Handler;
    end record;

    overriding procedure Resize
           (This       : in out Fullscreen_Window;
            X, Y, W, H : in     Integer);

    procedure Resize
           (This       : in out Fullscreen_Window;
            X, Y, W, H : in     Integer) is
    begin
        Sgl.Single_Window (This).Resize (X, Y, W, H);
        if This.After_Resize /= null then
            FLTK.Static.Add_Timeout (0.0, This.After_Resize);
        end if;
    end Resize;


    Two_Windows  : Boolean := False;
    Initial_Full : Boolean := False;

    function Arg
           (Index : in Positive)
        return Natural
    is
        Word : constant String := Ada.Command_Line.Argument (Index);
    begin
        if Word'Length >= 2 and then Word (Word'First + 1) = '2' then
            Two_Windows := True;
            return 1;
        elsif Word'Length >= 2 and then Word (Word'First + 1) = 'f' then
            Initial_Full := True;
            return 1;
        else
            return 0;
        end if;
    end Arg;

    Count     : Natural;
    Arguments : Boolean := True;

begin

    FLTK.Static.Set_Use_High_Res_GL (True);

    begin
        FLTK.Static.Parse_Args (Count, Arg'Unrestricted_Access);
        Arguments := Count >= Ada.Command_Line.Argument_Count;
    exception
        when FLTK.Static.Argument_Error =>
            Arguments := False;
    end;
    if not Arguments then
        --  As Fl::fatal writes it, before it exits with 1.
        Err.Put_Line (Err.Standard_Error,
            "Options are:" & ASCII.LF & " -2 = 2 windows" & ASCII.LF
            & " -f = startup fullscreen" & ASCII.LF & FLTK.Static.Help_Message);
        return 1;
    end if;

    declare

        Window : aliased Fullscreen_Window :=
            (Sgl.Forge.Create (460, 400 + 30 * Number_Of_Buttons) with others => <>);

        SW : aliased Shape_Window :=
           (OGL.Forge.Create
               (10, 10, Window.Get_W - 20, Window.Get_H - 30 * Number_Of_Buttons - 120)
            with others => <>);

        W : access Win.Window'Class;

    begin

        SW.Set_Visible;  --  necessary because SW is not a child of Window
        SW.Set_Mode ((others => False));  --  FL_RGB
        if Two_Windows then  --  make its own window
            SW.Set_Resizable (SW);
            W := SW'Unchecked_Access;
            Window.Set_Modal;  --  makes controls stay on top when full screen
            SW.Show;
        else  --  otherwise make a subwindow
            Window.Add (SW);
            Window.Set_Resizable (SW);
            W := Window'Unchecked_Access;
        end if;

        declare

            Y : Integer := Window.Get_H - 30 * Number_Of_Buttons - 105;

            function Next
                   (Height : in Integer := 30)
                return Integer
            is
                Here : constant Integer := Y;
            begin
                Y := Y + Height;
                return Here;
            end Next;

            Slider : HS.Horizontal_Slider :=
                HS.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "Sides:");
            B1 : Lit.Light_Button :=
                Lit.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "Double Buffered");
            I1 : Inp.Text_Input :=
                Inp.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "Input");
            pragma Unreferenced (I1);  --  only there to be typed into
            Border_Button : Lit.Light_Button :=
                Lit.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "Border");
            Fullscreen_Button : Lit.Light_Button :=
                Lit.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "FullScreen");
            Maximize_Button : Lit.Light_Button :=
                Lit.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "Maximize");
            All_Screens_Button : Lit.Light_Button :=
                Lit.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "All Screens");
            EB : Btn.Button :=
                Btn.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "Exit");
            Browser : Brw.Textline_Browser :=
                Brw.Forge.Create (Window, 50, Next (100), Window.Get_W - 60, 100);
            Update : Btn.Button :=
                Btn.Forge.Create (Window, 50, Next, Window.Get_W - 60, 30, "Update");


            procedure After_Resize is
            begin
                Maximize_Button.Set_State (if W.Is_Maximized then Btn.On else Btn.Off);
                Maximize_Button.Redraw;
                Fullscreen_Button.Set_State (if W.Is_Fullscreen then Btn.On else Btn.Off);
                Fullscreen_Button.Redraw;
            end After_Resize;

            procedure Sides_CB
                   (Item : in out FLTK.Widgets.Widget'Class) is
            begin
                SW.Sides := Integer (HS.Horizontal_Slider (Item).Get_Value);
                SW.Redraw;
            end Sides_CB;

            procedure Double_CB
                   (Item : in out FLTK.Widgets.Widget'Class) is
            begin
                SW.Set_Mode ((Double => Btn.Button (Item).Is_On, others => False));
            end Double_CB;

            procedure Border_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                D : constant Boolean := Btn.Button (Item).Is_On;
            begin
                W.Set_Border (D);
                --  The border change may have been refused (e.g. with a
                --  full screen window).
                if W.Has_Border /= D then
                    Btn.Button (Item).Set_State (if W.Has_Border then Btn.On else Btn.Off);
                end if;
            end Border_CB;

            procedure Flip
                   (Item : in out FLTK.Widgets.Widget'Class) is
            begin
                Btn.Button (Item).Set_State
                   (if Btn.Button (Item).Is_On then Btn.Off else Btn.On);
            end Flip;

            procedure Maximize_CB
                   (Item : in out FLTK.Widgets.Widget'Class) is
            begin
                if W.Is_Fullscreen then
                    Flip (Item);
                elsif W.Is_Maximized then
                    W.Un_Maximize;
                else
                    W.Maximize;
                end if;
            end Maximize_CB;

            procedure Fullscreen_CB
                   (Item : in out FLTK.Widgets.Widget'Class) is
            begin
                if W.Is_Maximized then
                    Flip (Item);
                elsif Btn.Button (Item).Is_On then
                    W.Fullscreen_On;
                else
                    W.Fullscreen_Off;
                end if;
            end Fullscreen_CB;

            --  FLTK numbers the screens from 0, FLTK.Screen from 1.
            procedure All_Screens_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                Top, Bottom, Left, Right                 : Natural := 0;
                Top_Y, Bottom_Y, Left_X, Right_X         : Integer;
                SX, SY, SWidth, SHeight                  : Integer;
            begin
                if Btn.Button (Item).Is_On then
                    FLTK.Screen.Bounding_Rect (SX, SY, SWidth, SHeight, 1);
                    Top_Y := SY;
                    Bottom_Y := SY + SHeight;
                    Left_X := SX;
                    Right_X := SX + SWidth;
                    for I in 1 .. FLTK.Screen.Count - 1 loop
                        FLTK.Screen.Bounding_Rect (SX, SY, SWidth, SHeight, I + 1);
                        if SY < Top_Y then
                            Top := I;
                            Top_Y := SY;
                        end if;
                        if SY + SHeight > Bottom_Y then
                            Bottom := I;
                            Bottom_Y := SY + SHeight;
                        end if;
                        if SX < Left_X then
                            Left := I;
                            Left_X := SX;
                        end if;
                        if SX + SWidth > Right_X then
                            Right := I;
                            Right_X := SX + SWidth;
                        end if;
                    end loop;
                    W.Fullscreen_Screens (Top, Bottom, Left, Right);
                else
                    W.Fullscreen_Own_Screen;
                end if;
            end All_Screens_CB;

            procedure Update_Screen_Info is
                X, Y, Width, Height : Integer;
                DPI_H, DPI_V        : Float;
            begin
                Browser.Clear;
                Browser.Add ("Main screen work area: " & Int (FLTK.Screen.Get_W) & "x"
                    & Int (FLTK.Screen.Get_H) & "@" & Int (FLTK.Screen.Get_X) & ","
                    & Int (FLTK.Screen.Get_Y));
                FLTK.Screen.Work_Area (X, Y, Width, Height);
                Browser.Add ("Mouse screen work area: " & Int (Width) & "x" & Int (Height)
                    & "@" & Int (X) & "," & Int (Y));
                for N in 1 .. FLTK.Screen.Count loop
                    FLTK.Screen.Bounding_Rect (X, Y, Width, Height, N);
                    FLTK.Screen.DPI (DPI_H, DPI_V, N);
                    Browser.Add ("Screen " & Int (N - 1) & ": " & Int (Width) & "x"
                        & Int (Height) & "@" & Int (X) & "," & Int (Y) & " DPI:"
                        & Fixed (DPI_H, 1) & "x" & Fixed (DPI_V, 1) & " scale:"
                        & Fixed (FLTK.Screen.Get_Scale (N), 2));
                    FLTK.Screen.Work_Area (X, Y, Width, Height, N);
                    Browser.Add ("Work area " & Int (N - 1) & ": " & Int (Width) & "x"
                        & Int (Height) & "@" & Int (X) & "," & Int (Y));
                end loop;
            end Update_Screen_Info;

            procedure Update_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                pragma Unreferenced (Item);
            begin
                Update_Screen_Info;
            end Update_CB;

            procedure Exit_CB
                   (Item : in out FLTK.Widgets.Widget'Class)
            is
                pragma Unreferenced (Item);
            begin
                GNAT.OS_Lib.OS_Exit (0);
            end Exit_CB;

        begin

            Slider.Set_Alignment (FLTK.Align_Left);
            Slider.Set_Callback (Sides_CB'Unrestricted_Access);
            Slider.Set_Value (Long_Float (SW.Sides));
            Slider.Set_Step (1);
            Slider.Set_Bounds (3.0, 40.0);
            B1.Set_Callback (Double_CB'Unrestricted_Access);
            Border_Button.Set_Callback (Border_CB'Unrestricted_Access);
            Border_Button.Set_State (Btn.On);
            Fullscreen_Button.Set_Callback (Fullscreen_CB'Unrestricted_Access);
            Maximize_Button.Set_Callback (Maximize_CB'Unrestricted_Access);
            All_Screens_Button.Set_Callback (All_Screens_CB'Unrestricted_Access);
            EB.Set_Callback (Exit_CB'Unrestricted_Access);
            Update_Screen_Info;
            Update.Set_Callback (Update_CB'Unrestricted_Access);
            if Initial_Full then
                Fullscreen_Button.Set_State (Btn.On);
                Fullscreen_Button.Do_Callback;
            end if;
            Window.After_Resize := After_Resize'Unrestricted_Access;
            Window.Show_With_Args;
            return FLTK.Run;

        end;

    end;

end Fullscreen;
