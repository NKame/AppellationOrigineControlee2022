with Ada.Text_IO;
with Ada.Strings.Fixed;

procedure Main is
   use Ada.Text_IO;
   type Instrs is (noop, addx);
begin
   declare
      subtype Reg_Val is Integer;
      F        : File_Type;
      Reg_X    : Reg_Val           := 1;
      Cycle    : Natural           := 0;
      Signal   : Natural           := 0;
      Per_Deb  : constant Positive := 20;
      Per_Lng  : constant Positive := 40;
      Larg_Ecr : constant Positive := 40;
      Canon    : Natural;
      type Lig_Loc is delta 0.1 digits 5;
      Lg_Cpt : Lig_Loc := 0.0;

      procedure clock_in (Lig : Lig_Loc) is
      begin
         Cycle := Cycle + 1;
         if Cycle = Per_Deb or else (Cycle - Per_Deb) mod Per_Lng = 0 then
            Signal := Signal + Cycle * Reg_X;
            -- Put_Line
            --  (Integer'Image (Cycle) & " " & Lig_Loc'Image(Lig) & " : " & Reg_Val'Image(Reg_X) & " => " &
            --   Positive'Image (Cycle * Reg_X));
         end if;
         if Cycle = 220 then
            -- Put_Line("Score : " & Natural'Image(Signal));
            null;
         end if;

         Canon := (Cycle - 1) rem Larg_Ecr;
         if Reg_X - 1 <= Canon and then Canon <= Reg_X + 1 then
            Put ("#");
         else
            Put (".");
         end if;

         if Cycle mod Larg_Ecr = 0 then
            Put_Line ("");
         end if;
      end clock_in;

      procedure addx (V : Reg_Val) is
      begin
         Reg_X := Reg_X + V;
      end addx;
   begin
      Open (F, Mode => In_File, Name => "ladata.txt");

      while not End_Of_File (F) loop
         declare
            use Ada.Strings.Fixed;
            Lig : constant String := Get_Line (F);

            Instr : Instrs := Instrs'Value (Lig (1 .. 4));
         begin
            Lg_Cpt := Lg_Cpt + 1.0;
            -- Put_Line (Lig);
            case Instr is
               when noop =>
                  clock_in (Lg_Cpt);
               when addx =>
                  declare
                     Val : Reg_Val := Reg_Val'Value (Lig (6 .. Lig'Last));
                  begin
                     clock_in (Lg_Cpt);
                     clock_in (Lg_Cpt + 0.5);
                     addx (Val);
                  end;
            end case;
         end;
      end loop;
      Close (F);
   end;
end Main;
