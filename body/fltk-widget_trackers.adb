--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package body FLTK.Widget_Trackers is


    use type Interfaces.C.int;


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_widget_tracker
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_widget_tracker, "new_fl_widget_tracker");
    pragma Inline (new_fl_widget_tracker);

    procedure free_fl_widget_tracker
           (T : in Storage.Integer_Address);
    pragma Import (C, free_fl_widget_tracker, "free_fl_widget_tracker");
    pragma Inline (free_fl_widget_tracker);




    function fl_widget_tracker_exists
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_tracker_exists, "fl_widget_tracker_exists");
    pragma Inline (fl_widget_tracker_exists);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out Widget_Tracker) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_widget_tracker (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        This.Watched := null;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
            return Widget_Tracker is
        begin
            return This : Widget_Tracker do
                This.Watched := null;
            end return;
        end Create;


        function Create
               (Item : in out FLTK.Widgets.Widget'Class)
            return Widget_Tracker is
        begin
            return This : Widget_Tracker do
                This.Track (Item);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    procedure Track
           (This : in out Widget_Tracker;
            Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Wrapper (Item).Void_Ptr = Null_Pointer then
            raise Program_Error with "Widget_Trackers.Track: the widget has no FLTK widget";
        end if;
        if This.Void_Ptr /= Null_Pointer then
            free_fl_widget_tracker (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        This.Watched := null;
        This.Void_Ptr := new_fl_widget_tracker (Wrapper (Item).Void_Ptr);
        This.Needs_Dealloc := True;
        This.Watched := Item'Unchecked_Access;
    end Track;


    function Exists
           (This : in Widget_Tracker)
        return Boolean is
    begin
        return This.Void_Ptr /= Null_Pointer
            and then fl_widget_tracker_exists (This.Void_Ptr) /= 0;
    end Exists;


    function Deleted
           (This : in Widget_Tracker)
        return Boolean is
    begin
        return not This.Exists;
    end Deleted;


    function Item
           (This : in Widget_Tracker)
        return access FLTK.Widgets.Widget'Class is
    begin
        if This.Exists then
            return This.Watched;
        else
            return null;
        end if;
    end Item;


end FLTK.Widget_Trackers;

