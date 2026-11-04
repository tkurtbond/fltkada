


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 51: an Fl_Preferences made for a group keeps
--  a plain pointer to the group's node, which Delete_Group,
--  Delete_All_Groups and Clear of a group above it free
--  (Fl_Preferences.cxx, Node::remove).  The group is then read from freed
--  memory.  A group that was deleted raises Preference_Error.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Environment;

use

    Checks,
    FLTK.Environment;


procedure Test_Pref_Groups is

    Top : Pref_Group := Forge.In_Memory ("test_pref_groups");

    A : Pref_Group'Class := Forge.By_Name (Top, "a");
    B : Pref_Group'Class := Forge.By_Name (Pref_Group (A), "b");
    C : Pref_Group'Class := Forge.By_Name (Top, "c");
    D : Pref_Group'Class := Forge.By_Name (Top, "d/e");

    Ignore : Natural;

    procedure Count_A is
    begin
        Ignore := A.Number_Of_Entries;
    end Count_A;

    procedure Get_B is
    begin
        Ignore := B.Get ("k", 0);
    end Get_B;

    procedure Open_Below_A is
        Below : constant Pref_Group'Class := Forge.By_Name (Pref_Group (A), "below");
    begin
        Ignore := Below.Number_Of_Entries;
    end Open_Below_A;

    procedure Set_C is
    begin
        C.Set ("k", 3);
    end Set_C;

    procedure Name_D is
    begin
        if D.At_Name = "" then
            Ignore := 0;
        end if;
    end Name_D;

begin

    A.Set ("k", 1);
    B.Set ("k", 2);
    D.Set ("k", "four");
    Check (A.Get ("k", 0) = 1 and then B.Get ("k", 0) = 2, "groups keep what is set");
    Check (Top.Group_Exists ("a/b") and then Top.Group_Exists ("d/e"),
        "groups are made below their parents");
    Check (D.At_Name = "e" and then D.Get ("k", "") = "four", "a group made by a path");
    Check (B.At_Path = A.At_Path & "/b", "a group's path: " & B.At_Path);

    declare
        By_Index : constant Pref_Group'Class := Forge.By_Index (Top, 1);
    begin
        Check (Top.Group_Exists (By_Index.At_Name), "a group by index: " & By_Index.At_Name);
    end;

    --  pofltk 51: a group deleted, and one below it.
    Top.Delete_Group ("a");
    Raises (Count_A'Access, Preference_Error'Identity, "a deleted group raises");
    Raises (Get_B'Access, Preference_Error'Identity, "a group below a deleted one raises");
    Raises (Open_Below_A'Access, Preference_Error'Identity,
        "opening a group below a deleted one raises");
    Check (not Top.Group_Exists ("a"), "opening below a deleted group doesn't make it again");
    Check (C.Number_Of_Entries = 0, "a group not deleted is still used");

    Top.Delete_All_Groups;
    Raises (Set_C'Access, Preference_Error'Identity,
        "a group raises after Delete_All_Groups of its parent");
    Check (Top.Number_Of_Groups = 0, "using a deleted group doesn't make it again");

    declare
        E : constant Pref_Group'Class := Forge.By_Name (Top, "d/e");
        procedure Name_E is
        begin
            if E.At_Name = "" then
                Ignore := 0;
            end if;
        end Name_E;
    begin
        E.Set ("k", "again");
        Top.Clear;
        Check (not Top.Group_Exists ("d"), "Clear deletes the groups");
        Raises (Name_E'Access, Preference_Error'Identity, "a group raises after Clear of a parent");
        Raises (Name_D'Access, Preference_Error'Identity,
            "a group deleted, made again and deleted again raises");
    end;

    --  A memory group's group outlives it.
    declare
        type Group_Access is access Pref_Group'Class;
        procedure Free is new Ada.Unchecked_Deallocation (Pref_Group'Class, Group_Access);
        Kept : Group_Access;
    begin
        declare
            Memory : constant Pref_Group := Forge.In_Memory ("test_pref_groups_2");
        begin
            Kept := new Pref_Group'Class'(Forge.By_Name (Memory, "kept"));
        end;
        Kept.Set ("k", 5);
        Check (Kept.Get ("k", 0) = 5, "a memory group's group outlives it");
        Free (Kept);
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Pref_Groups;


