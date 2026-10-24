

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Ada.Unchecked_Conversion;


package body FLTK.Multi_Labels is


    package ICS renames Interfaces.C.Strings;


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_multi_label
        return Storage.Integer_Address;
    pragma Import (C, new_fl_multi_label, "new_fl_multi_label");
    pragma Inline (new_fl_multi_label);

    procedure free_fl_multi_label
           (L : in Storage.Integer_Address);
    pragma Import (C, free_fl_multi_label, "free_fl_multi_label");
    pragma Inline (free_fl_multi_label);




    procedure fl_multi_label_set_a
           (L : in Storage.Integer_Address;
            K : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_multi_label_set_a, "fl_multi_label_set_a");
    pragma Inline (fl_multi_label_set_a);

    procedure fl_multi_label_set_b
           (L : in Storage.Integer_Address;
            K : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_multi_label_set_b, "fl_multi_label_set_b");
    pragma Inline (fl_multi_label_set_b);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out Multi_Label) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_multi_label (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        ICS.Free (This.My_Text_A);
        ICS.Free (This.My_Text_B);
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
            return Multi_Label is
        begin
            return This : Multi_Label do
                This.Void_Ptr := new_fl_multi_label;
                This.My_Text_A := ICS.Null_Ptr;
                This.My_Text_B := ICS.Null_Ptr;
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Parts  --

    function To_Address is new Ada.Unchecked_Conversion (ICS.chars_ptr, Storage.Integer_Address);


    procedure Set_First
           (This : in out Multi_Label;
            Text : in     String;
            Kind : in     Label_Kind := Normal_Label)
    is
        Old : ICS.chars_ptr := This.My_Text_A;
    begin
        This.My_Text_A := ICS.New_String (Text);
        fl_multi_label_set_a (This.Void_Ptr, Label_Kind'Pos (Kind), To_Address (This.My_Text_A));
        ICS.Free (Old);
    end Set_First;


    procedure Set_First
           (This : in out Multi_Label;
            Pict : in out FLTK.Images.Image'Class) is
    begin
        fl_multi_label_set_a
           (This.Void_Ptr, Label_Kind'Pos (FLTK.Image_Label), Wrapper (Pict).Void_Ptr);
        ICS.Free (This.My_Text_A);
    end Set_First;


    procedure Set_First
           (This : in out Multi_Label;
            Next : in out Multi_Label'Class) is
    begin
        fl_multi_label_set_a
           (This.Void_Ptr, Label_Kind'Pos (FLTK.Multi_Label), Wrapper (Next).Void_Ptr);
        ICS.Free (This.My_Text_A);
    end Set_First;


    procedure Set_Second
           (This : in out Multi_Label;
            Text : in     String;
            Kind : in     Label_Kind := Normal_Label)
    is
        Old : ICS.chars_ptr := This.My_Text_B;
    begin
        This.My_Text_B := ICS.New_String (Text);
        fl_multi_label_set_b (This.Void_Ptr, Label_Kind'Pos (Kind), To_Address (This.My_Text_B));
        ICS.Free (Old);
    end Set_Second;


    procedure Set_Second
           (This : in out Multi_Label;
            Pict : in out FLTK.Images.Image'Class) is
    begin
        fl_multi_label_set_b
           (This.Void_Ptr, Label_Kind'Pos (FLTK.Image_Label), Wrapper (Pict).Void_Ptr);
        ICS.Free (This.My_Text_B);
    end Set_Second;


    procedure Set_Second
           (This : in out Multi_Label;
            Next : in out Multi_Label'Class) is
    begin
        fl_multi_label_set_b
           (This.Void_Ptr, Label_Kind'Pos (FLTK.Multi_Label), Wrapper (Next).Void_Ptr);
        ICS.Free (This.My_Text_B);
    end Set_Second;


end FLTK.Multi_Labels;


