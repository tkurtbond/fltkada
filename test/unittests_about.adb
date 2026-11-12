--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Groups.Help_Views;


package body Unittests_About is


    package HV renames FLTK.Widgets.Groups.Help_Views;

    use Unittests_Common;


    type Help_View_Access is access HV.Help_View;


    function Create
        return Widget_Access
    is
        View : constant Help_View_Access := new HV.Help_View'
           (HV.Forge.Create (Test_Area_X, Test_Area_Y, Test_Area_W, Test_Area_H));
    begin
        View.Set_Content
           ("<htmL><body><h2>About Unit Testing...</h2>" & ASCII.LF &
            "The Unit Testing application can be used to verify correct graphics rendering " &
            "on the current platform. The core developer team uses this program to make " &
            "sure that the FLTK user experience is identical on all supported graphics " &
            "systems.<h3>The UI Designer</h3>" & ASCII.LF &
            "<p>Designing a good user interface is an art. Widgets must be selected and " &
            "carefully positioned to create a consistent look and feel for the user. Text " &
            "must fit into given boxes and graphic elements must be correctly aligned. A " &
            "good UI library will give consistent results on any supported platform and " &
            "render all graphics in the way the UI designer intended.</p>" & ASCII.LF &
            "<p>FLTK supports a large collection of platforms and graphics drivers. This " &
            "unit testing application contains modules which will test rendering and " &
            "alignment for most FLTK core graphics functions.</p>" & ASCII.LF &
            "<h3>The Developer</h3>" & ASCII.LF &
            "<p>Unittest is also a great help when implementing new graphics drivers. The " &
            "tests are sorted in the same order in which a new graphics driver could be " &
            "implemented. Most tests rely on the previous test to function correctly, so " &
            "sticking to the given order is a good idea.</p>" & ASCII.LF & "<h3>Conventions</h3>" &
            ASCII.LF &
            "<p>Two layers of graphics are drawn for most tests. The lower layer contains " &
            "red and green pixels. The upper layer contains black pixels. The test is " &
            "rendered correctly if all red pixels are covered, but none of the green " &
            "pixels. The top graphics layer can be switched on and off.</p></body></html>");
        return Widget_Access (View);
    end Create;


end Unittests_About;
