--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/threads.cxx: one task finds primes for the window "Single
--  Thread", and six share the work for "Six Threads".  Each prints its
--  primes in its window's terminal, and shows its largest in the window's
--  output, which turns red once that task passes 2,000,000.  The tasks
--  touch the widgets only under FLTK.Static.Lock, and wake the main loop
--  with FLTK.Static.Awake.  Closing either window hides both and prints
--  the maxima.
--
--  FLTK's program builds this only #if HAVE_PTHREAD || _WIN32, and
--  otherwise shows an alert that threads aren't supported.  Ada always
--  has tasks, so this port has no such alternative.
--
--  FLTK's Fl::awake (magic_number_cb, value) passes the output to the
--  callback; Awake_Handler takes no data, so each window has its own
--  handler.  The C++ program ends with its threads still running, and
--  exit kills them.  An Ada program waits for its tasks, so here they
--  check Stop, which the main program sets when Run returns; it then
--  unlocks, so that a task waiting for the lock can see it.


with

    Ada.Characters.Latin_1,
    Ada.Numerics.Long_Elementary_Functions,
    Ada.Text_IO,
    FLTK.Static,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Outputs;


function Threads
    return Integer
is


    package Latin renames Ada.Characters.Latin_1;
    package LEF   renames Ada.Numerics.Long_Elementary_Functions;
    package TIO   renames Ada.Text_IO;
    package Stc   renames FLTK.Static;
    package Term  renames FLTK.Widgets.Groups.Terminals;
    package Dbl   renames FLTK.Widgets.Groups.Windows.Double;
    package Outs  renames FLTK.Widgets.Inputs.Text.Outputs;


    subtype Number is Long_Long_Integer range 0 .. Long_Long_Integer'Last;


    Window_1 : Dbl.Double_Window := Dbl.Forge.Create (200, 200, "Single Thread");
    Tty_1    : aliased Term.Terminal := Term.Forge.Create (Window_1, 0, 0, 200, 175);
    Value_1  : aliased Outs.Output :=
        Outs.Forge.Create (Window_1, 100, 175, 98, 23, "Max Prime:");

    Window_2 : Dbl.Double_Window := Dbl.Forge.Create (200, 200, "Six Threads");
    Tty_2    : aliased Term.Terminal := Term.Forge.Create (Window_2, 0, 0, 200, 175);
    Value_2  : aliased Outs.Output :=
        Outs.Forge.Create (Window_2, 100, 175, 98, 23, "Max Prime:");

    --  The next start for one of the six tasks; read under the lock.
    Start_2 : Number := 3;

    Stop : Boolean := False
        with Atomic;

    Status : Integer;


    --  N, right-justified in Width columns, as printf's %Wu does.
    function Image
           (N     : in Number;
            Width : in Positive)
        return String
    is
        Img  : constant String := Number'Image (N);
        Text : constant String := Img (Img'First + 1 .. Img'Last);
    begin
        if Text'Length >= Width then
            return Text;
        else
            return (1 .. Width - Text'Length => ' ') & Text;
        end if;
    end Image;


    procedure Magic_1 is
    begin
        Value_1.Set_Label_Color (FLTK.Red_Color);
        Value_1.Redraw_Label;
    end Magic_1;

    procedure Magic_2 is
    begin
        Value_2.Set_Label_Color (FLTK.Red_Color);
        Value_2.Redraw_Label;
    end Magic_2;


    --  A very simple prime number calculator.  Six tasks share the second
    --  window, each starting at the next odd number and stepping by 12.
    task type Prime_Task
           (Six : Boolean);

    task body Prime_Task is
        N         : Number;
        Step      : Number;
        Max_Value : Number := 0;
        Proud     : Boolean := False;
        Tty       : constant access Term.Terminal :=
            (if Six then Tty_2'Access else Tty_1'Access);
        Value     : constant access Outs.Output :=
            (if Six then Value_2'Access else Value_1'Access);
    begin
        if Six then
            Stc.Lock;
            N := Start_2;
            Start_2 := Start_2 + 2;
            Stc.Unlock;
            Step := 12;
        else
            N := 3;
            Step := 2;
        end if;

        while not Stop loop
            declare
                HN : constant Number := Number (Long_Float'Truncation (LEF.Sqrt (Long_Float (N))));
                PP : Number := 3;
            begin
                while PP <= HN and then N mod PP /= 0 loop
                    PP := PP + 2;
                end loop;

                if PP > HN then
                    --  Locking for each prime isn't efficient, but it is what
                    --  FLTK's program does.
                    Stc.Lock;
                    Tty.Print ("prime: " & Image (N, 10) & Latin.LF);
                    if N > Max_Value then
                        Max_Value := N;
                        Value.Set_Value (Image (Max_Value, 9));
                    end if;
                    Stc.Unlock;

                    Stc.Awake;

                    N := N + Step;

                    if N > 2_000_000 and not Proud then
                        Proud := True;
                        Stc.Awake
                            (if Six then Magic_2'Unrestricted_Access
                             else Magic_1'Unrestricted_Access);
                    end if;
                else
                    Stc.Lock;
                    N := N + Step;
                    Stc.Unlock;
                end if;
            end;
        end loop;
    end Prime_Task;


    --  Closing either window closes both.
    procedure Close_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Stc.Hide_All_Windows;
        TIO.Put_Line ("Max prime number with 1 thread : " & Value_1.Get_Value);
        TIO.Put_Line ("Max prime number with 6 threads: " & Value_2.Get_Value);
    end Close_Callback;


begin


    Tty_1.Set_Background_Color (FLTK.Background2_Color);
    Tty_1.Set_Text_Color (FLTK.Foreground_Color);
    Window_1.Set_Resizable (Tty_1);
    Value_1.Set_Text_Font (FLTK.Courier);
    Window_1.Set_Callback (Close_Callback'Unrestricted_Access);
    Window_1.Show_With_Args;

    Tty_2.Set_Background_Color (FLTK.Background2_Color);
    Tty_2.Set_Text_Color (FLTK.Foreground_Color);
    Window_2.Set_Resizable (Tty_2);
    Value_2.Set_Text_Font (FLTK.Courier);
    Window_2.Set_Callback (Close_Callback'Unrestricted_Access);
    Window_2.Show;

    Tty_1.Print ("Prime numbers:" & Latin.LF);
    Tty_2.Print ("Prime numbers:" & Latin.LF);

    --  Lock in the main program first: Run then unlocks while it waits,
    --  and only then can a task have the lock.
    Stc.Lock;

    declare
        Single : Prime_Task (Six => False);
        Many   : array (1 .. 6) of Prime_Task (Six => True);
        pragma Unreferenced (Single, Many);
    begin
        Status := FLTK.Run;
        Stop := True;
        Stc.Unlock;
    end;

    return Status;


end Threads;

