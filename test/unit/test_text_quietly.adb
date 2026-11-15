--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Text_Buffer's Set_Entire_Text_Quietly (PLAN.md, Phase 30):  the
--  buffer's own callbacks aren't called, a display given the buffer is
--  still told, and the callbacks are as they were after.  After pofltk's
--  TestText.Mod.


with

    Checks,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays;

use

    Checks;


procedure Test_Text_Quietly is

    package TB renames FLTK.Text_Buffers;
    package TD renames FLTK.Widgets.Groups.Text_Displays;

    Modified, Predeleted, Detailed : Natural := 0;

    procedure Count_Modify
           (Action       : in TB.Modification;
            Place        : in TB.Position;
            Length       : in Natural;
            Deleted_Text : in String) is
    begin
        Modified := Modified + 1;
    end Count_Modify;

    procedure Count_Predelete
           (Place  : in TB.Position;
            Length : in Natural) is
    begin
        Predeleted := Predeleted + 1;
    end Count_Predelete;

    procedure Count_Details
           (Place        : in TB.Position;
            Inserted     : in Natural;
            Deleted      : in Natural;
            Restyled     : in Natural;
            Deleted_Text : in String) is
    begin
        Detailed := Detailed + 1;
    end Count_Details;

    procedure Reset is
    begin
        Modified := 0;
        Predeleted := 0;
        Detailed := 0;
    end Reset;

    Buffer  : TB.Text_Buffer := TB.Forge.Create;
    Display : TD.Text_Display := TD.Forge.Create (0, 0, 200, 100);

begin

    Buffer.Add_Modify_Callback (Count_Modify'Unrestricted_Access);
    Buffer.Add_Predelete_Callback (Count_Predelete'Unrestricted_Access);
    Buffer.Add_Modify_Details_Callback (Count_Details'Unrestricted_Access);
    Display.Set_Buffer (Buffer);

    Buffer.Set_Entire_Text ("hello world");
    Check (Modified > 0 and Detailed > 0,
        "Set_Entire_Text calls the callbacks:" & Modified'Image & Detailed'Image);

    Display.Set_Insert_Position (11);
    Reset;
    Buffer.Set_Entire_Text_Quietly ("ab");
    Check (Buffer.Get_Entire_Text = "ab", "Set_Entire_Text_Quietly sets the text");
    Check (Modified = 0 and Predeleted = 0 and Detailed = 0,
        "and calls none of the callbacks:" & Modified'Image & Predeleted'Image & Detailed'Image);
    Check (Display.Get_Insert_Position <= 2,
        "but the display is told:  its cursor is in the new text:" &
        Display.Get_Insert_Position'Image);

    Buffer.Append_Text ("c");
    Check (Modified = 1 and Detailed = 1,
        "the callbacks are called again after:" & Modified'Image & Detailed'Image);

    Buffer.Disable_Callbacks;
    Buffer.Set_Entire_Text_Quietly ("xyz");
    Reset;
    Buffer.Append_Text ("!");
    Check (Modified = 0 and Detailed = 0,
        "callbacks disabled before stay disabled after:" & Modified'Image);
    Buffer.Enable_Callbacks;
    Buffer.Append_Text ("?");
    Check (Modified = 1 and Buffer.Get_Entire_Text = "xyz!?", "and enable as before");

    Summary;

end Test_Text_Quietly;
