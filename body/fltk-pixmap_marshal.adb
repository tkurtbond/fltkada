

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Unchecked_Deallocation,
    FLTK.Images.Pixmaps;


package body FLTK.Pixmap_Marshal is


    package SU  renames Ada.Strings.Unbounded;
    package Pix renames FLTK.Images.Pixmaps;
    package C   renames Interfaces.C;
    package CS  renames Interfaces.C.Strings;




    function To_Coltype
           (Value : in Pix.Color_Kind)
        return Character is
    begin
        case Value is
        when Pix.Colorful   => return 'c';
        when Pix.Monochrome => return 'm';
        when Pix.Greyscale  => return 'g';
        when Pix.Symbolic   => return 's';
        end case;
    end To_Coltype;




    function Marshal_Data
           (Values : in Pix.Header;
            Colors : in Pix.Color_Definition_Array;
            Pixels : in Pix.Pixmap_Data)
        return chars_ptr_array_access
    is
        type Big is range 0 .. 2 ** 62;
        C_Data : chars_ptr_array_access;
    begin
        --  FLTK reads as many lines, and characters in a line, as the
        --  header says, so a header bigger than the data has it read past
        --  the end (fl_draw_pixmap.cxx:103-171).  It also sizes the image
        --  drawn as an int (Fl_Image.cxx:445), and fl_draw_pixmap
        --  allocates Width * Height * 4 bytes.  Pre doesn't hold in a
        --  release build (PLAN.md, Architecture decisions, 1).
        if Big (Values.Width) * Big (Values.Height) * 4 > Big (C.int'Last) then
            raise Constraint_Error with "a Pixmap too big for FLTK";
        end if;
        if Colors'Length /= Values.Colors then
            raise Constraint_Error with "a Pixmap with" & Natural'Image (Colors'Length) &
                " colors, not" & Positive'Image (Values.Colors);
        end if;
        if Pixels'Length (1) /= Values.Height then
            raise Constraint_Error with "a Pixmap with" &
                Natural'Image (Pixels'Length (1)) & " lines, not" &
                Positive'Image (Values.Height);
        end if;
        if Big (Pixels'Length (2)) /= Big (Values.Width) * Big (Values.Per_Pixel) then
            raise Constraint_Error with "a Pixmap with lines of" &
                Natural'Image (Pixels'Length (2)) & " characters, not" &
                Big'Image (Big (Values.Width) * Big (Values.Per_Pixel));
        end if;
        for Definition of Colors loop
            if SU.Length (Definition.Name) /= Values.Per_Pixel then
                raise Constraint_Error with "a Pixmap color named """ &
                    SU.To_String (Definition.Name) & """, not" &
                    Positive'Image (Values.Per_Pixel) & " characters";
            end if;
        end loop;
        C_Data := new CS.chars_ptr_array (1 .. C.size_t (1 + Colors'Length + Pixels'Length (1)));
        --  Header values line
        C_Data (1) := CS.New_String (Ada.Strings.Fixed.Trim
           ((Positive'Image (Values.Width)  & Positive'Image (Values.Height) &
             Positive'Image (Values.Colors) & Positive'Image (Values.Per_Pixel)),
            Ada.Strings.Left));

        --  Color definition lines
        for Place in 1 .. Colors'Length loop
            C_Data (C.size_t (Place + 1)) := CS.New_String
               (SU.To_String (Colors (Colors'First + Place - 1).Name) & " " &
                To_Coltype   (Colors (Colors'First + Place - 1).Kind) & " " &
                SU.To_String (Colors (Colors'First + Place - 1).Value));
        end loop;

        --  Pixel data lines
        for Place in 1 .. Pixels'Length (1) loop
            declare
                Line : String (1 .. Pixels'Length (2));
                for Line'Address use
                    Pixels (Pixels'First (1) + Place - 1, Pixels'First (2))'Address;
                pragma Import (Ada, Line);
            begin
                C_Data (C.size_t (Place + 1 + Colors'Length)) := CS.New_String (Line);
            end;
        end loop;

        return C_Data;
    end Marshal_Data;




    procedure Free is new Ada.Unchecked_Deallocation
        (Interfaces.C.Strings.chars_ptr_array, chars_ptr_array_access);

    procedure Free_Recursive
           (This : in out chars_ptr_array_access) is
    begin
        if This /= null then
            for Item of This.all loop
                CS.Free (Item);
            end loop;
            Free (This);
        end if;
    end Free_Recursive;


end FLTK.Pixmap_Marshal;


