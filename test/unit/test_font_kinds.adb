

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 33 (FLTKAda-BUGS.md): Set_Font_Kind and the font names FLTK keeps.
--  Fl::set_font keeps the name pointer, and compares the next name with the
--  one it holds (Fl_Cairo_Graphics_Driver.cxx:1158).  Copying one kind to
--  another shares the source's pointer (fl_set_font.cxx:71).  So the binding
--  must free an old name only after FLTK has let go of it, and give a copied
--  kind its own name.  After each change the heap is scribbled over with
--  same-sized strings, so a freed name FLTK still reads comes back as 'X's.


with

    Checks,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows,
    Interfaces.C.Strings;

use

    Checks,
    FLTK;


procedure Test_Font_Kinds is

    package Win renames FLTK.Widgets.Groups.Windows;
    package Bx  renames FLTK.Widgets.Boxes;
    package ICS renames Interfaces.C.Strings;

    Serial : Natural := 0;

    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

    function Expected
           (Base : in String)
        return String is
    begin
        return Base & Integer'Image (Serial);
    end Expected;

    Junk : array (1 .. 64) of ICS.chars_ptr := (others => ICS.Null_Ptr);

    --  Takes back any freed block of Length + 1 bytes and fills it with 'X's.
    procedure Scribble
           (Length : in Positive) is
    begin
        for J of Junk loop
            ICS.Free (J);
            J := ICS.New_String ((1 .. Length => 'X'));
        end loop;
    end Scribble;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 100, "Test_Font_Kinds");

    Times_Box : Bx.Box := Bx.Forge.Create (Window, Flat_Box, 10, 10, 280, 30, "Times");

    Copy_Box : Bx.Box := Bx.Forge.Create (Window, Flat_Box, 10, 50, 280, 30, "Copy");

begin

    Times_Box.Set_Label_Font (Times);
    Copy_Box.Set_Label_Font (Times_Bold);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump (5);


    --  Replacing a name: FLTK compares the new name with the old one.
    FLTK.Static.Set_Font_Kind (Times, Fresh ("Sans"));
    declare
        First : constant String := Expected ("Sans");
    begin
        FLTK.Static.Set_Font_Kind (Times, Fresh ("Serif"));
        Scribble (First'Length);
    end;
    Check (FLTK.Static.Font_Image (Times) = Expected ("Serif"),
        "a replaced font name stands: " & FLTK.Static.Font_Image (Times));
    Times_Box.Redraw;
    Pump (5);

    --  Setting the same name again.
    FLTK.Static.Set_Font_Kind (Times, Expected ("Serif"));
    Scribble (Expected ("Serif")'Length);
    Check (FLTK.Static.Font_Image (Times) = Expected ("Serif"),
        "setting the same font name again keeps it: " & FLTK.Static.Font_Image (Times));


    --  Copying one kind to another, then changing the source.
    FLTK.Static.Set_Font_Kind (Courier, Fresh ("Monospace"));
    declare
        Shared : constant String := Expected ("Monospace");
    begin
        FLTK.Static.Set_Font_Kind (Times_Bold, Courier);
        FLTK.Static.Set_Font_Kind (Courier, Fresh ("Mono"));
        Scribble (Shared'Length);
        Check (FLTK.Static.Font_Image (Times_Bold) = Shared,
            "a copied font kind keeps its name after the source changes: "
            & FLTK.Static.Font_Image (Times_Bold));
    end;
    Check (FLTK.Static.Font_Image (Courier) = Expected ("Mono"),
        "the source kind has its new name: " & FLTK.Static.Font_Image (Courier));
    Copy_Box.Redraw;
    Pump (5);

    --  Copying a kind onto itself.
    FLTK.Static.Set_Font_Kind (Courier, Courier);
    Scribble (Expected ("Mono")'Length);
    Check (FLTK.Static.Font_Image (Courier) = Expected ("Mono"),
        "copying a font kind onto itself keeps its name: " & FLTK.Static.Font_Image (Courier));

    Window.Hide;
    for J of Junk loop
        ICS.Free (J);
    end loop;
    Summary;

end Test_Font_Kinds;

