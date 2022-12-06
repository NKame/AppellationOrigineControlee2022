with Ada.Text_IO;
with Ada.Strings.Bounded;
with Ada.Characters;

procedure Main is
   use Ada.Text_IO;
   F : File_Type;
   package SB is new Ada.Strings.Bounded.Generic_Bounded_Length (8192);
   L     : SB.Bounded_String;
   Lng_Marqueur: constant Positive := 14;
   type Buf_Range is range 1 .. Lng_Marqueur;
   type Buf_Type is array(Buf_Range) of Character;


   function Unique(Buf: Buf_Type) return Boolean is
   begin
      for I in Buf_Range'First .. Buf_Range'Last - 1 loop
         for J in I + 1 .. Buf_Range'Last loop
            if Buf(I) = Buf(J) then
               return False;
            end if;
         end loop;
      end loop;
      return True;
   end;

   procedure Gere_Ligne(L     : SB.Bounded_String) is
      Buf: Buf_Type;
      CI: Buf_Range := 1;
   begin
      boucle:
      for I in 1 .. SB.Length(L) loop
         Buf(CI) := SB.Element(L, I);
         CI := (CI mod Buf_Range'Last) + 1;

         if I >= Lng_Marqueur and Unique(Buf) then
            Put_Line(Positive'Image(I));
            exit boucle;
         end if;
      end loop boucle;
   end;
begin
   Open (F, Mode => In_File, Name => "ladata.txt");
   while not End_Of_File (F) loop
      L := SB.To_Bounded_String (Get_Line (F));
      -- Put_Line (SB.To_String (L));
      Gere_Ligne(L);
   end loop;
end Main;
