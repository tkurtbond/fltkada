

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK.Widgets.Forms:  FLTK's Forms classes, Timers, Frees, Bitmaps,
--  Pixmaps and Texts, after pofltk's TestForms (pofltk 105, 106, 107).
--  Run from test/unit: test/images/rb.xpm and rb.gif are 4 by 2, red left
--  and blue right, and anim.gif is three frames of that size.  A widget
--  shows them at its top left.  pofltk's HaltFormsBitmap and
--  HaltFormsPixmap, an image of the wrong kind, can't be written in Ada:
--  Set_Bitmap and Set_Pixmap take only their own kind.  Its
--  HaltFormsTimerKind and HaltFormsFreeKind, a kind out of range, can't
--  either: the kinds are enumerations.


with

    Ada.Calendar,
    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Events,
    FLTK.Images.Bitmaps,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Images.Pixmaps.XPM,
    FLTK.Probe,
    FLTK.Widgets.Forms.Bitmaps,
    FLTK.Widgets.Forms.Frees,
    FLTK.Widgets.Forms.Pixmaps,
    FLTK.Widgets.Forms.Texts,
    FLTK.Widgets.Forms.Timers,
    FLTK.Widgets.Groups.Windows;

use

    Checks;

use type

    FLTK.Alignment,
    FLTK.Box_Kind,
    FLTK.Event_Kind,
    FLTK.Keypress,
    FLTK.Mouse_Button;


procedure Test_Forms is

    package Anm renames FLTK.Images.Pixmaps.GIF.Animated;
    package Bmp renames FLTK.Widgets.Forms.Bitmaps;
    package Fre renames FLTK.Widgets.Forms.Frees;
    package Gif renames FLTK.Images.Pixmaps.GIF;
    package Pxm renames FLTK.Widgets.Forms.Pixmaps;
    package Prb renames FLTK.Probe;
    package Txt renames FLTK.Widgets.Forms.Texts;
    package Tmr renames FLTK.Widgets.Forms.Timers;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Wdg renames FLTK.Widgets;

    use type Prb.RGB;


    White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);
    Red   : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Green : constant Prb.RGB := Prb.To_RGB (0, 255, 0);
    Blue  : constant Prb.RGB := Prb.To_RGB (0, 0, 255);

    Ignore      : Boolean;
    Ignore_Time : Long_Float;


    --  Pixel X, Y of Item as drawn.
    function Pixel
           (Item : in Wdg.Widget'Class;
            X, Y : in Integer)
        return Prb.RGB
    is
        Result : Prb.RGB;
    begin
        Ignore := Prb.Capture (Item);
        Result := Prb.Pixel (X, Y);
        Prb.Release;
        return Result;
    end Pixel;


    --  How many pixels of Item, as drawn, in columns X0 to X1 aren't Color.
    function Ink
           (Item   : in Wdg.Widget'Class;
            X0, X1 : in Integer;
            Color  : in Prb.RGB)
        return Natural
    is
        Count : Natural := 0;
    begin
        Ignore := Prb.Capture (Item);
        for Y in 0 .. Item.Get_H - 1 loop
            for X in X0 .. X1 loop
                if Prb.Pixel (X, Y) /= Color then
                    Count := Count + 1;
                end if;
            end loop;
        end loop;
        Prb.Release;
        return Count;
    end Ink;


    --  Lets FLTK's timers run for Seconds.
    procedure Run
           (Seconds : in Long_Float)
    is
        use type Ada.Calendar.Time;
        Stop : constant Ada.Calendar.Time := Ada.Calendar.Clock + Duration (Seconds);
    begin
        while Ada.Calendar.Clock < Stop loop
            Ignore_Time := FLTK.Wait (0.01);
        end loop;
    end Run;


    procedure Wait_For
           (Done : not null access function return Boolean) is
    begin
        for I in 1 .. 1000 loop
            exit when Done.all;
            Ignore_Time := FLTK.Wait (0.01);
        end loop;
    end Wait_For;




    --  Timers  --

    type Timer_Access is access Tmr.Timer;
    procedure Free is new Ada.Unchecked_Deallocation (Tmr.Timer, Timer_Access);

    Ringing : Timer_Access;
    Rung    : Natural := 0;
    Dies    : Boolean := False;

    procedure Ring
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Rung := Rung + 1;
        if Dies then
            Free (Ringing);
        end if;
    end Ring;

    function Has_Rung
        return Boolean is (Rung > 0);


    procedure Test_Timers is
        T          : Timer_Access :=
            new Tmr.Timer'(Tmr.Forge.Create (Tmr.Normal_Timer, 0, 0, 100, 30));
        V          : Long_Float;
        Gone, Left : Natural;
    begin
        Check (T.Is_Suspended, "a timer starts stopped");
        Check (T.Get_Value = 0.0, "with no time");
        Check (not T.Counts_Up, "showing the time left");
        Check (T.Get_Box = FLTK.Down_Box, "in a down box");
        T.Set_Value (1000.0);
        Check (not T.Is_Suspended, "setting a time starts it");
        V := T.Get_Value;
        Check (V > 0.0 and V <= 1000.0, "and it has that time");
        T.Set_Suspended (True);
        Check (T.Is_Suspended, "it can be suspended");
        T.Set_Suspended (False);
        Check (not T.Is_Suspended, "and started again");
        Free (T);
        Run (0.3);
        Check (True, "a timer freed as it runs stops");

        Ringing := new Tmr.Timer'(Tmr.Forge.Create (Tmr.Hidden_Timer, 0, 0, 10, 10));
        Ringing.Set_Callback (Ring'Unrestricted_Access);
        Check (not Ringing.Is_Visible, "a hidden timer isn't visible");
        Ringing.Set_Value (0.05);
        Wait_For (Has_Rung'Access);
        Check (Rung = 1, "it calls back as it runs out");
        Check (Ringing.Get_Value = 0.0, "with no time left");
        Check (Ringing.Is_Suspended, "and stops");
        Run (0.3);
        Check (Rung = 1, "calling back once");
        Free (Ringing);

        Rung := 0;
        Dies := True;
        Ringing := new Tmr.Timer'(Tmr.Forge.Create (Tmr.Hidden_Timer, 0, 0, 10, 10));
        Ringing.Set_Callback (Ring'Unrestricted_Access);
        Ringing.Set_Value (0.05);
        Wait_For (Has_Rung'Access);
        Run (0.3);
        Check (Rung = 1 and Ringing = null, "a timer can be freed in its callback as it runs out");

        --  pofltk 107: text as long as "1:40.0" against text as long as
        --  "0.0".  FLTK's header has these the other way around.
        T := new Tmr.Timer'(Tmr.Forge.Create (Tmr.Value_Timer, 0, 0, 100, 30));
        T.Set_Box (FLTK.Flat_Box);
        T.Set_Background_Color (FLTK.White_Color);
        T.Set_Label_Color (FLTK.Black_Color);
        T.Set_Value (100.0);
        T.Set_Suspended (True);
        Left := Ink (T.all, 0, 99, White);
        T.Set_Counts_Up (True);
        Check (T.Counts_Up, "a timer can show the time gone");
        Gone := Ink (T.all, 0, 99, White);
        Check (Left > Gone, "the default shows the time left, the other the time gone:"
            & Natural'Image (Left) & Natural'Image (Gone));
        Free (T);
    end Test_Timers;




    --  Frees  --

    type Heard is new Fre.Free with record
        Draws, Pushes, Drags, Keys, Steps, Unnamed, Calls : Natural := 0;
        X, Y   : Integer := -1;
        Button : FLTK.Mouse_Button := FLTK.No_Button;
        Key    : FLTK.Keypress;
        Called : Boolean := False;
    end record;

    overriding function Handle_Free
           (This  : in out Heard;
            Kind  : in     Fre.Free_Event_Kind;
            Event : in     FLTK.Event_Kind;
            X, Y  : in     Integer)
        return Boolean;

    function Handle_Free
           (This  : in out Heard;
            Kind  : in     Fre.Free_Event_Kind;
            Event : in     FLTK.Event_Kind;
            X, Y  : in     Integer)
        return Boolean is
    begin
        case Kind is
        when Fre.Draw_Event =>
            This.Draws := This.Draws + 1;
        when Fre.Step_Event =>
            This.Steps := This.Steps + 1;
        when Fre.FLTK_Event =>
            case Event is
            when FLTK.Push =>
                This.Pushes := This.Pushes + 1;
                This.Button := FLTK.Events.Last_Button;
            when FLTK.Drag =>
                This.Drags := This.Drags + 1;
            when FLTK.Keydown =>
                This.Keys := This.Keys + 1;
                This.Key := FLTK.Events.Last_Key;
            when others =>
                This.Unnamed := This.Unnamed + 1;
            end case;
        end case;
        This.X := X;
        This.Y := Y;
        return This.Called;
    end Handle_Free;

    function Make
           (Kind       : in Fre.Free_Kind;
            X, Y, W, H : in Integer)
        return Heard is
    begin
        return (Fre.Forge.Create (Kind, X, Y, W, H) with others => <>);
    end Make;

    type Heard_Access is access Heard;
    procedure Free is new Ada.Unchecked_Deallocation (Heard, Heard_Access);

    Current : Heard_Access;

    procedure Call_Back
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Current.Calls := Current.Calls + 1;
    end Call_Back;

    function Has_Stepped
        return Boolean is (Current.Steps > 0);


    procedure Test_Frees is
    begin
        declare
            Window : Win.Window := Win.Forge.Create (0, 0, 100, 100, "free");
            H      : Heard_Access := new Heard'(Make (Fre.Normal_Free, 10, 10, 40, 40));
        begin
            Window.Add (H.all);
            Current := H;
            H.Set_Callback (Call_Back'Unrestricted_Access);
            Ignore := Prb.Capture (H.all);
            Prb.Release;
            Check (H.Draws = 1, "a free draws through Handle_Free");
            Check (H.X = 0 and H.Y = 0 and H.Pushes + H.Unnamed = 0, "with nothing else to say");

            Ignore := Prb.Mouse (Window, FLTK.Push, 20, 30, FLTK.Left_Button);
            Check (H.Pushes = 1, "a free hears a push");
            Check (H.X = 20 and H.Y = 30, "and where:" & Integer'Image (H.X) & Integer'Image (H.Y));
            Check (H.Button = FLTK.Left_Button, "and FLTK.Events says with which button");
            Check (H.Calls = 0, "it doesn't call back when told not to");
            H.Called := True;
            Ignore := Prb.Mouse (Window, FLTK.Drag, 25, 35, FLTK.Left_Button);
            Check (H.Drags = 1, "it hears a drag");
            Check (H.Calls = 1, "and calls back when told to");
            H.Called := False;
            Ignore := Prb.Mouse (Window, FLTK.Release, 25, 35, FLTK.Left_Button);

            FLTK.Events.Set_Focus (H.all);
            Ignore := Prb.Key (FLTK.Keydown, FLTK.Enter_Key, Text => (1 => ASCII.CR));
            Check (H.Keys = 1, "it hears a key");
            Check (H.Key = FLTK.Enter_Key, "whole, from FLTK.Events, though FLTK passes a char");
            FLTK.Events.Clear_Focus;
            Free (H);
        end;

        Current := new Heard'(Make (Fre.Sleeping_Free, 0, 0, 10, 10));
        Check (not Current.Is_Active, "a sleeping free is inactive");
        Check (not Current.Take_Focus, "and takes no focus");
        Free (Current);

        Current := new Heard'(Make (Fre.Normal_Free, 0, 0, 10, 10));
        Check (not Current.Take_Focus, "a normal free takes no focus");
        Free (Current);

        Current := new Heard'(Make (Fre.Input_Free, 0, 0, 10, 10));
        Current.Called := True;
        Check (Current.Take_Focus, "an input free does");
        FLTK.Events.Clear_Focus;
        Free (Current);

        Current := new Heard'(Make (Fre.Continuous_Free, 0, 0, 10, 10));
        Wait_For (Has_Stepped'Access);
        Check (Current.Steps > 0, "a continuous free gets steps");
        Check (Current.X = 0 and Current.Y = 0, "with no place");
        Free (Current);
        Run (0.1);
        Check (True, "and stops when freed");

        Current := new Heard'(Make (Fre.All_Free, 0, 0, 10, 10));
        Wait_For (Has_Stepped'Access);
        Check (Current.Steps > 0, "so does a free of all kinds");
        Free (Current);

        --  A free whose Handle_Free raises:  the exception comes out of the
        --  call that drew it.
        declare
            type Raising is new Fre.Free with null record;
            overriding function Handle_Free
                   (This  : in out Raising;
                    Kind  : in     Fre.Free_Event_Kind;
                    Event : in     FLTK.Event_Kind;
                    X, Y  : in     Integer)
                return Boolean;
            function Handle_Free
                   (This  : in out Raising;
                    Kind  : in     Fre.Free_Event_Kind;
                    Event : in     FLTK.Event_Kind;
                    X, Y  : in     Integer)
                return Boolean
            is
                pragma Unreferenced (This, Kind, Event, X, Y);
            begin
                return (raise Constraint_Error with "from Handle_Free");
            end Handle_Free;
            R : constant Raising :=
                (Fre.Forge.Create (Fre.Normal_Free, 0, 0, 10, 10) with null record);
            Raised : Boolean := False;
        begin
            begin
                Ignore := Prb.Capture (R);
                Prb.Release;
            exception
            when Constraint_Error =>
                Raised := True;
                Prb.Release;
            end;
            Check (Raised, "an exception in Handle_Free comes out of the draw");
        end;
    end Test_Frees;




    --  Bitmaps, Pixmaps  --

    function Is_Playing_Of
           (A : in Anm.Animated_GIF_Image)
        return Boolean is (A.Is_Playing);


    procedure Test_Bitmaps is
        Bits : constant FLTK.Color_Component_Array := (16#FF#, 16#FF#);
        Wide : FLTK.Images.Bitmaps.Bitmap := FLTK.Images.Bitmaps.Forge.Create (Bits, 8, 2);
        Thin : FLTK.Images.Bitmaps.Bitmap := FLTK.Images.Bitmaps.Forge.Create (Bits, 2, 2);
        XPM  : FLTK.Images.Pixmaps.XPM.XPM_Image :=
            FLTK.Images.Pixmaps.XPM.Forge.Create ("../images/rb.xpm");
        RB   : Gif.GIF_Image := Gif.Forge.Create ("../images/rb.gif");
    begin
        declare
            B : Bmp.Forms_Bitmap := Bmp.Forge.Create (0, 0, 20, 20);
        begin
            Check (B.Get_Box = FLTK.No_Box, "a bitmap has no box to start with");
            Check (B.Get_Bitmap = null, "nor a bitmap");
            B.Set_Box (FLTK.Flat_Box);
            B.Set_Background_Color (FLTK.RGB_Color (0, 0, 255));
            B.Set_Selection_Color (FLTK.RGB_Color (255, 0, 0));
            Check (Pixel (B, 10, 10) = Red,
                "a bitmap with none shows its box, in the selection color");
            B.Set_Bitmap (Wide);
            Check (B.Get_Bitmap /= null and then B.Get_Bitmap.Get_W = 8, "it has the bitmap set");
            Check (Pixel (B, 1, 1) = Blue, "its bits take its color");
            Check (Pixel (B, 10, 10) = Red, "around them is its box");
            B.Set_Bitmap (Thin);
            Check (Pixel (B, 4, 1) = Red, "another bitmap replaces the first");
            B.Clear_Bitmap;
            Check (B.Get_Bitmap = null and Pixel (B, 1, 1) = Red, "and no bitmap shows none");
            B.Set_Bitmap (Wide);
        end;
        Check (Wide.Get_W = 8, "a bitmap's widget can go first, leaving it whole");

        declare
            P : Pxm.Forms_Pixmap := Pxm.Forge.Create (0, 0, 20, 20);
        begin
            Check (P.Get_Box = FLTK.No_Box, "a pixmap has no box to start with");
            P.Set_Box (FLTK.Flat_Box);
            P.Set_Selection_Color (FLTK.RGB_Color (0, 255, 0));
            Check (not XPM.Is_Empty, "an XPM loads");
            P.Set_Pixmap (XPM);
            Check (Pixel (P, 0, 0) = Red, "a pixmap shows its left");
            Check (Pixel (P, 3, 0) = Blue, "and its right");
            Check (Pixel (P, 10, 10) = Green, "around them is its box");
            P.Set_Pixmap (RB);
            Check (Pixel (P, 0, 0) = Red, "a GIF is a pixmap");
            P.Clear_Pixmap;
            Check (Pixel (P, 0, 0) = Green, "and no pixmap shows none");

            declare
                Still : Anm.Animated_GIF_Image := Anm.Forge.Create
                   ("../images/anim.gif", P,
                    (Dont_Set_As_Image => True, Dont_Start => True, others => False));
            begin
                Check (Still.Frames > 1, "an animation loads");
                P.Set_Pixmap (Still);
                Check (Pixel (P, 0, 0) = Red, "and a pixmap shows it");
                P.Clear_Pixmap;
            end;
        end;

        declare
            type Pixmap_Access is access Pxm.Forms_Pixmap;
            procedure Free is new Ada.Unchecked_Deallocation (Pxm.Forms_Pixmap, Pixmap_Access);
            P    : Pixmap_Access := new Pxm.Forms_Pixmap'(Pxm.Forge.Create (0, 0, 20, 20));
            Anim : Anm.Animated_GIF_Image := Anm.Forge.Create
               ("../images/anim.gif", P.all,
                (Dont_Set_As_Image => True, others => False));
            Before : Natural;
        begin
            P.Set_Pixmap (Anim);
            Run (0.35);
            Ignore := Prb.Capture (P.all);
            Prb.Release;
            Check (Anim.Is_Playing, "a pixmap shows an animation that plays");
            Free (P);
            Before := Anim.Get_Frame;
            for I in 1 .. 100 loop
                exit when Anim.Get_Frame /= Before;
                Ignore_Time := FLTK.Wait (0.01);
            end loop;
            Check (Is_Playing_Of (Anim) and Anim.Get_Frame /= Before,
                "an animation outlives its widget:" & Boolean'Image (Anim.Is_Playing)
                & Integer'Image (Before) & Integer'Image (Anim.Get_Frame));
        end;
        Run (0.1);
    end Test_Bitmaps;




    --  Text  --

    procedure Test_Text is
        T     : Txt.Forms_Text := Txt.Forge.Create (0, 0, 100, 30, "x");
        Left  : Natural;
        Right : Natural;
    begin
        Check (T.Get_Box = FLTK.No_Box, "text has no box to start with");
        Check (T.Get_Alignment = FLTK.Align_Left, "and its label at the left");
        T.Set_Box (FLTK.Flat_Box);
        T.Set_Background_Color (FLTK.White_Color);
        T.Set_Label_Color (FLTK.Black_Color);
        Left := Ink (T, 0, 49, White);
        Right := Ink (T, 50, 99, White);
        Check (Left > 0 and Right = 0, "its label is inside it:"
            & Natural'Image (Left) & Natural'Image (Right));
        Check (T.Get_Alignment = FLTK.Align_Left + FLTK.Align_Inside, "and drawing it says so");
    end Test_Text;


begin

    Test_Timers;
    Test_Frees;
    Test_Bitmaps;
    Test_Text;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Forms;
