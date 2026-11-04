

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    FLTK.Images.RGB,
    FLTK.Widgets;

private with

    Ada.Containers.Vectors;


package FLTK.Images.Pixmaps.GIF.Animated is


    type Animated_GIF_Image is new GIF_Image with private;

    type Animated_GIF_Image_Reference (Data : not null access Animated_GIF_Image'Class) is
        limited null record with Implicit_Dereference => Data;


    --  Frames are numbered from 1 to Frames. Get_Frame returns
    --  No_Frame when no frame is current.
    subtype Frame_Index is Positive;
    subtype Extended_Frame_Index is Natural;

    No_Frame : constant Extended_Frame_Index := Extended_Frame_Index'First;


    type Animation_Flags is record
        Dont_Start         : Boolean := False;
        Dont_Resize_Canvas : Boolean := False;
        Dont_Set_As_Image  : Boolean := False;
        Optimize_Memory    : Boolean := False;
        Log                : Boolean := False;
        Debug              : Boolean := False;
    end record;

    function "+" (Left, Right : in Animation_Flags) return Animation_Flags;
    function "-" (Left, Right : in Animation_Flags) return Animation_Flags;

    No_Animation_Flags      : constant Animation_Flags;
    Flag_Dont_Start         : constant Animation_Flags;
    Flag_Dont_Resize_Canvas : constant Animation_Flags;
    Flag_Dont_Set_As_Image  : constant Animation_Flags;
    Flag_Optimize_Memory    : constant Animation_Flags;
    Flag_Log                : constant Animation_Flags;
    Flag_Debug              : constant Animation_Flags;




    --  Static Settings  --

    --  If True, which is the default, an animation stops after the
    --  number of repeats given in the GIF file. If False, it loops forever.

    function Get_Loop
        return Boolean;

    procedure Set_Loop
           (Value : in Boolean);

    --  Minimum delay in seconds between frames, for all animations.

    function Get_Min_Delay
        return Long_Float;

    procedure Set_Min_Delay
           (Value : in Long_Float);

    function Frame_Count
           (Filename : in String)
        return Natural;

    function Frame_Count
           (Name : in String := "";
            Data : in Color_Component_Array)
        return Natural;




    package Forge is

        --  Unlike most other images in this binding, the constructors
        --  here do not raise an exception if loading fails, so that
        --  the result can be checked with Is_Loaded and Fail_Code.
        --  Unless Dont_Start is given the animation starts at once.

        --  An empty animation, for use with Load and Set_Canvas.
        function Create
            return Animated_GIF_Image;

        function Create
               (Filename : in String;
                Flags    : in Animation_Flags := No_Animation_Flags)
            return Animated_GIF_Image;

        --  The Canvas is the widget that shows the animation. Either
        --  may be finalized first: a canvas that goes is no longer the
        --  animation's (pofltk 62), and an animation that goes is no
        --  longer its canvas's image.
        function Create
               (Filename : in     String;
                Canvas   : in out FLTK.Widgets.Widget'Class;
                Flags    : in     Animation_Flags := No_Animation_Flags)
            return Animated_GIF_Image;

        --  The Data is decoded at once, so it need not outlive the result.
        function Create
               (Name  : in String := "";
                Data  : in Color_Component_Array;
                Flags : in Animation_Flags := No_Animation_Flags)
            return Animated_GIF_Image;

        function Create
               (Name   : in     String := "";
                Data   : in     Color_Component_Array;
                Canvas : in out FLTK.Widgets.Widget'Class;
                Flags  : in     Animation_Flags := No_Animation_Flags)
            return Animated_GIF_Image;

    end Forge;




    --  Loading  --

    procedure Load
           (This     : in out Animated_GIF_Image;
            Filename : in     String);

    function Load
           (This     : in out Animated_GIF_Image;
            Filename : in     String)
        return Boolean;

    procedure Load
           (This : in out Animated_GIF_Image;
            Name : in     String := "";
            Data : in     Color_Component_Array);

    function Load
           (This : in out Animated_GIF_Image;
            Name : in     String := "";
            Data : in     Color_Component_Array)
        return Boolean;

    --  True if the last load succeeded and there is at least one frame.
    function Is_Loaded
           (This : in Animated_GIF_Image)
        return Boolean;

    --  Zero after a successful load, otherwise the raw negative FLTK
    --  image error code (-1 no image, -2 file access, -3 format).
    function Fail_Code
           (This : in Animated_GIF_Image)
        return Integer;

    function Name
           (This : in Animated_GIF_Image)
        return String;




    --  Canvas  --

    --  Null once the canvas has been finalized.
    function Get_Canvas
           (This : in Animated_GIF_Image)
        return access FLTK.Widgets.Widget'Class;

    --  Unless Dont_Set_As_Image is given, the animation is also set as the
    --  image of the Canvas, so it is returned by the Canvas's Get_Image.
    --  The canvas it had before is left with no image, as FLTK leaves it.
    procedure Set_Canvas
           (This   : in out Animated_GIF_Image;
            Canvas : in out FLTK.Widgets.Widget'Class;
            Flags  : in     Animation_Flags := No_Animation_Flags);

    procedure Clear_Canvas
           (This : in out Animated_GIF_Image);

    function Get_Canvas_W
           (This : in Animated_GIF_Image)
        return Natural;

    function Get_Canvas_H
           (This : in Animated_GIF_Image)
        return Natural;




    --  Frames  --

    function Frames
           (This : in Animated_GIF_Image)
        return Natural;

    function Get_Frame
           (This : in Animated_GIF_Image)
        return Extended_Frame_Index;

    --  Only works while the animation is not playing.
    procedure Set_Frame
           (This  : in out Animated_GIF_Image;
            Frame : in     Frame_Index);

    function Frame_Image
           (This  : in out Animated_GIF_Image;
            Frame : in     Frame_Index)
        return FLTK.Images.RGB.RGB_Image_Reference
    with Pre => Frame <= This.Frames;

    function Current_Frame_Image
           (This : in out Animated_GIF_Image)
        return FLTK.Images.RGB.RGB_Image_Reference
    with Pre => This.Get_Frame in 1 .. This.Frames;

    --  Delay in seconds until the next frame is shown.
    function Get_Delay
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Long_Float;

    procedure Set_Delay
           (This  : in out Animated_GIF_Image;
            Frame : in     Frame_Index;
            Value : in     Long_Float);

    function Frame_X
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Integer;

    function Frame_Y
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Integer;

    function Frame_W
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Integer;

    function Frame_H
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Integer;




    --  Playback  --

    --  True if loaded and there is more than one frame.
    function Is_Animated
           (This : in Animated_GIF_Image)
        return Boolean;

    function Is_Playing
           (This : in Animated_GIF_Image)
        return Boolean;

    procedure Start
           (This : in out Animated_GIF_Image);

    function Start
           (This : in out Animated_GIF_Image)
        return Boolean;

    procedure Stop
           (This : in out Animated_GIF_Image);

    function Stop
           (This : in out Animated_GIF_Image)
        return Boolean;

    --  Shows the next frame, if the animation is not playing.
    procedure Next
           (This : in out Animated_GIF_Image);

    function Next
           (This : in out Animated_GIF_Image)
        return Boolean;

    function Get_Speed
           (This : in Animated_GIF_Image)
        return Long_Float;

    procedure Set_Speed
           (This  : in out Animated_GIF_Image;
            Value : in     Long_Float);

    function Get_Frame_Uncache
           (This : in Animated_GIF_Image)
        return Boolean;

    procedure Set_Frame_Uncache
           (This  : in out Animated_GIF_Image;
            Value : in     Boolean);

    function Debug_Level
           (This : in Animated_GIF_Image)
        return Natural;




    --  Dimensions  --

    --  Resizing to 0 x 0 resizes to the size of the canvas.
    procedure Resize
           (This          : in out Animated_GIF_Image;
            Width, Height : in     Natural);

    procedure Resize
           (This   : in out Animated_GIF_Image;
            Factor : in     Long_Float);




    --  Copying  --

    function Copy
           (This          : in Animated_GIF_Image;
            Width, Height : in Natural)
        return Animated_GIF_Image'Class;

    function Copy
           (This : in Animated_GIF_Image)
        return Animated_GIF_Image'Class;




    --  Colors  --

    procedure Color_Average
           (This   : in out Animated_GIF_Image;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out Animated_GIF_Image);




    --  Activity  --

    procedure Uncache
           (This : in out Animated_GIF_Image);




    --  Drawing  --

    procedure Draw
           (This           : in Animated_GIF_Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0);


private


    for Animation_Flags use record
        Dont_Start         at 0 range 0 .. 0;
        Dont_Resize_Canvas at 0 range 1 .. 1;
        Dont_Set_As_Image  at 0 range 2 .. 2;
        Optimize_Memory    at 0 range 3 .. 3;
        Log                at 0 range 6 .. 6;
        Debug              at 0 range 7 .. 7;
    end record;

    for Animation_Flags'Size use Interfaces.C.unsigned_short'Size;

    No_Animation_Flags      : constant Animation_Flags := (others => False);
    Flag_Dont_Start         : constant Animation_Flags := (Dont_Start => True, others => False);
    Flag_Dont_Resize_Canvas : constant Animation_Flags :=
        (Dont_Resize_Canvas => True, others => False);
    Flag_Dont_Set_As_Image  : constant Animation_Flags :=
        (Dont_Set_As_Image => True, others => False);
    Flag_Optimize_Memory    : constant Animation_Flags :=
        (Optimize_Memory => True, others => False);
    Flag_Log                : constant Animation_Flags := (Log => True, others => False);
    Flag_Debug              : constant Animation_Flags := (Debug => True, others => False);


    --  Non-owning wrappers for the frame images, kept for the lifetime of
    --  the animation so that Frame_Image can hand out stable references.

    type Frame_Wrapper_Access is access FLTK.Images.RGB.RGB_Image;

    package Frame_Wrapper_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Frame_Index,
        Element_Type => Frame_Wrapper_Access);

    type Animated_GIF_Image is new GIF_Image with record
        Canvas_Ptr  : access FLTK.Widgets.Widget'Class;
        Frame_Wraps : Frame_Wrapper_Vectors.Vector;
    end record;

    overriding procedure Finalize
           (This : in out Animated_GIF_Image);


    pragma Inline (Get_Loop);
    pragma Inline (Set_Loop);
    pragma Inline (Get_Min_Delay);
    pragma Inline (Set_Min_Delay);
    pragma Inline (Frame_Count);

    pragma Inline (Load);
    pragma Inline (Is_Loaded);
    pragma Inline (Fail_Code);

    pragma Inline (Get_Canvas);
    pragma Inline (Get_Canvas_W);
    pragma Inline (Get_Canvas_H);

    pragma Inline (Frames);
    pragma Inline (Get_Frame);
    pragma Inline (Set_Frame);
    pragma Inline (Get_Delay);
    pragma Inline (Set_Delay);
    pragma Inline (Frame_X);
    pragma Inline (Frame_Y);
    pragma Inline (Frame_W);
    pragma Inline (Frame_H);

    pragma Inline (Is_Animated);
    pragma Inline (Is_Playing);
    pragma Inline (Start);
    pragma Inline (Stop);
    pragma Inline (Next);
    pragma Inline (Get_Speed);
    pragma Inline (Set_Speed);
    pragma Inline (Get_Frame_Uncache);
    pragma Inline (Set_Frame_Uncache);
    pragma Inline (Debug_Level);

    pragma Inline (Resize);

    pragma Inline (Copy);

    pragma Inline (Color_Average);
    pragma Inline (Desaturate);

    pragma Inline (Uncache);

    pragma Inline (Draw);


end FLTK.Images.Pixmaps.GIF.Animated;


