

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    System;

private with

    Interfaces.C;


package FLTK.Widgets.Groups.Windows.OpenGL is


    type GL_Window is new Window with private;

    type GL_Window_Reference (Data : not null access GL_Window'Class) is
        limited null record with Implicit_Dereference => Data;

    --  RGB mode is achieved by Index being set to False
    --  Single buffer mode is achieved by Double being set to False
    type Mode_Mask is record
        Index       : Boolean := False;
        Double      : Boolean := False;
        Accum       : Boolean := False;
        Alpha       : Boolean := False;
        Depth       : Boolean := False;
        Stencil     : Boolean := False;
        RGB8        : Boolean := False;
        Multisample : Boolean := False;
        Stereo      : Boolean := False;
        Fake_Single : Boolean := False;
        OpenGL3     : Boolean := False;
    end record;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return GL_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return GL_Window;

    end Forge;




    ---------------
    --  Display  --
    ---------------

    procedure Show
           (This : in out GL_Window);

    procedure Show_With_Args
           (This : in out GL_Window);

    procedure Hide
           (This : in out GL_Window);

    procedure Hide_Overlay
           (This : in out GL_Window);

    procedure Flush
           (This : in out GL_Window);




    ------------------
    --  Dimensions  --
    ------------------

    function Pixel_H
           (This : in GL_Window)
        return Integer;

    function Pixel_W
           (This : in GL_Window)
        return Integer;

    function Pixels_Per_Unit
           (This : in GL_Window)
        return Float;

    procedure Resize
           (This       : in out GL_Window;
            X, Y, W, H : in     Integer);




    --------------------
    --  OpenGL Modes  --
    --------------------

    function Get_Mode
           (This : in GL_Window)
        return Mode_Mask;

    procedure Set_Mode
           (This : in out GL_Window;
            Mask : in     Mode_Mask);

    function Can_Do
           (Mask : in Mode_Mask)
        return Boolean;

    function Can_Do
           (This : in GL_Window)
        return Boolean;

    function Can_Do_Overlay
           (This : in GL_Window)
        return Boolean;




    -----------------------
    --  OpenGL Contexts  --
    -----------------------

    function Get_Context
           (This : in GL_Window)
        return System.Address;

    procedure Set_Context
           (This    : in out GL_Window;
            Struct  : in     System.Address;
            Destroy : in     Boolean := False);

    function Get_Context_Valid
           (This : in GL_Window)
        return Boolean;

    procedure Set_Context_Valid
           (This  : in out GL_Window;
            Value : in     Boolean);

    function Get_Valid
           (This : in GL_Window)
        return Boolean;

    procedure Set_Valid
           (This  : in out GL_Window;
            Value : in     Boolean);

    procedure Invalidate
           (This : in out GL_Window);

    procedure Make_Current
           (This : in out GL_Window);

    procedure Make_Overlay_Current
           (This : in out GL_Window);




    ----------------------------------
    --  Drawing and Event Handling  --
    ----------------------------------

    procedure Ortho
           (This : in out GL_Window);

    procedure Redraw_Overlay
           (This : in out GL_Window);

    procedure Swap_Buffers
           (This : in out GL_Window);

    procedure Draw
           (This : in out GL_Window);

    function Handle
           (This  : in out GL_Window;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type GL_Window is new Window with null record;

    overriding procedure Initialize
           (This : in out GL_Window);

    overriding procedure Finalize
           (This : in out GL_Window);

    procedure Extra_Init
           (This       : in out GL_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out GL_Window)
    with Inline;


    for Mode_Mask use record
        Index       at 0 range 0 .. 0;
        Double      at 0 range 1 .. 1;
        Accum       at 0 range 2 .. 2;
        Alpha       at 0 range 3 .. 3;
        Depth       at 0 range 4 .. 4;
        Stencil     at 0 range 5 .. 5;
        RGB8        at 0 range 6 .. 6;
        Multisample at 0 range 7 .. 7;
        Stereo      at 0 range 8 .. 8;
        Fake_Single at 0 range 9 .. 9;
        OpenGL3     at 0 range 10 .. Interfaces.C.unsigned'Size - 1;
    end record;

    for Mode_Mask'Size use Interfaces.C.unsigned'Size;

    pragma Convention (C_Pass_By_Copy, Mode_Mask);


    pragma Inline (Show);
    pragma Inline (Show_With_Args);
    pragma Inline (Hide);
    pragma Inline (Hide_Overlay);
    pragma Inline (Flush);

    pragma Inline (Pixel_H);
    pragma Inline (Pixel_W);
    pragma Inline (Pixels_Per_Unit);

    pragma Inline (Get_Mode);
    pragma Inline (Set_Mode);
    pragma Inline (Can_Do);
    pragma Inline (Can_Do_Overlay);

    pragma Inline (Get_Context);
    pragma Inline (Set_Context);
    pragma Inline (Get_Context_Valid);
    pragma Inline (Set_Context_Valid);
    pragma Inline (Get_Valid);
    pragma Inline (Set_Valid);
    pragma Inline (Invalidate);
    pragma Inline (Make_Current);
    pragma Inline (Make_Overlay_Current);

    pragma Inline (Ortho);
    pragma Inline (Redraw_Overlay);
    pragma Inline (Swap_Buffers);
    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Windows.OpenGL;


