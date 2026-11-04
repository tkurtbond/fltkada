

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Fl_Tree_Item::usericon and userdeicon keep the image's pointer, and
--  never copy or delete it (pofltk 78).  So an item is given a copy of the
--  Ada image, which this package holds for the item's tree.  A copy no
--  item of its tree shows is freed when an icon is next set or cleared,
--  or an item is removed; the rest go with the tree.


with

    FLTK.Images;


private package FLTK.Tree_Icons is


    --  Copies Pic, and holds the copy for Tree.  If Kept, the copy is held
    --  until the tree goes, because the item showing it isn't in the tree
    --  yet.  Returns the copy's Fl_Image.
    function Hold
           (Tree : in Storage.Integer_Address;
            Pic  : in FLTK.Images.Image'Class;
            Kept : in Boolean)
        return Storage.Integer_Address;

    --  The copy held for Tree whose Fl_Image is Ptr, or null.
    function Find
           (Tree : in Storage.Integer_Address;
            Ptr  : in Storage.Integer_Address)
        return access FLTK.Images.Image'Class;

    --  Frees the copies held for Tree that no item in it shows.
    procedure Drop_Unused
           (Tree : in Storage.Integer_Address);

    --  Frees every copy held for Tree, once it is gone.
    procedure Drop_All
           (Tree : in Storage.Integer_Address);


end FLTK.Tree_Icons;


