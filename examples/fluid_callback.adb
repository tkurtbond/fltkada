

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/fluid-callback.fl, as Fluid writes it out
--  with 'fluid -c': a Window type with a button whose callback calls a
--  dispatching "virtual callback" that deletes the window, and a
--  Finalize standing in for the virtual destructor.
--
--  FLTKAda callbacks take no user data, so the value the original passes
--  as user data (77) is kept in a Button extension.  The original's main
--  program creates its App as a C++ temporary, which is destroyed again at
--  once, so it closes before the button can be pressed; this port
--  allocates the App instead, so it works as the .fl file's comment
--  describes.


with

    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;


function Fluid_Callback
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;


    --  Fluid's "class App": a package spec, so that Cb_Bn_Virtual dispatches
    package Apps is

        --  A button carrying a value, in place of FLTK's callback user data
        type Valued_Button is new Btn.Button with record
            Value : Integer;
        end record;

        type Valued_Button_Access is access Valued_Button;


        type App is new Win.Window with record
            Exit_CB : Valued_Button_Access;
        end record;

        type App_Access is access all App'Class;


        --  Constructor
        function Create
               (X, Y : in Integer;
                L    : in String)
            return App;

        --  Virtual destructor
        overriding procedure Finalize
               (This : in out App);

        --  Virtual callback method
        procedure Cb_Bn_Virtual
               (This : in out App;
                V    : in     Integer);

    end Apps;


    package body Apps is


        --  Static callback method
        procedure Cb_Bn_Static
               (W : in out FLTK.Widgets.Widget'Class);


        function Create
               (X, Y : in Integer;
                L    : in String)
            return App is
        begin
            return This : App := (Win.Forge.Create (X, Y, L) with Exit_CB => null) do
                --  Code in constructor
                Ada.Text_IO.Put_Line ("Creating new App");
                This.Exit_CB := new Valued_Button'
                   (Btn.Forge.Create (This, 20, 20, 260, 60, "Exit: invokes virtual callback")
                    with Value => 77);
                This.Exit_CB.Set_Callback (Cb_Bn_Static'Unrestricted_Access);
                This.Show;
            end return;
        end Create;


        overriding procedure Finalize
               (This : in out App) is
        begin
            Ada.Text_IO.Put_Line ("Closing and deleting App");
            Win.Window (This).Finalize;
        end Finalize;


        procedure Cb_Bn_Static
               (W : in out FLTK.Widgets.Widget'Class)
        is
            --  code in static callback
            I      : constant Integer := Valued_Button'Class (W).Value;
            Window : constant access FLTK.Widgets.Groups.Group'Class := W.Parent;
        begin
            Ada.Text_IO.Put_Line
               ("Executing  static callback Cb_Bn_static,  value =" & Integer'Image (I));
            App'Class (Window.all).Cb_Bn_Virtual (I);
        end Cb_Bn_Static;


        procedure Cb_Bn_Virtual
               (This : in out App;
                V    : in     Integer)
        is
            procedure Free is new Ada.Unchecked_Deallocation (App'Class, App_Access);
            --  code in virtual callback
            Self : App_Access := This'Unchecked_Access;
        begin
            Ada.Text_IO.Put_Line
               ("Executing virtual callback Cb_Bn_virtual, value =" & Integer'Image (V));
            --  note: freeing a window hides it
            Free (Self);
        end Cb_Bn_Virtual;


    end Apps;


    The_App : Apps.App_Access;
    pragma Unreferenced (The_App);


begin


    --  Main program
    The_App := new Apps.App'(Apps.Create (300, 100, "Virtual Callback Test"));
    return FLTK.Run;


end Fluid_Callback;
