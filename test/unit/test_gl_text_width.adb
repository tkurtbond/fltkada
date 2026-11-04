


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 134: gl_draw makes a texture as wide as its
--  text (gl_texture_fifo::compute_texture, gl_draw.cxx), and text that
--  measures 0 wide, such as a line feed or a zero-width space, crashes in
--  making an Fl_Image_Surface 0 wide.  Each Draw_Text is given such text in
--  a GL window's Draw; before the fix the test dies there.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw.OpenGL,
    FLTK.Widgets.Groups.Windows.OpenGL;

use

    Checks,
    FLTK;


procedure Test_GL_Text_Width is

    package GLD renames FLTK.Draw.OpenGL;
    package GL  renames FLTK.Widgets.Groups.Windows.OpenGL;

    Line_Feed : constant String := (1 => ASCII.LF);
    Return_C  : constant String := (1 => ASCII.CR);
    Zero_Wide : constant String :=
        Character'Val (16#E2#) & Character'Val (16#80#) & Character'Val (16#8B#);
    Soft_Dash : constant String := Character'Val (16#C2#) & Character'Val (16#AD#);

    type Text_Access is access constant String;

    type Case_Index is range 1 .. 4;
    Texts : constant array (Case_Index) of Text_Access :=
       (new String'(Line_Feed), new String'(Return_C),
        new String'(Zero_Wide), new String'(Soft_Dash));
    Names : constant array (Case_Index) of Text_Access :=
       (new String'("a line feed"), new String'("a carriage return"),
        new String'("a zero-width space"), new String'("a soft hyphen"));

    Widths    : array (Case_Index) of Long_Float := (others => -1.0);
    Plain     : Long_Float := 0.0;
    Steps     : Natural := 0;
    Draws     : Natural := 0;
    Raised    : Text_Access := null;

    type Text_Window is new GL.GL_Window with null record;

    overriding procedure Draw
           (This : in out Text_Window);

    overriding procedure Draw
           (This : in out Text_Window) is
    begin
        Draws := Draws + 1;
        if Draws > 1 then
            return;
        end if;
        --  Without Ortho the raster positions below are outside the view,
        --  and FLTK draws no text there (gl_draw.cxx:516).
        This.Ortho;
        GLD.Set_Font (FLTK.Helvetica, 14);
        Plain := GLD.Width ("gl");
        GLD.Draw_Text (5, 5, "gl");
        for C in Case_Index loop
            Widths (C) := GLD.Width (Texts (C).all);
            GLD.Draw_Text (Texts (C).all);
            Steps := Steps + 1;
            GLD.Draw_Text (5, 20, Texts (C).all);
            Steps := Steps + 1;
            GLD.Draw_Text (5.0, 30.0, Texts (C).all);
            Steps := Steps + 1;
            GLD.Draw_Text (0, 0, 200, 100, "ab" & Line_Feed & Texts (C).all & Line_Feed & "cd",
                Align_Center);
            Steps := Steps + 1;
        end loop;
        GLD.Draw_Text (0, 0, 200, 100, Line_Feed, Align_Center);
        Steps := Steps + 1;
    exception
    when Occurrence : others =>
        Raised := new String'(Ada.Exceptions.Exception_Information (Occurrence));
    end Draw;

    function Drawn return Boolean is (Draws > 0);

    Window : Text_Window :=
        (GL.Forge.Create (0, 0, 200, 100, "Test_GL_Text_Width") with null record);

begin

    Window.Show;
    for N in 1 .. 40 loop
        exit when Drawn or else FLTK.Wait (0.05) < 0.0;
    end loop;

    Check (Draws > 0, "the GL window was drawn");
    Check (Raised = null, "nothing raised: " & (if Raised = null then "" else Raised.all));
    Check (Plain > 0.0, "ordinary text has a width, so it is drawn:" & Long_Float'Image (Plain));
    for C in Case_Index loop
        Check (Widths (C) = 0.0, Names (C).all & " measures 0 wide, as in pofltk 134:"
            & Long_Float'Image (Widths (C)));
    end loop;
    Check (Steps = 4 * 4 + 1, "every Draw_Text returned:" & Natural'Image (Steps));

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GL_Text_Width;


