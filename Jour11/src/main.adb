with Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Bounded;

procedure Main is
   use Ada.Text_IO;

   type Seum is array (0 .. 7) of Natural;
   package SB is new Ada.Strings.Bounded.Generic_Bounded_Length (40);

   package Seums_Vecs is new Ada.Containers.Indefinite_Vectors
     (Element_Type => Seum, Index_Type => Natural);
   subtype Seums is Seums_Vecs.Vector;

   Tours : constant Positive := 10_000;

   type Ope is (Plus, Mult);

   type Singe is record
      Elements   : Seums;
      Operateur  : Ope;
      Operande   : Natural := 0;
      Diviseur   : Positive;
      Cible_Vrai : Natural;
      Cible_Faux : Natural;
      Manip      : Natural := 0;
      Temp_Elems : SB.Bounded_String;
   end record;

   package Singes_Vecs is new Ada.Containers.Indefinite_Vectors
     (Element_Type => Singe, Index_Type => Natural);
   subtype Singes is Singes_Vecs.Vector;
   function Singe_Avant (L, R : Singe) return Boolean is (L.Manip > R.Manip);
   package SSorter is new Singes_Vecs.Generic_Sorting (Singe_Avant);

   type Singe_Ligne is mod 7;
   Sgs : Singes;

   function T_as_le_seum (E : Natural) return Seum is
      Res : Seum;
   begin
      for I in Sgs.First_Index .. Sgs.Last_Index loop
         Res (I) := E mod Sgs (I).Diviseur;
      end loop;
      return Res;
   end T_as_le_seum;

   function Cree_Singe
     (Elems    : SB.Bounded_String; Opet : Ope; Oper : String;
      Diviseur : Positive; CV : Natural; CF : Natural) return Singe
   is
      Res : Singe;
   begin
      Res.Operateur  := Opet;
      Res.Diviseur   := Diviseur;
      Res.Cible_Vrai := CV;
      Res.Cible_Faux := CF;
      Res.Temp_Elems := Elems;
      if "old" /= Oper then
         Res.Operande := Natural'Value (Oper);
      end if;

      return Res;
   end Cree_Singe;

   procedure Ajuste_Singe (Res : in out Singe) is
      Elems : String          := SB.To_String (Res.Temp_Elems);
      Prev  : Natural         := 1;
      Off   : Natural;
      Cpt   : Natural;
      Patt  : constant String := ", ";
   begin
      Cpt := Ada.Strings.Fixed.Count (Source => Elems, Pattern => Patt);

      for I in 1 .. Cpt loop
         Off :=
           Ada.Strings.Fixed.Index
             (Source => Elems, Pattern => Patt, From => Prev);
         Seums_Vecs.Append
           (Res.Elements,
            T_as_le_seum (Natural'Value (Elems (Prev .. Off - 1))));
         Prev := Off + 2;
      end loop;
      Res.Elements.Append
        (T_as_le_seum (Natural'Value (Elems (Prev .. Elems'Last))));
   end Ajuste_Singe;

begin
   declare
      F        : File_Type;
      Lg_Cpt   : Natural := 0;
      Elems    : SB.Bounded_String;
      Opet     : Ope;
      Oper     : SB.Bounded_String;
      Diviseur : Positive;
      CV       : Natural;
      CF       : Natural;
   begin
      Open (F, Mode => In_File, Name => "ladata.txt");

      while not End_Of_File (F) loop
         declare
            use Ada.Strings.Fixed;
            Lig : constant String      := Get_Line (F);
            SL  : constant Singe_Ligne := Singe_Ligne'Val (Lg_Cpt mod 7);
         begin
            Put_Line (Lig);
            case SL is
               when 0 =>
                  Put_Line (Lig (8 .. 8));
               when 1 =>
                  Elems := SB.To_Bounded_String (Lig (19 .. Lig'Last));

               when 2 =>
                  begin
                     Opet := Plus;
                     if Lig (24) = '*' then
                        Opet := Mult;
                     end if;
                     Oper := SB.To_Bounded_String (Lig (26 .. Lig'Last));
                  end;
               when 3 =>
                  Diviseur := Natural'Value (Lig (21 .. Lig'Last));
               when 4 =>
                  CV := Natural'Value (Lig (30 .. 30));
               when 5 =>
                  CF := Natural'Value (Lig (31 .. 31));
               when 6 =>
                  Sgs.Append
                    (Cree_Singe
                       (Elems, Opet, SB.To_String (Oper), Diviseur, CV, CF));
            end case;
         end;
         Lg_Cpt := Lg_Cpt + 1;
      end loop;
      Close (F);
      Sgs.Append
        (Cree_Singe (Elems, Opet, SB.To_String (Oper), Diviseur, CV, CF));

   end;

   for S of Sgs loop
      Ajuste_Singe (S);
   end loop;

   for I in Sgs.First_Index .. Sgs.Last_Index loop
      Put_Line
        (Positive'Image (I) & " => " &
         Ada.Containers.Count_Type'Image (Sgs (I).Elements.Length));
   end loop;

   for T in 1 .. Tours loop
      for MI in Sgs.First_Index .. Sgs.Last_Index loop
         declare
            Cheeteur : Singe renames Sgs (MI);
         begin
            for I in
              Cheeteur.Elements.First_Index .. Cheeteur.Elements.Last_Index
            loop
               declare
                  Val    : Seum;
                  Droite : Natural;
                  C      : Natural;
               begin

                  Cheeteur.Manip := Cheeteur.Manip + 1;
                  Val            := Cheeteur.Elements.First_Element;
                  -- Put_Line("Manip " & Seum'Image(Val));
                  Cheeteur.Elements.Delete_First;

                  -- Put("Val ");
                  for SI in Sgs.First_Index .. Sgs.Last_Index loop
                     Droite := Cheeteur.Operande;
                     if Droite = 0 then
                        Droite := Val (SI);
                     end if;
                     case Cheeteur.Operateur is
                        when Plus =>
                           Val (SI) := Val (SI) + Droite;
                        when Mult =>
                           begin
   --         Put_Line(Natural'Image(Val(SI)) & " * " & Natural'Image(Droite));
                              Val (SI) := Val (SI) * Droite;
                           end;
                     end case;
                     -- Put(Natural'Image(Val (SI)));
                     Val (SI) := Val (SI) mod Sgs (SI).Diviseur;

                  end loop;
                  -- Put_Line("");

                  -- Val := Val / 3;
                  if Val (MI) = 0 then
                     C := Cheeteur.Cible_Vrai;
                  else
                     C := Cheeteur.Cible_Faux;
                  end if;
                  --  Put_Line
                  --    ("Bouge " & Long_Long_Integer'Image (Val) & " à " &
                  --     Positive'Image (C));
                  Sgs (C).Elements.Append (Val);
               end;
            end loop;
         end;
      end loop;
   end loop;
   SSorter.Sort (Sgs);
   Put_Line (Natural'Image (Sgs (0).Manip));
   Put_Line (Natural'Image (Sgs (1).Manip));
   Put_Line (Natural'Image (Sgs (2).Manip));
   Put_Line (Natural'Image (Sgs (3).Manip));
   Put_Line
     (Long_Long_Integer'Image
        (Long_Long_Integer'Val (Sgs (0).Manip) *
         Long_Long_Integer'Val (Sgs (1).Manip)));
end Main;
