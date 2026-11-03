


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  N4 in PLAN.md and pofltk 90: a Help_View's link callback.  FLTK asks the
--  same link function what to load and where each image is, and asks about
--  the images again as it frees a page (Fl_Help_View.cxx:2788-2799, 3368,
--  3407).  The binding kept one answer and freed it at each question, so
--  load() opened a name freed while free_data() asked about the old page's
--  images.  And an image refused with "" was passed to FLTK as NULL, which
--  format() uses unchecked.  Run from test/unit, which holds the pages.


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Groups.Help_Views,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Help_Links is

    package Prb renames FLTK.Probe;
    package HV  renames FLTK.Widgets.Groups.Help_Views;
    package Win renames FLTK.Widgets.Groups.Windows;

    function Contains
           (Text, Part : in String)
        return Boolean is
    begin
        for I in Text'First .. Text'Last - Part'Length + 1 loop
            if Text (I .. I + Part'Length - 1) = Part then
                return True;
            end if;
        end loop;
        return False;
    end Contains;

    function Ends_With
           (Text, Part : in String)
        return Boolean is
    begin
        return Text'Length >= Part'Length
            and then Text (Text'Last - Part'Length + 1 .. Text'Last) = Part;
    end Ends_With;

    Image_Asks : Natural := 0;
    Page_Asks  : Natural := 0;
    Raised     : Boolean := False;

    --  Answers each image with a name as long as "help_two.html", which
    --  the old hook's freed answer was likely to be replaced by.  Refuses
    --  "refused" pages and images.
    function Link
           (Item : in out HV.Help_View'Class;
            URI  : in     String)
        return String
    is
        pragma Unreferenced (Item);
    begin
        if Contains (URI, "refused") then
            return "";
        elsif Ends_With (URI, ".png") then
            Image_Asks := Image_Asks + 1;
            return "no_image1.png";
        else
            Page_Asks := Page_Asks + 1;
            return URI;
        end if;
    end Link;

    --  Sets the page while asked about an image, which must raise.
    function Meddle
           (Item : in out HV.Help_View'Class;
            URI  : in     String)
        return String
    is
        pragma Unreferenced (URI);
    begin
        Item.Set_Content ("<p>No</p>");
        return "";
    exception
    when Program_Error =>
        Raised := True;
        return "";
    end Meddle;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Help_Links");

    View : HV.Help_View := HV.Forge.Create (Window, 0, 0, 300, 200);

    Ignore : Boolean;

    procedure Load
           (Name, What : in String) is
    begin
        View.Load (Name);
        Check (True, What);
    exception
    when HV.Load_Help_Error =>
        Check (False, What & ": Load_Help_Error, title """ & View.Document_Title & """");
    end Load;

begin

    View.Set_Link_Callback (Link'Unrestricted_Access);

    Load ("help_one.html", "Load");
    Check (View.Document_Title = "Help One", "its title: """ & View.Document_Title & """");
    Check (Page_Asks = 1, "the page is asked about once:" & Natural'Image (Page_Asks));
    Check (Image_Asks = 2, "each image is asked about:" & Natural'Image (Image_Asks));
    Ignore := Prb.Capture (View);
    Ignore := Prb.Capture (View);
    Prb.Release;
    Check (Image_Asks = 2, "and not asked again to draw:" & Natural'Image (Image_Asks));

    --  N4: free_data() asks about help_one's images before help_two is read.
    Load ("help_two.html", "Load of another page after one with images");
    Check (View.Document_Title = "Help Two", "its title: """ & View.Document_Title & """");
    Load ("help_one.html", "Load of the first page again");
    Check (Image_Asks = 2, "its images aren't asked about again:" & Natural'Image (Image_Asks));

    begin
        View.Load ("refused.html");
        Check (False, "a refused page raises Load_Help_Error");
    exception
    when HV.Load_Help_Error =>
        Check (View.Document_Title = "Help One", "a refused page leaves the page");
    end;

    --  Issue 90: a refused image is FLTK's broken image, not a crash.
    View.Set_Content ("<p>A refused image: <img src=""refused.png""></p>");
    Check (Prb.Capture (View), "a page with a refused image draws");
    Prb.Release;

    --  A click on a link loads it, by the handle path.
    View.Set_Content ("<p><a href=""help_two.html"">Two</a></p><p>And more.</p>");
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;
    declare
        Before : constant Natural := Page_Asks;
        Y      : Natural := 3;
    begin
        while Y < 40 and Page_Asks = Before loop
            Ignore := Prb.Mouse (Window, Push, 15, Y);
            Ignore := Prb.Mouse (Window, Release, 15, Y, Clicks => 1);
            Y := Y + 3;
        end loop;
        Check (Page_Asks = Before + 1, "a click on a link asks about it once");
    end;
    Check (View.Document_Title = "Help Two", "and loads it: """ & View.Document_Title & """");
    Window.Hide;

    --  The page set while asked about an image.
    declare
        Other : HV.Help_View := HV.Forge.Create (0, 0, 100, 100);
    begin
        Other.Set_Link_Callback (Meddle'Unrestricted_Access);
        Other.Set_Content ("<p><img src=""a.png""></p>");
        Check (Raised, "Set_Content asked about an image raises Program_Error");
    end;

    Summary;

end Test_Help_Links;


