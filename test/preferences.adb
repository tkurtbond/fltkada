

--  Released into the public domain


--  A database's root group: set, read back, and freed before and after
--  its database, then read from a second database; and Flush of a file
--  that can't be written.  Run it under
--  valgrind: it writes fltkada_test.prefs in the current directory,
--  and deletes it.


with

    Ada.Command_Line,
    Ada.Directories,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    FLTK.Environment;

use

    FLTK.Environment;


procedure Preferences is

    type Database_Access is access all Database'Class;
    type Group_Access is access all Pref_Group'Class;

    procedure Free is new Ada.Unchecked_Deallocation (Database'Class, Database_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Pref_Group'Class, Group_Access);

    File : constant String := "fltkada_test.prefs";

    Failed : Boolean := False;

    Data  : Database_Access;
    Group : Group_Access;

    procedure Open is
    begin
        Data := new Database'(Forge.From_Filesystem (".", "fltkada", "fltkada_test"));
        Group := new Pref_Group'Class'(Forge.Root (Database (Data.all)));
    end Open;

    procedure Check
           (Label, Expected : in String) is
    begin
        if Group.Get ("key", "none") = Expected then
            Ada.Text_IO.Put_Line ("ok   - " & Label);
        else
            Ada.Text_IO.Put_Line ("FAIL - " & Label & ": " & Group.Get ("key", "none"));
            Failed := True;
        end if;
    end Check;

begin

    --  The group freed first.
    Open;
    Group.Set ("key", "first");
    Flush (Data.all);
    Check ("the root group keeps what is set", "first");
    Free (Group);
    Free (Data);

    --  The database freed first.
    Open;
    Check ("a second database reads it back", "first");
    Group.Set ("key", "second");
    Free (Data);
    Check ("the root group outlives its database", "second");
    Free (Group);

    Open;
    Check ("the database is written when the last is freed", "second");
    Free (Group);
    Free (Data);

    --  A file that can't be written: no directory can be made in /proc.
    Data := new Database'(Forge.From_Filesystem ("/proc/fltkada_test", "fltkada", "fltkada_test"));
    Group := new Pref_Group'Class'(Forge.Root (Database (Data.all)));
    Group.Set ("key", "unwritten");
    begin
        Flush (Data.all);
        Ada.Text_IO.Put_Line ("FAIL - Flush raises Preference_Error when it can't write");
        Failed := True;
    exception
        when Preference_Error =>
            Ada.Text_IO.Put_Line ("ok   - Flush raises Preference_Error when it can't write");
    end;
    Free (Group);
    Free (Data);

    if Ada.Directories.Exists (File) then
        Ada.Directories.Delete_File (File);
    end if;

    if Failed then
        Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
    end if;

end Preferences;

