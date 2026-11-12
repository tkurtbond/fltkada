--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/native-filechooser.cxx: the buttons ask the native file
--  chooser for a file, with the filter and the file given above, or for
--  a directory, starting from that file; the terminal shows what was
--  chosen.  A first argument not starting with "-" is the file to start
--  with.  Guided by pofltk's NativeFileChooser.Mod.
--
--  FLTK's program shows its window with the arguments after that file,
--  with the file in place of the program's name, which is only the
--  window's class.  This port takes the file as its own option
--  (Parse_Args), which leaves FLTK's options after it to FLTK as before.


with

    Ada.Command_Line,
    Ada.Strings.Unbounded,
    FLTK.Asks,
    FLTK.Images.File_Icons,
    FLTK.Images.Shared,
    FLTK.Native_File_Choosers,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Help_Views,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text.Multiline;


function Native_FileChooser
    return Integer
is

    package SU  renames Ada.Strings.Unbounded;
    package NFC renames FLTK.Native_File_Choosers;
    package Btn renames FLTK.Widgets.Buttons;
    package Hlp renames FLTK.Widgets.Groups.Help_Views;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Txt renames FLTK.Widgets.Inputs.Text;
    package Mul renames FLTK.Widgets.Inputs.Text.Multiline;

    Terminal_Height : constant := 120;

    Tab    : constant String := "&lt;Tab&gt;";
    Ctrl_I : constant String := "<font color=#55f>&lt;Ctrl-I&gt;</font>";
    LF     : constant Character := ASCII.LF;

    File  : SU.Unbounded_String;
    Count : Natural;


    --  Argument 1, if it isn't an option, is the file to start with.
    function File_Arg
           (Index : in Positive)
        return Natural is
    begin
        if Index = 1 then
            declare
                Arg : constant String := Ada.Command_Line.Argument (1);
            begin
                if Arg'Length = 0 or else Arg (Arg'First) /= '-' then
                    File := SU.To_Unbounded_String (Arg);
                    return 1;
                end if;
            end;
        end if;
        return 0;
    end File_Arg;

begin

    --  For a nicer looking browser under linux/unix, call
    --  fl_register_images().  That's required for the preview option of
    --  the GTK filechooser.  In the unlikely situation where no native
    --  filechooser is found on the active Linux system, FLTK reverts to
    --  using its own file chooser (Fl_File_Chooser) which looks best if
    --  you also call Fl_File_Icon::load_system_icons().
    FLTK.Images.Shared.Register_Images;
    FLTK.Images.File_Icons.Load_System_Icons;

    FLTK.Static.Parse_Args (Count, File_Arg'Unrestricted_Access);

    declare

        Window : Win.Window := Win.Forge.Create
            (640, 400 + Terminal_Height, "Native File Chooser Test");

        G_TTY : Trm.Terminal := Trm.Forge.Create (Window, 0, 400, 640, Terminal_Height);

        X : constant := 80;
        Y : constant := 10;

        G_Filename : Txt.Text_Input := Txt.Forge.Create
            (Window, X, Y, 640 - 80 - 10, 25, "Filename");
        G_Filter   : Mul.Multiline_Input := Mul.Forge.Create
            (Window, X, Y + 25 + 10, 640 - 80 - 10, 100, "Filter");
        View       : Hlp.Help_View := Hlp.Forge.Create
            (Window, X, Y + 25 + 10 + 100 + 10, 640 - 80 - 10, 200);

        But    : Btn.Button := Btn.Forge.Create
            (Window, 640 - X - 10, 400 - 25 - 10, 80, 25, "Pick File");
        Butdir : Btn.Button := Btn.Forge.Create
            (Window, 640 - X - 10 - X - 10, 400 - 25 - 10, 80, 25, "Pick Dir");


        --  Shows Chooser and reports what it gives:  What is "filename" or
        --  "dirname".
        procedure Pick
               (Chooser : in out NFC.Native_File_Chooser;
                What    : in     String) is
        begin
            case Chooser.Show is
            when NFC.Error =>
                G_TTY.Print ("ERROR: " & Chooser.Get_Error_Message & LF);
            when NFC.Cancelled =>
                G_TTY.Print ("*** CANCEL" & LF);
                FLTK.Asks.Beep;
            when NFC.Picked =>
                --  FLTK's filename() gives "", not NULL, with nothing
                --  chosen, so the program's "(null)" case never happens.
                G_Filename.Set_Value (Chooser.Get_Filename);
                G_TTY.Print (What & "='" & Chooser.Get_Filename & "'" & LF);
            end case;
        end Pick;


        procedure Pick_File_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
            Native : NFC.Native_File_Chooser := NFC.Forge.Create (NFC.Browse_File);
        begin
            Native.Set_Title ("Pick a file");
            Native.Set_Filter (G_Filter.Get_Value);
            Native.Set_Preset_File (G_Filename.Get_Value);
            Pick (Native, "filename");
        end Pick_File_CB;


        procedure Pick_Dir_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
            Native : NFC.Native_File_Chooser := NFC.Forge.Create (NFC.Browse_Directory);
        begin
            Native.Set_Title ("Pick a Directory");
            Native.Set_Directory (G_Filename.Get_Value);
            Pick (Native, "dirname");
        end Pick_Dir_CB;

    begin

        Window.Set_Size_Range (Window.Get_W, Window.Get_H, 0, 0);

        G_Filename.Set_Value (if SU.Length (File) > 0 then SU.To_String (File) else ".");
        G_Filename.Set_Tooltip ("Default filename");

        G_Filter.Set_Value
           ("Text" & ASCII.HT & "*.txt" & LF &
            "C Files" & ASCII.HT & "*.{cxx,h,c,cpp}" & LF &
            "Tars" & ASCII.HT & "*.{tar,tar.gz}" & LF &
            "Apps" & ASCII.HT & "*.app");
        G_Filter.Set_Tooltip
           ("Filter to be used for browser." & LF & "An empty string may be used." & LF);

        View.Set_Box (FLTK.Flat_Box);
        View.Set_Background_Color (Window.Get_Background_Color);
        View.Set_Text_Font (FLTK.Helvetica);
        View.Set_Text_Size (10);
        View.Set_Content
           ("The Filter can be one or more filter patterns, one per line." & LF &
            "Patterns can be:<ul>" & LF &
            "  <li>A single wildcard (e.g. <tt>""*.txt""</tt>)</li>" & LF &
            "  <li>Multiple wildcards (e.g. <tt>""*.{cxx,h,H}""</tt>)</li>" & LF &
            "  <li>A descriptive name followed by a " & Tab &
            " and a wildcard (e.g. <tt>""Text Files" & Tab & "*.txt""</tt>)</li>" & LF &
            "</ul>" & LF &
            "In the above ""Filter"" field, you can use " &
            "<b><font color=#55f face=Courier>Ctrl-I</font></b> to enter " & Tab &
            " characters as needed.<br>" & LF &
            "Example:<pre>" & LF &
            LF &
            "    Text" & Ctrl_I & "*.txt" & LF &
            "    C Files" & Ctrl_I & "*.{cxx,h,c,cpp}" & LF &
            "    Tars" & Ctrl_I & "*.{tar,tar.gz}" & LF &
            "    Apps" & Ctrl_I & "*.app" & LF &
            "</pre>" & LF);

        But.Set_Callback (Pick_File_CB'Unrestricted_Access);
        Butdir.Set_Callback (Pick_Dir_CB'Unrestricted_Access);

        Window.Set_Resizable (G_Filter);
        Window.End_Current;
        Window.Show_With_Args;

        return FLTK.Run;

    end;

end Native_FileChooser;
