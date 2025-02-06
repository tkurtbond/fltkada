

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Boxes is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_box
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_box, "new_fl_box");
    pragma Inline (new_fl_box);

    function new_fl_box2
           (K, X, Y, W, H : in Interfaces.C.int;
            Text          : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_box2, "new_fl_box2");
    pragma Inline (new_fl_box2);

    procedure free_fl_box
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_box, "free_fl_box");
    pragma Inline (free_fl_box);




    --  Drawing, Events  --

    procedure fl_box_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_box_draw, "fl_box_draw");
    pragma Inline (fl_box_draw);

    function fl_box_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_box_handle, "fl_box_handle");
    pragma Inline (fl_box_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Box) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Box) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_box (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Box;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Box) is
    begin
        This.Draw_Ptr   := fl_box_draw'Address;
        This.Handle_Ptr := fl_box_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Box is
        begin
            return This : Box do
                This.Void_Ptr := new_fl_box
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Box is
        begin
            return This : Box := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;


        function Create
               (Kind       : in Box_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Box is
        begin
            return This : Box do
                This.Void_Ptr := new_fl_box2
                   (Box_Kind'Pos (Kind),
                    Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                Kind       : in     Box_Kind;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Box is
        begin
            return This : Box := Create (Kind, X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Drawing, Events  --

    procedure Draw
           (This : in out Box) is
    begin
        Widget (This).Draw;
    end Draw;


    function Handle
           (This  : in out Box;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Boxes;


