--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestKeys:  an editor's key bindings, its own and
--  the global ones, as FLTK orders them.  FLTKAda keeps the bindings in
--  Ada, so pofltk's checks of FLTK's own key functions (Builtin, KfEnd and
--  so on) become checks of the KF_ procedures.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Groups.Text_Displays.Text_Editors.Key_Func,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors.Default_Key_Func;


procedure Test_Key_Bindings is

    package Prb renames FLTK.Probe;
    package TB  renames FLTK.Text_Buffers;
    package TE  renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Editor_Access is access TE.Text_Editor;
    procedure Free is new Ada.Unchecked_Deallocation (TE.Text_Editor, Editor_Access);

    Buffer : TB.Text_Buffer := TB.Forge.Create;
    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Key_Bindings");
    Editor : Editor_Access := new TE.Text_Editor'(TE.Forge.Create (Window, 0, 0, 300, 200));

    First, Second, Global, Default, Adder, Closer : Natural := 0;
    Last_Key : Key_Combo := No_Key;
    Ignore      : Boolean;
    Ignore_Time : Long_Float;

    procedure Count_First
           (This : in out TE.Text_Editor'Class) is
    begin
        First := First + 1;
    end Count_First;

    procedure Count_Second
           (This : in out TE.Text_Editor'Class) is
    begin
        Second := Second + 1;
    end Count_Second;

    procedure Count_Global
           (This : in out TE.Text_Editor'Class) is
    begin
        Global := Global + 1;
    end Count_Global;

    procedure Count_Default
           (This : in out TE.Text_Editor'Class;
            Key  : in     Key_Combo) is
    begin
        Default := Default + 1;
        Last_Key := Key;
    end Count_Default;

    --  Binds Ctrl+n and removes its own binding, as it runs.
    procedure Add_And_Remove
           (This : in out TE.Text_Editor'Class) is
    begin
        Adder := Adder + 1;
        This.Add_Key_Binding (Mod_Ctrl + 'n', Count_First'Unrestricted_Access);
        This.Remove_Key_Binding (Mod_Ctrl + 'd');
    end Add_And_Remove;

    --  Frees the editor.
    procedure Close
           (This : in out TE.Text_Editor'Class) is
    begin
        Closer := Closer + 1;
        Free (Editor);
    end Close;

    function Ctrl
           (C : in Pressable_Key)
        return Boolean is
    begin
        return Prb.Key (Keydown, Press (C), Mod_Ctrl,
            (1 => Character'Val (Character'Pos (C) - Character'Pos ('a') + 1)));
    end Ctrl;

    --  Sends Ctrl+w from inside FLTK's dispatch, as a real key press is
    --  sent:  outside it the editor would be deleted inside its own handle.
    procedure Press_Close is
    begin
        Ignore := Ctrl ('w');
    end Press_Close;

begin

    Buffer.Set_Entire_Text ("hello");
    Editor.Set_Buffer (Buffer);
    Window.Show;
    Ignore := Editor.Take_Focus;

    --  The program's bindings.
    Editor.Add_Key_Binding (Mod_Ctrl + 'a', Count_First'Unrestricted_Access);
    Ignore := Ctrl ('a');
    Check (First = 1 and Buffer.Get_Entire_Text = "hello" and not Buffer.Has_Selection,
        "a binding of Ctrl+a, over the default select-all");
    Editor.Add_Key_Binding (Mod_Ctrl + 'a', Count_Second'Unrestricted_Access);
    Ignore := Ctrl ('a');
    Check (First = 1 and Second = 1, "the newest binding of a key wins");
    Check (Editor.Get_Bound_Key_Function (Mod_Ctrl + 'a') = Count_Second'Unrestricted_Access,
        "Get_Bound_Key_Function gives the newest");
    Editor.Remove_Key_Binding (Mod_Ctrl + 'a');
    Ignore := Ctrl ('a');
    Check (First = 2 and Second = 1, "removing it uncovers the one before");
    Check (Editor.Get_Bound_Key_Function (Mod_Ctrl + 'a') = Count_First'Unrestricted_Access,
        "Get_Bound_Key_Function after the removal");
    Ignore := Prb.Key (Keydown, Press ('a'), Mod_Ctrl + Mod_Shift, (1 => Character'Val (1)));
    Check (First = 2, "a Ctrl binding isn't Ctrl+Shift's");

    --  The KF_ procedures.
    Editor.Add_Key_Binding (Mod_Ctrl + 'k', TE.KF_End'Access);
    Editor.Set_Insert_Position (0);
    Ignore := Ctrl ('k');
    Check (Editor.Get_Insert_Position = 5, "a key bound to KF_End");
    Check (Editor.Get_Bound_Key_Function (Mod_None + Backspace_Key) = TE.KF_Backspace'Access,
        "the default binding of Backspace");
    Check (Editor.Get_Bound_Key_Function (Mod_Ctrl + 'j') = null, "a key bound to nothing");

    --  Undo and redo, bound to Ctrl+z and Ctrl+Shift+z as in FLTK
    --  (Fl_Text_Editor.cxx:134-135; KF_Redo, PLAN.md, Phase 25).
    Editor.Set_Insert_Position (5);
    Ignore := Prb.Key (Keydown, Press ('x'), Mod_None, "x");
    Check (Buffer.Get_Entire_Text = "hellox", "x typed, to undo");
    Ignore := Ctrl ('z');
    Check (Buffer.Get_Entire_Text = "hello", "Ctrl+z undoes");
    Ignore := Prb.Key (Keydown, Press ('z'), Mod_Ctrl + Mod_Shift, (1 => Character'Val (26)));
    Check (Buffer.Get_Entire_Text = "hellox" and Editor.Get_Insert_Position = 6,
        "Ctrl+Shift+z redoes");
    Check (Editor.Get_Bound_Key_Function (Mod_Command + Mod_Shift + 'z') = TE.KF_Redo'Access,
        "Ctrl+Shift+z is bound to KF_Redo");
    Ignore := Ctrl ('z');
    Check (Buffer.Get_Entire_Text = "hello", "and undone again");

    --  The default key function.
    Check (Editor.Get_Default_Key_Function = TE.KF_Default'Access,
        "the default key function is KF_Default");
    Editor.Set_Default_Key_Function (Count_Default'Unrestricted_Access);
    Ignore := Prb.Key (Keydown, Function_Key (1), Mod_None, "");
    Check (Default = 1 and Last_Key = Mod_None + Function_Key (1),
        "the default key function, for F1");
    Editor.Set_Insert_Position (5);
    Ignore := Prb.Key (Keydown, Press ('q'), Mod_None, "q");
    Check (Default = 1 and Buffer.Get_Entire_Text = "helloq",
        "a key that types text is typed, not given the default (pofltk 147)");
    Editor.Set_Default_Key_Function (TE.KF_Default'Access);

    --  The global bindings, before an editor's own.
    TE.Global_Key_Bindings.Append ((Mod_Ctrl + 'a', Count_Global'Unrestricted_Access));
    Ignore := Ctrl ('a');
    Check (Global = 1 and First = 2, "a global binding comes before the editor's");
    TE.Global_Key_Bindings.Clear;
    Ignore := Ctrl ('a');
    Check (Global = 1 and First = 3, "a global binding removed");

    --  A binding changing the bindings as it runs.
    Editor.Add_Key_Binding (Mod_Ctrl + 'd', Add_And_Remove'Unrestricted_Access);
    begin
        Ignore := Ctrl ('d');
        Ignore := Ctrl ('d');
        Check (Adder = 1 and Editor.Get_Bound_Key_Function (Mod_Ctrl + 'd') = null,
            "a binding removing itself");
        Ignore := Ctrl ('n');
        Check (First = 4, "a binding another added");
    exception
    when Occurrence : others =>
        Check (False, "a binding changing the bindings:  " &
            Ada.Exceptions.Exception_Information (Occurrence));
    end;

    --  Every binding gone.
    Editor.Remove_All_Key_Bindings;
    Check (Editor.Get_Bound_Key_Function (Mod_None + Backspace_Key) = null,
        "Remove_All_Key_Bindings");
    Ignore := Ctrl ('n');
    Check (First = 4, "a removed binding isn't called");

    --  An editor freed by its own binding.
    Editor.Add_Key_Binding (Mod_Ctrl + 'w', Close'Unrestricted_Access);
    begin
        FLTK.Static.Add_Timeout (0.0, Press_Close'Unrestricted_Access);
        for Tries in 1 .. 100 loop
            exit when Closer > 0;
            Ignore_Time := FLTK.Wait (0.02);
        end loop;
        Ignore := FLTK.Check;
        Check (Closer = 1 and Editor = null and Window.Number_Of_Children = 0,
            "an editor freed by its own binding");
    exception
    when Occurrence : others =>
        Check (False, "an editor freed by its own binding:  " &
            Ada.Exceptions.Exception_Information (Occurrence));
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Key_Bindings;
