

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/callbacks.cxx: callbacks that carry their
--  own custom parameters.
--
--  The original uses the macros in FL/fl_callback_macros.H, which build a
--  small object holding copies of the parameters for each callback.  Ada
--  needs no macros for this: a nested procedure can call a subprogram
--  with whatever arguments it likes, a widget type can carry its own
--  parameters as record components, and values captured when a callback is
--  set up are just constants declared where that happens.


with

    FLTK.Asks,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;


function Callbacks
    return Integer
is


    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;


    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return (if N < 0 then S else S (S'First + 1 .. S'Last));
    end Image;


    The_Window : Win.Window := Win.Forge.Create (580, 120);


    --  Here is a list of callback procedures that take custom parameters,
    --  which the widget callbacks below call.

    procedure Hello_0_Args_CB is
    begin
        FLTK.Asks.Message_Box ("Hello with 0 arguments");
    end Hello_0_Args_CB;


    procedure Hello_2_Args_CB
           (Text   : in String;
            Number : in Integer) is
    begin
        FLTK.Asks.Message_Box
           ("Hello with 2 arguments," & ASCII.LF &
            '"' & Text & """ and '" & Image (Number) & "'");
    end Hello_2_Args_CB;


    procedure Hello_4_Args_CB
           (A1, A2, A3, A4 : in Integer) is
    begin
        FLTK.Asks.Message_Box
           ("Hello with 4 arguments:" & ASCII.LF &
            Image (A1) & " " & Image (A2) & " " & Image (A3) & " " & Image (A4));
    end Hello_4_Args_CB;


    --  We create our own little type here that carries the parameters for its
    --  method callback along with it.
    type My_Button is new Btn.Button with record
        Id      : Integer;   --  id will be set when created
        A, B, C : Integer;   --  the custom parameters for Hello
    end record;

    type My_Button_Access is access My_Button;


    --  Create a simple push button
    function Create
           (Parent     : in out Win.Window;
            X, Y, W, H : in     Integer;
            Label      : in     String;
            Id         : in     Integer;
            A, B, C    : in     Integer)
        return My_Button_Access is
    begin
        return new My_Button'
            (Btn.Forge.Create (Parent, X, Y, W, H, Label)
             with Id => Id, A => A, B => B, C => C);
    end Create;


    --  It takes the My_Button itself, so it has full access to all
    --  of the button's components, i.e. Id
    procedure Hello
           (This    : in My_Button;
            A, B, C : in Integer) is
    begin
        FLTK.Asks.Message_Box
           ("MyButton has the id " & Image (This.Id) & ASCII.LF &
            "and was called with the custom parameters" & ASCII.LF &
            Image (A) & ", " & Image (B) & ", and " & Image (C) & ".");
    end Hello;


    --  The one callback all My_Buttons share, calling Hello with that
    --  button's own parameters
    procedure My_Button_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        This : My_Button renames My_Button (Item);
    begin
        Hello (This, This.A, This.B, This.C);
    end My_Button_CB;


    --  Each button made with the same procedure gets its own separate set of
    --  parameters, kept in the button itself.
    procedure Make_Button
           (Parent : in out Win.Window;
            Set    : in     Natural)
    is
        Y_Lut : constant array (0 .. 1) of Integer := (60, 90);
        Label : constant String :=
            (if Set = 0 then "id 2 (5, 6, 7)" else "id 3 (6, 7, 8)");
        B     : constant My_Button_Access :=
            Create (Parent, 200, Y_Lut (Set), 180, 25, Label, Set + 2,
                    Set + 5, Set + 6, Set + 7);
    begin
        B.Set_Callback (My_Button_CB'Unrestricted_Access);
    end Make_Button;


    procedure Func_CB_0
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Hello_0_Args_CB;
    end Func_CB_0;


    procedure Func_CB_2
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Hello_2_Args_CB ("FLTK", 2);
    end Func_CB_2;


    procedure Func_CB_4
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Hello_4_Args_CB (1, 2, 3, 4);
    end Func_CB_4;


    procedure Inline_CB_0
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        FLTK.Asks.Message_Box ("Inline callback with 0 args.");
    end Inline_CB_0;


    procedure Inline_CB_2
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Text   : constant String  := "FLTK";
        Number : constant Integer := 2;
    begin
        FLTK.Asks.Message_Box
           ("We received the message " & Text & " with " & Image (Number) & "!");
    end Inline_CB_2;


    --  testing function callbacks with multiple arguments
    --  These buttons call ordinary procedures with custom parameters.

    Func_Label : Bx.Box := Bx.Forge.Create (The_Window, 10, 5, 180, 25, "Function Callbacks:");

    Func_CB_Btn_0 : Btn.Button := Btn.Forge.Create (The_Window, 10, 30, 180, 25, "0 args");
    Func_CB_Btn_2 : Btn.Button := Btn.Forge.Create (The_Window, 10, 60, 180, 25, "2 args");
    Func_CB_Btn_4 : Btn.Button := Btn.Forge.Create (The_Window, 10, 90, 180, 25, "4 args");

    --  testing method callbacks with multiple arguments
    --  The following buttons call Hello on themselves with custom parameters.
    --  Check the type above to see how this is implemented.

    Meth_Label : Bx.Box := Bx.Forge.Create (The_Window, 200, 5, 180, 25, "Method Callbacks:");

    Meth_CB_Btn_0 : constant My_Button_Access :=
        Create (The_Window, 200, 30, 180, 25, "id 1 (1, 2, 3)", 1, 1, 2, 3);


begin


    Func_CB_Btn_0.Set_Callback (Func_CB_0'Unrestricted_Access);
    Func_CB_Btn_2.Set_Callback (Func_CB_2'Unrestricted_Access);
    Func_CB_Btn_4.Set_Callback (Func_CB_4'Unrestricted_Access);

    Meth_CB_Btn_0.Set_Callback (My_Button_CB'Unrestricted_Access);

    --  make the same kind of button more than once to ensure we get
    --  individual parameter sets
    Make_Button (The_Window, 0);
    Make_Button (The_Window, 1);

    --  testing inline callbacks
    --  Nested procedures are Ada's own way to write a callback in place.
    declare
        Inline_Label : Bx.Box :=
            Bx.Forge.Create (The_Window, 390, 5, 180, 25, "Inline Callbacks:");

        Inline_CB_Btn_0 : Btn.Button := Btn.Forge.Create (The_Window, 390, 30, 180, 25, "0 args");
        Inline_CB_Btn_2 : Btn.Button := Btn.Forge.Create (The_Window, 390, 60, 180, 25, "2 args");
        Inline_CB_Btn_4 : Btn.Button := Btn.Forge.Create (The_Window, 390, 90, 180, 25, "4 args");

        --  the main window's geometry when the callback was created
        X : constant Integer := The_Window.Get_X;
        Y : constant Integer := The_Window.Get_Y;
        W : constant Integer := The_Window.Get_W;
        H : constant Integer := The_Window.Get_H;

        procedure Inline_CB_4
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            FLTK.Asks.Message_Box
               ("The main window was at" & ASCII.LF &
                "x:" & Image (X) & ", y:" & Image (Y) &
                ", w:" & Image (W) & ", h:" & Image (H) & ASCII.LF &
                "when the callback was created" & ASCII.LF &
                "and is now at x:" & Image (The_Window.Get_X) &
                ", y:" & Image (The_Window.Get_Y));
        end Inline_CB_4;
    begin
        Inline_CB_Btn_0.Set_Callback (Inline_CB_0'Unrestricted_Access);
        Inline_CB_Btn_2.Set_Callback (Inline_CB_2'Unrestricted_Access);
        Inline_CB_Btn_4.Set_Callback (Inline_CB_4'Unrestricted_Access);

        The_Window.End_Current;
        The_Window.Show_With_Args;
        return FLTK.Run;
    end;


end Callbacks;
