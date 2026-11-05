

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Unchecked_Deallocation,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups is


    package Chk renames Ada.Assertions;


    procedure Free is new Ada.Unchecked_Deallocation (Address_Array, Address_Array_Access);




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

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




    --  Contents Modification  --

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




    --  Contents Query  --

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




    --  Clipping  --

    function fl_group_get_clip_children
           (G : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_group_get_clip_children, "fl_group_get_clip_children");
    pragma Inline (fl_group_get_clip_children);

    procedure fl_group_set_clip_children
           (G : in Storage.Integer_Address;
            C : in Interfaces.C.int);
    pragma Import (C, fl_group_set_clip_children, "fl_group_set_clip_children");
    pragma Inline (fl_group_set_clip_children);




    --  Dimensions  --

    procedure fl_group_add_resizable
           (G, W : in Storage.Integer_Address);
    pragma Import (C, fl_group_add_resizable, "fl_group_add_resizable");
    pragma Inline (fl_group_add_resizable);

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

    procedure fl_group_resize
           (G          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_group_resize, "fl_group_resize");
    pragma Inline (fl_group_resize);




    --  Current  --

    function fl_group_get_current
        return Storage.Integer_Address;
    pragma Import (C, fl_group_get_current, "fl_group_get_current");
    pragma Inline (fl_group_get_current);

    procedure fl_group_set_current
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_group_set_current, "fl_group_set_current");
    pragma Inline (fl_group_set_current);

    procedure fl_group_begin
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_group_begin, "fl_group_begin");
    pragma Inline (fl_group_begin);

    procedure fl_group_end
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_group_end, "fl_group_end");
    pragma Inline (fl_group_end);




    --  Drawing, Events  --

    procedure fl_group_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_group_draw, "fl_group_draw");
    pragma Inline (fl_group_draw);

    procedure fl_group_draw_child
           (G, W : in Storage.Integer_Address);
    pragma Import (C, fl_group_draw_child, "fl_group_draw_child");
    pragma Inline (fl_group_draw_child);

    procedure fl_group_draw_children
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_group_draw_children, "fl_group_draw_children");
    pragma Inline (fl_group_draw_children);

    procedure fl_group_draw_outside_label
           (G, W : in Storage.Integer_Address);
    pragma Import (C, fl_group_draw_outside_label, "fl_group_draw_outside_label");
    pragma Inline (fl_group_draw_outside_label);

    procedure fl_group_update_child
           (G, W : in Storage.Integer_Address);
    pragma Import (C, fl_group_update_child, "fl_group_update_child");
    pragma Inline (fl_group_update_child);

    function fl_group_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_group_handle, "fl_group_handle");
    pragma Inline (fl_group_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Remove_Ada_Children
           (This : in out Group)
    is
        function Is_Internal
               (Child_Ptr : in Storage.Integer_Address)
            return Boolean is
        begin
            if This.Internal /= null then
                for Item of This.Internal.all loop
                    if Item = Child_Ptr then
                        return True;
                    end if;
                end loop;
            end if;
            return False;
        end Is_Internal;
    begin
        --  Children with Ada objects are removed, as their Ada objects
        --  delete them, but the ones FLTK made are left for the C++
        --  destructor to delete.
        for I in reverse 1 .. This.Number_Of_Children loop
            if not Is_Internal (fl_group_child (This.Void_Ptr, Interfaces.C.int (I) - 1)) then
                This.Remove (Index (I));
            end if;
        end loop;
    end Remove_Ada_Children;


    procedure Extra_Final
           (This : in out Group) is
    begin
        if This.Needs_Dealloc and This.Void_Ptr /= Null_Pointer then
            This.Remove_Ada_Children;
        end if;
        Free (This.Internal);
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
            Text       : in     String)
    is
        Count : constant Natural := This.Number_Of_Children;
    begin
        fl_group_end (This.Void_Ptr);
        if Count > 0 then
            This.Internal := new Address_Array (1 .. Count);
            for I in This.Internal'Range loop
                This.Internal (I) := fl_group_child (This.Void_Ptr, Interfaces.C.int (I) - 1);
            end loop;
        end if;
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


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Group is
        begin
            return This : Group := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Contents Modification  --

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
        --  We don't use the actual clear method here because
        --  that would delete the children from memory.  The children FLTK
        --  made, such as a spinner's field and buttons, are part of the
        --  group and stay (pofltk 23).
        This.Remove_Ada_Children;
    end Clear;




    --  Contents Query  --

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
        Actual_Widget : access Widget'Class;
    begin
        --  A part FLTK made, such as a terminal's scrollbar, has no Ada object.
        Widget_Ptr := fl_widget_get_user_data (Widget_Ptr);
        if Widget_Ptr = Null_Pointer then
            raise Internal_FLTK_Error with
                "Fl_Group::child returned Widget with no user_data reference back to Ada";
        end if;
        Actual_Widget := Widget_Convert.To_Pointer (Storage.To_Address (Widget_Ptr));
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
           (This : in Group;
            Item : in Widget'Class)
        return Extended_Index
    is
        Result : constant Interfaces.C.int := fl_group_find (This.Void_Ptr, Item.Void_Ptr);
    begin
        if Result = fl_group_children (This.Void_Ptr) then
            return No_Index;
        end if;
        return Extended_Index (Result + 1);
    end Find;


    function Number_Of_Children
           (This : in Group)
        return Natural is
    begin
        return Natural (fl_group_children (This.Void_Ptr));
    end Number_Of_Children;




    --  Iteration  --

    function Iterate
           (This : in Group)
        return Group_Iterators.Reversible_Iterator'Class is
    begin
        return It : constant Iterator := (My_Container => This'Unrestricted_Access);
    end Iterate;


    function First
           (Object : in Iterator)
        return Cursor is
    begin
        return Cu : constant Cursor :=
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
        return Cu : constant Cursor :=
           (My_Container => Place.My_Container,
            My_Index     => Place.My_Index + 1);
    end Next;


    function Last
           (Object : in Iterator)
        return Cursor is
    begin
        return Cu : constant Cursor :=
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
        return Cu : constant Cursor :=
           (My_Container => Place.My_Container,
            My_Index     => Place.My_Index - 1);
    end Previous;




    --  Clipping  --

    function Get_Clip_Mode
           (This : in Group)
        return Clip_Mode
    is
        Result : constant Interfaces.C.unsigned := fl_group_get_clip_children (This.Void_Ptr);
    begin
        return Clip_Mode'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Group::clip_children returned unexpected unsigned int value of " &
        Interfaces.C.unsigned'Image (Result);
    end Get_Clip_Mode;


    procedure Set_Clip_Mode
           (This : in out Group;
            Mode : in     Clip_Mode := Clip) is
    begin
        fl_group_set_clip_children (This.Void_Ptr, Clip_Mode'Pos (Mode));
    end Set_Clip_Mode;




    --  Dimensions  --

    procedure Add_Resizable
           (This : in out Group;
            Item : in out Widget'Class) is
    begin
        fl_group_add_resizable (This.Void_Ptr, Item.Void_Ptr);
    end Add_Resizable;


    function Get_Resizable
           (This : in Group)
        return access Widget'Class
    is
        Widget_Ptr : Storage.Integer_Address := fl_group_get_resizable (This.Void_Ptr);
        Actual_Widget : access Widget'Class;
    begin
        if Widget_Ptr /= Null_Pointer then
            Widget_Ptr := fl_widget_get_user_data (Widget_Ptr);
            pragma Assert (Widget_Ptr /= Null_Pointer);
            Actual_Widget := Widget_Convert.To_Pointer (Storage.To_Address (Widget_Ptr));
        end if;
        return Actual_Widget;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Group::resizable returned Widget with no user_data reference back to Ada";
    end Get_Resizable;


    procedure Set_Resizable
           (This : in out Group;
            Item : in     Widget'Class) is
    begin
        fl_group_set_resizable (This.Void_Ptr, Item.Void_Ptr);
    end Set_Resizable;


    procedure Clear_Resizable
           (This : in out Group) is
    begin
        fl_group_set_resizable (This.Void_Ptr, Null_Pointer);
    end Clear_Resizable;


    procedure Reset_Sizes
           (This : in out Group) is
    begin
        fl_group_init_sizes (This.Void_Ptr);
    end Reset_Sizes;


    procedure Resize
           (This       : in out Group;
            X, Y, W, H : in     Integer) is
    begin
        fl_group_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --  Current  --

    function Get_Current
        return access Group'Class
    is
        Group_Ptr : Storage.Integer_Address := fl_group_get_current;
        Actual_Group : access Group'Class;
    begin
        if Group_Ptr /= Null_Pointer then
            Group_Ptr := fl_widget_get_user_data (Group_Ptr);
            pragma Assert (Group_Ptr /= Null_Pointer);
            Actual_Group := Group_Convert.To_Pointer (Storage.To_Address (Group_Ptr));
        end if;
        return Actual_Group;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Group::current returned Widget with no user_data reference back to Ada";
    end Get_Current;


    procedure Set_Current
           (To : in Group'Class) is
    begin
        fl_group_set_current (To.Void_Ptr);
    end Set_Current;


    procedure Begin_Current
           (This : in out Group) is
    begin
        fl_group_begin (This.Void_Ptr);
    end Begin_Current;


    procedure End_Current
           (This : in out Group) is
    begin
        fl_group_end (This.Void_Ptr);
    end End_Current;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Group) is
    begin
        Widget (This).Draw;
    end Draw;


    procedure Draw_Child
           (This : in out Group;
            Item : in out Widget'Class) is
    begin
        fl_group_draw_child (This.Void_Ptr, Item.Void_Ptr);
    end Draw_Child;


    procedure Draw_Children
           (This : in out Group) is
    begin
        fl_group_draw_children (This.Void_Ptr);
    end Draw_Children;


    procedure Draw_Outside_Label
           (This : in out Group;
            Item : in out Widget'Class) is
    begin
        fl_group_draw_outside_label (This.Void_Ptr, Item.Void_Ptr);
    end Draw_Outside_Label;


    procedure Update_Child
           (This : in out Group;
            Item : in out Widget'Class) is
    begin
        fl_group_update_child (This.Void_Ptr, Item.Void_Ptr);
    end Update_Child;


    function Handle
           (This  : in out Group;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups;


