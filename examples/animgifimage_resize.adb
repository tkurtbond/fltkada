

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/animgifimage-resize.cxx: a test program for
--  Animated_GIF_Image's Copy.  The animation is copied to fit the canvas
--  whenever the window is resized.
--
--  Keys: 'g' toggles the transparency grid, 'b' toggles bilinear scaling.
--
--  Timeout handlers take no data, so the canvas is a global.  The original
--  asks the canvas for its image to find the animation being shown; here
--  the shown animation is kept in a global too.


with

    Ada.Command_Line,
    Ada.Strings.Fixed,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    FLTK.Draw,
    FLTK.Errors,
    FLTK.Events,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Event_Kind,
    FLTK.Images.Scaling_Kind,
    FLTK.Keypress;


function Animgifimage_Resize
    return Integer
is


    package ACL  renames Ada.Command_Line;
    package TIO  renames Ada.Text_IO;
    package Img  renames FLTK.Images;
    package Anim renames FLTK.Images.Pixmaps.GIF.Animated;
    package Box  renames FLTK.Widgets.Boxes;
    package WD   renames FLTK.Widgets.Groups.Windows.Double;

    use type Anim.Animation_Flags;


    type Anim_Access is access Anim.Animated_GIF_Image'Class;

    procedure Free is new Ada.Unchecked_Deallocation (Anim.Animated_GIF_Image'Class, Anim_Access);


    Orig      : Anim_Access;    --  the animation as loaded
    Shown     : Anim_Access;    --  the animation shown on the canvas, Orig or a copy
    Draw_Grid : Boolean := True;


    function Image
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (Value), Ada.Strings.Left);
    end Image;


    function Image
           (Value : in Boolean)
        return String is
    begin
        return (if Value then "1" else "0");
    end Image;


    function Events
           (Event : in FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        if Event = FLTK.Shortcut and FLTK.Static.Get_First_Window /= null then
            if FLTK.Events.Last_Key = FLTK.Press ('g') then
                Draw_Grid := not Draw_Grid;
                TIO.Put_Line ("grid: " & (if Draw_Grid then "ON" else "OFF"));
            elsif FLTK.Events.Last_Key = FLTK.Press ('b') then
                if Img.Get_Draw_Algorithm /= Img.Bilinear then
                    Img.Set_Draw_Algorithm (Img.Bilinear);
                else
                    Img.Set_Draw_Algorithm (Img.Nearest);
                end if;
                TIO.Put_Line
                   ("bilenear: " &
                    (if Img.Get_Draw_Algorithm /= Img.Bilinear then "OFF" else "ON"));
            else
                return FLTK.Not_Handled;
            end if;
            FLTK.Static.Get_First_Window.Redraw;
        end if;
        return FLTK.Handled;
    end Events;


    type Canvas is new Box.Box with null record;

    overriding procedure Draw
           (This : in out Canvas);

    overriding procedure Resize
           (This       : in out Canvas;
            X, Y, W, H : in     Integer);


    type Canvas_Access is access Canvas;

    The_Canvas : Canvas_Access;


    overriding procedure Draw
           (This : in out Canvas)
    is
        --  draw a transparency grid as background
        C1 : constant FLTK.Color := FLTK.RGB_Color (16#cc#, 16#cc#, 16#cc#);
        C2 : constant FLTK.Color := FLTK.RGB_Color (16#88#, 16#88#, 16#88#);
        SZ : constant Integer := 8;
        Y  : Integer := 0;
        X  : Integer;
    begin
        if Draw_Grid then
            while Y < This.Get_H loop
                X := 0;
                while X < This.Get_W loop
                    FLTK.Draw.Set_Color
                       (if X mod (SZ * 2) /= 0
                        then (if Y mod (SZ * 2) /= 0 then C1 else C2)
                        else (if Y mod (SZ * 2) /= 0 then C2 else C1));
                    FLTK.Draw.Rect_Fill (X, Y, 32, 32);
                    X := X + SZ;
                end loop;
                Y := Y + SZ;
            end loop;
        end if;
        --  draw the current image frame over the grid
        Box.Box (This).Draw;
    end Draw;


    procedure Do_Resize
           (This : in out Canvas;
            W, H : in     Integer) is
    begin
        if Shown /= null and then (Shown.Get_W /= W or Shown.Get_H /= H) then
            Shown.Stop;
            Shown.Clear_Canvas;
            --  delete already copied images
            if Shown /= Orig then
                Free (Shown);
            end if;
            Shown := new Anim.Animated_GIF_Image'Class'(Orig.Copy (W, H));
            if not Shown.Is_Loaded then   --  check success of copy
                FLTK.Errors.Current_Warning
                   ("Fl_Anim_GIF_Image::copy() " & Image (W) & " x " & Image (H) & " failed");
            else
                TIO.Put_Line
                   ("resized to " & Image (Shown.Get_W) & " x " & Image (Shown.Get_H));
            end if;
            Shown.Set_Canvas (This, Anim.Flag_Dont_Resize_Canvas);
        end if;
        This.Nearest_Window.Set_Cursor (FLTK.Default_Mouse);
    end Do_Resize;


    procedure Do_Resize_CB is
    begin
        Do_Resize (The_Canvas.all, The_Canvas.Get_W, The_Canvas.Get_H);
    end Do_Resize_CB;


    overriding procedure Resize
           (This       : in out Canvas;
            X, Y, W, H : in     Integer) is
    begin
        Box.Box (This).Resize (X, Y, W, H);
        --  decouple resize event from actual resize operation
        --  to avoid lockups..
        FLTK.Static.Remove_Timeout (Do_Resize_CB'Unrestricted_Access);
        FLTK.Static.Add_Timeout (0.1, Do_Resize_CB'Unrestricted_Access);
        This.Nearest_Window.Set_Cursor (FLTK.Wait_Mouse);
    end Resize;


    --  setup play parameters from args
    Bilinear : Boolean := False;
    Optimize : Boolean := False;
    Uncache  : Boolean := False;
    Debug    : Boolean := False;
    File_Arg : Natural := 0;


begin


    for I in 1 .. ACL.Argument_Count loop
        declare
            Arg : constant String := ACL.Argument (I);
        begin
            if Arg = "-b" then      --  turn bilinear scaling on
                Bilinear := True;
            elsif Arg = "-o" then   --  turn optimize on
                Optimize := True;
            elsif Arg = "-g" then   --  disable grid
                Draw_Grid := False;
            elsif Arg = "-u" then   --  uncache
                Uncache := True;
            elsif Arg = "-d" then   --  debug
                Debug := True;
            elsif (Arg'Length = 0 or else Arg (Arg'First) /= '-') and File_Arg = 0 then
                File_Arg := I;
            elsif Arg'Length > 0 and then Arg (Arg'First) = '-' then
                TIO.Put_Line ("Invalid argument: '" & Arg & "'");
                return 1;
            end if;
        end;
    end loop;
    if File_Arg = 0 then
        TIO.Put_Line (TIO.Standard_Error, "Test program for animated copy.");
        TIO.Put_Line
           (TIO.Standard_Error,
            "Usage: " & ACL.Command_Name & " fileName [-b]ilinear [-o]ptimize [-g]rid [-u]ncache");
        return 0;
    end if;
    Anim.Set_Min_Delay (0.1);   --  set a minumum delay for playback

    declare
        File_Name : constant String := ACL.Argument (File_Arg);

        Win : WD.Double_Window := WD.Forge.Create (640, 480);

        Win_W : constant Integer := Win.Get_W;
        Win_H : constant Integer := Win.Get_H;

        Flags : Anim.Animation_Flags := Anim.Flag_Dont_Resize_Canvas;
    begin
        --  prepare a canvas for the animation
        --  (we want to show it in the center of the window)
        The_Canvas := new Canvas'(Box.Forge.Create (Win, 0, 0, Win_W, Win_H) with null record);
        Win.Set_Resizable (Win);
        Win.Set_Size_Range (1, 1);

        Win.End_Current;
        Win.Show;

        --  create/load the animated gif and start it immediately.
        --  We use the Dont_Resize_Canvas flag here to tell the
        --  animation not to change the canvas size (which is the default).
        if Optimize then
            Flags := Flags + Anim.Flag_Optimize_Memory;
            TIO.Put_Line ("Using memory optimization (if image supports)");
        end if;
        if Debug then
            Flags := Flags + Anim.Flag_Debug;
        end if;
        Orig := new Anim.Animated_GIF_Image'(Anim.Forge.Create (File_Name, The_Canvas.all, Flags));
        Shown := Orig;

        --  check if loading succeeded
        TIO.Put_Line
           (Orig.Name & ": valid: " & Image (Orig.Is_Loaded) &
            " frames: " & Image (Orig.Frames) &
            " uncache: " & Image (Orig.Get_Frame_Uncache));
        if Orig.Is_Loaded then
            Win.Set_Label (File_Name);

            --  print information about image optimization
            declare
                N : Natural := 0;
            begin
                for I in 1 .. Orig.Frames loop
                    if Orig.Frame_X (I) /= 0 or Orig.Frame_Y (I) /= 0 then
                        N := N + 1;
                    end if;
                end loop;
                TIO.Put_Line ("image has " & Image (N) & " optimized frames");
            end;

            Img.Set_Draw_Algorithm (Img.Nearest);
            if Bilinear then
                Img.Set_Draw_Algorithm (Img.Bilinear);
                TIO.Put_Line ("Using bilinear scaling - can be slow!");
                --  NOTE: this can be *really* slow with large sizes, if FLTK
                --        has to resize on its own without hardware scaling enabled.
            end if;
            Orig.Set_Frame_Uncache (Uncache);
            if Uncache then
                TIO.Put_Line ("Caching disabled - watch cpu load!");
            end if;

            --  set initial size to fit into window
            declare
                Ratio : constant Long_Float :=
                    (if Orig.Is_Loaded
                     then Long_Float (Orig.Get_W) / Long_Float (Orig.Get_H)
                     else 1.0);
                W : constant Integer := Win.Get_W - 40;
                H : constant Integer := Integer (Long_Float'Truncation (Long_Float (W) / Ratio));
            begin
                TIO.Put_Line ("original size: " & Image (Orig.Get_W) & " x " & Image (Orig.Get_H));
                Win.Resize (W, H);
                FLTK.Events.Add_Handler (Events'Unrestricted_Access);

                return FLTK.Run;
            end;
        end if;
        return 0;
    end;


end Animgifimage_Resize;
