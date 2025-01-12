

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Inputs.Text is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_text_input
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_text_input, "new_fl_text_input");
    pragma Inline (new_fl_text_input);

    procedure free_fl_text_input
           (T : in Storage.Integer_Address);
    pragma Import (C, free_fl_text_input, "free_fl_text_input");
    pragma Inline (free_fl_text_input);




    procedure fl_text_input_draw
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_text_input_draw, "fl_text_input_draw");
    pragma Inline (fl_text_input_draw);

    function fl_text_input_handle
           (T : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_input_handle, "fl_text_input_handle");
    pragma Inline (fl_text_input_handle);




    -------------------
    --  Destructors  --
    -------------------

    --  Message received, every zig will take off
    procedure text_input_extra_final_hook
           (Ada_Obj : in Storage.Integer_Address);
    pragma Export (C, text_input_extra_final_hook, "text_input_extra_final_hook");

    procedure text_input_extra_final_hook
           (Ada_Obj : in Storage.Integer_Address)
    is
        My_Text_Input : Text_Input;
        for My_Text_Input'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Text_Input);
    begin
        Extra_Final (My_Text_Input);
    end text_input_extra_final_hook;


    procedure Extra_Final
           (This : in out Text_Input) is
    begin
        Extra_Final (Input (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Text_Input) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_text_input (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Last stop, everyone out!
    procedure text_input_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr);
    pragma Export (C, text_input_extra_init_hook, "text_input_extra_init_hook");

    procedure text_input_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr)
    is
        My_Text_Input : Text_Input;
        for My_Text_Input'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Text_Input);
    begin
        Extra_Init
           (My_Text_Input,
            Integer (X), Integer (Y),
            Integer (W), Integer (H),
            Interfaces.C.Strings.Value (C_Str));
    end text_input_extra_init_hook;


    procedure Extra_Init
           (This       : in out Text_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Input (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Text_Input) is
    begin
        This.Draw_Ptr   := fl_text_input_draw'Address;
        This.Handle_Ptr := fl_text_input_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Text_Input is
        begin
            return This : Text_Input do
                This.Void_Ptr := new_fl_text_input
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
           (This : in out Text_Input) is
    begin
        Input (This).Draw;
    end Draw;


    function Handle
           (This  : in out Text_Input;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Input (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Inputs.Text;


