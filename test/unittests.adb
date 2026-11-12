--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/unittests.cxx: a browser of pages, each testing some part
--  of FLTK, mostly its drawing, by showing what the reader can check by
--  eye.  The last page runs the core tests, which "unittests --core" runs
--  without a window, giving an exit status of the number that failed.
--  "--color=0" leaves the ANSI colour sequences out of their output.


with

    Ada.Command_Line,
    Ada.Text_IO,
    FLTK.Filenames,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Windows.Double,
    Unittests_About,
    Unittests_Circles,
    Unittests_Common,
    Unittests_Complex_Shapes,
    Unittests_Core,
    Unittests_Fast_Shapes,
    Unittests_Images,
    Unittests_Points,
    Unittests_Schemes,
    Unittests_Scrollbarsize,
    Unittests_Suite,
    Unittests_Symbol,
    Unittests_Terminal,
    Unittests_Text,
    Unittests_Unicode,
    Unittests_Viewport;

use type

    FLTK.Alignment;


function Unittests
    return Integer
is

    package Hold renames FLTK.Widgets.Groups.Browsers.Textline.Hold;
    package Double renames FLTK.Widgets.Groups.Windows.Double;

    use Unittests_Common;


    type Creator is access function
        return Widget_Access;

    type String_Access is access constant String;

    type Page_Info is record
        Label  : String_Access;
        Create : Creator;
        Widget : Widget_Access;
    end record;

    Pages : array (Positive range <>) of Page_Info :=
       ((new String'("About..."), Unittests_About.Create'Access, null),
        (new String'("Drawing Points"), Unittests_Points.Create'Access, null),
        (new String'("Fast Shapes"), Unittests_Fast_Shapes.Create'Access, null),
        (new String'("Circles and Arcs"), Unittests_Circles.Create'Access, null),
        (new String'("Complex Shapes"), Unittests_Complex_Shapes.Create'Access, null),
        (new String'("Rendering Text"), Unittests_Text.Create'Access, null),
        (new String'("Unicode Boxes"), Unittests_Unicode.Create'Access, null),
        (new String'("Symbol Text"), Unittests_Symbol.Create'Access, null),
        (new String'("Drawing Images"), Unittests_Images.Create'Access, null),
        (new String'("Viewport Test"), Unittests_Viewport.Create'Access, null),
        (new String'("Scrollbar Size"), Unittests_Scrollbarsize.Create'Access, null),
        (new String'("Schemes Test"), Unittests_Schemes.Create'Access, null),
        (new String'("Terminal"), Unittests_Terminal.Create'Access, null),
        (new String'("Core Functionality"), Unittests_Core.Create'Access, null));

    type Hold_Access is access Hold.Hold_Browser;

    Browser : Hold_Access;

    Core_Only : Boolean := False;


    procedure Browser_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        for T in 1 .. Browser.Number_Of_Lines loop
            if Browser.Is_Selected (T) then
                Pages (T).Widget.Show;
            else
                Pages (T).Widget.Hide;
            end if;
        end loop;
    end Browser_CB;


    function Arg
           (Index : in Positive)
        return Natural
    is
        Text : constant String := Ada.Command_Line.Argument (Index);
    begin
        if Text = "--core" then
            Core_Only := True;
            return 1;
        elsif Text = "--color=0" then
            Unittests_Suite.Set_Color (False);
            return 1;
        elsif Text = "--color=1" then
            Unittests_Suite.Set_Color (True);
            return 1;
        end if;
        return 0;
    end Arg;


    Count : Natural;

begin

    Unittests_Core.Register;

    begin
        FLTK.Static.Parse_Args (Count, Arg'Unrestricted_Access);
    exception
        when FLTK.Static.Argument_Error =>
            declare
                Name : constant String := FLTK.Filenames.Base_Name (Ada.Command_Line.Command_Name);
                App  : constant String := (if Name = "" then "unittests" else Name);
                use Ada.Text_IO;
            begin
                Put_Line (Standard_Error, "usage: " & App & " <switches>");
                Put_Line (Standard_Error, " --core : test core functionality only");
                Put_Line (Standard_Error, " --color=1, --color=0 : print test output in color or " &
                    "plain text --help, -h : print this help page");
            end;
            return 1;
    end;

    if Core_Only then
        return Unittests_Suite.Run_All_Tests;
    end if;

    FLTK.Static.System_Colors;
    FLTK.Static.Set_System_Scheme;
    FLTK.Screen.Set_Visual_Mode (FLTK.Screen.RGB);
    FLTK.Static.Set_Use_High_Res_GL (True);

    Main_Win := new Main_Window'
       (Double.Forge.Create (Main_Window_W, Main_Window_H, "FLTK Unit Tests") with others => <>);
    Main_Win.Set_Size_Range (Main_Window_W, Main_Window_H);
    Main_Win.Begin_Current;

    Browser := new Hold.Hold_Browser'
       (Hold.Forge.Create (Browser_X, Browser_Y, Browser_W, Browser_H, "Unit Tests"));
    Browser.Set_Alignment (FLTK.Align_Top + FLTK.Align_Left);
    Browser.Set_When (FLTK.When_Changed);
    Browser.Set_Callback (Browser_CB'Unrestricted_Access);
    Browser.Set_Line_Spacing (2);

    for P of Pages loop
        P.Widget := P.Create.all;
        P.Widget.Hide;
        Browser.Add (P.Label.all);
    end loop;
    Main_Win.End_Current;

    Main_Win.Set_Resizable (Main_Win.all);
    Main_Win.Show_With_Args;
    Browser.Set_Select (Line => 1);
    Browser_CB (Browser.all);
    return FLTK.Run;

end Unittests;
