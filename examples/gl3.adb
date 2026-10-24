

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.Strings.chars_ptr;


package body GL3 is


    package IntC renames Interfaces.C;
    package ICS  renames Interfaces.C.Strings;




    ------------------------
    --  Functions From C  --
    ------------------------

    function glGetString
           (Name : in GLenum)
        return ICS.chars_ptr;
    pragma Import (C, glGetString, "glGetString");

    type chars_ptr_Array is array (Natural range <>) of aliased ICS.chars_ptr;
    pragma Convention (C, chars_ptr_Array);

    procedure glShaderSource
           (Shader  : in GLuint;
            Count   : in GLsizei;
            Strings : in chars_ptr_Array;
            Lengths : in ICS.chars_ptr);
    pragma Import (C, glShaderSource, "glShaderSource");

    procedure glGetShaderInfoLog
           (Shader     : in     GLuint;
            Max_Length : in     GLsizei;
            Length     :    out GLsizei;
            Log        :    out IntC.char_array);
    pragma Import (C, glGetShaderInfoLog, "glGetShaderInfoLog");

    procedure glGetProgramInfoLog
           (Program    : in     GLuint;
            Max_Length : in     GLsizei;
            Length     :    out GLsizei;
            Log        :    out IntC.char_array);
    pragma Import (C, glGetProgramInfoLog, "glGetProgramInfoLog");

    procedure glBindAttribLocation
           (Program : in GLuint;
            Index   : in GLuint;
            Name    : in IntC.char_array);
    pragma Import (C, glBindAttribLocation, "glBindAttribLocation");

    procedure glBindFragDataLocation
           (Program : in GLuint;
            Color   : in GLuint;
            Name    : in IntC.char_array);
    pragma Import (C, glBindFragDataLocation, "glBindFragDataLocation");

    function glGetUniformLocation
           (Program : in GLuint;
            Name    : in IntC.char_array)
        return GLint;
    pragma Import (C, glGetUniformLocation, "glGetUniformLocation");

    function glGetAttribLocation
           (Program : in GLuint;
            Name    : in IntC.char_array)
        return GLint;
    pragma Import (C, glGetAttribLocation, "glGetAttribLocation");




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Get_String
           (Name : in GLenum)
        return String
    is
        Result : constant ICS.chars_ptr := glGetString (Name);
    begin
        if Result = ICS.Null_Ptr then
            return "";
        else
            return ICS.Value (Result);
        end if;
    end Get_String;


    procedure Shader_Source
           (Shader : in GLuint;
            Source : in String)
    is
        Text : chars_ptr_Array (0 .. 0) := (0 => ICS.New_String (Source));
    begin
        glShaderSource (Shader, 1, Text, ICS.Null_Ptr);
        ICS.Free (Text (0));
    end Shader_Source;


    function Shader_Info_Log
           (Shader     : in GLuint;
            Max_Length : in Positive)
        return String
    is
        Log    : IntC.char_array (1 .. IntC.size_t (Max_Length)) := (others => IntC.nul);
        Length : GLsizei := 0;
    begin
        glGetShaderInfoLog (Shader, GLsizei (Max_Length), Length, Log);
        return IntC.To_Ada (Log, Trim_Nul => True);
    end Shader_Info_Log;


    function Program_Info_Log
           (Program    : in GLuint;
            Max_Length : in Positive)
        return String
    is
        Log    : IntC.char_array (1 .. IntC.size_t (Max_Length)) := (others => IntC.nul);
        Length : GLsizei := 0;
    begin
        glGetProgramInfoLog (Program, GLsizei (Max_Length), Length, Log);
        return IntC.To_Ada (Log, Trim_Nul => True);
    end Program_Info_Log;


    procedure Bind_Attrib_Location
           (Program : in GLuint;
            Index   : in GLuint;
            Name    : in String) is
    begin
        glBindAttribLocation (Program, Index, IntC.To_C (Name));
    end Bind_Attrib_Location;


    procedure Bind_Frag_Data_Location
           (Program : in GLuint;
            Color   : in GLuint;
            Name    : in String) is
    begin
        glBindFragDataLocation (Program, Color, IntC.To_C (Name));
    end Bind_Frag_Data_Location;


    function Get_Uniform_Location
           (Program : in GLuint;
            Name    : in String)
        return GLint is
    begin
        return glGetUniformLocation (Program, IntC.To_C (Name));
    end Get_Uniform_Location;


    function Get_Attrib_Location
           (Program : in GLuint;
            Name    : in String)
        return GLint is
    begin
        return glGetAttribLocation (Program, IntC.To_C (Name));
    end Get_Attrib_Location;


end GL3;


