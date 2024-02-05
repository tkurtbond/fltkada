

with

    System;

private with

    Interfaces.C;


package FLTK.Widgets.Groups.Windows.OpenGL is


    -------------
    --  Types  --
    -------------

    type GL_Window is new Window with private;

    type GL_Window_Reference (Data : not null access GL_Window'Class) is
        limited null record with Implicit_Dereference => Data;

    type Mode_Mask is record
        Index       : Boolean;
        Double      : Boolean;
        Accum       : Boolean;
        Alpha       : Boolean;
        Depth       : Boolean;
        Stencil     : Boolean;
        RGB8        : Boolean;
        Multisample : Boolean;
        Stereo      : Boolean;
        Fake_Single : Boolean;
        OpenGL3     : Boolean;
    end record;




    --------------------
    --  Constructors  --
    --------------------

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

    overriding procedure Finalize
           (This : in out GL_Window);




    pragma Inline (Show);
    pragma Inline (Hide);
    pragma Inline (Hide_Overlay);
    pragma Inline (Flush);


    pragma Inline (Pixel_H);
    pragma Inline (Pixel_W);
    pragma Inline (Pixels_Per_Unit);


    pragma Inline (Can_Do_Overlay);


    pragma Inline (Get_Context);
    pragma Inline (Set_Context);
    pragma Inline (Get_Context_Valid);
    pragma Inline (Set_Context_Valid);
    pragma Inline (Get_Valid);
    pragma Inline (Set_Valid);
    pragma Inline (Make_Current);
    pragma Inline (Make_Overlay_Current);


    pragma Inline (Ortho);
    pragma Inline (Redraw_Overlay);
    pragma Inline (Swap_Buffers);
    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Windows.OpenGL;

