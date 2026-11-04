

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 36: with Match_Case, Fl_Text_Buffer's
--  search_forward and search_backward compare the needle with
--  memcmp (sp, address (bp), l) and never check bp against the length
--  (Fl_Text_Buffer.cxx:1312, 1364).  A string not in the buffer, or found
--  only near its end, is compared with bytes past the text.  The buffer is
--  built so that its gap is near the start and the text runs to the end of
--  its allocation, so valgrind sees the reads.


with

    Ada.Characters.Latin_1,
    Ada.Exceptions,
    Checks,
    FLTK.Text_Buffers;

use

    Checks,
    FLTK.Text_Buffers;


procedure Test_Text_Search is

    LF : constant Character := Ada.Characters.Latin_1.LF;

    --  "first line", "second LINE", "third": LINE at 18, third at 23.
    Text : constant String := "first line" & LF & "second LINE" & LF & "third";

    Buffer : Text_Buffer := Forge.Create (0, 16);

    Place : Position := 0;

    function Forward
           (Start : in Position;
            Item  : in String;
            Exact : in Boolean := True)
        return Boolean is
    begin
        return Buffer.Search_Forward (Start, Item, Place, Exact);
    end Forward;

    function Backward
           (Start : in Position;
            Item  : in String;
            Exact : in Boolean := True)
        return Boolean is
    begin
        return Buffer.Search_Backward (Start, Item, Place, Exact);
    end Backward;

    --  The message is made here, after the search, since a Check's message
    --  may be evaluated before its condition.
    procedure Finds
           (Found : in Boolean;
            Want  : in Position;
            Name  : in String) is
    begin
        Check (Found and then Place = Want, Name & ":" & Boolean'Image (Found)
            & Integer'Image (Place));
    end Finds;

begin

    --  The gap goes after the first character, and the rest of the text
    --  runs to the end of the buffer's memory.
    Buffer.Append_Text (Text (Text'First + 1 .. Text'Last));
    Buffer.Insert_Text (0, Text (Text'First .. Text'First));
    Check (Buffer.Length = 28, "the buffer's length:" & Natural'Image (Buffer.Length));

    Finds (Forward (0, "LINE", False), 6, "not matching case");
    Finds (Forward (0, "LINE"), 18, "matching case");
    Finds (Forward (0, "line"), 6, "matching case, lower");
    Finds (Backward (Buffer.Length, "r"), 26, "backward from the end");
    Finds (Forward (0, "third"), 23, "found at the end");
    Check (not Forward (24, "third"), "not found past its start");
    Finds (Backward (Buffer.Length, "third"), 23, "backward, found at the end");
    Finds (Backward (99, "first"), 0, "backward from past the end");
    Check (not Forward (0, "thirdd"), "a string running past the end");
    Check (not Forward (0, "absent"), "a string not in the buffer");
    Check (not Backward (Buffer.Length, "dz"), "backward, a string running past the end");
    Check (not Backward (Buffer.Length, "absent"), "backward, a string not in the buffer");
    Check (not Forward (99, "first"), "forward from past the end");
    Finds (Forward (3, ""), 3, "an empty string, forward");
    Finds (Backward (5, ""), 5, "an empty string, backward");
    Check (not Forward (Buffer.Length, ""), "an empty string, forward from the end");

    --  Not matching case, the same searches.
    Finds (Forward (0, "THIRD", False), 23, "not matching case, at the end");
    Check (not Forward (0, "thirdd", False), "not matching case, running past the end");
    Finds (Backward (Buffer.Length, "FIRST", False), 0, "not matching case, backward");

    --  FLTK-issues.md F6: from past the end, FLTK's search_backward never
    --  ended, matching case or not.
    Finds (Backward (99, "THIRD", False), 23, "not matching case, backward from past the end");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Text_Search;


