with Ada.Text_IO;
with Ada.Strings.Bounded;
with Ada.Characters;

procedure Main is
   use Ada.Text_IO;
   F : File_Type;
   package SB is new Ada.Strings.Bounded.Generic_Bounded_Length (30);
   type Section_Range is record
      Deb : Positive;
      Fin : Positive;
   end record;
   procedure Aff_SR (SR : Section_Range) is
   begin
      Put_Line (Positive'Image(SR.Deb)
                & " => "
                & Positive'Image(SR.Fin));
   end Aff_SR;

   function RecouvreTotal(SR1 : Section_Range; SR2 : Section_Range) return Boolean is
   begin
      return (SR1.Deb <= SR2.Deb and SR1.Fin >= SR2.Fin) or (SR2.Deb <= SR1.Deb and SR2.Fin >= SR1.Fin);
   end;

   function Recouvre(SR1 : Section_Range; SR2 : Section_Range) return Boolean is
   begin
      return (SR1.Deb >= SR2.Deb and SR1.Deb <= SR2.Fin)
        or (SR1.Fin >= SR2.Deb and SR1.Fin <= SR2.Fin)
        or (SR2.Deb >= SR1.Deb and SR2.Deb <= SR1.Fin)
        or (SR2.Fin >= SR1.Deb and SR2.Fin <= SR1.Fin);
   end;

   S1, S2 : Section_Range;
   L      : SB.Bounded_String;
   Prev, Off: Natural;

   Score1, Score2 : Natural := 0;
begin
   Open (F, Mode => In_File, Name => "ladata.txt");
   while not End_Of_File (F) loop
      L := SB.To_Bounded_String (Get_Line (F));


      Prev := 1;
      Off := SB.Index(Source => L, Pattern => "-", From => Prev);
      S1.Deb := Positive'Value(SB.To_String(L)(Prev .. Off - 1));
      Prev := Off + 1;
      Off := SB.Index(Source => L, Pattern => ",", From => Prev);
      S1.Fin := Positive'Value(SB.To_String(L)(Prev .. Off - 1));
      -- Aff_SR(S1);

      Prev := Off + 1;
      Off := SB.Index(Source => L, Pattern => "-", From => Prev);
      S2.Deb := Positive'Value(SB.To_String(L)(Prev .. Off - 1));
      Prev := Off + 1;
      S2.Fin := Positive'Value(SB.To_String(L)(Prev .. SB.Length(L)));
      -- Aff_SR(S2);

      If RecouvreTotal(S1, S2) Then
         Score1 := Score1 + 1;
      end if;
      If Recouvre(S1, S2) Then
         Score2 := Score2 + 1;
      end if;
   end loop;
   Put_Line("Score1 : " & Natural'Image(Score1));
   Put_Line("Score2 : " & Natural'Image(Score2));
end Main;
