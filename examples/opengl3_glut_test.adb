

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/OpenGL3-glut-test.cxx, which draws two
--  triangles with OpenGL 3 shaders in a window made with FLTK's GLUT
--  emulation.

--  Deliberate differences from the C++ original:
--
--  * GLEW is not used. On Linux libGL exports the OpenGL 3 core functions
--    directly, so the GL3 package imports them by name. There is therefore
--    no "Status: Using GLEW ..." line on standard error.
--
--  * The never-taken full screen branch uses FLTK.GLUT.Full_Screen on the
--    current GLUT window rather than Fl::first_window()->fullscreen(),
--    since GLUT's windows are not Ada objects.
--
--  * exit (1) becomes returning 1 from the main function.


with

    Ada.Text_IO,
    FLTK.Asks,
    FLTK.GLUT,
    FLTK.Static,
    GL3;

use type

    GL3.GLbitfield,
    GL3.GLfloat,
    GL3.GLint,
    GL3.GLsizeiptr;


function OpenGL3_Glut_Test
    return Integer
is


    package GLUT renames FLTK.GLUT;
    package TIO  renames Ada.Text_IO;

    use GL3;


    Vertices : constant GLfloat_Array (0 .. 8) :=
       (-1.0, 0.0, 0.0,
         0.0, 1.0, 0.0,
         0.0, 0.0, 0.0);

    Colours : constant GLfloat_Array (0 .. 8) :=
       (1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0);

    Vertices_2 : constant GLfloat_Array (0 .. 8) :=
       (0.0,  0.0, 0.0,
        0.0, -1.0, 0.0,
        1.0,  0.0, 0.0);

    Vertex_Array_Obj_ID  : GLuint_Array (0 .. 1) := (others => 0);
    Vertex_Buffer_Obj_ID : GLuint_Array (0 .. 2) := (others => 0);


    procedure Print_Shader_Info_Log
           (Shader : in GLuint)
    is
        Info_Log_Len : GLint := 0;
    begin
        Get_Shader (Shader, GL_INFO_LOG_LENGTH, Info_Log_Len);
        if Info_Log_Len > 0 then
            TIO.Put_Line (TIO.Standard_Error, "InfoLog:");
            TIO.Put_Line
               (TIO.Standard_Error, Shader_Info_Log (Shader, Positive (Info_Log_Len)));
        end if;
    end Print_Shader_Info_Log;


    procedure Init is
    begin
        --  Would load objects from file here - but using globals in this example

        --  Allocate Vertex Array Objects
        Gen_Vertex_Arrays (2, Vertex_Array_Obj_ID);
        --  Setup first Vertex Array Object
        Bind_Vertex_Array (Vertex_Array_Obj_ID (0));
        Gen_Buffers (2, Vertex_Buffer_Obj_ID (0 .. 1));

        --  VBO for vertex data
        Bind_Buffer (GL_ARRAY_BUFFER, Vertex_Buffer_Obj_ID (0));
        Buffer_Data (GL_ARRAY_BUFFER, 9 * Float_Bytes, Vertices, GL_STATIC_DRAW);
        Vertex_Attrib_Pointer (0, 3, GL_FLOAT, GL_FALSE, 0, 0);
        Enable_Vertex_Attrib_Array (0);

        --  VBO for colour data
        Bind_Buffer (GL_ARRAY_BUFFER, Vertex_Buffer_Obj_ID (1));
        Buffer_Data (GL_ARRAY_BUFFER, 9 * Float_Bytes, Colours, GL_STATIC_DRAW);
        Vertex_Attrib_Pointer (1, 3, GL_FLOAT, GL_FALSE, 0, 0);
        Enable_Vertex_Attrib_Array (1);

        --  Setup second Vertex Array Object
        Bind_Vertex_Array (Vertex_Array_Obj_ID (1));
        Gen_Buffers (1, Vertex_Buffer_Obj_ID (2 .. 2));

        --  VBO for vertex data
        Bind_Buffer (GL_ARRAY_BUFFER, Vertex_Buffer_Obj_ID (2));
        Buffer_Data (GL_ARRAY_BUFFER, 9 * Float_Bytes, Vertices_2, GL_STATIC_DRAW);
        Vertex_Attrib_Pointer (0, 3, GL_FLOAT, GL_FALSE, 0, 0);
        Enable_Vertex_Attrib_Array (0);

        Bind_Vertex_Array (0);
    end Init;


    procedure Init_Shaders
    is
        Shading_Lang_Vers : constant String := "130";

        VV : constant String := "#version " & Shading_Lang_Vers & ASCII.LF
            & "  in  vec3 in_Position;"
            & "  in  vec3 in_Color;"
            & "  out vec3 ex_Color;"
            & "  void main(void)"
            & "  {"
            & "    ex_Color = in_Color;"
            & "    gl_Position = vec4(in_Position, 1.0);"
            & "  }";

        FF : constant String := "#version " & Shading_Lang_Vers & ASCII.LF
            & "  precision highp float;"
            & "  in  vec3 ex_Color;"
            & "  out vec4 out_Color;"
            & "  void main(void)"
            & "  {"
            & "    out_Color = vec4(ex_Color,1.0);"
            & "  }";

        P, F, V  : GLuint;
        Compiled : GLint;
        Length   : GLint;
    begin
        Clear_Color (1.0, 1.0, 1.0, 0.0);

        V := Create_Shader (GL_VERTEX_SHADER);
        F := Create_Shader (GL_FRAGMENT_SHADER);

        --  load shaders
        Shader_Source (V, VV);
        Shader_Source (F, FF);

        Compile_Shader (V);
        Get_Shader (V, GL_COMPILE_STATUS, Compiled);
        if Compiled = 0 then
            TIO.Put_Line (TIO.Standard_Error, "Vertex shader not compiled.");
            Print_Shader_Info_Log (V);
        end if;

        Compile_Shader (F);
        Get_Shader (F, GL_COMPILE_STATUS, Compiled);
        if Compiled = 0 then
            TIO.Put_Line (TIO.Standard_Error, "Fragment shader not compiled.");
            Print_Shader_Info_Log (F);
        end if;

        P := Create_Program;

        Attach_Shader (P, V);
        Attach_Shader (P, F);
        Bind_Attrib_Location (P, 0, "in_Position");
        Bind_Attrib_Location (P, 1, "in_Color");

        Link_Program (P);
        Get_Program (P, GL_LINK_STATUS, Compiled);
        if Compiled /= GLint (GL_TRUE) then
            Get_Program (P, GL_INFO_LOG_LENGTH, Length);
            TIO.Put_Line (TIO.Standard_Error,
                "Link log=" & Program_Info_Log (P, Positive'Max (1, Integer (Length))));
        end if;
        Use_Program (P);
    end Init_Shaders;


    procedure Display is
    begin
        --  clear the screen
        Clear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

        Bind_Vertex_Array (Vertex_Array_Obj_ID (0));  --  First VAO
        Draw_Arrays (GL_TRIANGLES, 0, 3);             --  draw first object

        Bind_Vertex_Array (Vertex_Array_Obj_ID (1));  --  select second VAO
        Vertex_Attrib_3f (1, 1.0, 0.0, 0.0);          --  set constant color attribute
        Draw_Arrays (GL_TRIANGLES, 0, 3);             --  draw second object
    end Display;


    Fullscreen : constant Boolean := False;

    Window : GLUT.Valid_Window_Number;
    pragma Unreferenced (Window);


begin


    FLTK.Static.Set_Use_High_Res_GL (True);
    GLUT.Init;
    GLUT.Init_Display_Mode ((Double | OpenGL3 => True, others => False));
    GLUT.Init_Window_Size (400, 400);
    Window := GLUT.Create_Window ("Triangle Test");

    declare
        GLV : constant String := Get_String (GL_VERSION);
        GL_Version_Major : Natural := 0;
    begin
        for C of GLV loop
            exit when C not in '0' .. '9';
            GL_Version_Major :=
                GL_Version_Major * 10 + (Character'Pos (C) - Character'Pos ('0'));
        end loop;
        TIO.Put_Line (TIO.Standard_Error, "OpenGL version " & GLV & " supported");
        if GL_Version_Major < 3 then
            TIO.Put_Line (TIO.Standard_Error, "");
            TIO.Put_Line (TIO.Standard_Error, "This platform does not support OpenGL V3");
            TIO.Put_Line (TIO.Standard_Error, "");
            TIO.Flush (TIO.Standard_Error);
            --  ensure that users see a message on Windows w/o console output:
            FLTK.Asks.Alert ("OpenGL version " & GLV & " supported." & ASCII.LF
                & "This platform does not support OpenGL V3!");
            return 1;
        end if;
    end;

    Init_Shaders;
    Init;
    GLUT.Display_Func (Display'Unrestricted_Access);
    if Fullscreen then
        GLUT.Full_Screen;
    end if;
    GLUT.Main_Loop;
    return 0;


end OpenGL3_Glut_Test;


