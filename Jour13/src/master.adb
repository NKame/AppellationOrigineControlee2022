with Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;
with Ada.Containers.Indefinite_Vectors;

procedure Master is
   use Ada.Text_IO;
   Dit_Beug : constant Boolean := False;

   F : File_Type;
   type Decision is (OK, KO, Continue, Fin_Seq);

   procedure Dbg (S : String) is
   begin
      if Dit_Beug then
         Put_Line (S);
      end if;
   end Dbg;

   function DT (S : String; SI : Positive) return Boolean is
   begin
      return S (SI) = '[';
   end DT;
   function FT (S : String; SI : Positive) return Boolean is
   begin
      return S (SI) = ']';
   end FT;
   function NI (E : Natural) return String renames Natural'Image;

   function Fin_Tableau
     (G, D : String; SI, DI : Positive; AG, AD : Boolean) return Decision
   is
      A, B : Boolean;
      use Ada.Characters.Handling;
   begin
      A := FT (G, SI) or (AG and then not Is_Digit (G (SI)));
      B := FT (D, DI) or (AD and then not Is_Digit (D (DI)));

      if A and not B then
         -- plus d'élément à gauche, c'est bon et terminal
         Dbg ("OK Gauche fini a " & NI (SI) & " " & Boolean'Image (AG));
         return OK;
      elsif B and not A then
         -- plus d'élément à droite et encore à gauche, mauvais et terminal
         Dbg ("KO Droite fini a " & NI (DI) & " " & Boolean'Image (AD));
         return KO;
      elsif A and B then
         return Fin_Seq;
      end if;
      return Continue;
   end Fin_Tableau;

   function Next_Nat (S : String; SI : in out Natural) return Natural is
      use Ada.Strings.Fixed;
      Off1 : Natural := Index (Source => S, Pattern => ",", From => SI);
      Off2 : Natural := Index (Source => S, Pattern => "]", From => SI);
      Off  : Natural;
   begin
      Off := Off1;
      if Off = 0 or Off2 < Off1 then
         Off := Off2;
      end if;
      Off1 := Natural'Value (S (SI .. Off - 1));
      -- on bouge le pointeur
      SI := Off;
      return Off1;
   end Next_Nat;

   procedure saute_virg (S : String; SI : in out Natural; Aug : Boolean) is
   begin
      if not Aug and S (SI) = ',' then
         SI := SI + 1;
      end if;
   end saute_virg;

   function dans_l_ordre_tab
     (G, D : String; SI, DI : in out Positive) return Decision
   is
      Res    : Decision := Continue;
      AG, AD : Boolean  := False;
      GN, DN : Natural;
   begin
      Dbg ("dans_l_ordre_tab " & NI (SI) & ", " & NI (DI));
      if not DT (D, DI) then
         -- augmente droite
         AD := True;
      elsif not DT (G, SI) then
         -- augmente gauche
         AG := True;
      end if;

      -- on passe au "deuxième caractère"
      if not AG then
         SI := SI + 1;
      end if;
      if not AD then
         DI := DI + 1;
      end if;

      while Res = Continue loop

         case Fin_Tableau (G, D, SI, DI, AG, AD) is
            when OK =>
               return OK;
            when KO =>
               return KO;
            when Fin_Seq =>
               begin
                  if not AG then
                     SI := SI + 1;
                  end if;
                  if not AD then
                     DI := DI + 1;
                  end if;
                  return Continue;
               end;
            when Continue =>
               null;
         end case;

         if DT (G, SI) or else DT (D, DI) then
            case dans_l_ordre_tab (G, D, SI, DI) is
               when OK =>
                  return OK;
               when KO =>
                  return KO;
               when Fin_Seq =>
                  null; -- impossible
               when Continue =>
                  null;
            end case;
         else
            GN := Next_Nat (G, SI);
            DN := Next_Nat (D, DI);

            if GN < DN then
               Dbg ("OK " & NI (GN) & " < " & NI (DN));
               return OK;
            elsif GN > DN then
               Dbg ("KO " & NI (GN) & " > " & NI (DN));
               return KO;
            end if;
         end if;

         -- on saute les virgules
         saute_virg (G, SI, AG);
         saute_virg (D, DI, AD);
      end loop;

      return Res;
   end dans_l_ordre_tab;

   function dans_l_ordre (G, D : String) return Boolean is
      SI, DI : Positive := 1;
      Rate : exception;
   begin
      case dans_l_ordre_tab (G, D, SI, DI) is
         when OK =>
            return True;
         when KO =>
            return False;
         when Continue =>
            return True;
         when others =>
            raise Rate;
      end case;
   end dans_l_ordre;

begin
   declare
      Score : Natural  := 0;
      Cpt   : Positive := 1;
      package Signal_Liste is new Ada.Containers.Indefinite_Vectors
        (Element_Type => String, Index_Type => Positive);
      function Signal_Avant (G, D : String) return Boolean is
        (dans_l_ordre (G, D));
      package SSorter is new Signal_Liste.Generic_Sorting (Signal_Avant);
      Sig1    : constant String := "[[2]]";
      Sig2    : constant String := "[[6]]";
      Signaux : Signal_Liste.Vector;
   begin

      Open (F, Mode => In_File, Name => "ladata.txt");
      Signaux.Append (Sig1);
      Signaux.Append (Sig2);

      while not End_Of_File (F) loop
         declare
            use Ada.Strings.Fixed;
            Lig1 : constant String := Get_Line (F);
            Lig2 : constant String := Get_Line (F);
         begin
            -- Put_Line (Lig1);
            -- Put_Line (Lig2);
            Signaux.Append (Lig1);
            Signaux.Append (Lig2);

            if dans_l_ordre (Lig1, Lig2) then
               Dbg ("Dans l'ordre");
               Score := Score + Cpt;
            else
               Dbg ("PAS dans l'ordre");
            end if;
            Cpt := Cpt + 1;
            if not End_Of_File (F) then

               declare
                  Buf : constant String := Get_Line (F);
               begin
                  null;
               end;
            end if;
         end;
      end loop;
      SSorter.Sort (Signaux);

      If Dit_Beug then
      For S of Signaux loop
         Put_Line(S);
         end loop;
         end if;

      Put_Line ("Score : " & Natural'Image (Score));
      Put_Line ("Score2 : " & Natural'Image (Signaux.Find_Index(Sig1) * Signaux.Find_Index(Sig2)));
   end;
end Master;
