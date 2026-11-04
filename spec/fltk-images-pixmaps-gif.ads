

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.Pixmaps.GIF is


    type GIF_Image is new Pixmap with private;

    type GIF_Image_Reference (Data : not null access GIF_Image'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        --  A GIF whose sizes or LZW codes FLTK would follow past its
        --  buffers raises Format_Error, from a file or from memory.
        function Create
               (Filename : in String)
            return GIF_Image;

        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return GIF_Image;

    end Forge;




    --  Animation  --

    --  If set then Shared_Image, and anything that loads images by
    --  file type such as file chooser previews, will load animated GIF
    --  files as Animated_GIF_Image objects. Defaults to False.

    function Get_Animate
        return Boolean;

    procedure Set_Animate
           (Value : in Boolean);

    function Is_Animated
           (Filename : in String)
        return Boolean;


private


    type GIF_Image is new Pixmap with null record;

    overriding procedure Finalize
           (This : in out GIF_Image);


    pragma Inline (Get_Animate);
    pragma Inline (Set_Animate);
    pragma Inline (Is_Animated);


end FLTK.Images.Pixmaps.GIF;


