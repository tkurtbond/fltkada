--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/clipboard.cxx: a viewer of the clipboard, with two tabs,
--  one showing an image on a chess pattern, with its size below, and one
--  showing text, in Courier.  It shows what the clipboard holds at the
--  start, and again whenever the clipboard changes or the Refresh button
--  is pressed, and Save PNG writes the image to a file the user chooses.
--  The image taken from the clipboard is allocated, and freed when the
--  next one replaces it and after the event loop.  Guided by pofltk's
--  Clipboard.Mod.


with

    Ada.Strings.Fixed,
    Ada.Unchecked_Deallocation,
    FLTK.Asks,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Images.RGB.PNG,
    FLTK.Images.Shared,
    FLTK.Native_File_Choosers,
    FLTK.Static,
    FLTK.Text_Buffers,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Groups.Windows;

use type

    FLTK.Alignment,
    FLTK.Event_Kind,
    FLTK.Static.Buffer_Kind,
    FLTK.Native_File_Choosers.Chooser_Option,
    FLTK.Native_File_Choosers.Show_Result;


function Clipboard
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Tab renames FLTK.Widgets.Groups.Tabbed;
    package TD  renames FLTK.Widgets.Groups.Text_Displays;
    package Win renames FLTK.Widgets.Groups.Windows;
    package RGB renames FLTK.Images.RGB;
    package NFC renames FLTK.Native_File_Choosers;

    Tab_Color : constant FLTK.Color := FLTK.Dark3_Color;

    type RGB_Access is access RGB.RGB_Image;

    procedure Free is new Ada.Unchecked_Deallocation (RGB.RGB_Image, RGB_Access);

    Cl_Img : RGB_Access := null;  --  image from clipboard


    --  A box with a chess pattern below its image.
    type Chess is new Bx.Box with null record;

    overriding procedure Draw
           (This : in out Chess);

    procedure Draw
           (This : in out Chess)
    is
        Side  : constant := 4;
        Side2 : constant := 2 * Side;
        Img   : constant access FLTK.Images.Image'Class := This.Get_Image;
    begin
        This.Draw_Box;
        if Img /= null then  --  draw the chess pattern below the box centered image
            declare
                X : constant Integer := This.Get_X + (This.Get_W - Img.Get_W) / 2;
                Y : constant Integer := This.Get_Y + (This.Get_H - Img.Get_H) / 2;
                W : constant Integer := Img.Get_W;
                H : constant Integer := Img.Get_H;
                I : Integer;
                J : Integer := Y;
            begin
                FLTK.Draw.Push_Clip (X, Y, W, H);
                FLTK.Draw.Push_Clip (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
                FLTK.Draw.Set_Color (FLTK.White_Color);
                FLTK.Draw.Rect_Fill (X, Y, W, H);
                FLTK.Draw.Set_Color (FLTK.Light2_Color);
                while J < Y + H loop
                    I := X + (J - Y) mod Side2;
                    while I < X + W loop
                        FLTK.Draw.Rect_Fill (I, J, Side, Side);
                        I := I + Side2;
                    end loop;
                    J := J + Side;
                end loop;
                FLTK.Draw.Pop_Clip;
                FLTK.Draw.Pop_Clip;
            end;
        end if;
        This.Draw_Label;  --  draw the box image
    end Draw;


    --  The tabs, which take what is pasted.
    type Clipboard_Viewer is new Tab.Tabbed_Group with null record;

    overriding function Handle
           (This  : in out Clipboard_Viewer;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    function Image
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Value'Image, Ada.Strings.Left);
    end Image;


    Window : Win.Window := Win.Forge.Create (500, 550, "FLTK Clipboard Viewer");
    Tabs   : Clipboard_Viewer := (Tab.Forge.Create (Window, 0, 0, 500, 500) with null record);

    --  will display the image form
    G          : Grp.Group := Grp.Forge.Create (Tabs, 5, 30, 490, 460, FLTK.Clipboard_Image);
    Image_Box  : Chess := (Bx.Forge.Create (G, FLTK.Flat_Box, 5, 30, 490, 450) with null record);
    Image_Size : Bx.Box := Bx.Forge.Create (G, FLTK.No_Box, 5, 485, 490, 10);

    Buffer  : FLTK.Text_Buffers.Text_Buffer := FLTK.Text_Buffers.Forge.Create;
    --  will display the text form
    Display : TD.Text_Display :=
        TD.Forge.Create (Tabs, 5, 30, 490, 460, FLTK.Clipboard_Plain_Text);

    G2      : Grp.Group := Grp.Forge.Create (Window, 10, 510, 330, 25);
    Refresh : Btn.Button := Btn.Forge.Create (G2, 10, 510, 200, 25, "Refresh from clipboard");
    Save    : Btn.Button := Btn.Forge.Create (G2, 220, 510, 100, 25, "Save PNG");


    function Handle
           (This  : in out Clipboard_Viewer;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        if Event /= FLTK.Paste then
            return Tab.Tabbed_Group (This).Handle (Event);
        end if;
        if FLTK.Events.Clipboard_Kind = FLTK.Clipboard_Image then  --  an image is being pasted
            if not FLTK.Events.Has_Clipboard_Image then
                return FLTK.Handled;
            end if;
            declare
                --  get it as an RGB_Image
                New_Img : RGB_Access := new RGB.RGB_Image'(RGB.Forge.Pasted);
                --  display the image original size
                Title   : constant String :=
                    Image (New_Img.Get_W) & "x" & Image (New_Img.Get_H);
            begin
                if New_Img.Get_W > Image_Box.Get_W or New_Img.Get_H > Image_Box.Get_H then
                    New_Img.Scale (Image_Box.Get_W, Image_Box.Get_H);
                end if;
                Image_Box.Set_Image (New_Img.all);  --  show the scaled image
                Free (Cl_Img);
                Cl_Img := New_Img;
                New_Img := null;
                Image_Size.Set_Label (Title);
                This.Set_Visible (G);
                Window.Redraw;
            end;
        else  --  text is being pasted
            Buffer.Set_Entire_Text (FLTK.Events.Clipboard_Text);
            This.Set_Visible (Display);
            Display.Redraw;
        end if;
        return FLTK.Handled;
    end Handle;


    procedure CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if FLTK.Static.Clipboard_Contains (FLTK.Clipboard_Image) then
            FLTK.Static.Paste_Image (Tabs);  --  try to find image in the clipboard
            return;
        end if;
        if FLTK.Static.Clipboard_Contains (FLTK.Clipboard_Plain_Text) then
            FLTK.Static.Paste (Tabs, FLTK.Static.Clipboard);  --  also try to find text
        end if;
    end CB;


    procedure Save_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Cl_Img /= null then
            declare
                Fnfc : NFC.Native_File_Chooser := NFC.Forge.Create (NFC.Browse_Save_File);
            begin
                Fnfc.Set_Title ("Please select a .png file");
                Fnfc.Set_Filter ("PNG" & ASCII.HT & "*.png" & ASCII.LF);
                Fnfc.Set_Options (NFC.Saveas_Confirm + NFC.Use_Filter_Ext);
                if Fnfc.Show /= NFC.Picked then
                    return;
                end if;
                declare
                    Filename : constant String := Fnfc.Get_Filename;
                begin
                    if Filename /= "" then
                        RGB.PNG.Write_PNG (Cl_Img.all, Filename);
                    end if;
                end;
            end;
        else
            FLTK.Asks.Message_Box ("No image available");
        end if;
    end Save_CB;


    procedure Clip_Callback
           (Kind : in FLTK.Static.Buffer_Kind) is
    begin
        if Kind = FLTK.Static.Clipboard then
            CB (Tabs);
        end if;
    end Clip_Callback;

begin

    --  required for the X11 platform to allow pasting of images
    FLTK.Images.Shared.Register_Images;

    G.Set_Box (FLTK.Flat_Box);
    Image_Box.Set_Alignment (FLTK.Align_Center + FLTK.Align_Clip);
    G.End_Current;
    G.Set_Selection_Color (Tab_Color);

    Display.Set_Buffer (Buffer);
    Display.Set_Selection_Color (Tab_Color);
    Display.Set_Text_Font (FLTK.Courier);  --  use fixed font for text display
    Tabs.End_Current;
    Tabs.Set_Resizable (Display);

    Refresh.Set_Callback (CB'Unrestricted_Access);
    Save.Set_Callback (Save_CB'Unrestricted_Access);
    G2.End_Current;
    G2.Clear_Resizable;
    Window.End_Current;
    Window.Set_Resizable (Tabs);
    Window.Show_With_Args;

    --  use clipboard content at start
    Clip_Callback (FLTK.Static.Clipboard);
    --  will update with new clipboard content
    FLTK.Static.Add_Clipboard_Notify (Clip_Callback'Unrestricted_Access);
    --  set bilinear image scaling method
    FLTK.Images.Set_Copy_Algorithm (FLTK.Images.Bilinear);

    return Result : constant Integer := FLTK.Run do
        FLTK.Static.Remove_Clipboard_Notify (Clip_Callback'Unrestricted_Access);
        Image_Box.Clear_Image;
        Free (Cl_Img);
    end return;

end Clipboard;

