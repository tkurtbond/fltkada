


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  The fixed-function OpenGL calls and constants that the demo programs in
--  test/ use (cube, gl_overlay, glut_test), imported straight from libGL.
--  This is not a general OpenGL binding, which is out of FLTKAda's scope
--  (PLAN.md, Scope); examples/gl3.ads is the same for OpenGL 3.


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


    GL_LINES      : constant GLenum := 16#0001#;
    GL_LINE_LOOP  : constant GLenum := 16#0002#;
    GL_LINE_STRIP : constant GLenum := 16#0003#;
    GL_TRIANGLES  : constant GLenum := 16#0004#;
    GL_QUADS      : constant GLenum := 16#0007#;
    GL_POLYGON    : constant GLenum := 16#0009#;

    GL_DEPTH_BUFFER_BIT : constant GLbitfield := 16#0000_0100#;
    GL_COLOR_BUFFER_BIT : constant GLbitfield := 16#0000_4000#;

    GL_DEPTH_TEST : constant GLenum := 16#0B71#;
    GL_LIGHTING   : constant GLenum := 16#0B50#;

    GL_PROJECTION : constant GLenum := 16#1701#;
    GL_MODELVIEW  : constant GLenum := 16#1700#;


    procedure glBegin (Mode : in GLenum);
    procedure glEnd;

    procedure glVertex2f (X, Y : in GLfloat);
    procedure glVertex3f (X, Y, Z : in GLfloat);
    procedure glColor3f (R, G, B : in GLfloat);
    procedure glColor3ub (R, G, B : in GLubyte);

    procedure glEnable (Cap : in GLenum);
    procedure glDisable (Cap : in GLenum);

    procedure glClear (Mask : in GLbitfield);
    procedure glClearColor (R, G, B, A : in GLfloat);

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


private


    pragma Import (C, glBegin, "glBegin");
    pragma Import (C, glEnd, "glEnd");
    pragma Import (C, glVertex2f, "glVertex2f");
    pragma Import (C, glVertex3f, "glVertex3f");
    pragma Import (C, glColor3f, "glColor3f");
    pragma Import (C, glColor3ub, "glColor3ub");
    pragma Import (C, glEnable, "glEnable");
    pragma Import (C, glDisable, "glDisable");
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


end GL1;

