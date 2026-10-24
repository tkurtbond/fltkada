

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  An Ada port of FLTK's examples/animgifimage.cxx: opens animated GIFs,
--  letting each one play itself in its own window, and exercises the
--  optional features of Animated_GIF_Image.
--
--  Usage:
--     animgifimage -t [directory] [-{flags}]  open all GIFs in directory (default: testsuite)
--     animgifimage filename [-{flags}]        open single file
--     animgifimage                            open a file chooser
--  where {flags} can be: d=debug mode, u=uncached, D=desaturated, A=color averaged,
--  T=tiled, m=minimal update, f=forced redraw of a second canvas,
--  r[scale factor]=resize by 'scale factor'.
--  Use keys '+' / '-' / '0' to change the speed of the image below the mouse.
--
--  Deliberate differences:
--
--  The C++ version stores each animation in its window's user_data. Here
--  openFile returns the animation along with the window instead.
--
--  To find the animation inside a tiled image (the 'T' flag), the C++
--  version uses Fl_Tiled_Image::image. Tiled_Image.Tile in the binding
--  returns a plain Image view of the tile rather than the original Ada
--  object, so this program keeps a list of which animation went into
--  which tiled image instead.
--
--  The forced redraw timeout of the C++ version walks all of FLTK's
--  windows with Fl::first_window and Fl::next_window. In the binding those
--  only work for windows created from Ada, and the file chooser's window
--  is not, so here only the windows this program created are redrawn. As
--  a result the preview in the file chooser does not animate.
--
--  The scale factor after the 'r' flag is parsed by Leading_Float below,
--  which takes the same leading part of the string that atof would.


with

    Ada.Command_Line,
    Ada.Containers.Vectors,
    Ada.Long_Float_Text_IO,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    FLTK.Asks,
    FLTK.Events,
    FLTK.Filenames,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Images.Shared,
    FLTK.Images.Tiled,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    GNAT.OS_Lib,
    System;

use type

    FLTK.Event_Kind,
    FLTK.Images.Pixmaps.GIF.Animated.Animation_Flags,
    System.Address,
    FLTK.Keypress,
    Ada.Strings.Unbounded.Unbounded_String;


function Animgifimage
    return Integer
is

    package ACL  renames Ada.Command_Line;
    package SF   renames Ada.Strings.Fixed;
    package SU   renames Ada.Strings.Unbounded;
    package TIO  renames Ada.Text_IO;
    package Anim renames FLTK.Images.Pixmaps.GIF.Animated;
    package Til  renames FLTK.Images.Tiled;
    package Box  renames FLTK.Widgets.Boxes;
    package Grp  renames FLTK.Widgets.Groups;
    package WD   renames FLTK.Widgets.Groups.Windows.Double;


    type Animation_Access is access Anim.Animated_GIF_Image;
    type Window_Access    is access WD.Double_Window;
    type Box_Access       is access Box.Box;
    type Group_Access     is access Grp.Group;
    type Tiled_Access     is access Til.Tiled_Image;

    procedure Free is new Ada.Unchecked_Deallocation (Anim.Animated_GIF_Image, Animation_Access);
    procedure Free is new Ada.Unchecked_Deallocation (WD.Double_Window, Window_Access);


    --  What the C++ version keeps in the window's user_data.
    type Opened is record
        Win       : Window_Access;
        Animation : Animation_Access;
    end record;

    No_Window : constant Opened := (null, null);


    --  Which animation went into which tiled image.
    type Tile_Entry is record
        Tile      : Tiled_Access;
        Animation : Animation_Access;
    end record;

    package Tile_Vectors is new Ada.Containers.Vectors (Positive, Tile_Entry);
    package Window_Vectors is new Ada.Containers.Vectors (Positive, Window_Access);

    Tile_List   : Tile_Vectors.Vector;
    Window_List : Window_Vectors.Vector;


    Good_Count, Bad_Count, Frame_Count : Natural := 0;

    Background_Color : constant FLTK.Color := FLTK.Background_Color;
        --  use e.g. FLTK.Red_Color to see transparent parts better
    Redraw_Delay : constant Long_Float := 1.0 / 20.0;  --  interval [sec] for forced redraw

    Testsuite : constant String := "testsuite";




    function Img
           (Value : in Integer)
        return String is
    begin
        return SF.Trim (Integer'Image (Value), Ada.Strings.Left);
    end Img;


    --  Like C's "%.2f".
    function Fixed_2
           (Value : in Long_Float)
        return String
    is
        Result : String (1 .. 40);
    begin
        Ada.Long_Float_Text_IO.Put (Result, Value, Aft => 2, Exp => 0);
        return SF.Trim (Result, Ada.Strings.Left);
    end Fixed_2;


    --  Like C's atof: the value of the longest leading part of Item that
    --  looks like a decimal number, or 0.0 if there is none.
    function Leading_Float
           (Item : in String)
        return Long_Float
    is
        Last       : Natural := Item'First - 1;
        Seen_Digit : Boolean := False;
        Seen_Point : Boolean := False;
    begin
        for Index in Item'Range loop
            if Item (Index) in '0' .. '9' then
                Seen_Digit := True;
                Last := Index;
            elsif Item (Index) = '.' and not Seen_Point then
                Seen_Point := True;
            elsif Item (Index) in '+' | '-' and Index = Item'First then
                null;
            else
                exit;
            end if;
        end loop;
        if not Seen_Digit then
            return 0.0;
        end if;
        declare
            Text : constant String := Item (Item'First .. Last);
            Head : constant String :=
                (if Text (Text'First) in '+' | '-' then Text (Text'First .. Text'First) else "");
            Body_Text : constant String := Text (Text'First + Head'Length .. Text'Last);
        begin
            --  Long_Float'Value needs digits on both sides of the point.
            return Long_Float'Value
               (Head &
                (if Body_Text (Body_Text'First) = '.' then "0" else "") &
                Body_Text &
                (if SF.Index (Body_Text, ".") = 0 then ".0"
                 elsif Body_Text (Body_Text'Last) = '.' then "0"
                 else ""));
        end;
    end Leading_Float;


    function Contains
           (Flags : in SU.Unbounded_String;
            Char  : in Character)
        return Boolean is
    begin
        return SU.Index (Flags, (1 => Char)) /= 0;
    end Contains;




    procedure Quit_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        TIO.Flush;
        GNAT.OS_Lib.OS_Exit (0);
    end Quit_Callback;


    procedure Set_Title
           (Win       : in out FLTK.Widgets.Groups.Windows.Window'Class;
            Animation : in     Anim.Animated_GIF_Image'Class)
    is
        Title : constant String :=
            FLTK.Filenames.Base_Name (Animation.Name) &
            " (" & Img (Animation.Frames) & " frames)  " &
            Fixed_2 (Animation.Get_Speed) & "x" &
            (if Animation.Get_Frame_Uncache then " U" else "");
    begin
        Win.Set_Label (Title);
        Win.Set_Tooltip (Title);
    end Set_Title;


    procedure Forced_Redraw is
        Any_Shown : Boolean := False;
    begin
        for Win of Window_List loop
            if Win.Is_Shown then
                Any_Shown := True;
                if not Win.Is_Menu_Window then
                    Win.Redraw;
                end if;
            end if;
        end loop;
        if Any_Shown then
            FLTK.Static.Repeat_Timeout (Redraw_Delay, Forced_Redraw'Unrestricted_Access);
        end if;
    end Forced_Redraw;




    function Open_File
           (Name      : in     String;
            Flags     : in     SU.Unbounded_String;
            Close     : in     Boolean := False)
        return Opened
    is
        --  determine test options from Flags
        Uncache      : constant Boolean := Contains (Flags, 'u');
        Debug        : constant Natural := SU.Count (Flags, "d");
        Optimize_Mem : constant Boolean := Contains (Flags, 'm');
        Desaturate   : constant Boolean := Contains (Flags, 'D');
        Average      : constant Boolean := Contains (Flags, 'A');
        Test_Tiles   : constant Boolean := Contains (Flags, 'T');
        Test_Forced  : constant Boolean := Contains (Flags, 'f');
        R            : constant Natural := SU.Index (Flags, "r");
        Resizable    : constant Boolean := R /= 0 and not Test_Tiles;
        Scale        : Long_Float := 1.0;

        Win       : Window_Access;
        Canvas    : Box_Access;
        Canvas2   : Box_Access;
        GIF_Flags : Anim.Animation_Flags := Anim.No_Animation_Flags;
        Animation : Animation_Access;
        Good      : Boolean;
        W, H      : Integer;
    begin
        if R /= 0 and Resizable then
            Scale := Leading_Float (SU.Slice (Flags, R + 1, SU.Length (Flags)));
        end if;
        if Scale <= 0.1 or Scale > 5.0 then
            Scale := (if Resizable then 0.7 else 1.0);
        end if;

        --  setup window
        FLTK.Static.Remove_Timeout (Forced_Redraw'Unrestricted_Access);
        Win := new WD.Double_Window'(WD.Forge.Create (300, 300));
        Win.Set_Background_Color (Background_Color);
        if Close then
            Win.Set_Callback (Quit_Callback'Unrestricted_Access);
        end if;
        TIO.Put ("Loading '" & Name & "'" &
            (if Uncache then " (uncached)" else "") &
            (if Optimize_Mem then " (optimized)" else "") & " ... ");

        --  create a canvas for the animation
        if not Test_Tiles then
            --  canvas will be resized by animation
            Canvas := new Box.Box'(Box.Forge.Create (Win.all, 0, 0, 0, 0));
        end if;
        if Debug > 0 then
            GIF_Flags := GIF_Flags + Anim.Flag_Log;
        end if;
        if Debug > 1 then
            GIF_Flags := GIF_Flags + Anim.Flag_Debug;
        end if;
        if Optimize_Mem then
            GIF_Flags := GIF_Flags + Anim.Flag_Optimize_Memory;
        end if;

        --  create animation, specifying this canvas as display widget
        if Canvas = null then
            Animation := new Anim.Animated_GIF_Image'(Anim.Forge.Create (Name, GIF_Flags));
        else
            Animation := new Anim.Animated_GIF_Image'
                (Anim.Forge.Create (Name, Canvas.all, GIF_Flags));
        end if;
        Good := Animation.Fail_Code = 0 and Animation.Is_Loaded;
        TIO.Put_Line
           (Animation.Name & ": " & Img (Animation.Get_W) & " x " & Img (Animation.Get_H) &
            " (" & Img (Animation.Frames) & " frames) " & (if Good then "OK" else "ERROR"));
        --  for the statistics (when run on testsuite):
        if Good then
            Good_Count := Good_Count + 1;
        else
            Bad_Count := Bad_Count + 1;
        end if;
        Frame_Count := Frame_Count + Animation.Frames;

        --  exercise the optional tests on the animation
        Animation.Set_Frame_Uncache (Uncache);
        if Scale /= 1.0 then
            Animation.Resize (Scale);
            TIO.Put_Line ("TEST: resized " & Animation.Name & " by " & Fixed_2 (Scale) &
                " to " & Img (Animation.Get_W) & " x " & Img (Animation.Get_H));
        end if;
        if Average then
            TIO.Put_Line ("TEST: color_average " & Animation.Name);
            Animation.Color_Average (FLTK.Green_Color, 0.5);  --  currently hardcoded
        end if;
        if Desaturate then
            TIO.Put_Line ("TEST: desaturate " & Animation.Name);
            Animation.Desaturate;
        end if;
        W := Animation.Get_W;
        H := Animation.Get_H;

        if Animation.Frames = 0 then
            Free (Animation);
            Free (Win);
            return No_Window;
        end if;

        if Test_Tiles then
            --  demonstrate a way how to use the animation with Tiled_Image
            TIO.Put_Line ("TEST: use " & Animation.Name & " as tiles");
            W := W * 2;
            H := H * 2;
            declare
                Tiled_Image : constant Tiled_Access :=
                    new Til.Tiled_Image'(Til.Forge.Create (Animation.all));
                Group : constant Group_Access :=
                    new Grp.Group'(Grp.Forge.Create (Win.all, 0, 0, Win.Get_W, Win.Get_H));
            begin
                Tile_List.Append ((Tiled_Image, Animation));
                Group.Set_Image (Tiled_Image.all);
                Group.Set_Alignment (FLTK.Align_Inside);
                Animation.Set_Canvas
                   (Group.all, Anim.Flag_Dont_Resize_Canvas + Anim.Flag_Dont_Set_As_Image);
                Win.Set_Resizable (Group.all);
            end;
        else
            --  demonstrate a way how to use same animation in another canvas simultaneously:
            --  as the current implementation allows only automatic redraw of one canvas..
            if Test_Forced and W < 400 then
                TIO.Put_Line ("TEST: open " & Animation.Name &
                    " in another animation with application redraw");
                --  another canvas for animation
                Canvas2 := new Box.Box'(Box.Forge.Create
                    (Win.all, W, 0, Animation.Get_W, Animation.Get_H));
                Canvas2.Set_Image (Animation.all);  --  is set to same animation!
                W := W * 2;
                FLTK.Static.Add_Timeout (Redraw_Delay, Forced_Redraw'Unrestricted_Access);
            end if;
        end if;

        --  make window resizable (must be done before show())
        if Resizable and Canvas /= null and not Test_Tiles then
            Win.Set_Resizable (Win.all);
        end if;
        Win.Resize (W, H);  --  change to actual size of canvas

        --  start the animation
        Win.Show;
        Win.Wait_For_Expose;
        Window_List.Append (Win);
        Set_Title (Win.all, Animation.all);
        if Resizable and not Test_Tiles then
            --  need to reposition the widgets (have been moved by setting resizable())
            if Canvas /= null and Canvas2 /= null then
                Canvas.Resize (0, 0, W / 2, Canvas.Get_H);
                Canvas2.Resize (W / 2, 0, W / 2, Canvas2.Get_H);
            elsif Canvas /= null then
                Canvas.Resize (0, 0, Animation.Get_Canvas_W, Animation.Get_Canvas_H);
            end if;
        end if;
        Win.Reset_Sizes;  --  IMPORTANT: otherwise weird things happen at Ctrl+/- scaling

        if Debug >= 3 then
            --  open each frame in a separate window
            for I in 1 .. Animation.Frames loop
                declare
                    Label : constant String := "Frame #" & Img (I);
                    Frame_Win : constant Window_Access := new WD.Double_Window'
                        (WD.Forge.Create (Animation.Get_W, Animation.Get_H));
                    Frame_W : constant Integer := Animation.Frame_Image (I).Get_W;
                    Frame_H : constant Integer := Animation.Frame_Image (I).Get_H;
                    Whole   : constant Boolean :=
                        Frame_W = Animation.Get_W and Frame_H = Animation.Get_H;
                    --  in Optimize_Memory mode frames must be offset to canvas
                    X : constant Integer := (if Whole then 0 else Animation.Frame_X (I));
                    Y : constant Integer := (if Whole then 0 else Animation.Frame_Y (I));
                    B : constant Box_Access := new Box.Box'(Box.Forge.Create
                        (Frame_Win.all, X, Y, Frame_W, Frame_H));
                begin
                    Frame_Win.Set_Tooltip (Label);
                    Frame_Win.Set_Label (Label);
                    Frame_Win.Set_Background_Color (Background_Color);
                    --  get the frame image
                    B.Set_Image (Animation.Frame_Image (I).Data.all);
                    Frame_Win.Show;
                    Window_List.Append (Frame_Win);
                end;
            end loop;
        end if;

        return (Win, Animation);
    end Open_File;


    --  The C++ version returns whether any file was opened, which
    --  nothing uses.
    procedure Open_Directory
           (Dir   : in     String;
            Flags : in out SU.Unbounded_String)
    is
        List  : constant FLTK.Filenames.File_List :=
            FLTK.Filenames.Get_Listing (Dir, FLTK.Filenames.Alpha_Sort'Access);
        Count : Natural := 0;
    begin
        for I in 1 .. List.Length loop
            declare
                Name : constant String := List.Item (I);
                P    : Natural := SF.Index (Name, ".gif");
            begin
                if P = 0 then
                    P := SF.Index (Name, ".GIF");
                end if;
                if Name /= "." and then Name /= ".." and then P /= 0 and then P + 3 = Name'Last then
                    --  hack: when name contains 'debug' open single frames
                    if SF.Index (Name, "debug") /= 0 then
                        SU.Append (Flags, "d");
                    end if;
                    if Open_File (Dir & "/" & Name, Flags, Count = 0) /= No_Window then
                        Count := Count + 1;
                    end if;
                end if;
            end;
        end loop;
    exception
        when Constraint_Error =>
            --  the directory could not be read
            null;
    end Open_Directory;




    procedure Change_Speed
           (Delta_Speed : in Long_Float)
    is
        Below     : constant access FLTK.Widgets.Widget'Class := FLTK.Events.Get_Below_Mouse;
        Animation : access Anim.Animated_GIF_Image'Class;
        Speed     : Long_Float;
    begin
        if Below = null or else Below.Get_Image = null then
            return;
        end if;
        if Below.Get_Image.all in Anim.Animated_GIF_Image'Class then
            Animation := Anim.Animated_GIF_Image'Class (Below.Get_Image.all)'Unchecked_Access;
        elsif Below.Get_Image.all in Til.Tiled_Image'Class then
            for Item of Tile_List loop
                if Item.Tile.all'Address = Below.Get_Image.all'Address then
                    Animation := Item.Animation;
                end if;
            end loop;
        end if;
        if Animation /= null and then Animation.Is_Playing then
            Speed := Animation.Get_Speed;
            if Delta_Speed = 0.0 then
                Speed := 1.0;
            else
                Speed := Speed + Delta_Speed;
            end if;
            Speed := Long_Float'Max (0.1, Long_Float'Min (10.0, Speed));
            Animation.Set_Speed (Speed);
            Set_Title (Below.Nearest_Window.all, Animation.all);
        end if;
    end Change_Speed;


    function Events
           (Event : in FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        if Event = FLTK.Shortcut then
            if FLTK.Events.Last_Key = FLTK.Press ('+') then
                Change_Speed (0.1);
            elsif FLTK.Events.Last_Key = FLTK.Press ('-') then
                Change_Speed (-0.1);
            elsif FLTK.Events.Last_Key = FLTK.Press ('0') then
                Change_Speed (0.0);
            else
                return FLTK.Not_Handled;
            end if;
            return FLTK.Handled;
        end if;
        return FLTK.Not_Handled;
    end Events;


    Open_Flags : SU.Unbounded_String;


begin

    FLTK.Images.Shared.Register_Images;
    FLTK.Events.Add_Handler (Events'Unrestricted_Access);

    if ACL.Argument_Count > 0 then
        --  started with arguments
        if SF.Index (ACL.Argument (1), "-h") /= 0 then
            TIO.Put_Line ("Usage:");
            TIO.Put_Line ("   -t [directory] [-{flags}] open all files in directory " &
                "(default name: " & Testsuite & ") [with options]");
            TIO.Put_Line ("   filename [-{flags}] open single file [with options] ");
            TIO.Put_Line ("   No arguments open a fileselector");
            TIO.Put_Line ("   {flags} can be: d=debug mode, u=uncached, D=desaturated, " &
                "A=color averaged, T=tiled");
            TIO.Put_Line ("                   m=minimal update, " &
                "r[scale factor]=resize by 'scale factor'");
            TIO.Put_Line ("   Use keys '+'/'-/0' to change speed of the active image " &
                "(belowmouse).");
            return 1;
        end if;
        for I in 1 .. ACL.Argument_Count loop
            declare
                Arg : constant String := ACL.Argument (I);
            begin
                if Arg'Length > 0 and then Arg (Arg'First) = '-' then
                    SU.Append (Open_Flags, Arg (Arg'First + 1 .. Arg'Last));
                end if;
            end;
        end loop;
        if Contains (Open_Flags, 't') then
            --  open all GIF-files in a given directory
            declare
                Dir : SU.Unbounded_String := SU.To_Unbounded_String (Testsuite);
            begin
                for I in 2 .. ACL.Argument_Count loop
                    declare
                        Arg : constant String := ACL.Argument (I);
                    begin
                        if Arg'Length = 0 or else Arg (Arg'First) /= '-' then
                            Dir := SU.To_Unbounded_String (Arg);
                        end if;
                    end;
                end loop;
                Open_Directory (SU.To_String (Dir), Open_Flags);
            end;
            TIO.Put_Line ("Summary: good=" & Img (Good_Count) & ", bad=" & Img (Bad_Count) &
                ", frames=" & Img (Frame_Count));
        else
            --  open given file(s)
            for I in 1 .. ACL.Argument_Count loop
                declare
                    Arg : constant String := ACL.Argument (I);
                begin
                    if Arg'Length = 0 or else Arg (Arg'First) /= '-' then
                        if Open_File (Arg, Open_Flags, Contains (Open_Flags, 'd')) = No_Window
                        then
                            null;
                        end if;
                    end if;
                end;
            end loop;
        end if;
    else
        --  started without arguments: choose file
        --  create animated shared .GIF images (e.g. file chooser)
        FLTK.Images.Pixmaps.GIF.Set_Animate (True);
        loop
            FLTK.Static.Add_Timeout (0.1, Forced_Redraw'Unrestricted_Access);
            declare
                Filename : constant String :=
                    FLTK.Asks.File_Chooser ("Select a GIF image file", "*.{gif,GIF}", "");
                Result   : Opened;
            begin
                FLTK.Static.Remove_Timeout (Forced_Redraw'Unrestricted_Access);
                exit when Filename = "";
                Result := Open_File (Filename, Open_Flags);
                if FLTK.Run = 0 then
                    null;
                end if;
                --  delete last window (which is now just hidden) to test destructors
                --  NOTE: it is essential that *before* doing this also the
                --        animated image is destroyed, otherwise it will crash
                --        because its canvas will be gone.
                if Result.Win /= null then
                    Window_List.Delete (Window_List.Find_Index (Result.Win));
                    Free (Result.Animation);
                    Free (Result.Win);
                end if;
            end;
        end loop;
    end if;

    return FLTK.Run;

end Animgifimage;


