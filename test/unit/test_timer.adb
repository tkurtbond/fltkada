

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestTimer: timeouts fire, repeat from their
--  handler, and are removed.  pofltk's timers are objects, and adding a
--  pending one moves it; FLTKAda's are plain procedures, as FLTK's are,
--  and adding one twice gives two timeouts, as in FLTK (Fl_Timeout.cxx,
--  add_timeout), so that is what is checked here.  pofltk's check that a
--  timer only FLTK holds survives a collection has no counterpart.  Added
--  here: file descriptors, through a pipe, which pofltk doesn't test.


with

    Checks,
    FLTK.Static,
    Interfaces.C;

use

    Checks,
    FLTK;


procedure Test_Timer is

    package C renames Interfaces.C;
    package Sta renames FLTK.Static;

    use type C.int;
    use type C.long;
    use type Sta.File_Descriptor;


    Once_Fired, Repeat_Fired, Other_Fired : Natural := 0;
    Repeat_Times : constant Natural := 3;

    procedure Once is
    begin
        Once_Fired := Once_Fired + 1;
    end Once;

    procedure Repeating is
    begin
        Repeat_Fired := Repeat_Fired + 1;
        if Repeat_Fired < Repeat_Times then
            Sta.Repeat_Timeout (0.01, Repeating'Unrestricted_Access);
        end if;
    end Repeating;

    procedure Other is
    begin
        Other_Fired := Other_Fired + 1;
    end Other;


    --  Waits up to about a second for Count to reach N.
    procedure Wait_For
           (Count : in Natural;
            N     : in Natural)
    is
        Left : Long_Float;
        pragma Unreferenced (Left);
    begin
        for K in 1 .. 100 loop
            exit when Count >= N;
            Left := Wait (0.01);
        end loop;
    end Wait_For;

    procedure Wait_A_Little is
        Left : Long_Float;
        pragma Unreferenced (Left);
    begin
        for K in 1 .. 5 loop
            Left := Wait (0.01);
        end loop;
    end Wait_A_Little;


    --  File descriptors, through a pipe.
    type Pipe_Ends is array (0 .. 1) of C.int with Convention => C;

    function Pipe
           (Ends : out Pipe_Ends)
        return C.int
    with Import, Convention => C, External_Name => "pipe";

    function Write
           (FD    : in C.int;
            Data  : in C.char_array;
            Count : in C.size_t)
        return C.long
    with Import, Convention => C, External_Name => "write";

    function Read
           (FD    : in     C.int;
            Data  :    out C.char_array;
            Count : in     C.size_t)
        return C.long
    with Import, Convention => C, External_Name => "read";

    function Close
           (FD : in C.int)
        return C.int
    with Import, Convention => C, External_Name => "close";

    Readable : Natural := 0;
    Got_FD   : Sta.File_Descriptor := -1;
    Got_Byte : Character := ' ';

    procedure On_Readable
           (FD : in Sta.File_Descriptor)
    is
        Buffer : C.char_array (1 .. 16);
        Count  : C.long;
        pragma Unreferenced (Count);
    begin
        Readable := Readable + 1;
        Got_FD := FD;
        Count := Read (C.int (FD), Buffer, Buffer'Length);
        Got_Byte := C.To_Ada (Buffer (1));
    end On_Readable;

    Ends : Pipe_Ends;
    Done : C.long;
    Shut : C.int;
    pragma Unreferenced (Shut);

begin

    --  Once.
    Sta.Add_Timeout (0.01, Once'Unrestricted_Access);
    Check (Sta.Has_Timeout (Once'Unrestricted_Access)
            and not Sta.Has_Timeout (Other'Unrestricted_Access),
        "an added timeout is pending, and only it");
    Wait_For (Once_Fired, 1);
    Check (Once_Fired = 1 and not Sta.Has_Timeout (Once'Unrestricted_Access),
        "it fired once, and is no longer pending");

    --  Repeating from its handler.
    Sta.Add_Timeout (0.01, Repeating'Unrestricted_Access);
    Wait_For (Repeat_Fired, 3);
    Wait_A_Little;
    Check (Repeat_Fired = 3 and not Sta.Has_Timeout (Repeating'Unrestricted_Access),
        "Repeat_Timeout from the handler repeats it, until it stops:"
            & Natural'Image (Repeat_Fired));

    --  Repeat_Timeout outside a handler is Add_Timeout.
    Once_Fired := 0;
    Sta.Repeat_Timeout (0.01, Once'Unrestricted_Access);
    Wait_For (Once_Fired, 1);
    Check (Once_Fired = 1, "Repeat_Timeout outside a handler adds one");

    --  Adding twice gives two.
    Once_Fired := 0;
    Sta.Add_Timeout (10.0, Once'Unrestricted_Access);
    Sta.Add_Timeout (0.01, Once'Unrestricted_Access);
    Wait_For (Once_Fired, 1);
    Wait_A_Little;
    Check (Once_Fired = 1 and Sta.Has_Timeout (Once'Unrestricted_Access),
        "adding a pending timeout adds another: one fired, one is pending");
    Sta.Remove_Timeout (Once'Unrestricted_Access);
    Check (not Sta.Has_Timeout (Once'Unrestricted_Access), "Remove_Timeout removes it");

    --  Removing.
    Once_Fired := 0;
    Sta.Add_Timeout (0.01, Once'Unrestricted_Access);
    Sta.Add_Timeout (0.01, Once'Unrestricted_Access);
    Sta.Add_Timeout (0.01, Other'Unrestricted_Access);
    Sta.Remove_Timeout (Once'Unrestricted_Access);
    Check (not Sta.Has_Timeout (Once'Unrestricted_Access)
            and Sta.Has_Timeout (Other'Unrestricted_Access),
        "Remove_Timeout removes every one of its handler's, and no other's");
    Wait_For (Other_Fired, 1);
    Wait_A_Little;
    Check (Once_Fired = 0 and Other_Fired = 1, "the removed ones don't fire; the other does");
    Sta.Remove_Timeout (Once'Unrestricted_Access);
    Check (not Sta.Has_Timeout (Once'Unrestricted_Access), "removing again does nothing");

    --  File descriptors.
    Check (Pipe (Ends) = 0, "a pipe");
    Sta.Add_File_Descriptor (Sta.File_Descriptor (Ends (0)), Sta.Read_Mode,
        On_Readable'Unrestricted_Access);
    Wait_A_Little;
    Check (Readable = 0, "an empty pipe isn't readable");
    Done := Write (Ends (1), C.To_C ("x", Append_Nul => False), 1);
    Wait_For (Readable, 1);
    Check (Done = 1 and Readable = 1 and Got_FD = Sta.File_Descriptor (Ends (0))
            and Got_Byte = 'x',
        "a byte written makes it readable, and the handler has its descriptor");
    Sta.Remove_File_Descriptor (Sta.File_Descriptor (Ends (0)));
    Done := Write (Ends (1), C.To_C ("y", Append_Nul => False), 1);
    Wait_A_Little;
    Check (Readable = 1, "a removed descriptor's handler isn't run");
    Sta.Add_File_Descriptor (Sta.File_Descriptor (Ends (0)), On_Readable'Unrestricted_Access);
    Wait_For (Readable, 2);
    Check (Readable = 2 and Got_Byte = 'y', "the default mode is reading");
    Sta.Remove_File_Descriptor (Sta.File_Descriptor (Ends (0)), Sta.Read_Mode);
    Done := Write (Ends (1), C.To_C ("z", Append_Nul => False), 1);
    Wait_A_Little;
    Check (Readable = 2, "nor one whose mode is removed");
    Shut := Close (Ends (0));
    Shut := Close (Ends (1));

    Summary;

end Test_Timer;
