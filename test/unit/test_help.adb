

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestHelp: a help view's settings, position,
--  selection and text, a file that can't be read, and the help dialog.
--  Pages and images asked about through the link callback, a click on a
--  link and a broken image are test_help_links's; a link held while the
--  page changes test_help_held's; a page the callback sets itself
--  test_help_pages_load's; the dialog and the current group
--  test_help_dialog_group's.  pofltk's open and closed dialogs have no
--  counterpart, as Ada finalizes them.  Run from test/unit, which holds
--  the pages.


with

    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Checks,
    FLTK.Help_Dialogs,
    FLTK.Widgets.Groups.Help_Views,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Help is

    package HD  renames FLTK.Help_Dialogs;
    package HV  renames FLTK.Widgets.Groups.Help_Views;
    package Win renames FLTK.Widgets.Groups.Windows;
    package SU  renames Ada.Strings.Unbounded;

    use type SU.Unbounded_String;

    function Contains
           (Text, Part : in String)
        return Boolean is
    begin
        return Ada.Strings.Fixed.Index (Text, Part) > 0;
    end Contains;

    Calls : Natural := 0;

    procedure Called
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Calls := Calls + 1;
    end Called;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Help");
    View   : HV.Help_View := HV.Forge.Create (Window, 0, 0, 200, 100);

    Page : SU.Unbounded_String := SU.To_Unbounded_String ("<a name=""top"">t</a>");
    Top, At_Needle : Natural;

begin

    --  Settings.
    Check (View.Get_Content = "", "a view starts with no text");
    Check (View.Document_Title = "Untitled",
        "and FLTK's title: """ & View.Document_Title & """");
    Check (View.Current_Directory = "" and View.Current_File = "", "nor directory nor file");

    View.Set_Content ("<title>One</title><p>First <b>words</b>.</p>");
    Check (Contains (View.Get_Content, "First <b>words"), "Set_Content");
    Check (View.Document_Title = "One", "Document_Title: """ & View.Document_Title & """");
    Check (View.Get_Size > 0, "Get_Size");

    for K in 1 .. 60 loop
        SU.Append (Page, "<p>A line of text.</p>");
    end loop;
    SU.Append (Page, "<a name=""end"">here</a><p>needle</p>");
    View.Set_Content (SU.To_String (Page));
    Check (View.Get_Topline_Pixel = 0, "a page starts at its top");
    View.Set_Topline_Pixel (50);
    Check (View.Get_Topline_Pixel = 50, "Set_Topline_Pixel");
    View.Set_Topline_Target ("end");
    Top := View.Get_Topline_Pixel;
    Check (Top > 50, "Set_Topline_Target:" & Natural'Image (Top));
    View.Set_Topline_Target ("nothing");
    Check (View.Get_Topline_Pixel = Top, "a target not there moves nothing");
    View.Set_Topline_Pixel (0);
    At_Needle := View.Find ("NEEDLE");
    Check (At_Needle > 1 and View.Get_Topline_Pixel > 0,
        "Find ignores case and scrolls:" & Natural'Image (At_Needle));
    Check (View.Find ("needle", At_Needle + 1) = HV.No_Position,
        "and goes from where it is told");
    Check (View.Find ("no such text") = HV.No_Position, "Find of nothing there");
    View.Set_Leftline_Pixel (0);
    Check (View.Get_Leftline_Pixel = 0, "Set_Leftline_Pixel");

    View.Set_Text_Color (Blue_Color);
    Check (View.Get_Text_Color = Blue_Color, "Set_Text_Color");
    View.Set_Text_Font (Courier);
    Check (View.Get_Text_Font = Courier, "Set_Text_Font");
    View.Set_Text_Size (18);
    Check (View.Get_Text_Size = 18, "Set_Text_Size");
    View.Set_Scrollbar_Size (12);
    Check (View.Get_Scrollbar_Size = 12, "Set_Scrollbar_Size");

    --  Selection.
    Check (not View.Has_Selection and not View.Copy, "nothing selected, nothing copied");
    View.Select_All;
    Check (View.Has_Selection, "Select_All");
    Check (View.Copy (HV.Selection_Buffer) and View.Copy, "Copy of the selection");
    View.Clear_Selection;
    Check (not View.Has_Selection, "Clear_Selection");

    --  The callback.
    View.Set_Callback (Called'Unrestricted_Access);
    View.Set_Topline_Pixel (10);
    Check (Calls > 0, "scrolling calls back");
    View.Set_Content ("");
    Check (View.Get_Content = "", "Set_Content of nothing");

    --  Files.
    View.Load ("help_one.html");
    Check (View.Current_File = "help_one.html" and View.Document_Title = "Help One",
        "Load: Current_File and the title: " & View.Current_File);
    Check (View.Current_Directory = "", "a name without a directory leaves none");
    View.Load ("../unit/help_two.html");
    Check (View.Current_Directory = "../unit" and View.Current_File = "../unit/help_two.html",
        "Current_Directory is the name's: " & View.Current_Directory);
    begin
        View.Load ("no-such-file.html");
        Check (False, "a file that can't be read raises Load_Help_Error");
    exception
    when HV.Load_Help_Error =>
        Check (Contains (View.Get_Content, "no-such-file"),
            "a file that can't be read raises Load_Help_Error, and shows FLTK's message");
    end;

    --  The dialog.
    declare
        Dialog : HD.Help_Dialog := HD.Forge.Create;
    begin
        Check (not Dialog.Is_Visible, "a help dialog starts hidden");
        Dialog.Load ("help_one.html");
        Check (Contains (Dialog.Get_Content, "findme"), "Load, and Get_Content");
        Dialog.Set_Topline_Number (1);
        Dialog.Set_Topline_Target ("nothing");
        Dialog.Load ("no-such-file.html");
        Check (Contains (Dialog.Get_Content, "no-such-file"),
            "a file that can't be read shows FLTK's message");
        Dialog.Set_Content ("<p>In the dialog</p>");
        Check (Contains (Dialog.Get_Content, "In the dialog"), "Set_Content");
        Dialog.Set_Text_Size (16);
        Check (Dialog.Get_Text_Size = 16, "Set_Text_Size");
        Dialog.Reposition (10, 20);
        Check (Dialog.Get_X = 10 and Dialog.Get_Y = 20, "Reposition");
        Dialog.Resize (5, 6, 400, 300);
        Check (Dialog.Get_X = 5 and Dialog.Get_Y = 6 and Dialog.Get_W = 400
                and Dialog.Get_H = 300,
            "Resize");
        Dialog.Show;
        Check (Dialog.Is_Visible, "Show");
        FLTK.Check;
        Dialog.Hide;
        Check (not Dialog.Is_Visible, "Hide");
    end;

    Summary;

end Test_Help;
