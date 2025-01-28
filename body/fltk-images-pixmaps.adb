

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Unchecked_Deallocation,
    Interfaces.C.Strings;


package body FLTK.Images.Pixmaps is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_pixmap
           (D : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pixmap, "new_fl_pixmap");
    pragma Inline (new_fl_pixmap);

    procedure free_fl_pixmap
           (I : in Storage.Integer_Address);
    pragma Import (C, free_fl_pixmap, "free_fl_pixmap");
    pragma Inline (free_fl_pixmap);

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




    procedure fl_pixmap_uncache
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_pixmap_uncache, "fl_pixmap_uncache");
    pragma Inline (fl_pixmap_uncache);




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

    type chars_ptr_array_access is access all Interfaces.C.Strings.chars_ptr_array;

    procedure Free is new Ada.Unchecked_Deallocation
        (Interfaces.C.Strings.chars_ptr_array, chars_ptr_array_access);

    overriding procedure Finalize
           (This : in out Pixmap) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            if This.Loose_Ptr /= null then
                for Item of This.Loose_Ptr.all loop
                    Interfaces.C.Strings.Free (Item);
                end loop;
                Free (This.Loose_Ptr);
            end if;
            free_fl_pixmap (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function To_Coltype
               (Value : in Color_Kind)
            return Character is
        begin
            case Value is
            when Colorful   => return 'c';
            when Monochrome => return 'm';
            when Greyscale  => return 'g';
            when Symbolic   => return 's';
            end case;
        end To_Coltype;


        function Create
               (Values : in Header;
                Colors : in Color_Definition_Array;
                Pixels : in Pixmap_Data)
            return Pixmap
        is
            use Interfaces.C.Strings;
            C_Data : access chars_ptr_array := new chars_ptr_array
                (1 .. Interfaces.C.size_t (1 + Colors'Length + Pixels'Length (1)));
        begin
            --  Header values line
            C_Data (1) := New_String (Ada.Strings.Fixed.Trim
               ((Positive'Image (Values.Width)  & Positive'Image (Values.Height) &
                 Positive'Image (Values.Colors) & Positive'Image (Values.Per_Pixel)),
                Ada.Strings.Left));

            --  Color definition lines
            for Place in 1 .. Colors'Length loop
                C_Data (Interfaces.C.size_t (Place + 1)) := New_String
                   (Ada.Strings.Unbounded.To_String (Colors (Colors'First + Place - 1).Name) & " " &
                    To_Coltype (Colors (Colors'First + Place - 1).Kind) & " " &
                    Ada.Strings.Unbounded.To_String (Colors (Colors'First + Place - 1).Value));
            end loop;

            --  Pixel data lines
            for Place in 1 .. Pixels'Length (1) loop
                declare
                    Line : String (1 .. Pixels'Length (2));
                    for Line'Address use Pixels (Pixels'First (1) + Place - 1, 1)'Address;
                    pragma Import (Ada, Line);
                begin
                    C_Data (Interfaces.C.size_t (Place + 1 + Colors'Length)) := New_String (Line);
                end;
            end loop;

            --  Pass it all off to C++ to actually create the cursed thing
            return This : Pixmap do
                This.Void_Ptr := new_fl_pixmap (Storage.To_Integer (C_Data (C_Data'First)'Address));
                This.Loose_Ptr := C_Data;  --  Much easier to save this for later
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

