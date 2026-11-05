

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  PLAN.md Phase 12: undo and redo, in an Input and in a Text_Buffer.


with

    Checks,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text;

use

    Checks,
    FLTK;


procedure Test_Undo_Redo is

    package TB  renames FLTK.Text_Buffers;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Txt renames FLTK.Widgets.Inputs.Text;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 100, "Test_Undo_Redo");

    Input : Txt.Text_Input := Txt.Forge.Create (Window, 10, 10, 200, 30);

    Buffer : TB.Text_Buffer := TB.Forge.Create;

    Cursor : TB.Position;

begin

    --  Input.
    Input.Set_Value ("abc");
    Check (not Input.Can_Undo and not Input.Can_Redo,
        "a value set leaves nothing to undo or redo");
    Check (not Input.Redo, "Redo with nothing undone does nothing");

    Input.Set_Position (3);
    Input.Insert ("def");
    Check (Input.Get_Value = "abcdef", "Insert inserts: " & Input.Get_Value);
    Check (Input.Can_Undo and not Input.Can_Redo, "an insert can be undone");

    Check (Input.Undo, "Undo undoes");
    Check (Input.Get_Value = "abc", "Undo takes the insert out: " & Input.Get_Value);
    Check (Input.Can_Redo, "an undone insert can be redone");

    Check (Input.Redo, "Redo redoes");
    Check (Input.Get_Value = "abcdef", "Redo puts the insert back: " & Input.Get_Value);
    Check (not Input.Can_Redo, "nothing is left to redo");

    Input.Undo;
    Input.Redo;
    Check (Input.Get_Value = "abcdef", "the procedures undo and redo too: " & Input.Get_Value);

    --  Text buffer.
    Check (not Buffer.Can_Undo and not Buffer.Can_Redo, "a new buffer has nothing to undo");
    Check (not Buffer.Undo (Cursor) and Cursor = 0, "Undo with nothing done gives 0");

    Buffer.Append_Text ("hello");
    Check (Buffer.Can_Undo and not Buffer.Can_Redo, "an append can be undone");

    Buffer.Remove_Text (0, 2);
    Check (Buffer.Get_Entire_Text = "llo", "Remove_Text removes");

    Check (Buffer.Undo (Cursor), "Undo undoes the removal");
    Check (Buffer.Get_Entire_Text = "hello", "the removal is undone: " & Buffer.Get_Entire_Text);
    Check (Cursor = 2, "the cursor is after the text put back:" & Integer'Image (Cursor));
    Check (Buffer.Can_Redo, "an undone removal can be redone");

    Check (Buffer.Redo (Cursor), "Redo redoes the removal");
    Check (Buffer.Get_Entire_Text = "llo", "the removal is redone: " & Buffer.Get_Entire_Text);
    Check (Cursor = 0, "the cursor is where the text was:" & Integer'Image (Cursor));
    Check (not Buffer.Redo, "nothing is left to redo");

    Buffer.Undo;
    Check (Buffer.Get_Entire_Text = "hello", "the procedure undoes: " & Buffer.Get_Entire_Text);
    Buffer.Redo;
    Check (Buffer.Get_Entire_Text = "llo", "the procedure redoes: " & Buffer.Get_Entire_Text);

    Buffer.Can_Undo (False);
    Check (not Buffer.Can_Undo and not Buffer.Undo, "undo turned off undoes nothing");
    Check (Buffer.Get_Entire_Text = "llo", "and leaves the text alone");

    Summary;

end Test_Undo_Redo;
