with Ada.Text_IO;
with Ada.Strings.Hash;
with Ada.Characters;
with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Strings.Fixed;

procedure Main is
   use Ada.Text_IO;

   F : File_Type;
   type Hauteur is mod 10;
   package Hauteur_Liste is new Ada.Containers.Indefinite_Vectors
     (Element_Type => Hauteur, Index_Type => Positive);
   subtype Type_Hauteurs is Hauteur_Liste.Vector;

   Foret  : Type_Hauteurs;
   Nb_Col : Natural := 0;
   Nb_Lig : Natural := 0;

   function H (L : Natural; C : Natural) return Hauteur is
   begin
      return Foret ((L - 1) * Nb_Col + C);
   end H;

   procedure Calcule1 (Taille : Natural) is
      type Marques_Array is array (1 .. Taille) of Hauteur;
      Marques : Marques_Array := (others => 0);
      Max     : Hauteur;
      Val     : Hauteur;
      Score   : Natural;
      subtype LR is Natural range 2 .. Nb_Lig - 1;
      subtype CR is Natural range 2 .. Nb_Col - 1;

      procedure Marque (L : Natural; C : Natural) is
      begin
         Put_Line ("Marque" & Natural'Image (L) & "," & Natural'Image (C));
         Marques ((L - 2) * (Nb_Col - 2) + C - 1) := 1;
      end Marque;
   begin
      -- gauche -> droite
      for I in LR'Range loop
         Max := H (I, 1);
         for J in CR'Range loop
            Val := H (I, J);
            if Val > Max then
               Max := Val;
               Marque (I, J);
            end if;
         end loop;
      end loop;

      -- droite -> gauche
      for I in LR'Range loop
         Max := H (I, Nb_Col);
         for J in reverse CR'Range loop
            Val := H (I, J);
            if Val > Max then
               Max := Val;
               Marque (I, J);
            end if;
         end loop;
      end loop;

      -- haut -> bas
      for J in CR'Range loop
         Max := H (1, J);
         for I in LR'Range loop
            Val := H (I, J);
            if Val > Max then
               Max := Val;
               Marque (I, J);
            end if;
         end loop;
      end loop;

      -- bas -> haut
      for J in CR'Range loop
         Max := H (Nb_Lig, J);
         for I in reverse LR'Range loop
            Val := H (I, J);
            if Val > Max then
               Max := Val;
               Marque (I, J);
            end if;
         end loop;
      end loop;

      --  for I of Marques loop
      --     Put (Hauteur'Image (I));
      --  end loop;

      Score := 2 * Nb_Lig + 2 * Nb_Col - 4;
      Put_Line ("Score :" & Integer'Image (Score));
   end Calcule1;

   procedure Calcule2 is
      Score2    : Natural := 0;
      H_Ref     : Hauteur;
      Pas       : Natural;
      Score_Int : Natural;
      subtype LR is Natural range 2 .. Nb_Lig - 1;
      subtype CR is Natural range 2 .. Nb_Col - 1;

   begin
      for I in LR'Range loop
         for J in CR'Range loop
            H_Ref     := H (I, J);
            Score_Int := 1;

            -- droite
            Pas := 0;
            for C in I + 1 .. Nb_Col loop
               Pas := Pas + 1;
               if H (C, J) >= H_Ref then
                  exit;
               end if;
            end loop;
            Score_Int := Pas * Score_Int;

            -- gauche
            Pas := 0;
            for C in reverse 1 .. I - 1 loop
               Pas := Pas + 1;
               if H (C, J) >= H_Ref then
                  exit;
               end if;
            end loop;
            Score_Int := Pas * Score_Int;

            -- bas
            Pas := 0;
            for L in J + 1 .. Nb_Lig loop
               Pas := Pas + 1;
               if H (I, L) >= H_Ref then
                  exit;
               end if;
            end loop;
            Score_Int := Pas * Score_Int;

            -- haut
            Pas := 0;
            for L in reverse 1 .. J - 1 loop
               Pas := Pas + 1;
               if H (I, L) >= H_Ref then
                  exit;
               end if;
            end loop;
            Score_Int := Pas * Score_Int;

            if Score_Int > Score2 then
               Score2 := Score_Int;
            end if;
         end loop;
      end loop;
      Put_Line ("Score 2 :" & Natural'Image (Score2));
   end Calcule2;
begin
   Open (F, Mode => In_File, Name => "ladata.txt");

   while not End_Of_File (F) loop
      declare
         use Ada.Strings.Fixed;
         L : constant String := Get_Line (F);
      begin
         if Nb_Lig = 0 then
            Nb_Col := L'Length;
         end if;
         Nb_Lig := Nb_Lig + 1;
         for I in L'Range loop
            Foret.Append (Hauteur'Value ("" & L (I)));
         end loop;
         Put_Line (L);
      end;
   end loop;
   Put_Line
     ("Nb_Col" & Natural'Image (Nb_Col) & ", Nb_Lig" & Natural'Image (Nb_Lig));
   -- for I of Foret loop
   --   Put(Hauteur'Image(I));
   -- end loop;
   Calcule1 ((Nb_Col - 2) * (Nb_Lig - 2));
   Calcule2;
end Main;
