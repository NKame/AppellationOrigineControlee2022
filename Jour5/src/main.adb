with Ada.Text_IO;
with Ada.Strings.Bounded;
with Ada.Characters;
with Ada.Containers.Vectors;
with Ada.Strings.Fixed;

procedure Main is
   use Ada.Text_IO;
   F : File_Type;
   package SB is new Ada.Strings.Bounded.Generic_Bounded_Length (36);
   L     : SB.Bounded_String;
   Mouvs : Boolean := False;

   subtype Stock_CPT is Positive range 1 .. 1_000;

   package StockDesc_Vecs is new Ada.Containers.Vectors
     (Element_Type => SB.Bounded_String, Index_Type => Stock_CPT,
      "="          => SB."=");
   package Stock_Vecs is new Ada.Containers.Vectors
     (Element_Type => Character, Index_Type => Stock_CPT);

   subtype Stock_Vec is Stock_Vecs.Vector;

   package Stocks_Vecs is new Ada.Containers.Vectors
     (Element_Type => Stock_Vec, Index_Type => Stock_CPT,
      "="          => Stock_Vecs."=");

   StockDesc : StockDesc_Vecs.Vector;

   Stocks : Stocks_Vecs.Vector;

   function Extrait_Stocks return Stocks_Vecs.Vector is
      Prems  : Boolean := True;
      Result : Stocks_Vecs.Vector;
      S      : SB.Bounded_String;
      Off    : Natural;
      Top    : Positive;
      C      : Character;
      use Ada.Strings;
      function Nouv_Stock return Stock_Vec is
         Result : Stock_Vec;
      begin
         return Result;
      end Nouv_Stock;
   begin
      for I in reverse StockDesc.First_Index .. StockDesc.Last_Index loop
         S := StockDesc.Element (I);
         if Prems then
            -- première ligne, il nous faut le dernier numéro
            Off := SB.Index (S, " ", Going => Backward) + 1;
            Ada.Text_IO.Put_Line (SB.To_String (S) (Off .. SB.Length (S)));
            Top := Positive'Value (SB.To_String (S) (Off .. SB.Length (S)));

            for J in 1 .. Top loop
               Result.Append (Nouv_Stock);
            end loop;

            Prems := False;
         else
            for I in 1 .. Top loop
               Off := 2 + 4 * (I - 1);
               if Off <= SB.Length (S) then
                  C := SB.Element (S, Off);
                  if C /= ' ' then
                     Result (I).Append (C);
                     -- Ada.Text_IO.Put_Line (Character'Image(C));
                  end if;
               end if;
            end loop;
         end if;
      end loop;
      return Result;
   end Extrait_Stocks;

   procedure Aff_Stocks is
      SV : Stock_Vec;
   begin
      for I in Stocks.First_Index .. Stocks.Last_Index loop
         Put (Integer'Image (I) & " :");
         SV := Stocks.Element (I);
         for J in SV.First_Index .. SV.Last_Index loop
            Put (" " & Character'Image (SV.Element (J)));
         end loop;
         Put_Line ("");
      end loop;
   end Aff_Stocks;

   procedure Bouge1 (L : SB.Bounded_String) is
      S, D, N   : Positive;
      Prev, Off : Natural := 1;
      Src, Dst  : Stock_Vec;
   begin
      Off  := SB.Index (L, " from");
      N    := Positive'Value (SB.To_String (L) (6 .. Off - 1));
      Prev := Off;
      Off  := SB.Index (L, " to", From => Prev);
      S    := Positive'Value (SB.To_String (L) (Prev + 6 .. Off - 1));
      D    := Positive'Value (SB.To_String (L) (Off + 4 .. SB.Length (L)));

      -- Put_Line
      --   (Natural'Image (S) & "=(" & Natural'Image (N) & ")=>" &
      --   Natural'Image (D));
      Src := Stocks.Element (S);
      Dst := Stocks.Element (D);
      for I in 1 .. N loop
         Dst.Append (Src.Last_Element);
         Src.Delete_Last;
      end loop;
      Stocks.Replace_Element (S, Src);
      Stocks.Replace_Element (D, Dst);
   end Bouge1;


   procedure Bouge2 (L : SB.Bounded_String) is
      S, D, N   : Positive;
      Prev, Off : Natural := 1;
      Src, Dst  : Stock_Vec;
   begin
      Off  := SB.Index (L, " from");
      N    := Positive'Value (SB.To_String (L) (6 .. Off - 1));
      Prev := Off;
      Off  := SB.Index (L, " to", From => Prev);
      S    := Positive'Value (SB.To_String (L) (Prev + 6 .. Off - 1));
      D    := Positive'Value (SB.To_String (L) (Off + 4 .. SB.Length (L)));

      -- Put_Line
      --   (Natural'Image (S) & "=(" & Natural'Image (N) & ")=>" &
      --   Natural'Image (D));
      Src := Stocks.Element (S);
      Dst := Stocks.Element (D);
      for I in Src.Last_Index - N + 1 .. Src.Last_Index loop
         Dst.Append (Src.Element(I));
      end loop;
      Src.Delete_Last(Ada.Containers.Count_Type(N));

      Stocks.Replace_Element (S, Src);
      Stocks.Replace_Element (D, Dst);
   end Bouge2;

   procedure Soluce is
   begin
      Put_Line ("Soluce :");
      Aff_Stocks;
      for I in Stocks.First_Index .. Stocks.Last_Index loop
         Put("" & Stocks.Element(I).Last_Element);
      end loop;
   end Soluce;
begin
   Open (F, Mode => In_File, Name => "ladata.txt");
   while not End_Of_File (F) loop
      L := SB.To_Bounded_String (Get_Line (F));

      if Mouvs then
         Bouge2 (L);
         -- Aff_Stocks;
      else
         if SB.Length (L) = 0 then
            Put_Line ("Fin de l'état initial");
            Stocks := Extrait_Stocks;
            Mouvs  := True;
            Aff_Stocks;
         else
            StockDesc.Append (L);
         end if;
      end if;

      -- Put_Line (SB.To_String (L));
   end loop;
   Soluce;
end Main;
