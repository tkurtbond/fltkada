

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Dials.Line is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_line_dial
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_line_dial, "new_fl_line_dial");
    pragma Inline (new_fl_line_dial);

    procedure free_fl_line_dial
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_line_dial, "free_fl_line_dial");
    pragma Inline (free_fl_line_dial);




    --  Drawing, Events  --

    procedure fl_line_dial_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_line_dial_draw, "fl_line_dial_draw");
    pragma Inline (fl_line_dial_draw);

    function fl_line_dial_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_line_dial_handle, "fl_line_dial_handle");
    pragma Inline (fl_line_dial_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Line_Dial) is
    begin
        Extra_Final (Dial (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Line_Dial) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_line_dial (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Line_Dial;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Dial (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Line_Dial) is
    begin
        This.Draw_Ptr   := fl_line_dial_draw'Address;
        This.Handle_Ptr := fl_line_dial_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Line_Dial is
        begin
            return This : Line_Dial do
                This.Void_Ptr := new_fl_line_dial
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
            return Line_Dial is
        begin
            return This : Line_Dial := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;


end FLTK.Widgets.Valuators.Dials.Line;


