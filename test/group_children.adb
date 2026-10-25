

--  Released into the public domain


--  A group freed before its children: the children made in Ada are
--  taken out of it and outlive it, and the ones FLTK made itself, such
--  as a Text_Display's scrollbars, are deleted with it.  Run it under
--  valgrind, which finds those scrollbars lost if the group took them
--  out too.


with

    Ada.Command_Line,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Groups.Trees;

use

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Groups.Trees;


procedure Group_Children is

    type Box_Access is access all Box'Class;
    type Display_Access is access all Text_Display'Class;
    type Tree_Access is access all Tree'Class;

    procedure Free is new Ada.Unchecked_Deallocation (Box'Class, Box_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Text_Display'Class, Display_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Tree'Class, Tree_Access);

    Failed : Boolean := False;

    procedure Check
           (Label     : in String;
            Condition : in Boolean) is
    begin
        if Condition then
            Ada.Text_IO.Put_Line ("ok   - " & Label);
        else
            Ada.Text_IO.Put_Line ("FAIL - " & Label);
            Failed := True;
        end if;
    end Check;

    Display : Display_Access;
    Holder  : Tree_Access;
    Child   : Box_Access;
    Before  : Natural;

begin

    Display := new Text_Display'(FLTK.Widgets.Groups.Text_Displays.Forge.Create (0, 0, 200, 100));
    Check ("a Text_Display has its two scrollbars", Display.Number_Of_Children = 2);
    Free (Display);

    Display := new Text_Display'(FLTK.Widgets.Groups.Text_Displays.Forge.Create (0, 0, 200, 100));
    Child := new Box'(FLTK.Widgets.Boxes.Forge.Create (0, 0, 10, 10));
    Display.Add (Child.all);
    Check ("a child added to it is its third", Display.Number_Of_Children = 3);
    Free (Display);
    Check ("the child outlives it, in no group", Child.Parent = null);
    Free (Child);

    Holder := new Tree'(FLTK.Widgets.Groups.Trees.Forge.Create (0, 0, 200, 100));
    Before := Holder.Number_Of_Children;
    Child := new Box'(FLTK.Widgets.Boxes.Forge.Create (0, 0, 10, 10));
    Holder.Add (Child.all);
    Free (Child);
    Check ("a child freed first leaves its group", Holder.Number_Of_Children = Before);
    Free (Holder);

    if Failed then
        Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
    end if;

end Group_Children;
