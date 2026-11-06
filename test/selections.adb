


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A text buffer's three selections, primary, secondary and highlight,
--  after pofltk's examples/Selections.Mod.
--
--  The buffer calls a modify callback on each change to its text and to
--  its selections, so the labels below always say what each holds, and
--  the buttons are active only when they have something to work on.


with

    Ada.Strings.Fixed,
    Ada.Strings.Maps,
    FLTK.Text_Buffers,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Groups.Windows;


function Selections
    return Integer
is


    package TB  renames FLTK.Text_Buffers;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package TD  renames FLTK.Widgets.Groups.Text_Displays;
    package Ed  renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type FLTK.Alignment;


    Window : Win.Window := Win.Forge.Create (480, 300, "Selections");
    Buffer : TB.Text_Buffer := TB.Forge.Create;
    Editor : Ed.Text_Editor := Ed.Forge.Create (Window, 10, 10, 460, 170);

    To_Secondary : Btn.Button := Btn.Forge.Create (Window, 10, 190, 110, 25, "To &secondary");
    To_Highlight : Btn.Button := Btn.Forge.Create (Window, 125, 190, 110, 25, "To &highlight");
    Replace      : Btn.Button := Btn.Forge.Create (Window, 240, 190, 110, 25, "&Replace");
    Clear        : Btn.Button := Btn.Forge.Create (Window, 360, 190, 110, 25, "&Clear");

    Primary_Box   : Bx.Box := Bx.Forge.Create (Window, 10, 225, 300, 22);
    Secondary_Box : Bx.Box := Bx.Forge.Create (Window, 10, 247, 300, 22);
    Highlight_Box : Bx.Box := Bx.Forge.Create (Window, 10, 269, 300, 22);


    --  C's "%d".
    function Image
           (Item : in Integer)
        return String is (Ada.Strings.Fixed.Trim (Integer'Image (Item), Ada.Strings.Left));


    --  "Name: none", or "Name: 4 to 9, 5 bytes".
    procedure Show
           (Box           : in out Bx.Box;
            Name          : in     String;
            Selected      : in     Boolean;
            Start, Finish : in     TB.Position) is
    begin
        if Selected then
            Box.Set_Label (Name & ": " & Image (Start) & " to " & Image (Finish) & ", "
                & Image (Finish - Start) & " bytes");
        else
            Box.Set_Label (Name & ": none");
        end if;
    end Show;


    procedure Set_Active
           (Button : in out Btn.Button;
            To     : in     Boolean) is
    begin
        if To then
            Button.Activate;
        else
            Button.Deactivate;
        end if;
    end Set_Active;


    procedure Modified
           (Ignore_Action : in TB.Modification;
            Ignore_Place  : in TB.Position;
            Ignore_Length : in Natural;
            Ignore_Text   : in String)
    is
        Start, Finish : TB.Position;
        Primary       : constant Boolean := Buffer.Get_Selection (Start, Finish);
    begin
        Show (Primary_Box, "Primary", Primary, Start, Finish);
        Set_Active (To_Secondary, Primary);
        Set_Active (To_Highlight, Primary);

        declare
            Secondary : constant Boolean := Buffer.Get_Secondary_Selection (Start, Finish);
        begin
            Show (Secondary_Box, "Secondary", Secondary, Start, Finish);
            Set_Active (Replace, Secondary);
        end;

        Buffer.Get_Highlight (Start, Finish);
        Show (Highlight_Box, "Highlight", Buffer.Has_Highlight, Start, Finish);
    end Modified;


    procedure To_Secondary_CB
           (Ignore : in out Wdg.Widget'Class)
    is
        Start, Finish : TB.Position;
    begin
        if Buffer.Get_Selection (Start, Finish) then
            Buffer.Unselect;
            Buffer.Set_Secondary_Selection (Start, Finish);
        end if;
    end To_Secondary_CB;


    procedure To_Highlight_CB
           (Ignore : in out Wdg.Widget'Class)
    is
        Start, Finish : TB.Position;
    begin
        if Buffer.Get_Selection (Start, Finish) then
            Buffer.Unselect;
            Buffer.Set_Highlight (Start, Finish);
        end if;
    end To_Highlight_CB;


    procedure Clear_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Buffer.Unselect;
        Buffer.Secondary_Unselect;
        Buffer.Unhighlight;
    end Clear_CB;


    --  ASCII letters only, so that a UTF-8 sequence is left as it is.
    Capitals : constant Ada.Strings.Maps.Character_Mapping :=
        Ada.Strings.Maps.To_Mapping
           ("abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ");


    --  The secondary selection's text gives way to the primary's, or to
    --  its own text in capitals if there is no primary selection.
    procedure Replace_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        if Buffer.Has_Selection then
            Buffer.Replace_Secondary_Selection (Buffer.Selection_Text);
        else
            Buffer.Replace_Secondary_Selection
               (Ada.Strings.Fixed.Translate (Buffer.Secondary_Selection_Text, Capitals));
        end if;
    end Replace_CB;


    procedure Status
           (Box : in out Bx.Box) is
    begin
        Box.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Left);
    end Status;


begin


    Buffer.Set_Entire_Text
       ("Select some of this text with the mouse, then make it the secondary "
        & "selection or a highlight. A buffer has one of each, and they can overlap.");
    Editor.Set_Buffer (Buffer);
    Editor.Set_Wrap_Mode (TD.Bounds);

    To_Secondary.Set_Callback (To_Secondary_CB'Unrestricted_Access);
    To_Highlight.Set_Callback (To_Highlight_CB'Unrestricted_Access);
    Replace.Set_Callback (Replace_CB'Unrestricted_Access);
    Clear.Set_Callback (Clear_CB'Unrestricted_Access);
    Status (Primary_Box);
    Status (Secondary_Box);
    Status (Highlight_Box);

    Window.Set_Resizable (Editor);
    Buffer.Add_Modify_Callback (Modified'Unrestricted_Access);
    Modified (TB.None, 0, 0, "");
    Window.Show_With_Args;

    return FLTK.Run;


end Selections;


