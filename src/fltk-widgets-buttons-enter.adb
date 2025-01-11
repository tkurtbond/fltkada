

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Buttons.Enter is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_return_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_return_button, "new_fl_return_button");
    pragma Inline (new_fl_return_button);

    procedure free_fl_return_button
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_return_button, "free_fl_return_button");
    pragma Inline (free_fl_return_button);




    procedure fl_return_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_return_button_draw, "fl_return_button_draw");
    pragma Inline (fl_return_button_draw);

    function fl_return_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_return_button_handle, "fl_return_button_handle");
    pragma Inline (fl_return_button_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Enter_Button) is
    begin
        Extra_Final (Button (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Enter_Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_return_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Enter_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Button (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Enter_Button) is
    begin
        This.Draw_Ptr   := fl_return_button_draw'Address;
        This.Handle_Ptr := fl_return_button_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Enter_Button is
        begin
            return This : Enter_Button do
                This.Void_Ptr := new_fl_return_button
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

    procedure Draw
           (This : in out Enter_Button) is
    begin
        Button (This).Draw;
    end Draw;


    function Handle
           (This  : in out Enter_Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Button (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Buttons.Enter;


