

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  The handful of OpenGL 3 core profile functions and constants used by the
--  OpenGL3test and OpenGL3-glut-test examples, imported straight from libGL
--  (link with -lGL). This is not a general OpenGL binding.

--  On Linux, libGL exports the core OpenGL 3 entry points directly, so no
--  loader such as GLEW is needed. Other platforms may need the addresses
--  found at run time instead, for example with FLTK.GLUT.Get_Proc_Address.


with

    Interfaces.C;


package GL3 is


    subtype GLenum     is Interfaces.C.unsigned;
    subtype GLbitfield is Interfaces.C.unsigned;
    subtype GLuint     is Interfaces.C.unsigned;
    subtype GLint      is Interfaces.C.int;
    subtype GLsizei    is Interfaces.C.int;
    subtype GLfloat    is Interfaces.C.C_float;
    subtype GLboolean  is Interfaces.C.unsigned_char;
    subtype GLintptr   is Interfaces.C.ptrdiff_t;
    subtype GLsizeiptr is Interfaces.C.ptrdiff_t;

    type GLuint_Array is array (Natural range <>) of aliased GLuint;
    pragma Convention (C, GLuint_Array);

    type GLfloat_Array is array (Natural range <>) of aliased GLfloat;
    pragma Convention (C, GLfloat_Array);

    Float_Bytes : constant := GLfloat'Size / 8;


    GL_FALSE : constant GLboolean := 0;
    GL_TRUE  : constant GLboolean := 1;

    GL_TRIANGLES    : constant GLenum := 16#0004#;
    GL_TRIANGLE_FAN : constant GLenum := 16#0006#;

    GL_DEPTH_BUFFER_BIT : constant GLbitfield := 16#0000_0100#;
    GL_COLOR_BUFFER_BIT : constant GLbitfield := 16#0000_4000#;

    GL_FLOAT : constant GLenum := 16#1406#;

    GL_VERSION                  : constant GLenum := 16#1F02#;
    GL_SHADING_LANGUAGE_VERSION : constant GLenum := 16#8B8C#;

    GL_ARRAY_BUFFER : constant GLenum := 16#8892#;
    GL_STATIC_DRAW  : constant GLenum := 16#88E4#;

    GL_FRAGMENT_SHADER : constant GLenum := 16#8B30#;
    GL_VERTEX_SHADER   : constant GLenum := 16#8B31#;
    GL_COMPILE_STATUS  : constant GLenum := 16#8B81#;
    GL_LINK_STATUS     : constant GLenum := 16#8B82#;
    GL_INFO_LOG_LENGTH : constant GLenum := 16#8B84#;




    --  Strings  --

    --  glGetString
    function Get_String
           (Name : in GLenum)
        return String;




    --  Shaders and Programs  --

    function Create_Shader
           (Kind : in GLenum)
        return GLuint;
    pragma Import (C, Create_Shader, "glCreateShader");

    --  glShaderSource with a single string
    procedure Shader_Source
           (Shader : in GLuint;
            Source : in String);

    procedure Compile_Shader
           (Shader : in GLuint);
    pragma Import (C, Compile_Shader, "glCompileShader");

    procedure Delete_Shader
           (Shader : in GLuint);
    pragma Import (C, Delete_Shader, "glDeleteShader");

    --  glGetShaderiv with a single result
    procedure Get_Shader
           (Shader : in     GLuint;
            Name   : in     GLenum;
            Value  :    out GLint);
    pragma Import (C, Get_Shader, "glGetShaderiv");

    --  glGetShaderInfoLog, for a log at most Max_Length long
    function Shader_Info_Log
           (Shader     : in GLuint;
            Max_Length : in Positive)
        return String;

    function Create_Program
        return GLuint;
    pragma Import (C, Create_Program, "glCreateProgram");

    procedure Attach_Shader
           (Program, Shader : in GLuint);
    pragma Import (C, Attach_Shader, "glAttachShader");

    procedure Bind_Attrib_Location
           (Program : in GLuint;
            Index   : in GLuint;
            Name    : in String);

    procedure Bind_Frag_Data_Location
           (Program : in GLuint;
            Color   : in GLuint;
            Name    : in String);

    procedure Link_Program
           (Program : in GLuint);
    pragma Import (C, Link_Program, "glLinkProgram");

    --  glGetProgramiv with a single result
    procedure Get_Program
           (Program : in     GLuint;
            Name    : in     GLenum;
            Value   :    out GLint);
    pragma Import (C, Get_Program, "glGetProgramiv");

    --  glGetProgramInfoLog, for a log at most Max_Length long
    function Program_Info_Log
           (Program    : in GLuint;
            Max_Length : in Positive)
        return String;

    procedure Use_Program
           (Program : in GLuint);
    pragma Import (C, Use_Program, "glUseProgram");

    function Get_Uniform_Location
           (Program : in GLuint;
            Name    : in String)
        return GLint;

    function Get_Attrib_Location
           (Program : in GLuint;
            Name    : in String)
        return GLint;

    procedure Uniform_2fv
           (Location : in GLint;
            Count    : in GLsizei;
            Value    : in GLfloat_Array);
    pragma Import (C, Uniform_2fv, "glUniform2fv");




    --  Buffers and Vertex Arrays  --

    procedure Gen_Vertex_Arrays
           (Count  : in     GLsizei;
            Arrays :    out GLuint_Array);
    pragma Import (C, Gen_Vertex_Arrays, "glGenVertexArrays");

    procedure Bind_Vertex_Array
           (Item : in GLuint);
    pragma Import (C, Bind_Vertex_Array, "glBindVertexArray");

    procedure Gen_Buffers
           (Count   : in     GLsizei;
            Buffers :    out GLuint_Array);
    pragma Import (C, Gen_Buffers, "glGenBuffers");

    procedure Bind_Buffer
           (Target : in GLenum;
            Buffer : in GLuint);
    pragma Import (C, Bind_Buffer, "glBindBuffer");

    procedure Buffer_Data
           (Target : in GLenum;
            Size   : in GLsizeiptr;
            Data   : in GLfloat_Array;
            Usage  : in GLenum);
    pragma Import (C, Buffer_Data, "glBufferData");

    procedure Buffer_Sub_Data
           (Target : in GLenum;
            Offset : in GLintptr;
            Size   : in GLsizeiptr;
            Data   : in GLfloat_Array);
    pragma Import (C, Buffer_Sub_Data, "glBufferSubData");

    procedure Get_Buffer_Sub_Data
           (Target : in     GLenum;
            Offset : in     GLintptr;
            Size   : in     GLsizeiptr;
            Data   :    out GLfloat_Array);
    pragma Import (C, Get_Buffer_Sub_Data, "glGetBufferSubData");

    procedure Enable_Vertex_Attrib_Array
           (Index : in GLuint);
    pragma Import (C, Enable_Vertex_Attrib_Array, "glEnableVertexAttribArray");

    --  The C pointer argument is always a byte offset into the bound buffer here
    procedure Vertex_Attrib_Pointer
           (Index      : in GLuint;
            Size       : in GLint;
            Kind       : in GLenum;
            Normalized : in GLboolean;
            Stride     : in GLsizei;
            Offset     : in GLintptr);
    pragma Import (C, Vertex_Attrib_Pointer, "glVertexAttribPointer");

    procedure Vertex_Attrib_3f
           (Index   : in GLuint;
            X, Y, Z : in GLfloat);
    pragma Import (C, Vertex_Attrib_3f, "glVertexAttrib3f");




    --  Drawing  --

    procedure Viewport
           (X, Y : in GLint;
            W, H : in GLsizei);
    pragma Import (C, Viewport, "glViewport");

    procedure Clear_Color
           (R, G, B, A : in GLfloat);
    pragma Import (C, Clear_Color, "glClearColor");

    procedure Clear
           (Mask : in GLbitfield);
    pragma Import (C, Clear, "glClear");

    procedure Draw_Arrays
           (Mode  : in GLenum;
            First : in GLint;
            Count : in GLsizei);
    pragma Import (C, Draw_Arrays, "glDrawArrays");


end GL3;


