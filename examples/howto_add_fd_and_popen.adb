

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/howto-add_fd-and-popen.cxx: show how to
--  use Add_File_Descriptor to have FLTK call back when a slow command
--  started with popen produces output, appending each line it writes to
--  a browser.
--
--  Ada has no standard popen, so popen, pclose and fgets are imported
--  from the C library, with Interfaces.C_Streams supplying the FILE type
--  and fileno.  The original's Windows ping command is left out.  File
--  handlers take no data, so the browser is a global, like the stream.


with

    Ada.Text_IO,
    Interfaces.C.Strings,
    Interfaces.C_Streams,
    FLTK.Static,
    FLTK.Widgets.Groups.Browsers.Textline.Multi,
    FLTK.Widgets.Groups.Windows,
    GNAT.OS_Lib;


function Howto_Add_FD_And_Popen
    return Integer
is


    package C   renames Interfaces.C;
    package CS  renames Interfaces.C.Strings;
    package ICS renames Interfaces.C_Streams;
    package Mul renames FLTK.Widgets.Groups.Browsers.Textline.Multi;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type ICS.FILEs;
    use type CS.chars_ptr;


    Ping_Cmd : constant String := "ping -i 2 -c 10 localhost";   --  'slow command' under unix


    function popen
           (Command, Mode : in C.char_array)
        return ICS.FILEs;
    pragma Import (C, popen, "popen");

    function pclose
           (Stream : in ICS.FILEs)
        return C.int;
    pragma Import (C, pclose, "pclose");

    function fgets
           (S      : in CS.chars_ptr;
            N      : in C.int;
            Stream : in ICS.FILEs)
        return CS.chars_ptr;
    pragma Import (C, fgets, "fgets");


    type Multi_Browser_Access is access Mul.Multi_Browser;

    G_FP : ICS.FILEs := ICS.NULL_Stream;
    Brow : Multi_Browser_Access;


    procedure Handle_FD
           (FD : in FLTK.Static.File_Descriptor)
    is
        pragma Unreferenced (FD);
        S : aliased C.char_array := (0 .. 1023 => C.nul);
        P : constant CS.chars_ptr := CS.To_Chars_Ptr (S'Unchecked_Access);
        Status : C.int;   --  the exit status, which the original ignores too
        pragma Unreferenced (Status);
    begin
        if fgets (P, 1023, G_FP) = CS.Null_Ptr then   --  read the line of data
            --  command ended? disconnect callback
            FLTK.Static.Remove_File_Descriptor (FLTK.Static.File_Descriptor (ICS.fileno (G_FP)));
            Status := pclose (G_FP);   --  close the descriptor
            Brow.Add ("");   --  append msg indicating command finished
            Brow.Add ("<<DONE>>");
            return;
        end if;
        Brow.Add (C.To_Ada (S));   --  line of data read? append to widget
    end Handle_FD;


    The_Window : Win.Window := Win.Forge.Create (600, 600);


begin


    Brow := new Mul.Multi_Browser'(Mul.Forge.Create (The_Window, 10, 10, 580, 580));
    G_FP := popen (C.To_C (Ping_Cmd), C.To_C ("r"));   --  start the external unix command
    if G_FP = ICS.NULL_Stream then
        Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "popen failed: " & GNAT.OS_Lib.Errno_Message);
        return 1;
    end if;
    --  setup a callback for the popen()ed descriptor
    FLTK.Static.Add_File_Descriptor
       (FLTK.Static.File_Descriptor (ICS.fileno (G_FP)), Handle_FD'Unrestricted_Access);
    The_Window.End_Current;
    The_Window.Set_Resizable (Brow.all);
    The_Window.Show_With_Args;
    return FLTK.Run;


end Howto_Add_FD_And_Popen;
