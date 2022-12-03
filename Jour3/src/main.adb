with Ada.Text_IO;
with Ada.Strings.Bounded;
with Ada.Characters;
with Ada.Containers.Hashed_Sets;
with Ada.Containers;
with Ada.Characters.Handling;

procedure Main is
   use Ada.Text_IO;
   use Ada.Containers;
   use Ada.Characters.Handling;

   F : File_Type;
   package SB is new Ada.Strings.Bounded.Generic_Bounded_Length (60);
   L      : SB.Bounded_String;
   Milieu : Integer;

   function Hash (C : Character) return Hash_Type is
   begin
      return Hash_Type (Character'Pos (C));
   end Hash;

   package Char_Sets is new Ada.Containers.Hashed_Sets
     (Element_Type => Character, Hash => Hash, Equivalent_Elements => "=");

   use Char_Sets;
   G, D, Inter : Set;
   type Compteur is range 1..3;
   type BadgeType is array(Compteur) of Set;
   Badge: BadgeType;
   Seq: Compteur := Compteur'First;

   Prios, Prios2       : Integer := 0;

   function prems (S : Set) return Character is
      Res: Character;
   begin
      for E of S loop
         Res := E;
         exit;
      end loop;
      return Res;
   end prems;

   function prio (C : Character) return Integer is
      Res : Integer;
   begin
      if Is_Lower (C) then
         Res := Character'Pos (C) - Character'Pos ('a') + 1;
      else
         Res := Character'Pos (C) - Character'Pos ('A') + 27;
      end if;
      return Res;
   end prio;

   function prioBadge(B: BadgeType) return Integer is
      Comm: Character;
   begin
      Comm := prems (B(1) and B(2) and B(3));
      return prio (Comm);
   end;
begin
   Open (F, Mode => In_File, Name => "ladata.txt");
   while not End_Of_File (F) loop
      L := SB.To_Bounded_String (Get_Line (F));

      -- pour le 2
      Clear(Badge(Seq));
      for i in 1 .. SB.Length(L) loop
         Badge(Seq).Include(SB.Element (L, i));
      end loop;

      if Seq = Compteur'Last then
         Prios2 := Prios2 + prioBadge(Badge);
         Seq := Compteur'First;
      else
         Seq := Seq + 1;
      end if;

      -- pour le 1
      Clear (G);
      Clear (D);
      Milieu := SB.Length (L) / 2;
      for i in 1 .. Milieu loop
         G.Include (SB.Element (L, i));
      end loop;

      for i in Milieu + 1 .. 2 * Milieu loop
         D.Include (SB.Element (L, i));
      end loop;
      Inter := G and D;

      Prios := Prios + prio (prems (Inter));
   end loop;

   Put_Line (Integer'Image (Prios));
   Put_Line (Integer'Image (Prios2));

exception
   when End_Error =>
      Close (F);
end Main;
