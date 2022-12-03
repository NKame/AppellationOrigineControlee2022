with Ada.Text_IO;
with Ada.Strings.Bounded;
with Ada.Characters;

package body Jour2 is

   procedure Main is
      use Ada.Text_IO;

      F : File_Type;
      package SB is new Ada.Strings.Bounded.Generic_Bounded_Length (3);
      L : SB.Bounded_String;
      Autre, Moi: Integer;
      Score: Integer := 0;
      Score2: Integer := 0;

   begin
      Open (F, Mode => In_File, Name => "ladata.txt");
      while not End_Of_File (F) loop
         L := SB.To_Bounded_String (Get_Line (F));
         Autre := Character'Pos(SB.Element(L, 1)) - Character'Pos('A');
         Moi := Character'Pos(SB.Element(L, 3)) - Character'Pos('X');
         
         Score := Score + 1 + Moi;
         if Autre = Moi then
            Score := Score + 3;
         elsif (Moi - Autre) mod 3 = 1 then
            Score := Score + 6;
         end if;
         
         Score2 := Score2 + 1 + 3 * Moi + (Autre + Moi - 1) mod 3;         
      end loop;
      Put_Line (Integer'Image(Score));
      Put_Line (Integer'Image(Score2));
      exception
      when End_Error =>
         Close (F);
   end Main;
end Jour2;
