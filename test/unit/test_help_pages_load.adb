--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 102:  a link callback can answer a page itself, by
--  setting the view's content and refusing the name.  Fl_Help_View::load
--  returns -1 for the refusal (Fl_Help_View.cxx:3411-3412), so Load raised
--  Load_Help_Error though the page was shown.  Load succeeds when the
--  callback set the content, by Set_Content or by a Load of its own, and
--  raises for a refusal that set nothing.  Run from test/unit, which holds
--  the pages.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Groups.Help_Views;

use

    Checks;


procedure Test_Help_Pages_Load is

    package HV renames FLTK.Widgets.Groups.Help_Views;

    function Link
           (Item : in out HV.Help_View'Class;
            URI  : in     String)
        return String is
    begin
        if URI = "page:a" then
            Item.Set_Content ("<head><title>Page A</title></head><p>A</p>");
            return "";
        elsif URI = "page:file" then
            Item.Load ("help_two.html");
            return "";
        elsif URI = "refused.html" then
            return "";
        else
            return URI;
        end if;
    end Link;

    View : HV.Help_View := HV.Forge.Create (0, 0, 300, 200);

    procedure Loads
           (Name, Title, What : in String) is
    begin
        View.Load (Name);
        Check (View.Document_Title = Title, What & ": """ & View.Document_Title & """");
    exception
    when HV.Load_Help_Error =>
        Check (False, What & ": Load_Help_Error, title """ & View.Document_Title & """");
    end Loads;

    procedure Refuses
           (Title, What : in String) is
    begin
        View.Load ("refused.html");
        Check (False, What & ": no Load_Help_Error");
    exception
    when HV.Load_Help_Error =>
        Check (View.Document_Title = Title, What & ": """ & View.Document_Title & """");
    end Refuses;

begin

    View.Set_Link_Callback (Link'Unrestricted_Access);

    Loads ("help_one.html", "Help One", "a file loads");
    Refuses ("Help One", "a refusal raises and leaves the page");
    Loads ("page:a", "Page A", "a page the callback set loads");
    Refuses ("Page A", "a refusal after it still raises");
    Loads ("page:file", "Help Two", "a page the callback loaded loads");
    Refuses ("Help Two", "and a refusal after that still raises");
    View.Set_Content ("<head><title>Set</title></head><p>Set</p>");
    Refuses ("Set", "a refusal after Set_Content outside the callback raises");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Help_Pages_Load;
