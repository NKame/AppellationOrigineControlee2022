with Ada.Text_IO;
with Ada.Strings.Hash;
with Ada.Characters;
with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Strings.Fixed;

procedure Main is
   use Ada.Text_IO;
   F : File_Type;
   subtype Dossier is String;
   package Dossier_Piles is new Ada.Containers.Indefinite_Vectors
     (Element_Type => Dossier, Index_Type => Positive);
   subtype Dossier_Pile is Dossier_Piles.Vector;

   package Dossier_Maps is new Ada.Containers.Indefinite_Hashed_Maps
     (Key_Type => Dossier, Element_Type => Natural, Hash => Ada.Strings.Hash,
      Equivalent_Keys => "=");

   Parkour  : Dossier_Pile;
   Dossiers : Dossier_Maps.Map;
   Cible1   : constant Natural := 100_000;
   Score1   : Natural          := 0;
   Taill2   : constant Natural := 70_000_000;
   Cible2   : constant Natural := 30_000_000;
   Score2   : Natural          := 0;
begin
   Open (F, Mode => In_File, Name => "ladata.txt");

   while not End_Of_File (F) loop
      declare
         use Ada.Strings.Fixed;
         L : constant String := Get_Line (F);
      begin

         Put_Line (L);

         if L = "$ cd .." then
            Parkour.Delete_Last;
         elsif L = "$ ls" then
            Put_Line ("LS");
            null;
         elsif Index (L, "$ cd") = 1 then
            declare
               Buf : constant String := L (6 .. L'Last);
            begin
               if Buf = "/" then
                  Parkour.Clear;
                  Parkour.Append ("/");
               else
                  Parkour.Append (Parkour.Last_Element & "/" & Buf);
               end if;
               -- Put_Line ("CD Down " & Buf);
            end;
         elsif Index (L, "dir ") = 1 then
            -- Put_Line ("Présence dossier");
            null;
         else
            declare
               Off : constant Natural := Index (L, " ");
               Val : constant Natural := Positive'Value (L (1 .. Off));
            begin
               Put_Line ("Contenu " & Positive'Image (Val));
               for C in Parkour.Iterate loop
                  declare
                     Cur    : constant String := Parkour (C);
                     OldVal : Natural         := 0;
                  begin
                     if Dossiers.Contains (Cur) then
                        OldVal         := Dossiers (Cur);
                        Dossiers (Cur) := OldVal + Val;
                     else
                        Dossiers.Include (Cur, Val);
                     end if;
                  end;
               end loop;
            end;
         end if;
      end;
   end loop;

   declare
      Restant : constant Natural := Cible2 - (Taill2 - Dossiers ("/"));
   begin
      Put_Line ("Nouvelle cible " & Restant'Image);
      for C in Dossiers.Iterate loop
         declare
            use Dossier_Maps;
            Val : constant Natural := Dossiers (C);
         begin
            Put_Line ("Dossier = " & Key (C) & " => " & Val'Image);
            if Val <= Cible1 then
               Score1 := Score1 + Val;
            end if;
            if Val >= Restant and (Val < Score2 or Score2 = 0) then
               Put_Line ("Nouv score 2" & Val'Image);
               Score2 := Val;
            end if;
         end;
      end loop;
   end;

   Put_Line ("Score 1 : " & Score1'Image);
   Put_Line ("Score 2 : " & Score2'Image);
end Main;
