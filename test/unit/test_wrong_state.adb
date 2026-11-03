


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 3: calls that crash FLTK 1.4.5 without the window they
--  need, now raise instead (pofltk 109, 111, 124 and 129).  Overlays and
--  scrolling need a current, shown window; Make_Current a shown one; FL/gl.h
--  text a GL context; Set_Grab a shown window.  Each is also tried where it
--  is allowed, to check the guards don't refuse it there.


with

    Ada.Exceptions,
    Checks,
    FLTK.Devices.Surface.Image,
    FLTK.Draw.OpenGL,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Windows.OpenGL,
    Scroll_Areas;

use

    Checks;

use type

    Scroll_Areas.Area_Record;


procedure Test_Wrong_State is

    package Dr  renames FLTK.Draw;
    package GLD renames FLTK.Draw.OpenGL;
    package Win renames FLTK.Widgets.Groups.Windows;
    package GL  renames FLTK.Widgets.Groups.Windows.OpenGL;
    package Img renames FLTK.Devices.Surface.Image;

    PE : constant Ada.Exceptions.Exception_Id := Program_Error'Identity;




    --  What the calls do, outside any window  --

    procedure Overlay_Rect is
    begin
        Dr.Overlay_Rect (0, 0, 10, 10);
    end Overlay_Rect;

    procedure Overlay_Clear is
    begin
        Dr.Overlay_Clear;
    end Overlay_Clear;

    procedure Scroll_By_One is
    begin
        Dr.Scroll (0, 0, 10, 10, 1, 0, Scroll_Areas.Draw'Access);
    end Scroll_By_One;

    procedure Scroll_By_None is
    begin
        Dr.Scroll (0, 0, 10, 10, 0, 0, Scroll_Areas.Draw'Access);
    end Scroll_By_None;

    procedure GL_Font is
    begin
        GLD.Set_Font (FLTK.Helvetica, 14);
    end GL_Font;

    procedure GL_Text is
    begin
        GLD.Draw_Text ("text");
    end GL_Text;

    procedure GL_Height is
        Ignore : constant Integer := GLD.Font_Height;
    begin
        null;
    end GL_Height;

    procedure GL_Width is
        Ignore : constant Long_Float := GLD.Width ("text");
    begin
        null;
    end GL_Width;

    procedure GL_Start is
    begin
        GLD.Start;
    end GL_Start;

    procedure GL_Finish is
    begin
        GLD.Finish;
    end GL_Finish;




    --  What they do inside a draw  --

    type Exception_Name is access constant String;

    function Name_Of
           (Occurrence : in Ada.Exceptions.Exception_Occurrence)
        return Exception_Name is
    begin
        return new String'(Ada.Exceptions.Exception_Name (Occurrence));
    end Name_Of;

    None : constant Exception_Name := new String'("none");

    Wayland : Boolean := False;

    type Plain_Window is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Plain_Window);

    Plain_Draws   : Natural := 0;
    Overlay_Draw  : Exception_Name := None;
    Scroll_Draw   : Exception_Name := None;
    Start_Draw    : Exception_Name := None;
    Start_Font    : Exception_Name := None;

    overriding procedure Draw
           (This : in out Plain_Window) is
    begin
        Win.Window (This).Draw;
        begin
            Dr.Overlay_Rect (1, 1, 10, 10);
            Dr.Overlay_Clear;
        exception
        when Occurrence : others => Overlay_Draw := Name_Of (Occurrence);
        end;
        begin
            Dr.Scroll (0, 0, 20, 20, 0, 0, Scroll_Areas.Draw'Access);
            Dr.Scroll (0, 0, 20, 20, 2, 0, Scroll_Areas.Draw'Access);
        exception
        when Occurrence : others => Scroll_Draw := Name_Of (Occurrence);
        end;
        begin
            GLD.Start;
            begin
                GLD.Set_Font (FLTK.Helvetica, 14);
                GLD.Draw_Text (5, 20, "gl");
            exception
            when Occurrence : others => Start_Font := Name_Of (Occurrence);
            end;
            GLD.Finish;
        exception
        when Occurrence : others => Start_Draw := Name_Of (Occurrence);
        end;
        Plain_Draws := Plain_Draws + 1;
    end Draw;

    type Text_GL_Window is new GL.GL_Window with null record;

    overriding procedure Draw
           (This : in out Text_GL_Window);

    GL_Draws    : Natural := 0;
    GL_Text_Run : Exception_Name := None;
    GL_Mode_Run : Exception_Name := None;

    overriding procedure Draw
           (This : in out Text_GL_Window) is
    begin
        begin
            GLD.Set_Font (FLTK.Helvetica, 14);
            GLD.Draw_Text (5.0, 5.0, "gl");
        exception
        when Occurrence : others => GL_Text_Run := Name_Of (Occurrence);
        end;
        begin
            This.Set_Mode (This.Get_Mode);
        exception
        when Occurrence : others => GL_Mode_Run := Name_Of (Occurrence);
        end;
        GL_Draws := GL_Draws + 1;
    end Draw;

    procedure Settle
           (Done : access function return Boolean) is
    begin
        for N in 1 .. 40 loop
            exit when Done.all or else FLTK.Wait (0.05) < 0.0;
        end loop;
    end Settle;

    function Plain_Drawn return Boolean is (Plain_Draws > 0);
    function GL_Drawn return Boolean is (GL_Draws > 0);

begin

    FLTK.Static.Open_Display;
    Wayland := FLTK.Probe.On_Wayland;

    --  pofltk 124: no current window.
    Raises (Overlay_Rect'Access, PE, "Overlay_Rect with no window raises Program_Error");
    Raises (Overlay_Clear'Access, PE, "Overlay_Clear with no window raises Program_Error");
    Raises (Scroll_By_One'Access, PE, "Scroll with no window raises Program_Error");
    Raises (Scroll_By_None'Access, PE, "Scroll by nothing with no window raises Program_Error");

    --  pofltk 111: no GL context.
    Raises (GL_Font'Access, PE, "GL Set_Font with no context raises Program_Error");
    Raises (GL_Text'Access, PE, "GL Draw_Text with no context raises Program_Error");
    Raises (GL_Height'Access, PE, "GL Font_Height with no context raises Program_Error");
    Raises (GL_Width'Access, PE, "GL Width with no context raises Program_Error");
    Raises (GL_Finish'Access, PE, "GL Finish with no Start raises Program_Error");

    --  pofltk 109 and 111: gl_start needs a shown current window, and
    --  crashes on Wayland whatever there is.
    if Wayland then
        Raises (GL_Start'Access, FLTK.Unsupported_Error'Identity,
            "GL Start on Wayland raises Unsupported_Error");
    else
        Raises (GL_Start'Access, PE, "GL Start with no window raises Program_Error");
    end if;

    --  pofltk 124: on a surface, Scroll draws the whole area again.
    declare
        Surface : Img.Image_Surface := Img.Forge.Create (20, 20);
    begin
        FLTK.Devices.Surface.Push_Current (Surface);
        Scroll_Areas.Calls := 0;
        Dr.Scroll (2, 3, 10, 12, 4, 0, Scroll_Areas.Draw'Access);
        Check (Scroll_Areas.Calls = 1 and then Scroll_Areas.Last = (2, 3, 10, 12),
            "Scroll on a surface draws the whole area:" & Natural'Image (Scroll_Areas.Calls));
        Scroll_Areas.Calls := 0;
        Dr.Scroll (2, 3, 10, 12, 0, 0, Scroll_Areas.Draw'Access);
        Check (Scroll_Areas.Calls = 0, "Scroll by nothing on a surface draws nothing");
        Raises (Overlay_Rect'Access, PE, "Overlay_Rect on a surface raises Program_Error");
        FLTK.Devices.Surface.Pop_Current;
    end;

    --  pofltk 111 and 129: windows not shown.
    declare
        Window    : Win.Window := Win.Forge.Create (0, 0, 100, 100, "Test_Wrong_State");
        GL_Window : GL.GL_Window := GL.Forge.Create (0, 0, 100, 100);

        procedure Make_Window_Current is
        begin
            Window.Make_Current;
        end Make_Window_Current;

        procedure Make_GL_Current is
        begin
            GL_Window.Make_Current;
        end Make_GL_Current;

        procedure Grab is
        begin
            FLTK.Events.Set_Grab (Window);
        end Grab;
    begin
        Raises (Make_Window_Current'Access, PE,
            "Window Make_Current before Show raises Program_Error");
        Raises (Make_GL_Current'Access, PE,
            "GL_Window Make_Current before Show raises Program_Error");
        Raises (Grab'Access, PE, "Set_Grab on a window not shown raises Program_Error");
        Check (FLTK.Events.Get_Grab = null, "the refused grab was not set");

        Window.Show;
        Window.Wait_For_Expose;
        No_Raise (Make_Window_Current'Access, "Window Make_Current after Show raises nothing");
        No_Raise (Grab'Access, "Set_Grab on a shown window raises nothing");
        Check (FLTK.Events.Get_Grab /= null, "the grab is set");
    end;

    --  pofltk 129: the grabbed window was finalized.
    Check (FLTK.Events.Get_Grab = null, "a finalized window's grab is cleared");

    --  pofltk 111: Fl_Window::current() dangles now, and must not be used.
    Raises (Overlay_Rect'Access, PE,
        "Overlay_Rect after the current window was finalized raises Program_Error");
    Raises (GL_Font'Access, PE,
        "GL Set_Font after the current window was finalized raises Program_Error");

    --  Inside a plain window's draw.
    declare
        Window : Plain_Window := (Win.Forge.Create (0, 0, 100, 100) with null record);
    begin
        Window.Show;
        Settle (Plain_Drawn'Access);
        Check (Plain_Draws > 0, "the plain window was drawn");
        Check (Overlay_Draw.all = "none",
            "Overlay_Rect and Overlay_Clear in a draw raise nothing: " & Overlay_Draw.all);
        Check (Scroll_Draw.all = "none", "Scroll in a draw raises nothing: " & Scroll_Draw.all);
        if Wayland then
            Check (Start_Draw.all = "FLTK.UNSUPPORTED_ERROR",
                "GL Start in a draw on Wayland raises Unsupported_Error: " & Start_Draw.all);
        else
            Check (Start_Draw.all = "none", "GL Start in a draw raises nothing: " & Start_Draw.all);
            Check (Start_Font.all = "none",
                "GL text after Start raises nothing: " & Start_Font.all);
        end if;
    end;

    --  Inside a GL window's draw.
    declare
        GL_Window : Text_GL_Window := (GL.Forge.Create (0, 0, 100, 100) with null record);

        procedure Make_GL_Current is
        begin
            GL_Window.Make_Current;
        end Make_GL_Current;
    begin
        GL_Window.Show;
        Settle (GL_Drawn'Access);
        Check (GL_Draws > 0, "the GL window was drawn");
        Check (GL_Text_Run.all = "none", "GL text in a GL draw raises nothing: " & GL_Text_Run.all);
        Check (GL_Mode_Run.all = "PROGRAM_ERROR",
            "GL_Window Set_Mode in its draw raises Program_Error: " & GL_Mode_Run.all);
        No_Raise (Make_GL_Current'Access, "GL_Window Make_Current after Show raises nothing");
        No_Raise (GL_Font'Access, "GL Set_Font after Make_Current raises nothing");
    end;

    Summary;

end Test_Wrong_State;


