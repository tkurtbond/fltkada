

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A help view whose pages are in the program, kept and followed by its
--  link callback, after pofltk's examples/HelpPages.Mod.
--
--  A link's address needn't be a file:  the link callback answers those
--  starting "page:" by setting the view's content, and lets the others
--  load.  An address with a colon reaches the callback as it is written;
--  one without comes joined to the page's directory.  The file it links to
--  is help_dialog.html, in the current directory, as make runs it from
--  test/.  Back goes back through every page followed.


with

    Ada.Containers.Indefinite_Vectors,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    FLTK.Images.Shared,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Help_Views,
    FLTK.Widgets.Groups.Windows;


function Help_Pages
    return Integer
is


    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Hlp renames FLTK.Widgets.Groups.Help_Views;
    package Win renames FLTK.Widgets.Groups.Windows;

    package String_Vectors is new Ada.Containers.Indefinite_Vectors (Positive, String);

    use Ada.Strings.Unbounded;


    Home : constant String := "page:home";

    Window : Win.Window := Win.Forge.Create (420, 300, "Help Pages");
    Title  : Bx.Box := Bx.Forge.Create (Window, 10, 10, 220, 25);
    Back   : Btn.Button := Btn.Forge.Create (Window, 240, 10, 80, 25, "Back");
    Quit   : Btn.Button := Btn.Forge.Create (Window, 330, 10, 80, 25, "Quit");
    View   : Hlp.Help_View := Hlp.Forge.Create (Window, 10, 45, 400, 245);

    --  The pages followed, newest last.
    History : String_Vectors.Vector;

    --  The page shown, or "" while Back goes to one.
    Current : Unbounded_String;


    --  The program's page at URI, or "" if it has none.
    function Page
           (URI : in String)
        return String is
    begin
        if URI = Home then
            return "<head><title>Home</title></head><body><h1>Pages in a Program</h1>"
                & "<p>Nothing here is in a file. See <a href=""page:views"">views</a>, "
                & "<a href=""page:links"">links</a> or "
                & "<a href=""help_dialog.html"">a file</a>.</p>";
        elsif URI = "page:views" then
            return "<head><title>Views</title></head><body><h2>Views</h2>"
                & "<p>A <b>Help_View</b> shows HTML, and has a scroll bar when it needs one.</p>"
                & "<p><a href=""page:home"">Home</a></p>";
        elsif URI = "page:links" then
            return "<head><title>Links</title></head><body><h2>Links</h2>"
                & "<p>A <b>link callback</b> is asked about each link and each image.</p>"
                & "<p><a href=""page:home"">Home</a></p>";
        else
            return "";
        end if;
    end Page;


    --  The view goes on to URI:  remembers the page it leaves.
    procedure Follow
           (URI : in String) is
    begin
        if Current /= "" then
            History.Append (To_String (Current));
        end if;
        Current := To_Unbounded_String (URI);
    end Follow;


    function Link
           (Item : in out Hlp.Help_View'Class;
            URI  : in     String)
        return String
    is
        Text : constant String := Page (URI);
    begin
        if Text /= "" then
            Follow (URI);
            Item.Set_Content (Text);
            return "";
        end if;
        --  Not an image.
        if Ada.Strings.Fixed.Index (URI, ".html") > 0 then
            Follow (URI);
        end if;
        return URI;
    end Link;


    --  The page has changed:  show its title.
    procedure View_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Title.Set_Label (View.Document_Title);
    end View_CB;


    procedure Back_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        if not History.Is_Empty then
            declare
                Last : constant String := History.Last_Element;
            begin
                History.Delete_Last;
                --  So that Follow keeps nothing.
                Current := Null_Unbounded_String;
                View.Load (Last);
            end;
        end if;
    end Back_CB;


    procedure Quit_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Window.Hide;
    end Quit_CB;


begin


    --  For the images of the file it links to.
    FLTK.Images.Shared.Register_Images;
    View.Set_Link_Callback (Link'Unrestricted_Access);
    View.Set_Callback (View_CB'Unrestricted_Access);
    Back.Set_Callback (Back_CB'Unrestricted_Access);
    Quit.Set_Callback (Quit_CB'Unrestricted_Access);
    Window.Set_Resizable (View);
    View.Load (Home);
    Window.Show;

    return FLTK.Run;


end Help_Pages;

