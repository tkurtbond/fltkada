

--  Released into the public domain


--  Clear_Image and Clear_Chosen: a widget shows no image again, and a
--  Choice no item.  A label's measure counts its image, so the C
--  widget's image is seen gone, as well as Get_Image's.  It opens the
--  display, to measure; run it under Xvfb.


with

    Ada.Command_Line,
    Ada.Text_IO,
    FLTK.Images.RGB,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Menus.Choices;

procedure Clear_Image_Chosen is

    Failed : Boolean := False;

    procedure Check
           (Label     : in String;
            Condition : in Boolean) is
    begin
        if Condition then
            Ada.Text_IO.Put_Line ("ok   - " & Label);
        else
            Ada.Text_IO.Put_Line ("FAIL - " & Label);
            Failed := True;
        end if;
    end Check;

    Pixels : constant FLTK.Color_Component_Array (1 .. 3600) := (others => 255);
    Pic    : FLTK.Images.RGB.RGB_Image := FLTK.Images.RGB.Forge.Create (Pixels, 40, 30);
    Shower : FLTK.Widgets.Boxes.Box := FLTK.Widgets.Boxes.Forge.Create (0, 0, 100, 100);
    Pick   : FLTK.Widgets.Menus.Choices.Choice :=
        FLTK.Widgets.Menus.Choices.Forge.Create (0, 0, 100, 20);
    W, H   : Integer;

begin

    Shower.Set_Image (Pic);
    Shower.Measure_Label (W, H);
    Check ("a label with an image measures the image", W = 40 and H = 30);

    Shower.Clear_Image;
    Check ("Clear_Image: Get_Image is null", Shower.Get_Image = null);
    Shower.Measure_Label (W, H);
    Check ("Clear_Image: the label measures no image", W = 0 and H = 0);

    Pick.Add ("one", null);
    Pick.Add ("two", null);
    Pick.Set_Chosen (2);
    Check ("Set_Chosen (2): Chosen_Index is 2", Pick.Chosen_Index = 2);
    Pick.Clear_Chosen;
    Check ("Clear_Chosen: Chosen_Index is No_Index",
        Pick.Chosen_Index = FLTK.Widgets.Menus.No_Index);

    if Failed then
        Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
    end if;

end Clear_Image_Chosen;
