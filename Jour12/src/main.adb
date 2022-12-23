with Ada.Text_IO;
with Ada.Strings.Hash;
with Ada.Characters;
with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Strings.Fixed;

procedure Main is
   use Ada.Text_IO;

   F : File_Type;
   type Hauteur is mod 26;

   package Hauteur_Liste is new Ada.Containers.Indefinite_Vectors
     (Element_Type => Hauteur, Index_Type => Natural);
   subtype Type_Hauteurs is Hauteur_Liste.Vector;

   function NI (E : Natural) return String renames Natural'Image;

   Foret  : Type_Hauteurs;
   Nb_Col : Natural := 0;
   Nb_Lig : Natural := 0;

   type Coord is record
      X : Positive;
      Y : Positive;
   end record;

   -- Index basé sur 0
   function I4LC (L : Positive; C : Positive) return Natural is
   begin
      return (L - 1) * Nb_Col + C - 1;
   end I4LC;

   function I4Coord (C : Coord) return Natural is
   begin
      return I4LC (C.Y, C.X);
   end I4Coord;

   function Coord4I (I : Natural) return Coord is
      Res : Coord;
   begin
      Res.X := I mod Nb_Col + 1;
      Res.Y := I / Nb_Col + 1;
      return Res;
   end Coord4I;

   type Score_Array is array (Natural range <>) of Natural;

   function Edsger2 (Arr : Coord) return Natural is
      package Natural_Queue is new Ada.Containers.Indefinite_Vectors
        (Element_Type => Natural, Index_Type => Natural);
      use Natural_Queue;
      Q : Natural_Queue.Vector;
      type Natural_Array is
        array (Foret.First_Index .. Foret.Last_Index) of Natural;
      Prev, Dist : Natural_Array;
      Res        : Natural := Natural'Last;

      function Q_Min_Dist return Natural is
         Min : Natural := Natural'Last;
         Res : Natural := Natural'Last;
      begin
         for I in Dist'Range loop
            if Dist (I) < Min and then Q.Find (I) /= No_Element then
               Min := Dist (I);
               Res := I;
            end if;
         end loop;
         return Res;
      end Q_Min_Dist;

      procedure V_Tech (U, V : Natural) is
      begin
         if Integer'Val (Foret (U)) - Integer'Val (Foret (V)) <= 1
           and then Q.Find (V) /= No_Element
         then
            if (Dist (U) + 1) < Dist (V) then
               Dist (V) := Dist (U) + 1;
               Prev (V) := U;
            end if;
         end if;
      end V_Tech;
   begin
      for I in Foret.First_Index .. Foret.Last_Index loop
         Dist (I) := Natural'Last;
         Prev (I) := Foret.Last_Index + 1;
         Q.Append (I);
      end loop;
      Dist (I4Coord (Arr)) := 0;

      while not Q.Is_Empty loop
         declare
            U       : Natural := Q_Min_Dist;
            U_Coord : Coord   := Coord4I (U);
            U_Curs  : Cursor;
         begin
         -- on n'a pas construit de graphe, Q n'est pas forcément traversable
            if U = Natural'Last then
               exit;
            end if;
            U_Curs := Q.Find (U);
            Q.Delete (U_Curs);

            -- gauche
            if U_Coord.X > 1 then
               V_Tech (U, I4LC (U_Coord.Y, U_Coord.X - 1));
            end if;

            -- droite
            if U_Coord.X < Nb_Col then
               V_Tech (U, I4LC (U_Coord.Y, U_Coord.X + 1));
            end if;

            -- haut
            if U_Coord.Y > 1 then
               V_Tech (U, I4LC (U_Coord.Y - 1, U_Coord.X));
            end if;

            -- bas
            if U_Coord.Y < Nb_Lig then
               V_Tech (U, I4LC (U_Coord.Y + 1, U_Coord.X));
            end if;
         end;
      end loop;

      for I in Foret.First_Index .. Foret.Last_Index loop
         if Foret (I) = 0 and Dist (I) < Res then
            Res := Dist (I);
         end if;
      end loop;
      return Res;
   end Edsger2;
   function Edsger (Dep : Coord; Arr : Coord) return Natural is
      package Natural_Queue is new Ada.Containers.Indefinite_Vectors
        (Element_Type => Natural, Index_Type => Natural);
      use Natural_Queue;
      Q : Natural_Queue.Vector;
      type Natural_Array is
        array (Foret.First_Index .. Foret.Last_Index) of Natural;
      Prev, Dist : Natural_Array;
      Cible      : Natural := I4Coord (Arr);
      Res        : Natural := 0;

      function Q_Min_Dist return Natural is
         Min : Natural := Natural'Last;
         Res : Natural := Natural'Last;
      begin
         for I in Dist'Range loop
            if Dist (I) < Min and then Q.Find (I) /= No_Element then
               Min := Dist (I);
               Res := I;
            end if;
         end loop;
         return Res;
      end Q_Min_Dist;

      procedure V_Tech (U, V : Natural) is
      begin
         if Integer'Val (Foret (V)) - Integer'Val (Foret (U)) <= 1
           and then Q.Find (V) /= No_Element
         then
            if (Dist (U) + 1) < Dist (V) then
               Dist (V) := Dist (U) + 1;
               Prev (V) := U;
            end if;
         end if;
      end V_Tech;
   begin
      for I in Foret.First_Index .. Foret.Last_Index loop
         Dist (I) := Natural'Last;
         Prev (I) := Foret.Last_Index + 1;
         Q.Append (I);
      end loop;
      Dist (I4Coord (Dep)) := 0;

      while not Q.Is_Empty loop
         declare
            U       : Natural := Q_Min_Dist;
            U_Coord : Coord   := Coord4I (U);
            U_Curs  : Cursor;
         begin
         -- on n'a pas construit de graphe, Q n'est pas forcément traversable
            if U = Cible or U = Natural'Last then
               exit;
            end if;
            U_Curs := Q.Find (U);
            Q.Delete (U_Curs);

            -- gauche
            if U_Coord.X > 1 then
               V_Tech (U, I4LC (U_Coord.Y, U_Coord.X - 1));
            end if;

            -- droite
            if U_Coord.X < Nb_Col then
               V_Tech (U, I4LC (U_Coord.Y, U_Coord.X + 1));
            end if;

            -- haut
            if U_Coord.Y > 1 then
               V_Tech (U, I4LC (U_Coord.Y - 1, U_Coord.X));
            end if;

            -- bas
            if U_Coord.Y < Nb_Lig then
               V_Tech (U, I4LC (U_Coord.Y + 1, U_Coord.X));
            end if;
         end;
      end loop;

      Res := Dist (Cible);
      if Res = 0 then
         declare
            procedure P (S : String; C : Coord) is
               I   : Natural         := I4Coord (C);
               DTQ : String (1 .. 2) := " .";
            begin
               if Q.Find (I) = No_Element then
                  DTQ := " X";
               end if;
               Put_Line
                 ("Dist " & S & "H " & Hauteur'Image (Foret (I)) & ", " &
                  NI (Dist (I)) & " : " & NI (C.X) & ", " & NI (C.Y) & ", P " &
                  NI (Prev (I)) & DTQ);
            end P;
         begin
            P ("d ", (74, 10));
            P ("l ", (63, 9));
            P ("o ", (69, 31));
            P ("q ", (72, 19));
            P ("r ", (69, 28));
            P ("s ", (63, 29));
            P ("t ", (58, 25));
            for i in 18 .. 24 loop
               P ("t ", (55, i));
            end loop;

         end;
      end if;
      return Res;
   end Edsger;

begin
   declare
      Lettre   : String (1 .. 1);
      Dep, Arr : Coord;

      function rel_h (C : Character) return Hauteur is
         Sol : constant Natural := Character'Pos ('a');
      begin
         return Hauteur'Val (Character'Pos (C) - Sol);
      end rel_h;
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
               Lettre := L (I .. I);
               if Lettre = "S" then
                  Dep.X := I;
                  Dep.Y := Nb_Lig;
                  Foret.Append (rel_h ('a'));
               elsif Lettre = "E" then
                  Arr.X := I;
                  Arr.Y := Nb_Lig;
                  Foret.Append (rel_h ('z'));
               else
                  Foret.Append (rel_h (Lettre (1)));
               end if;
            end loop;
            Put_Line (L);
         end;
      end loop;
      Put_Line
        ("Nb_Col" & Natural'Image (Nb_Col) & ", Nb_Lig" &
         Natural'Image (Nb_Lig));
      Put_Line
        ("Dep " & NI (Dep.X) & ", " & NI (Dep.Y) & ", Arr " & NI (Arr.X) &
         ", " & NI (Arr.Y));
      declare
         Score : Positive := Positive'Last;
      begin
         Score := Edsger2 (Arr);
         Put_Line ("Score : " & Positive'Image (Score));
      end;

      -- for I of Foret loop
      --   Put(Hauteur'Image(I));
      -- end loop;
--   Calcule1 ((Nb_Col - 2) * (Nb_Lig - 2));
      --    Calcule2;
   end;
end Main;
