


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  N10 in PLAN.md and pofltk 34: a Text_Buffer let go while a display still
--  holds it.  The C++ buffer is reference counted, so it lives on in the
--  display, but the modify and predelete callbacks the Ada buffer gave it
--  carry the Ada record's address, and FLTK went on calling them with it.
--  The buffer here is on the heap, so valgrind sees the freed record.


with

    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays;

use

    Checks,
    FLTK;


procedure Test_Buffer_Life is

    package TB renames FLTK.Text_Buffers;
    package TD renames FLTK.Widgets.Groups.Text_Displays;

    type Buffer_Access is access TB.Text_Buffer;

    procedure Free is new Ada.Unchecked_Deallocation (TB.Text_Buffer, Buffer_Access);

    Modified  : Natural := 0;
    Predelete : Natural := 0;

    procedure Count_Modify
           (Action       : in TB.Modification;
            Place        : in TB.Position;
            Length       : in Natural;
            Deleted_Text : in String)
    is
        pragma Unreferenced (Action, Place, Length, Deleted_Text);
    begin
        Modified := Modified + 1;
    end Count_Modify;

    procedure Count_Predelete
           (Place  : in TB.Position;
            Length : in Natural)
    is
        pragma Unreferenced (Place, Length);
    begin
        Predelete := Predelete + 1;
    end Count_Predelete;

    Display : TD.Text_Display := TD.Forge.Create (0, 0, 200, 100);

    Buffer : Buffer_Access := new TB.Text_Buffer'(TB.Forge.Create);

begin

    Buffer.Add_Modify_Callback (Count_Modify'Unrestricted_Access);
    Buffer.Add_Predelete_Callback (Count_Predelete'Unrestricted_Access);
    Display.Set_Buffer (Buffer.all);

    Display.Insert_Text ("hello");
    Display.Set_Insert_Position (0);
    Display.Overstrike ("J");
    Check (Buffer.Get_Entire_Text = "Jello",
        "the display edits the buffer: """ & Buffer.Get_Entire_Text & """");
    Check (Modified = 2, "the buffer's modify callback ran:" & Natural'Image (Modified));
    --  Fl_Text_Buffer::insert calls the predelete callbacks too, with 0
    --  deleted (Fl_Text_Buffer.cxx:398-399).
    Check (Predelete = 2, "the buffer's predelete callback ran:" & Natural'Image (Predelete));

    --  The Ada buffer goes; the display keeps the C++ one.
    Free (Buffer);

    Display.Insert_Text ("more");
    Display.Set_Insert_Position (0);
    Display.Overstrike ("Y");
    Check (Display.Get_Insert_Position = 1,
        "the display still edits its buffer:" & Natural'Image (Display.Get_Insert_Position));
    Check (Modified = 2 and Predelete = 2,
        "the freed buffer's callbacks don't run:" & Natural'Image (Modified)
        & Natural'Image (Predelete));

    Summary;

end Test_Buffer_Life;


