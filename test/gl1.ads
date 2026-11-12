


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  The fixed-function OpenGL calls and constants that the demo programs in
--  test/ use (cube, gl_overlay, glut_test, shape, CubeView, fullscreen,
--  fractals, glpuzzle), imported straight from libGL.  This is not a
--  general OpenGL binding, which is out of FLTKAda's scope (PLAN.md,
--  Scope); examples/gl3.ads is the same for OpenGL 3.


with

    Interfaces.C;


package GL1 is


    pragma Linker_Options ("-lGL");


    subtype GLenum     is Interfaces.C.unsigned;
    subtype GLbitfield is Interfaces.C.unsigned;
    subtype GLint      is Interfaces.C.int;
    subtype GLsizei    is Interfaces.C.int;
    subtype GLfloat    is Interfaces.C.C_float;
    subtype GLdouble   is Interfaces.C.double;
    subtype GLubyte    is Interfaces.C.unsigned_char;
    subtype GLuint     is Interfaces.C.unsigned;
    subtype GLboolean  is Interfaces.C.unsigned_char;

    --  Arrays for the calls that take a pointer:  C passes them by
    --  reference.
    type GLfloat_Array is array (Natural range <>) of aliased GLfloat
        with Convention => C;
    type GLint_Array is array (Natural range <>) of aliased GLint
        with Convention => C;
    type GLuint_Array is array (Natural range <>) of aliased GLuint
        with Convention => C;
    type GLubyte_Array is array (Natural range <>) of aliased GLubyte
        with Convention => C;

    GL_FALSE : constant := 0;
    GL_TRUE  : constant := 1;


    GL_LINES      : constant GLenum := 16#0001#;
    GL_LINE_LOOP  : constant GLenum := 16#0002#;
    GL_LINE_STRIP : constant GLenum := 16#0003#;
    GL_TRIANGLES  : constant GLenum := 16#0004#;
    GL_QUADS      : constant GLenum := 16#0007#;
    GL_POLYGON    : constant GLenum := 16#0009#;

    GL_DEPTH_BUFFER_BIT : constant GLbitfield := 16#0000_0100#;
    GL_COLOR_BUFFER_BIT : constant GLbitfield := 16#0000_4000#;

    GL_DEPTH_TEST : constant GLenum := 16#0B71#;
    GL_BLEND      : constant GLenum := 16#0BE2#;
    GL_LIGHTING   : constant GLenum := 16#0B50#;
    GL_CULL_FACE  : constant GLenum := 16#0B44#;
    GL_NORMALIZE  : constant GLenum := 16#0BA1#;
    GL_LIGHT0     : constant GLenum := 16#4000#;

    GL_COLOR_MATERIAL : constant GLenum := 16#0B57#;

    GL_FRONT          : constant GLenum := 16#0404#;
    GL_BACK           : constant GLenum := 16#0405#;
    GL_FRONT_AND_BACK : constant GLenum := 16#0408#;

    GL_LEQUAL : constant GLenum := 16#0203#;

    GL_AMBIENT             : constant GLenum := 16#1200#;
    GL_DIFFUSE             : constant GLenum := 16#1201#;
    GL_SPECULAR            : constant GLenum := 16#1202#;
    GL_POSITION            : constant GLenum := 16#1203#;
    GL_SHININESS           : constant GLenum := 16#1601#;
    GL_AMBIENT_AND_DIFFUSE : constant GLenum := 16#1602#;

    GL_LIGHT_MODEL_LOCAL_VIEWER : constant GLenum := 16#0B51#;
    GL_LIGHT_MODEL_TWO_SIDE     : constant GLenum := 16#0B52#;
    GL_LIGHT_MODEL_AMBIENT      : constant GLenum := 16#0B53#;

    GL_LIGHTING_BIT : constant GLbitfield := 16#0000_0040#;

    GL_COMPILE : constant GLenum := 16#1300#;

    GL_VIEWPORT          : constant GLenum := 16#0BA2#;
    GL_MODELVIEW_MATRIX  : constant GLenum := 16#0BA6#;
    GL_PROJECTION_MATRIX : constant GLenum := 16#0BA7#;

    GL_RENDER : constant GLenum := 16#1C00#;
    GL_SELECT : constant GLenum := 16#1C02#;

    GL_PROJECTION : constant GLenum := 16#1701#;
    GL_MODELVIEW  : constant GLenum := 16#1700#;

    GL_SRC_ALPHA           : constant GLenum := 16#0302#;
    GL_ONE_MINUS_SRC_ALPHA : constant GLenum := 16#0303#;

    GL_FLAT   : constant GLenum := 16#1D00#;
    GL_SMOOTH : constant GLenum := 16#1D01#;


    procedure glBegin (Mode : in GLenum);
    procedure glEnd;

    procedure glVertex2f (X, Y : in GLfloat);
    procedure glVertex3f (X, Y, Z : in GLfloat);
    procedure glColor3f (R, G, B : in GLfloat);
    procedure glColor3ub (R, G, B : in GLubyte);
    procedure glColor4f (R, G, B, A : in GLfloat);
    procedure glColor3ubv (V : in GLubyte_Array);
    procedure glVertex3fv (V : in GLfloat_Array);
    procedure glNormal3f (X, Y, Z : in GLfloat);
    procedure glNormal3fv (V : in GLfloat_Array);

    procedure glEnable (Cap : in GLenum);
    procedure glDisable (Cap : in GLenum);
    procedure glShadeModel (Mode : in GLenum);
    procedure glBlendFunc (S_Factor, D_Factor : in GLenum);
    procedure glCullFace (Mode : in GLenum);
    procedure glDepthFunc (Func : in GLenum);
    procedure glPushAttrib (Mask : in GLbitfield);
    procedure glPopAttrib;

    procedure glMaterialfv (Face, Name : in GLenum; Params : in GLfloat_Array);
    procedure glColorMaterial (Face, Mode : in GLenum);
    procedure glLightfv (Light, Name : in GLenum; Params : in GLfloat_Array);
    procedure glLightModelfv (Name : in GLenum; Params : in GLfloat_Array);

    procedure glNewList (List : in GLuint; Mode : in GLenum);
    procedure glEndList;
    procedure glCallList (List : in GLuint);

    procedure glGetIntegerv (Name : in GLenum; Params : out GLint_Array);
    procedure glGetFloatv (Name : in GLenum; Params : out GLfloat_Array);

    procedure glFlush;
    procedure glFinish;

    procedure glClear (Mask : in GLbitfield);
    procedure glClearColor (R, G, B, A : in GLfloat);
    procedure glClearDepth (Depth : in GLdouble);

    procedure glViewport (X, Y : in GLint; W, H : in GLsizei);
    procedure glMatrixMode (Mode : in GLenum);
    procedure glLoadIdentity;
    procedure glPushMatrix;
    procedure glPopMatrix;
    procedure glFrustum (Left, Right, Bottom, Top, Near, Far : in GLdouble);
    procedure glOrtho (Left, Right, Bottom, Top, Near, Far : in GLdouble);
    procedure glTranslatef (X, Y, Z : in GLfloat);
    procedure glRotatef (Angle, X, Y, Z : in GLfloat);
    procedure glScalef (X, Y, Z : in GLfloat);
    procedure glMultMatrixf (M : in GLfloat_Array);

    --  GL keeps Buffer, and writes the hits there until the next
    --  glRenderMode:  it must stay where it is until then.
    procedure glSelectBuffer (Size : in GLsizei; Buffer : in out GLuint_Array);
    function glRenderMode (Mode : in GLenum) return GLint;
    procedure glInitNames;
    procedure glLoadName (Name : in GLuint);
    procedure glPushName (Name : in GLuint);


private


    pragma Import (C, glBegin, "glBegin");
    pragma Import (C, glEnd, "glEnd");
    pragma Import (C, glVertex2f, "glVertex2f");
    pragma Import (C, glVertex3f, "glVertex3f");
    pragma Import (C, glColor3f, "glColor3f");
    pragma Import (C, glColor3ub, "glColor3ub");
    pragma Import (C, glColor4f, "glColor4f");
    pragma Import (C, glEnable, "glEnable");
    pragma Import (C, glDisable, "glDisable");
    pragma Import (C, glShadeModel, "glShadeModel");
    pragma Import (C, glBlendFunc, "glBlendFunc");
    pragma Import (C, glClear, "glClear");
    pragma Import (C, glClearColor, "glClearColor");
    pragma Import (C, glViewport, "glViewport");
    pragma Import (C, glMatrixMode, "glMatrixMode");
    pragma Import (C, glLoadIdentity, "glLoadIdentity");
    pragma Import (C, glPushMatrix, "glPushMatrix");
    pragma Import (C, glPopMatrix, "glPopMatrix");
    pragma Import (C, glFrustum, "glFrustum");
    pragma Import (C, glOrtho, "glOrtho");
    pragma Import (C, glTranslatef, "glTranslatef");
    pragma Import (C, glRotatef, "glRotatef");
    pragma Import (C, glScalef, "glScalef");
    pragma Import (C, glColor3ubv, "glColor3ubv");
    pragma Import (C, glVertex3fv, "glVertex3fv");
    pragma Import (C, glNormal3f, "glNormal3f");
    pragma Import (C, glNormal3fv, "glNormal3fv");
    pragma Import (C, glCullFace, "glCullFace");
    pragma Import (C, glDepthFunc, "glDepthFunc");
    pragma Import (C, glPushAttrib, "glPushAttrib");
    pragma Import (C, glPopAttrib, "glPopAttrib");
    pragma Import (C, glMaterialfv, "glMaterialfv");
    pragma Import (C, glColorMaterial, "glColorMaterial");
    pragma Import (C, glLightfv, "glLightfv");
    pragma Import (C, glLightModelfv, "glLightModelfv");
    pragma Import (C, glNewList, "glNewList");
    pragma Import (C, glEndList, "glEndList");
    pragma Import (C, glCallList, "glCallList");
    pragma Import (C, glGetIntegerv, "glGetIntegerv");
    pragma Import (C, glGetFloatv, "glGetFloatv");
    pragma Import (C, glFlush, "glFlush");
    pragma Import (C, glFinish, "glFinish");
    pragma Import (C, glClearDepth, "glClearDepth");
    pragma Import (C, glMultMatrixf, "glMultMatrixf");
    pragma Import (C, glSelectBuffer, "glSelectBuffer");
    pragma Import (C, glRenderMode, "glRenderMode");
    pragma Import (C, glInitNames, "glInitNames");
    pragma Import (C, glLoadName, "glLoadName");
    pragma Import (C, glPushName, "glPushName");


end GL1;

