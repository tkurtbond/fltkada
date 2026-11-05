

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Ada.Containers.Vectors,
    Ada.Unchecked_Deallocation,
    FLTK.Images.Shared,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Tree_Icons is


    type Image_Access is access FLTK.Images.Image'Class;

    procedure Free is new Ada.Unchecked_Deallocation (FLTK.Images.Image'Class, Image_Access);

    type Held is record
        Tree  : Storage.Integer_Address;
        Image : Image_Access;
        Kept  : Boolean;
    end record;

    package Held_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Held);

    Store : Held_Vectors.Vector;


    function fl_tree_shows_icon
           (T, Img : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_shows_icon, "fl_tree_shows_icon");
    pragma Inline (fl_tree_shows_icon);

    function fl_shared_image_own_copy
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_own_copy, "fl_shared_image_own_copy");
    pragma Inline (fl_shared_image_own_copy);


    function Pointer
           (Image : in Image_Access)
        return Storage.Integer_Address is
    begin
        return Wrapper (Image.all).Void_Ptr;
    end Pointer;


    function Hold
           (Tree : in Storage.Integer_Address;
            Pic  : in FLTK.Images.Image'Class;
            Kept : in Boolean)
        return Storage.Integer_Address
    is
        Copied : constant Image_Access := new FLTK.Images.Image'Class'(Pic.Copy);
    begin
        Store.Append ((Tree => Tree, Image => Copied, Kept => Kept));
        return Pointer (Copied);
    end Hold;


    function Hold_Private
           (Tree : in Storage.Integer_Address;
            Pic  : in FLTK.Images.Image'Class)
        return Storage.Integer_Address
    is
        Copied : Image_Access;
    begin
        if Pic not in FLTK.Images.Shared.Shared_Image'Class then
            return Hold (Tree, Pic, Kept => False);
        end if;
        Copied := new FLTK.Images.Image;
        Wrapper (Copied.all).Void_Ptr := fl_shared_image_own_copy (Wrapper (Pic).Void_Ptr);
        if Pointer (Copied) = Null_Pointer then
            Free (Copied);
            raise Storage_Error with "a Shared_Image that could not be copied";
        end if;
        Store.Append ((Tree => Tree, Image => Copied, Kept => False));
        return Pointer (Copied);
    end Hold_Private;


    function Find
           (Tree : in Storage.Integer_Address;
            Ptr  : in Storage.Integer_Address)
        return access FLTK.Images.Image'Class is
    begin
        if Ptr /= Null_Pointer then
            for Item of Store loop
                if Item.Tree = Tree and then Pointer (Item.Image) = Ptr then
                    return Item.Image;
                end if;
            end loop;
        end if;
        return null;
    end Find;


    procedure Drop
           (Tree : in Storage.Integer_Address;
            All_Of_Them : in Boolean)
    is
        Kept : Held_Vectors.Vector;
        Gone : Image_Access;
    begin
        for Item of Store loop
            if Item.Tree /= Tree
                or else (not All_Of_Them
                    and then (Item.Kept
                        or else fl_tree_shows_icon (Tree, Pointer (Item.Image)) /= 0))
            then
                Kept.Append (Item);
            else
                Gone := Item.Image;
                Free (Gone);
            end if;
        end loop;
        Store.Move (Kept);
    end Drop;


    procedure Drop_Unused
           (Tree : in Storage.Integer_Address) is
    begin
        Drop (Tree, All_Of_Them => False);
    end Drop_Unused;


    procedure Drop_All
           (Tree : in Storage.Integer_Address) is
    begin
        Drop (Tree, All_Of_Them => True);
    end Drop_All;


end FLTK.Tree_Icons;


