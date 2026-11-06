
--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/symbols.cxx: every symbol a label can show, each as a
--  symbol in an up box and as its name under it.  Two sliders turn the
--  symbols and change their size.  The C++ finds the boxes among the
--  window's children by their user data; here they are kept in an array.


with

    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Unchecked_Deallocation,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Sliders.Value;


function Symbols
    return Integer
is


    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package Val renames FLTK.Widgets.Valuators.Sliders.Value;


    use Ada.Strings.Unbounded;

    function "+"
           (Item : in String)
        return Unbounded_String
        renames To_Unbounded_String;


    W    : constant := 70;
    H    : constant := 70;
    Rows : constant := 6;
    Cols : constant := 7;

    --  Each symbol's name, without the "@" that starts a label's symbol.
    Names : constant array (Positive range <>) of Unbounded_String :=
       (+"->", +">", +">>", +">|",
        +">[]", +"|>", +"<-", +"<",
        +"<<", +"|<", +"[]<", +"<|",
        +"<->", +"-->", +"+", +"->|",
        +"||", +"arrow", +"returnarrow",
        +"square", +"circle", +"line",
        +"menu", +"UpArrow", +"DnArrow",
        +"search", +"FLTK", +"filenew",
        +"fileopen", +"filesave", +"filesaveas",
        +"fileprint", +"refresh", +"reload",
        +"undo", +"redo", +"import",
        +"export");

    type Box_Access is access Bx.Box;

    procedure Free is new Ada.Unchecked_Deallocation (Bx.Box, Box_Access);

    --  A symbol's name as text, in a box with no frame, and the symbol
    --  itself, in an up box over it.  Freed when the program ends.
    Legends, Pictures : array (Names'Range) of Box_Access;

    Window : Dbl.Double_Window := Dbl.Forge.Create (Cols * W, Rows * H + 60);

    --  C's (int) (window->w () * Fraction + .5).
    function Part
           (Fraction : in Float)
        return Integer is (Integer (Float'Truncation (Float (Window.Get_W) * Fraction + 0.5)));

    type Slider_Access is access Val.Value_Slider;

    procedure Free is new Ada.Unchecked_Deallocation (Val.Value_Slider, Slider_Access);

    --  Made after the boxes, as in the C++, so that they come last among
    --  the window's children.
    Orientation, Size : Slider_Access;


    --  C's "%+d".
    function Signed
           (Item : in Integer)
        return String is
    begin
        return (if Item < 0 then "-" else "+")
            & Ada.Strings.Fixed.Trim (Integer'Image (abs Item), Ada.Strings.Left);
    end Signed;


    --  C's "%d", for 0 .. 9.
    function Digit
           (Item : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (Item), Ada.Strings.Left);
    end Digit;


    --  Start ("@", or "@@" for the name as text), then the size, then the
    --  orientation, then the name, each of the two only if it isn't 0.
    function Label
           (Start      : in String;
            Name       : in String;
            Turn, Grow : in Integer)
        return String is
    begin
        return Start & (if Grow /= 0 then Signed (Grow) else "")
            & (if Turn /= 0 then Digit (Turn) else "") & Name;
    end Label;


    procedure Slider_CB
           (Ignore : in out Wdg.Widget'Class)
    is
        Turn : constant Integer := Integer (Long_Float'Truncation (Orientation.Get_Value));
        Grow : constant Integer := Integer (Long_Float'Truncation (Size.Get_Value));
    begin
        for Index in Names'Range loop
            Legends (Index).Set_Label (Label ("@@", To_String (Names (Index)), Turn, Grow));
            Pictures (Index).Set_Label (Label ("@", To_String (Names (Index)), Turn, Grow));
        end loop;
        Window.Redraw;
    end Slider_CB;


    procedure Make_Cells is
        X, Y : Integer;
    begin
        for Index in Names'Range loop
            X := (Index - 1) mod Cols * W + 10;
            Y := (Index - 1) / Cols * H + 10;
            Legends (Index) := new Bx.Box'(Bx.Forge.Create
               (Window, X, Y, W - 20, H - 20, "@@" & To_String (Names (Index))));
            Legends (Index).Set_Box (FLTK.No_Box);
            Legends (Index).Set_Alignment (FLTK.Align_Bottom);
            Legends (Index).Set_Label_Size (11);
            Pictures (Index) := new Bx.Box'(Bx.Forge.Create
               (Window, X, Y, W - 20, H - 20, "@" & To_String (Names (Index))));
            Pictures (Index).Set_Box (FLTK.Up_Box);
            Pictures (Index).Set_Label_Color (FLTK.Dark3_Color);
        end loop;
    end Make_Cells;


begin


    Make_Cells;

    Orientation := new Val.Value_Slider'(Val.Forge.Create
       (Window, Part (0.05), Window.Get_H - 40, Part (0.42), 16, "Orientation"));
    Size := new Val.Value_Slider'(Val.Forge.Create
       (Window, Part (0.53), Window.Get_H - 40, Part (0.42), 16, "Size"));

    Sld.Extra.Set_Kind (Sld.Slider (Orientation.all), Sld.Horizontal_Slider);
    Orientation.Set_Range (0.0, 9.0);
    Orientation.Set_Value (0.0);
    Orientation.Set_Step (1);
    Orientation.Set_Callback (Slider_CB'Unrestricted_Access);

    Sld.Extra.Set_Kind (Sld.Slider (Size.all), Sld.Horizontal_Slider);
    Size.Set_Range (-3.0, 9.0);
    Size.Set_Value (0.0);
    Size.Set_Step (1);
    Size.Set_Callback (Slider_CB'Unrestricted_Access);

    Window.Set_Resizable (Window);
    Window.Show_With_Args;

    return Result : constant Integer := FLTK.Run do
        for Index in Names'Range loop
            Free (Legends (Index));
            Free (Pictures (Index));
        end loop;
        Free (Orientation);
        Free (Size);
    end return;


end Symbols;
