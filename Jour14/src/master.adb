with Ada.Text_IO;
with Ada.Strings.Fixed;

procedure Master is
   use Ada.Text_IO;
begin
   declare
      type Tuile is (Air, Pierre, Sable);
      type Tuiles_Grille is array (Natural range <>) of Tuile;

      type Coord is record
         X, Y : Natural;
      end record;
      C_Min  : Coord := (Natural'Last, Natural'Last);
      C_Max  : Coord := (0, 0);
      Nb_Col : Positive;

      function I4XY (X, Y : Natural) return Natural is
      begin
         return Y * Nb_Col + X - C_Min.X;
      end I4XY;
      function I4Coord (C : Coord) return Natural is
      begin
         return I4XY (C.X, C.Y);
      end I4Coord;

      function extr (S : String; SI : in out Positive) return Coord is
         use Ada.Strings.Fixed;

         Res  : Coord;
         Off1 : Natural := Index (S, ",", SI);
         Off2 : Natural := Index (S, " ", SI);
      begin
         if Off2 = 0 then
            Off2 := S'Length + 1;
         end if;

         Res.X := Natural'Value (S (SI .. Off1 - 1));
         Res.Y := Natural'Value (S (Off1 + 1 .. Off2 - 1));
         SI    := Off2;
         return Res;
      end extr;
      function Coord_ToS (C : Coord) return String is
      begin
         return "C(" & Natural'Image (C.X) & "," & Natural'Image (C.Y) & ")";
      end Coord_ToS;

      function Min_N (A, B : Natural) return Natural is
      begin
         if A < B then
            return A;
         else
            return B;
         end if;
      end Min_N;

      function Max_N (A, B : Natural) return Natural is
      begin
         if A > B then
            return A;
         else
            return B;
         end if;
      end Max_N;

      procedure Trouve_Dimensions is
         F : File_Type;

      begin
         Open (F, Mode => In_File, Name => "ladata.txt");
         while not End_Of_File (F) loop
            declare
               Lig : constant String := Get_Line (F);
               SI  : Natural         := 1;
               C   : Coord;
            begin
               while SI <= Lig'Length loop
                  C := extr (Lig, SI);

                  if C.X < C_Min.X then
                     C_Min.X := C.X;
                  end if;
                  if C.X > C_Max.X then
                     C_Max.X := C.X;
                  end if;
                  if C.Y < C_Min.Y then
                     C_Min.Y := C.Y;
                  end if;
                  if C.Y > C_Max.Y then
                     C_Max.Y := C.Y;
                  end if;

                  SI := SI + 4;
               end loop;
            end;
         end loop;
         Put_Line ("Min " & Coord_ToS (C_Min) & ", Max " & Coord_ToS (C_Max));
         Close (F);
      end Trouve_Dimensions;
      procedure Dessine_Grotte (Grotte : in out Tuiles_Grille) is
         F : File_Type;

      begin
         Open (F, Mode => In_File, Name => "ladata.txt");
         while not End_Of_File (F) loop
            declare
               Lig       : constant String := Get_Line (F);
               SI        : Natural         := 1;
               C, Prev_C : Coord;
            begin
               Prev_C := extr (Lig, SI);
               while SI <= Lig'Length loop
                  SI := SI + 4;
                  C  := extr (Lig, SI);

                  for X in Min_N (Prev_C.X, C.X) .. Max_N (Prev_C.X, C.X) loop
                     for Y in Min_N (Prev_C.Y, C.Y) .. Max_N (Prev_C.Y, C.Y)
                     loop
                        Grotte (I4XY (X, Y)) := Pierre;
                     end loop;
                  end loop;

                  Prev_C := C;
               end loop;
            end;
         end loop;
         Close (F);
      end Dessine_Grotte;
      procedure Aff_Grotte (G : Tuiles_Grille) is
      begin
         for I in G'Range loop
            if I mod Nb_Col = 0 then
               Put_Line ("");
            end if;

            if C_Min.X + I = 500 then
               Put ("x");
            else
               case G (I) is
                  when Air =>
                     Put (".");
                  when Pierre =>
                     Put ("#");
                  when Sable =>
                     Put ("o");
               end case;
            end if;
         end loop;
      end Aff_Grotte;
      procedure Chute_1 (G : Tuiles_Grille) is
         Score               : Natural       := 0;
         C_Fini, Grain_tombe : Boolean       := False;
         Grain               : Coord;
         Grotte              : Tuiles_Grille := G;

      begin
         while not C_Fini loop

            Score       := Score + 1;
            Grain       := (500, 0);
            Grain_tombe := False;
            while not Grain_tombe loop
               Grain.Y := Grain.Y + 1;
               if Grotte (I4Coord (Grain)) /= Air then
                  if Grain.X = C_Min.X then
                     -- Put_Line("C'est fini à gauche ");
                     C_Fini      := True;
                     Grain_tombe := True;
                  else
                     Grain.X := Grain.X - 1;
                     if Grotte (I4Coord (Grain)) /= Air then
                        Grain.X := Grain.X + 2;
                        if Grain.X > C_Max.X then
                        -- Put_Line("C'est fini à droite " & Coord_ToS(Grain));
                           C_Fini      := True;
                           Grain_tombe := True;
                        elsif Grotte (I4Coord (Grain)) /= Air then
                           Grain.Y                  := Grain.Y - 1;
                           Grain.X                  := Grain.X - 1;
                           Grain_tombe              := True;
                           Grotte (I4Coord (Grain)) := Sable;
                        end if;
                     end if;
                  end if;
               end if;
            end loop;

         end loop;
         Score := Score - 1;
         Put_Line ("Score : " & Natural'Image (Score));

      end Chute_1;
      procedure Chute_2 is
         Score               : Natural        := 0;
         C_Fini, Grain_tombe : Boolean        := False;
         Grain               : Coord;
         Source              : constant Coord := (500, 0);
         Delt                : Integer;
      begin
         -- on a vraisemblablement besoin d'enlarge
         C_Max.Y := C_Max.Y + 2;
         Delt    := 499 - C_Min.X;
         if Delt < C_Max.Y then
            C_Min.X := 499 - C_Max.Y;
         end if;
         Delt := C_Max.X - 501;
         if Delt < C_Max.Y then
            C_Max.X := 501 + C_Max.Y;
         end if;
         Nb_Col := C_Max.X - C_Min.X + 1;

         declare
            Taille : constant Positive               := (C_Max.Y + 1) * Nb_Col;
            Grotte : Tuiles_Grille (0 .. Taille - 1) := (others => Air);
         begin
            Dessine_Grotte (Grotte);

            for I in Grotte'Last - Nb_Col + 1 .. Grotte'Last loop
               Grotte (I) := Pierre;

            end loop;

            Aff_Grotte (Grotte);
            while not C_Fini loop
               Score       := Score + 1;
               Grain       := Source;
               Grain_tombe := False;
               while not Grain_tombe loop
                  Grain.Y := Grain.Y + 1;
                  if Grotte (I4Coord (Grain)) /= Air then
                     if Grain.X = C_Min.X then
                        -- Put_Line("C'est fini à gauche ");
                        C_Fini      := True;
                        Grain_tombe := True;
                     else
                        Grain.X := Grain.X - 1;
                        if Grotte (I4Coord (Grain)) /= Air then
                           Grain.X := Grain.X + 2;
                           if Grain.X > C_Max.X then
                        -- Put_Line("C'est fini à droite " & Coord_ToS(Grain));
                              C_Fini      := True;
                              Grain_tombe := True;
                           elsif Grotte (I4Coord (Grain)) /= Air then
                              Grain.Y                  := Grain.Y - 1;
                              Grain.X                  := Grain.X - 1;
                              Grain_tombe              := True;
                              Grotte (I4Coord (Grain)) := Sable;
                              if Grain = Source then
                                 C_Fini := True;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end loop;

            end loop;
            Aff_Grotte (Grotte);
            Put_Line ("Score : " & Natural'Image (Score));
         end;
      end Chute_2;
   begin
      Trouve_Dimensions;
      C_Min.Y := 0;
      Nb_Col  := C_Max.X - C_Min.X + 1;

      declare
         Taille : constant Positive               := (C_Max.Y + 1) * Nb_Col;
         Grotte : Tuiles_Grille (0 .. Taille - 1) := (others => Air);
      begin
         Put_Line ("Nb_Col " & Natural'Image (Nb_Col));
         Dessine_Grotte (Grotte);

         -- Aff_Grotte (Grotte);

         -- Chute_1 (Grotte);
         -- Aff_Grotte (Grotte);
         Chute_2;
      end;
   end;
end Master;
