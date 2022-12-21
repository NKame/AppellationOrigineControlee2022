with Ada.Text_IO;
with Ada.Strings.Fixed;

procedure Main is
   use Ada.Text_IO;

   type Dirs is (U, R, D, L);
   type Axe is (X, Y);
   function Next_Axe (A : Axe) return Axe is
     (if A =
        Axe'Last then Axe'First else Axe'Succ
          (A))                                --'
   with
      Inline_Always;

   subtype Val_Type is Integer;
   type Vals_Array is array (Axe'Range) of Val_Type;
   type Quad is record
      Taille : Vals_Array;
      Orig   : Vals_Array;
   end record;

   Nb_Noeuds : constant Positive := 9;

   function V (N : Val_Type) return String renames Val_Type'Image;
   function VV (N : Vals_Array) return String is
   begin
      return "(" & V(N(X)) & ", " & V(N(Y)) & ")";
   end;

   function trouve_dim_grille return Quad is
      Curs   : Vals_Array := (others => 0);
      Mins   : Vals_Array := (others => 0);
      Maxs   : Vals_Array := (others => 0);
      Result : Quad;

      procedure Adj (Dir : Axe; Delt : Val_Type) is
         Val : Val_Type;
      begin
         Val        := Delt + Curs (Dir);
         Curs (Dir) := Val;
         if Val > Maxs (Dir) then
            Maxs (Dir) := Val;
         end if;
         if Val < Mins (Dir) then
            Mins (Dir) := Val;
         end if;
      end Adj;
      F : File_Type;
   begin
      Open (F, Mode => In_File, Name => "ladata.txt");

      while not End_Of_File (F) loop
         declare
            use Ada.Strings.Fixed;
            Lig : constant String := Get_Line (F);
            Dir : Dirs            := Dirs'Value (Lig (1 .. 1));
            Val : Natural         := Natural'Value (Lig (3 .. Lig'Last));
         begin
            -- Put_Line (Lig);
            case Dir is
               when U =>
                  Adj (Y, Val);
               when R =>
                  Adj (X, Val);
               when D =>
                  Adj (Y, -Val);
               when L =>
                  Adj (X, -Val);
            end case;
         end;
      end loop;
      Close (F);
      Put_Line
        ("Min X " & V (Mins (X)) & ", Max X" & V (Maxs (X)) & ", Min Y" &
         V (Mins (Y)) & ", Max Y" & V (Maxs (Y)));
      for I in Axe'Range loop
         Result.Taille (I) := Maxs (I) - Mins (I) + 1;
         Result.Orig (I)   := -Mins (I);
      end loop;

      return Result;
   end trouve_dim_grille;

   procedure parkour (Dims : Quad) is
      F : File_Type;
      type Boolean_Array is
        array (1 .. Dims.Taille (X) * Dims.Taille (Y)) of Boolean with
         Component_Size => 1,
         Pack;
      type Diffs_Array is array (1 .. Nb_Noeuds) of Vals_Array;
      H_Pos  : Vals_Array    := Dims.Orig;
      Diffs  : Diffs_Array   := (others => (0, 0));
      Grille : Boolean_Array := (others => False);

      function Somme_Diffs(Dir : Axe) return Val_Type is
         Res: Val_Type := 0;
      begin
         for D of Diffs loop
            Res := Res + D(Dir);
         end loop;
         return Res;
      end;

      procedure Adj (Dir : Axe; Delt : Val_Type) is
         Inc     : Val_Type := 1;
         Sub_Inc : Val_Type;
      begin
         if Delt < 0 then
            Inc := -1;
         end if;

         for I in 1 .. abs Delt loop
            H_Pos (Dir)     := H_Pos (Dir) + Inc;
            Diffs (1) (Dir) := Diffs (1) (Dir) - Inc;

            for J in Diffs_Array'Range loop
               if not (abs Diffs (J) (X) < 2 and abs Diffs (J) (Y) < 2) then
                  for I in Axe'Range loop
                     if abs Diffs (J) (I) = 2 then
                        Sub_Inc       := Diffs (J) (I) / (abs Diffs (J) (I));
                        Diffs (J) (I) := Sub_Inc;
                        if J /= Diffs_Array'Last then
                           Diffs (J + 1) (I) := Diffs (J + 1) (I) + Sub_Inc;
                        end if;
                     elsif abs Diffs (J) (I) = 1 then
                        if J /= Diffs_Array'Last then
                           Diffs (J + 1) (I) :=
                             Diffs (J + 1) (I) + Diffs (J) (I);
                        end if;
                        Diffs (J) (I) := 0;
                     end if;
                  end loop;
               end if;
            end loop;

            --  Put(VV(H_Pos));
            --  for D of Diffs loop
            --     Put(VV(D));
            --  end loop;
            --  Put_Line("");

            Grille
              (1 + H_Pos (X) + Somme_Diffs (X) +
               Dims.Taille (X) * (H_Pos (Y) + Somme_Diffs (Y))) :=
              True;
         end loop;
         --  for I of Grille loop
         --     if I then
         --        Put ("#");
         --     else
         --        Put ("-");
         --     end if;
         --  end loop;
         --  Put_Line ("");
         declare
            Score : Natural := 0;
         begin
            for I of Grille loop
               if I then
                  Score := Score + 1;
               end if;
            end loop;
            Put_Line ("Score : " & Natural'Image (Score));
         end;
      end Adj;
   begin
      Open (F, Mode => In_File, Name => "ladata.txt");

      while not End_Of_File (F) loop
         declare
            use Ada.Strings.Fixed;
            Lig : constant String := Get_Line (F);
            Dir : Dirs            := Dirs'Value (Lig (1 .. 1));
            Val : Natural         := Natural'Value (Lig (3 .. Lig'Last));
         begin
            case Dir is
               when U =>
                  Adj (Y, Val);
               when R =>
                  Adj (X, Val);
               when D =>
                  Adj (Y, -Val);
               when L =>
                  Adj (X, -Val);
            end case;
         end;
      end loop;

   end parkour;
begin
   declare
      Dims : Quad;

   begin
      Dims := trouve_dim_grille;
      Put_Line
        ("Larg " & V (Dims.Taille (X)) & ", Haut " & V (Dims.Taille (Y)) &
         ", Orig X " & V (Dims.Orig (X)) & ", Orig Y " & V (Dims.Orig (Y)));
      parkour (Dims);
   end;
end Main;
