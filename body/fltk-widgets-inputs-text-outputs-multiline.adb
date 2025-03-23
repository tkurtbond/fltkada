

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups;


package body FLTK.Widgets.Inputs.Text.Outputs.Multiline is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_multiline_output
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_multiline_output, "new_fl_multiline_output");
    pragma Inline (new_fl_multiline_output);

    procedure free_fl_multiline_output
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_multiline_output, "free_fl_multiline_output");
    pragma Inline (free_fl_multiline_output);




    --  Drawing, Events  --

    procedure fl_multiline_output_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_multiline_output_draw, "fl_multiline_output_draw");
    pragma Inline (fl_multiline_output_draw);

    function fl_multiline_output_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_multiline_output_handle, "fl_multiline_output_handle");
    pragma Inline (fl_multiline_output_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Multiline_Output) is
    begin
        Extra_Final (Output (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Multiline_Output) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_multiline_output (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Multiline_Output;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Output (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Multiline_Output) is
    begin
        This.Draw_Ptr   := fl_multiline_output_draw'Address;
        This.Handle_Ptr := fl_multiline_output_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Multiline_Output is
        begin
            return This : Multiline_Output do
                This.Void_Ptr := new_fl_multiline_output
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
            return Multiline_Output is
        begin
            return This : Multiline_Output := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;


end FLTK.Widgets.Inputs.Text.Outputs.Multiline;


