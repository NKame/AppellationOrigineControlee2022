with Ada.Text_IO;
with Ada.Strings.Unbounded;

package body Jour1 is

   procedure Main is
      use Ada.Text_IO;
      use Ada.Strings.Unbounded;

      F      : File_Type;
      S      : Unbounded_String;
      CurCal : Integer  := 0;
      GrosMax : Integer := 0;
      Tops   : TopsType := (0, 0, 0);
   begin
      Open (F, Mode => In_File, Name => "ladata.txt");
      while not End_Of_File (F) loop
         S := To_Unbounded_String (Get_Line (F));
         if S = Null_Unbounded_String then
            control :
            for I in TopsRange loop
               if CurCal > Tops (I) then
                  Put_Line
                    ("Nouveau max " & Integer'Image (CurCal) & " à " &
                     TopsRange'Image (I));
                  Decale (Tops, I);
                  Tops (I) := CurCal;
                  exit control;
               end if;
            end loop control;
            CurCal := 0;
         else
            CurCal := CurCal + Integer'Value (To_String (S));
         end if;

         -- Put_Line(To_String(S));
      end loop;
      Put_Line ("Le grand max ");
      for I in TopsRange loop
         Put_Line (Integer'Image (Tops (I)));
         GrosMax := GrosMax + Tops(I);
      end loop;
      Put_Line (Integer'Image(GrosMax));
   exception
      when End_Error =>
         Close (F);
   end Main;

   procedure Decale (Tableau : in out TopsType; Depart : TopsRange) is
      Max : TopsRange;
   begin
      Max := TopsRange'Last - 1;
      for I in reverse Depart .. Max loop
         Ada.Text_IO.Put_Line (TopsRange'Image (I));
         Tableau (I + 1) := Tableau (I);
      end loop;
   end Decale;
end Jour1;
