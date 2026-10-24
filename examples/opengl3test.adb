

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/OpenGL3test.cxx, a tiny OpenGL 3 demo with
--  FLTK widgets drawn over the GL scene.

--  Deliberate differences from the C++ original:
--
--  * GLEW is not used. On Linux libGL exports the OpenGL 3 core functions
--    directly, so the GL3 package imports them by name. There is therefore
--    no "Using GLEW ..." line at the start of the output.
--
--  * The C++ statics "first", "factor" and "doublebuff" become variables
--    of the main function.


pragma Ada_2012;


with

    Ada.Float_Text_IO,
    Ada.Strings.Fixed,
    FLTK.Draw.OpenGL,
    FLTK.Static,
    FLTK.Text_Buffers,
    FLTK.Widgets.Buttons.Light,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Groups.Windows.OpenGL,
    GL3;

use type

    GL3.GLboolean,
    GL3.GLfloat,
    GL3.GLint,
    GL3.GLsizeiptr,
    GL3.GLuint;


function OpenGL3test
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package LBt renames FLTK.Widgets.Buttons.Light;
    package TD  renames FLTK.Widgets.Groups.Text_Displays;
    package TB  renames FLTK.Text_Buffers;
    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;


    function Image
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (Value), Ada.Strings.Left);
    end Image;


    --  The integer at the start of Text, as sscanf "%d" would read it, and the
    --  index just after it
    procedure Scan_Integer
           (Text  : in     String;
            From  : in     Positive;
            Value :    out Integer;
            Next  :    out Positive) is
    begin
        Value := 0;
        Next  := From;
        while Next <= Text'Last and then Text (Next) in '0' .. '9' loop
            Value := Value * 10 + (Character'Pos (Text (Next)) - Character'Pos ('0'));
            Next  := Next + 1;
        end loop;
    end Scan_Integer;


    --  Enables high resolution GL before any window is made, as the first
    --  statement of the C++ main does
    function Use_High_Res_GL
        return Boolean is
    begin
        FLTK.Static.Set_Use_High_Res_GL (True);
        return True;
    end Use_High_Res_GL;

    High_Res_GL : constant Boolean := Use_High_Res_GL;
    pragma Unreferenced (High_Res_GL);




    type Simple_GL3_Window is new OGL.GL_Window with record
        Shader_Program     : GL3.GLuint := 0;
        Vertex_Array       : GL3.GLuint_Array (0 .. 0) := (others => 0);
        Vertex_Buffer      : GL3.GLuint_Array (0 .. 0) := (others => 0);
        Position_Uniform   : GL3.GLint  := 0;
        Colour_Attribute   : GL3.GLint  := 0;
        Position_Attribute : GL3.GLint  := 0;
        GL_Version_Major   : Integer    := 0;
    end record;

    overriding procedure Draw
           (This : in out Simple_GL3_Window);

    overriding function Handle
           (This  : in out Simple_GL3_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    procedure Reset
           (This : in out Simple_GL3_Window'Class);


    function Create_Simple_GL3_Window
           (Parent     : in out Win.Window'Class;
            X, Y, W, H : in     Integer)
        return Simple_GL3_Window is
    begin
        return This : Simple_GL3_Window :=
           (OGL.Forge.Create (Parent, X, Y, W, H) with others => <>)
        do
            This.Set_Mode ((RGB8 | Double | OpenGL3 => True, others => False));
        end return;
    end Create_Simple_GL3_Window;




    Top_Window : Win.Window := Win.Forge.Create (800, 300);

    The_GL : Simple_GL3_Window := Create_Simple_GL3_Window (Top_Window, 0, 0, 300, 300);

    Output_Buffer : TB.Text_Buffer := TB.Forge.Create;

    Output : TD.Text_Display := TD.Forge.Create (Top_Window, 300, 0, 500, 280);

    Double_Button : LBt.Light_Button :=
        LBt.Forge.Create (Top_Window, 300, 280, 500, 20, "Double-Buffered");

    First      : Boolean      := True;
    Factor     : GL3.GLfloat  := 1.1;
    Doublebuff : Boolean      := True;


    procedure Add_Output
           (Text : in String) is
    begin
        Output.Get_Buffer.Append_Text (Text);
        Output.Scroll_To (10000, 0);
        Output.Redraw;
    end Add_Output;




    procedure Draw
           (This : in out Simple_GL3_Window)
    is
        use GL3;
    begin
        if This.GL_Version_Major >= 3 and This.Shader_Program = 0 then
            declare
                SLV  : constant String := Get_String (GL_SHADING_LANGUAGE_VERSION);
                Mslv : Integer;
                Mnlv : Integer;
                Next : Positive;

                Vertex_Data : constant GLfloat_Array (0 .. 31) :=
                   (-0.5, -0.5, 0.0, 1.0,   1.0, 0.0, 0.0, 1.0,
                    -0.5,  0.5, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,
                     0.5,  0.5, 0.0, 1.0,   0.0, 0.0, 1.0, 1.0,
                     0.5, -0.5, 0.0, 1.0,   1.0, 1.0, 1.0, 1.0);

                VS, FS : GLuint;
                Err    : GLint;
            begin
                Scan_Integer (SLV, SLV'First, Mslv, Next);
                Scan_Integer (SLV, Next + 1, Mnlv, Next);
                Add_Output ("Shading Language Version=" & Image (Mslv) & "." & Image (Mnlv)
                    & ASCII.LF);
                declare
                    Version : constant String :=
                        "#version " & Image (Mslv) & Image (Mnlv) & ASCII.LF;
                    VSS : constant String := Version
                        & "      uniform vec2 p;"
                        & "      in vec4 position;"
                        & "      in vec4 colour;"
                        & "      out vec4 colourV;"
                        & "      void main (void)"
                        & "      {"
                        & "      colourV = colour;"
                        & "      gl_Position = vec4(p, 0.0, 0.0) + position;"
                        & "      }";
                    FSS : constant String := Version
                        & "      in vec4 colourV;"
                        & "      out vec4 fragColour;"
                        & "      void main(void)"
                        & "      {"
                        & "      fragColour = colourV;"
                        & "      }";
                begin
                    VS := Create_Shader (GL_VERTEX_SHADER);
                    Shader_Source (VS, VSS);
                    Compile_Shader (VS);
                    Get_Shader (VS, GL_COMPILE_STATUS, Err);
                    if Err /= GLint (GL_TRUE) then
                        Add_Output ("vs ShaderInfoLog=" & Shader_Info_Log (VS, 1000) & ASCII.LF);
                    end if;
                    FS := Create_Shader (GL_FRAGMENT_SHADER);
                    Shader_Source (FS, FSS);
                    Compile_Shader (FS);
                    Get_Shader (FS, GL_COMPILE_STATUS, Err);
                    if Err /= GLint (GL_TRUE) then
                        Add_Output ("fs ShaderInfoLog=" & Shader_Info_Log (FS, 1000) & ASCII.LF);
                    end if;
                end;

                --  Attach the shaders
                This.Shader_Program := Create_Program;
                Attach_Shader (This.Shader_Program, VS);
                Attach_Shader (This.Shader_Program, FS);
                Bind_Frag_Data_Location (This.Shader_Program, 0, "fragColour");
                Link_Program (This.Shader_Program);
                Get_Program (This.Shader_Program, GL_LINK_STATUS, Err);
                if Err /= GLint (GL_TRUE) then
                    Add_Output ("link log=" & Program_Info_Log (This.Shader_Program, 1000)
                        & ASCII.LF);
                end if;

                --  Get pointers to uniforms and attributes
                This.Position_Uniform   := Get_Uniform_Location (This.Shader_Program, "p");
                This.Colour_Attribute   := Get_Attrib_Location (This.Shader_Program, "colour");
                This.Position_Attribute := Get_Attrib_Location (This.Shader_Program, "position");
                Delete_Shader (VS);
                Delete_Shader (FS);

                --  Upload vertices (1st four values in a row) and colours
                --  (following four values)
                Gen_Vertex_Arrays (1, This.Vertex_Array);
                Bind_Vertex_Array (This.Vertex_Array (0));

                Gen_Buffers (1, This.Vertex_Buffer);
                Bind_Buffer (GL_ARRAY_BUFFER, This.Vertex_Buffer (0));
                Buffer_Data (GL_ARRAY_BUFFER, 4 * 8 * Float_Bytes, Vertex_Data, GL_STATIC_DRAW);

                Enable_Vertex_Attrib_Array (GLuint (This.Position_Attribute));
                Enable_Vertex_Attrib_Array (GLuint (This.Colour_Attribute));
                Vertex_Attrib_Pointer
                   (GLuint (This.Position_Attribute), 4, GL_FLOAT, GL_FALSE,
                    8 * Float_Bytes, 0);
                Vertex_Attrib_Pointer
                   (GLuint (This.Colour_Attribute), 4, GL_FLOAT, GL_FALSE,
                    8 * Float_Bytes, 4 * Float_Bytes);
                Use_Program (This.Shader_Program);
            end;
        elsif not This.Get_Valid then
            Viewport (0, 0, GLsizei (This.Pixel_W), GLsizei (This.Pixel_H));
        end if;
        Clear_Color (0.08, 0.8, 0.8, 1.0);
        Clear (GL_COLOR_BUFFER_BIT);
        if This.Shader_Program /= 0 then
            Uniform_2fv (This.Position_Uniform, 1, (0.0, 0.0));
            Draw_Arrays (GL_TRIANGLE_FAN, 0, 4);
        end if;
        OGL.GL_Window (This).Draw;  --  Draw FLTK child widgets.
    end Draw;


    function Handle
           (This  : in out Simple_GL3_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        use GL3;
        use type FLTK.Event_Kind, FLTK.Event_Outcome;
        Retval : FLTK.Event_Outcome;
    begin
        if First and Event = FLTK.Show and This.Is_Shown then
            First := False;
            This.Make_Current;
            declare
                GLV  : constant String := Get_String (GL_VERSION);
                Next : Positive;
                Mode : OGL.Mode_Mask;
            begin
                Add_Output ("GL_VERSION=" & GLV & ASCII.LF);
                Scan_Integer (GLV, GLV'First, This.GL_Version_Major, Next);
                if This.GL_Version_Major < 3 then
                    Add_Output (ASCII.LF & "This platform does not support OpenGL V3 :" & ASCII.LF
                        & "FLTK widgets will appear but the programmed "
                        & "rendering pipeline will not run." & ASCII.LF);
                    Mode := This.Get_Mode;
                    Mode.OpenGL3 := False;
                    This.Set_Mode (Mode);
                end if;
            end;
            This.Redraw;
        end if;

        Retval := OGL.GL_Window (This).Handle (Event);
        if Retval = FLTK.Handled then
            return Retval;
        end if;

        if Event = FLTK.Push and This.GL_Version_Major >= 3 then
            declare
                Data : GLfloat_Array (0 .. 3);
                PPU  : String (1 .. 20);
            begin
                Get_Buffer_Sub_Data (GL_ARRAY_BUFFER, 0, 4 * Float_Bytes, Data);
                if Long_Float (Data (0)) < -0.88 or Long_Float (Data (0)) > -0.5 then
                    Factor := 1.0 / Factor;
                end if;
                Data (0) := Data (0) * Factor;
                Buffer_Sub_Data (GL_ARRAY_BUFFER, 0, 4 * Float_Bytes, Data);
                Get_Buffer_Sub_Data (GL_ARRAY_BUFFER, 24 * Float_Bytes, 4 * Float_Bytes, Data);
                Data (0) := Data (0) * Factor;
                Buffer_Sub_Data (GL_ARRAY_BUFFER, 24 * Float_Bytes, 4 * Float_Bytes, Data);
                This.Redraw;
                Ada.Float_Text_IO.Put (PPU, This.Pixels_Per_Unit, Aft => 1, Exp => 0);
                Add_Output ("push  Fl_Gl_Window::pixels_per_unit()="
                    & Ada.Strings.Fixed.Trim (PPU, Ada.Strings.Left) & ASCII.LF);
                return FLTK.Handled;
            end;
        end if;
        return Retval;
    end Handle;


    procedure Reset
           (This : in out Simple_GL3_Window'Class) is
    begin
        This.Shader_Program := 0;
        FLTK.Draw.OpenGL.Texture_Reset;
    end Reset;




    procedure Toggle_Double
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Flags : OGL.Mode_Mask := The_GL.Get_Mode;
    begin
        Doublebuff := not Doublebuff;
        Flags.Double := Doublebuff;
        Reset (The_GL);
        The_GL.Hide;
        The_GL.Set_Mode (Flags);
        The_GL.Show;
    end Toggle_Double;


    procedure Button_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Add_Output ("run " & Item.Get_Label & " callback" & ASCII.LF);
    end Button_Callback;




    --  Widgets to go above the GL3 scene, made after the partially
    --  transparent white they are coloured with

    function Set_Free_Color
        return Boolean is
    begin
        FLTK.Static.Set_Color (FLTK.Free_Color, 255, 255, 255, 140);
        return True;
    end Set_Free_Color;

    Free_Color_Set : constant Boolean := Set_Free_Color;
    pragma Unreferenced (Free_Color_Set);

    Button_1 : Btn.Button := Btn.Forge.Create (The_GL, 0, 0, 60, 30, "button");

    Button_2 : Btn.Button := Btn.Forge.Create (The_GL, 0, 170, 60, 30, "button2");


begin


    Double_Button.Set_Callback (Toggle_Double'Unrestricted_Access);
    Double_Button.Set_State (Btn.On);
    Output.Set_Buffer (Output_Buffer);

    Button_1.Set_Background_Color (FLTK.Free_Color);
    Button_1.Set_Box (FLTK.Down_Box);
    Button_1.Set_Callback (Button_Callback'Unrestricted_Access);
    Button_2.Set_Background_Color (FLTK.Free_Color);
    Button_2.Set_Box (FLTK.Border_Box);
    Button_2.Set_Callback (Button_Callback'Unrestricted_Access);

    Top_Window.Set_Resizable (The_GL);
    Top_Window.Set_Label ("Click GL panel to reshape");
    Top_Window.Show_With_Args;

    return FLTK.Run;


end OpenGL3test;


