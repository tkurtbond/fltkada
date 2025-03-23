

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Pixmap_Marshal;


package body FLTK.Images.Pixmaps is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_pixmap
           (D : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pixmap, "new_fl_pixmap");
    pragma Inline (new_fl_pixmap);

    procedure free_fl_pixmap
           (I : in Storage.Integer_Address);
    pragma Import (C, free_fl_pixmap, "free_fl_pixmap");
    pragma Inline (free_fl_pixmap);




    --  Copying  --

    function fl_pixmap_copy
           (I    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_pixmap_copy, "fl_pixmap_copy");
    pragma Inline (fl_pixmap_copy);

    function fl_pixmap_copy2
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_pixmap_copy2, "fl_pixmap_copy2");
    pragma Inline (fl_pixmap_copy2);




    --  Colors  --

    procedure fl_pixmap_color_average
           (I : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_pixmap_color_average, "fl_pixmap_color_average");
    pragma Inline (fl_pixmap_color_average);

    procedure fl_pixmap_desaturate
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_pixmap_desaturate, "fl_pixmap_desaturate");
    pragma Inline (fl_pixmap_desaturate);




    --  Activity  --

    procedure fl_pixmap_uncache
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_pixmap_uncache, "fl_pixmap_uncache");
    pragma Inline (fl_pixmap_uncache);




    --  Drawing  --

    procedure fl_pixmap_draw2
           (I    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_pixmap_draw2, "fl_pixmap_draw2");
    pragma Inline (fl_pixmap_draw2);

    procedure fl_pixmap_draw
           (I                  : in Storage.Integer_Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_pixmap_draw, "fl_pixmap_draw");
    pragma Inline (fl_pixmap_draw);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out Pixmap) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            Pixmap_Marshal.Free_Recursive (This.Loose_Ptr);
            free_fl_pixmap (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Values : in Header;
                Colors : in Color_Definition_Array;
                Pixels : in Pixmap_Data)
            return Pixmap is
        begin
            return This : Pixmap do
                This.Loose_Ptr := Pixmap_Marshal.Marshal_Data (Values, Colors, Pixels);
                This.Void_Ptr := new_fl_pixmap
                    (Storage.To_Integer (This.Loose_Ptr (This.Loose_Ptr'First)'Address));
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Copying  --

    function Copy
           (This          : in Pixmap;
            Width, Height : in Natural)
        return Pixmap'Class is
    begin
        return Copied : Pixmap do
            Copied.Void_Ptr := fl_pixmap_copy
               (This.Void_Ptr,
                Interfaces.C.int (Width),
                Interfaces.C.int (Height));
        end return;
    end Copy;


    function Copy
           (This : in Pixmap)
        return Pixmap'Class is
    begin
        return Copied : Pixmap do
            Copied.Void_Ptr := fl_pixmap_copy2 (This.Void_Ptr);
        end return;
    end Copy;




    --  Colors  --

    procedure Color_Average
           (This   : in out Pixmap;
            Col    : in     Color;
            Amount : in     Blend) is
    begin
        fl_pixmap_color_average
           (This.Void_Ptr,
            Interfaces.C.int (Col),
            Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out Pixmap) is
    begin
        fl_pixmap_desaturate (This.Void_Ptr);
    end Desaturate;




    --  Activity  --

    procedure Uncache
           (This : in out Pixmap) is
    begin
        fl_pixmap_uncache (This.Void_Ptr);
    end Uncache;




    --  Drawing  --

    procedure Draw
           (This : in Pixmap;
            X, Y : in Integer) is
    begin
        fl_pixmap_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw;


    procedure Draw
           (This           : in Pixmap;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0) is
    begin
        fl_pixmap_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Clip_X),
            Interfaces.C.int (Clip_Y));
    end Draw;


end FLTK.Images.Pixmaps;


