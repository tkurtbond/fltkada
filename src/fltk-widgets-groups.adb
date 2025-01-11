

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_group
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_group, "new_fl_group");
    pragma Inline (new_fl_group);

    procedure free_fl_group
           (G : in Storage.Integer_Address);
    pragma Import (C, free_fl_group, "free_fl_group");
    pragma Inline (free_fl_group);




    procedure fl_group_end
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_group_end, "fl_group_end");
    pragma Inline (fl_group_end);




    procedure fl_group_add
           (G, W : in Storage.Integer_Address);
    pragma Import (C, fl_group_add, "fl_group_add");
    pragma Inline (fl_group_add);

    procedure fl_group_insert
           (G, W : in Storage.Integer_Address;
            P    : in Interfaces.C.int);
    pragma Import (C, fl_group_insert, "fl_group_insert");
    pragma Inline (fl_group_insert);

    procedure fl_group_insert2
           (G, W, B : in Storage.Integer_Address);
    pragma Import (C, fl_group_insert2, "fl_group_insert2");
    pragma Inline (fl_group_insert2);

    procedure fl_group_remove
           (G, W : in Storage.Integer_Address);
    pragma Import (C, fl_group_remove, "fl_group_remove");
    pragma Inline (fl_group_remove);

    procedure fl_group_remove2
           (G : in Storage.Integer_Address;
            P : in Interfaces.C.int);
    pragma Import (C, fl_group_remove2, "fl_group_remove2");
    pragma Inline (fl_group_remove2);




    function fl_group_child
           (G : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_group_child, "fl_group_child");
    pragma Inline (fl_group_child);

    function fl_group_find
           (G, W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_group_find, "fl_group_find");
    pragma Inline (fl_group_find);

    function fl_group_children
           (G : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_group_children, "fl_group_children");
    pragma Inline (fl_group_children);




    --  function fl_group_get_clip_children
    --         (G : in Storage.Integer_Address)
    --      return Interfaces.C.unsigned;
    --  pragma Import (C, fl_group_get_clip_children, "fl_group_get_clip_children");
    --  pragma Inline (fl_group_get_clip_children);

    --  procedure fl_group_set_clip_children
    --         (G : in Storage.Integer_Address;
    --          C : in Interfaces.C.unsigned);
    --  pragma Import (C, fl_group_set_clip_children, "fl_group_set_clip_children");
    --  pragma Inline (fl_group_set_clip_children);




    function fl_group_get_resizable
           (G : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_group_get_resizable, "fl_group_get_resizable");
    pragma Inline (fl_group_get_resizable);

    procedure fl_group_set_resizable
           (G, W : in Storage.Integer_Address);
    pragma Import (C, fl_group_set_resizable, "fl_group_set_resizable");
    pragma Inline (fl_group_set_resizable);

    procedure fl_group_init_sizes
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_group_init_sizes, "fl_group_init_sizes");
    pragma Inline (fl_group_init_sizes);




    function fl_group_get_current
        return Storage.Integer_Address;
    pragma Import (C, fl_group_get_current, "fl_group_get_current");
    pragma Inline (fl_group_get_current);

    procedure fl_group_set_current
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_group_set_current, "fl_group_set_current");
    pragma Inline (fl_group_set_current);




    procedure fl_group_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_group_draw, "fl_group_draw");
    pragma Inline (fl_group_draw);

    function fl_group_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_group_handle, "fl_group_handle");
    pragma Inline (fl_group_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Group) is
    begin
        This.Clear;
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Group) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_group (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Group;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        fl_group_end (This.Void_Ptr);
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Group) is
    begin
        This.Draw_Ptr   := fl_group_draw'Address;
        This.Handle_Ptr := fl_group_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Group is
        begin
            return This : Group do
                This.Void_Ptr := new_fl_group
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    procedure Add
           (This : in out Group;
            Item : in out Widget'Class) is
    begin
        fl_group_add (This.Void_Ptr, Item.Void_Ptr);
    end Add;


    procedure Insert
           (This  : in out Group;
            Item  : in out Widget'Class;
            Place : in     Index) is
    begin
        fl_group_insert
               (This.Void_Ptr,
                Item.Void_Ptr,
                Interfaces.C.int (Place) - 1);
    end Insert;


    procedure Insert
           (This   : in out Group;
            Item   : in out Widget'Class;
            Before : in     Widget'Class) is
    begin
        fl_group_insert2
               (This.Void_Ptr,
                Item.Void_Ptr,
                Before.Void_Ptr);
    end Insert;


    procedure Remove
           (This : in out Group;
            Item : in out Widget'Class) is
    begin
        fl_group_remove (This.Void_Ptr, Item.Void_Ptr);
    end Remove;


    procedure Remove
           (This  : in out Group;
            Place : in     Index) is
    begin
        fl_group_remove2 (This.Void_Ptr, Interfaces.C.int (Place) - 1);
    end Remove;


    procedure Clear
           (This : in out Group) is
    begin
        for I in reverse 1 .. This.Number_Of_Children loop
            This.Remove (Index (I));
        end loop;
    end Clear;




    function Has_Child
           (This  : in Group;
            Place : in Index)
        return Boolean is
    begin
        return Place in 1 .. This.Number_Of_Children;
    end Has_Child;


    function Has_Child
           (Place : in Cursor)
        return Boolean is
    begin
        return Place.My_Container.Has_Child (Place.My_Index);
    end Has_Child;


    function Child
           (This  : in Group;
            Place : in Index)
        return Widget_Reference
    is
        Widget_Ptr : Storage.Integer_Address :=
            fl_group_child (This.Void_Ptr, Interfaces.C.int (Place) - 1);
        Actual_Widget : access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (fl_widget_get_user_data (Widget_Ptr)));
    begin
        return (Data => Actual_Widget);
    end Child;


    function Child
           (This  : in Group;
            Place : in Cursor)
        return Widget_Reference is
    begin
        return This.Child (Place.My_Index);
    end Child;


    function Find
           (This : in     Group;
            Item : in out Widget'Class)
        return Extended_Index
    is
        Ret : Interfaces.C.int;
    begin
        Ret := fl_group_find (This.Void_Ptr, Item.Void_Ptr);
        if Ret = fl_group_children (This.Void_Ptr) then
            return No_Index;
        end if;
        return Extended_Index (Ret + 1);
    end Find;


    function Number_Of_Children
           (This : in Group)
        return Natural is
    begin
        return Natural (fl_group_children (This.Void_Ptr));
    end Number_Of_Children;




    function Iterate
           (This : in Group)
        return Group_Iterators.Reversible_Iterator'Class is
    begin
        return It : Iterator := (My_Container => This'Unrestricted_Access);
    end Iterate;


    function First
           (Object : in Iterator)
        return Cursor is
    begin
        return Cu : Cursor :=
           (My_Container => Object.My_Container,
            My_Index     => 1);
    end First;


    function Next
           (Object : in Iterator;
            Place  : in Cursor)
        return Cursor is
    begin
        if Object.My_Container /= Place.My_Container then
            raise Program_Error;
        end if;
        return Cu : Cursor :=
           (My_Container => Place.My_Container,
            My_Index     => Place.My_Index + 1);
    end Next;


    function Last
           (Object : in Iterator)
        return Cursor is
    begin
        return Cu : Cursor :=
           (My_Container => Object.My_Container,
            My_Index     => Object.My_Container.Number_Of_Children);
    end Last;


    function Previous
           (Object : in Iterator;
            Place  : in Cursor)
        return Cursor is
    begin
        if Object.My_Container /= Place.My_Container then
            raise Program_Error;
        end if;
        return Cu : Cursor :=
           (My_Container => Place.My_Container,
            My_Index     => Place.My_Index - 1);
    end Previous;




    --  function Get_Clip_Mode
    --         (This : in Group)
    --      return Clip_Mode is
    --  begin
    --      return Clip_Mode'Val (fl_group_get_clip_children (This.Void_Ptr));
    --  end Get_Clip_Mode;


    --  procedure Set_Clip_Mode
    --         (This : in out Group;
    --          Mode : in     Clip_Mode) is
    --  begin
    --      fl_group_set_clip_children (This.Void_Ptr, Clip_Mode'Pos (Mode));
    --  end Set_Clip_Mode;




    function Get_Resizable
           (This : in Group)
        return access Widget'Class
    is
        Widget_Ptr : Storage.Integer_Address :=
            fl_group_get_resizable (This.Void_Ptr);
        Actual_Widget : access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (fl_widget_get_user_data (Widget_Ptr)));
    begin
        return Actual_Widget;
    end Get_Resizable;


    procedure Set_Resizable
           (This : in out Group;
            Item : in     Widget'Class) is
    begin
        fl_group_set_resizable (This.Void_Ptr, Item.Void_Ptr);
    end Set_Resizable;


    procedure Reset_Initial_Sizes
           (This : in out Group) is
    begin
        fl_group_init_sizes (This.Void_Ptr);
    end Reset_Initial_Sizes;




    function Get_Current
        return access Group'Class
    is
        Group_Ptr : Storage.Integer_Address := fl_group_get_current;
        Actual_Group : access Group'Class;
    begin
        if Group_Ptr /= Null_Pointer then
            Actual_Group := Group_Convert.To_Pointer (Storage.To_Address (Group_Ptr));
        end if;
        return Actual_Group;
    end Get_Current;


    procedure Set_Current
           (To : in Group'Class) is
    begin
        fl_group_set_current (To.Void_Ptr);
    end Set_Current;




    procedure Draw
           (This : in out Group) is
    begin
        Widget (This).Draw;
    end Draw;


    function Handle
           (This  : in out Group;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups;


