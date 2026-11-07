--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK-issues.md F3, and PLAN.md's decision on drawing state: a hook that
--  pushes a clip, a matrix or a current surface, begins an offscreen,
--  starts a page or calls OpenGL.Start, and then raises before the pop,
--  has what it pushed undone as the exception leaves the hook
--  (FLTK.Drawing_State).  Otherwise FLTK goes on drawing the rest of the
--  window clipped, transformed, into the offscreen or at OpenGL's scale.
--  A raise in a nested hook undoes only what that hook pushed, not what
--  the hook around it did.  The guards (Clip_Guard, Matrix_Guard, ...)
--  pop on both a normal exit and a raise.
--
--  In the window, a group clips to itself around two boxes.  Box A pushes
--  something and raises; box B, drawn after it, and the group, after both,
--  note the state they draw with.


with

    Ada.Directories,
    Ada.Exceptions,
    Checks,
    FLTK.Devices.Surface.Image,
    FLTK.Devices.Surface.Paged.Postscript,
    FLTK.Draw.OpenGL,
    FLTK.Draw.Offscreens,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Draw_State is

    package Prb renames FLTK.Probe;
    package Dr  renames FLTK.Draw;
    package GL  renames FLTK.Draw.OpenGL;
    package Off renames FLTK.Draw.Offscreens;
    package Srf renames FLTK.Devices.Surface;
    package Pgd renames FLTK.Devices.Surface.Paged;
    package PS  renames FLTK.Devices.Surface.Paged.Postscript;
    package Wdg renames FLTK.Widgets;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;

    Boom : exception;

    Boom_Id : constant Ada.Exceptions.Exception_Id := Boom'Identity;

    On_X11 : constant Boolean := not Prb.On_Wayland;

    type Mode_Kind is
       (Quiet,
        Clip, No_Clip, Matrix, Drawing, Current, Start,
        Clip_Guarded, No_Clip_Guarded, Matrix_Guarded, Drawing_Guarded, Current_Guarded,
        Start_Guarded,
        Guards_Kept);

    Picture : aliased Off.Offscreen := Off.Forge.Create (20, 20);

    Image : aliased FLTK.Devices.Surface.Image.Image_Surface :=
        FLTK.Devices.Surface.Image.Forge.Create (20, 20);


    --  What B and the group saw.
    B_Drawn       : Boolean     := False;
    B_Clipped     : Boolean     := False;
    B_Shift       : Long_Float  := 0.0;
    B_On_Screen   : Boolean     := False;
    B_Starts      : Boolean     := False;
    Check_Start   : Boolean     := False;
    Outside_Shown : Boolean     := False;

    --  What A saw in Guards_Kept, inside its guards and after them.
    Inside_Clipped, After_Clipped     : Boolean    := False;
    Inside_No_Clip, After_No_Clip     : Boolean    := False;
    Inside_Shift, After_Shift         : Long_Float := 0.0;
    Inside_Drawing, After_Drawing     : Boolean    := False;
    Inside_Current, After_Current     : Boolean    := False;
    Start_Kept                        : Boolean    := False;




    --  The boxes and the group  --

    type A_Box is new Bx.Box with record
        Mode : Mode_Kind := Quiet;
    end record;

    overriding procedure Draw
           (This : in out A_Box);

    type B_Box is new Bx.Box with null record;

    overriding procedure Draw
           (This : in out B_Box);

    type Clip_Group is new Grp.Group with null record;

    overriding procedure Draw
           (This : in out Clip_Group);


    function On_Screen
        return Boolean is
    begin
        return Srf.Get_Original.Is_Current;
    end On_Screen;


    overriding procedure Draw
           (This : in out A_Box) is
    begin
        case This.Mode is
            when Quiet =>
                Bx.Box (This).Draw;
            when Clip =>
                Dr.Push_Clip (0, 0, 1, 1);
                raise Boom with "clip";
            when No_Clip =>
                Dr.Push_No_Clip;
                raise Boom with "no clip";
            when Matrix =>
                Dr.Push_Matrix;
                Dr.Translate (1000.0, 0.0);
                raise Boom with "matrix";
            when Drawing =>
                Picture.Begin_Drawing;
                raise Boom with "offscreen";
            when Current =>
                Srf.Push_Current (Image);
                raise Boom with "current surface";
            when Start =>
                GL.Start;
                raise Boom with "OpenGL.Start";
            when Clip_Guarded =>
                declare
                    Guard : Dr.Clip_Guard (0, 0, 1, 1);
                begin
                    raise Boom with "clip guard";
                end;
            when No_Clip_Guarded =>
                declare
                    Guard : Dr.No_Clip_Guard;
                begin
                    raise Boom with "no clip guard";
                end;
            when Matrix_Guarded =>
                declare
                    Guard : Dr.Matrix_Guard;
                begin
                    Dr.Translate (1000.0, 0.0);
                    raise Boom with "matrix guard";
                end;
            when Drawing_Guarded =>
                declare
                    Guard : Off.Drawing_Guard (Picture'Access);
                begin
                    raise Boom with "drawing guard";
                end;
            when Current_Guarded =>
                declare
                    Guard : Srf.Current_Guard (Image'Access);
                begin
                    raise Boom with "current guard";
                end;
            when Start_Guarded =>
                declare
                    Guard : GL.Start_Guard;
                begin
                    raise Boom with "start guard";
                end;
            when Guards_Kept =>
                declare
                    Guard : Dr.Clip_Guard (0, 0, 1, 1);
                begin
                    Inside_Clipped := not Dr.Clip_Intersects (100, 10, 60, 40);
                end;
                After_Clipped := not Dr.Clip_Intersects (100, 10, 60, 40);
                declare
                    Guard : Dr.No_Clip_Guard;
                begin
                    Inside_No_Clip := Dr.Clip_Intersects (250, 150, 10, 10);
                end;
                After_No_Clip := Dr.Clip_Intersects (250, 150, 10, 10);
                declare
                    Guard : Dr.Matrix_Guard;
                begin
                    Dr.Translate (1000.0, 0.0);
                    Inside_Shift := Dr.Transform_X (0.0, 0.0);
                end;
                After_Shift := Dr.Transform_X (0.0, 0.0);
                declare
                    Guard : Off.Drawing_Guard (Picture'Access);
                begin
                    Inside_Drawing := Picture.Is_Drawing and not On_Screen;
                end;
                After_Drawing := not Picture.Is_Drawing and On_Screen;
                declare
                    Guard : Srf.Current_Guard (Image'Access);
                begin
                    Inside_Current := Image.Is_Current;
                end;
                After_Current := On_Screen;
                if On_X11 then
                    declare
                        Guard : GL.Start_Guard;
                    begin
                        null;
                    end;
                    begin
                        GL.Start;
                        GL.Finish;
                        Start_Kept := True;
                    exception
                    when others =>
                        Start_Kept := False;
                    end;
                end if;
        end case;
    end Draw;


    overriding procedure Draw
           (This : in out B_Box) is
    begin
        B_Drawn := True;
        B_Clipped := not Dr.Clip_Intersects (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        B_Shift := Dr.Transform_X (0.0, 0.0);
        B_On_Screen := On_Screen;
        if Check_Start then
            begin
                GL.Start;
                GL.Finish;
                B_Starts := True;
            exception
            when others =>
                B_Starts := False;
            end;
        end if;
        Bx.Box (This).Draw;
    end Draw;


    --  Clips to itself, which leaves 250, 150 outside, then draws A and B.
    overriding procedure Draw
           (This : in out Clip_Group) is
    begin
        Dr.Push_Clip (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        This.Draw_Children;
        Outside_Shown := Dr.Clip_Intersects (250, 150, 10, 10);
        Dr.Pop_Clip;
    end Draw;




    --  The window  --

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Draw_State");

    Group : Clip_Group := (Grp.Forge.Create (Window, 0, 0, 200, 100) with null record);

    A : A_Box := (Bx.Forge.Create (Group, Flat_Box, 10, 10, 60, 40) with Mode => Quiet);

    B : B_Box := (Bx.Forge.Create (Group, Flat_Box, 100, 10, 60, 40) with null record);

    Button : Btn.Button := Btn.Forge.Create (Window, 210, 10, 80, 30, "Page");


    procedure Pump
           (Times : in Positive := 10) is
    begin
        for I in 1 .. Times loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    procedure Pump_10 is
    begin
        Pump (10);
    end Pump_10;

    procedure Redraw is
    begin
        B_Drawn := False;
        Outside_Shown := True;
        Window.Redraw;
    end Redraw;

    --  A draws in Mode and raises; B and the group draw as they would with
    --  nothing pushed.
    procedure Raise_In
           (Mode : in Mode_Kind;
            What : in String) is
    begin
        A.Mode := Mode;
        Check_Start := Mode in Start | Start_Guarded;
        Redraw;
        Raises (Pump_10'Access, Boom_Id, What & ": the exception reaches Wait");
        A.Mode := Quiet;
        Check (B_Drawn, What & ": B is drawn");
        Check (not B_Clipped, What & ": B is not clipped");
        Check (B_Shift = 0.0, What & ": B is not translated:" & B_Shift'Image);
        Check (B_On_Screen, What & ": B draws on the screen");
        Check (not Picture.Is_Drawing, What & ": the offscreen is not begun");
        if Check_Start then
            Check (B_Starts, What & ": B can Start and Finish");
        end if;
        Check (not Outside_Shown, What & ": the group's clip is kept");
        Check_Start := False;
        Redraw;
        Pump (5);
        Check (B_Drawn and B_On_Screen and not B_Clipped, What & ": a later redraw is right");
    end Raise_In;




    --  Pages, in a callback  --

    Name : constant String := "test_draw_state.ps";

    Device : aliased PS.Postscript_File_Device := PS.Forge.Create;

    type Page_Mode is (Start_Page, Page_Guarded, Page_Kept);

    Doing : Page_Mode := Start_Page;

    Inside_Page : Boolean := False;

    procedure Press
           (Ignore : in out Wdg.Widget'Class) is
    begin
        case Doing is
            when Start_Page =>
                Device.Start_Page;
                Dr.Line (10, 10, 100, 100);
                raise Boom with "page";
            when Page_Guarded =>
                declare
                    Guard : Pgd.Page_Guard (Device'Access);
                begin
                    raise Boom with "page guard";
                end;
            when Page_Kept =>
                declare
                    Guard : Pgd.Page_Guard (Device'Access);
                begin
                    Inside_Page := Device.Is_Current;
                    Dr.Line (10, 10, 100, 100);
                end;
        end case;
    end Press;

    --  A click, so that FLTK calls Press: Do_Callback calls it from Ada,
    --  where an exception propagates as usual and nothing is undone.
    procedure Do_Press
    is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Push, 250, 25);
        Ignore := Prb.Mouse (Window, Release, 250, 25);
    end Do_Press;

    procedure Page_Raises
           (Mode : in Page_Mode;
            What : in String) is
    begin
        Doing := Mode;
        Raises (Do_Press'Access, Boom_Id, What & ": the exception reaches the click");
        Check (not Device.Is_Current, What & ": the device is not current");
        Check (On_Screen, What & ": the screen is current again");
        Device.Start_Page;
        Check (Device.Is_Current, What & ": a later Start_Page works");
        Device.End_Page;
    end Page_Raises;

    Output : PS.File_Type;

    procedure End_Job is
    begin
        Device.End_Job;
    end End_Job;


begin

    A.Set_Background_Color (RGB_Red_Color);
    B.Set_Background_Color (RGB_Red_Color);
    Button.Set_Callback (Press'Unrestricted_Access);

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump;
    Check (not Outside_Shown, "the group clips itself");
    Check (B_Drawn and B_On_Screen and not B_Clipped and B_Shift = 0.0,
        "B draws unclipped, untranslated, on the screen");


    Raise_In (Clip, "Push_Clip");
    Raise_In (No_Clip, "Push_No_Clip");
    Raise_In (Matrix, "Push_Matrix");
    Raise_In (Drawing, "Begin_Drawing");
    Raise_In (Current, "Push_Current");
    if On_X11 then
        Raise_In (Start, "OpenGL.Start");
    else
        Skip ("OpenGL.Start: FLTK crashes on it under Wayland (pofltk 109)");
    end if;

    Raise_In (Clip_Guarded, "Clip_Guard");
    Raise_In (No_Clip_Guarded, "No_Clip_Guard");
    Raise_In (Matrix_Guarded, "Matrix_Guard");
    Raise_In (Drawing_Guarded, "Drawing_Guard");
    Raise_In (Current_Guarded, "Current_Guard");
    if On_X11 then
        Raise_In (Start_Guarded, "Start_Guard");
    else
        Skip ("Start_Guard: FLTK crashes on Start under Wayland (pofltk 109)");
    end if;


    --  The guards, left normally.
    A.Mode := Guards_Kept;
    Redraw;
    Pump;
    A.Mode := Quiet;
    Check (Inside_Clipped and not After_Clipped, "Clip_Guard clips inside and not after");
    Check (Inside_No_Clip and not After_No_Clip, "No_Clip_Guard unclips inside and not after");
    Check (Inside_Shift = 1000.0 and After_Shift = 0.0,
        "Matrix_Guard keeps a matrix inside and not after:"
        & Inside_Shift'Image & After_Shift'Image);
    Check (Inside_Drawing and After_Drawing, "Drawing_Guard begins inside and ends after");
    Check (Inside_Current and After_Current, "Current_Guard pushes inside and pops after");
    if On_X11 then
        Check (Start_Kept, "Start_Guard finishes after");
    end if;
    Check (not Outside_Shown, "the group's clip is kept after the guards");
    Check (B_Drawn and B_On_Screen and not B_Clipped and B_Shift = 0.0,
        "B is drawn as before after the guards");


    --  Pages.
    Output.Open (Name);
    Device.Start_Job (Output, 3);
    Page_Raises (Start_Page, "Start_Page");
    Page_Raises (Page_Guarded, "Page_Guard");
    Doing := Page_Kept;
    Do_Press;
    Check (Inside_Page and not Device.Is_Current and On_Screen,
        "Page_Guard starts a page inside and ends it after");
    No_Raise (End_Job'Access, "End_Job after the pages");
    Output.Close;
    if Ada.Directories.Exists (Name) then
        Ada.Directories.Delete_File (Name);
    end if;

    Window.Hide;
    Summary;

end Test_Draw_State;
