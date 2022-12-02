package Jour1 is
   type TopsRange is range 1 .. 3;
   type TopsType is array(TopsRange) of Integer;

   procedure Main;
   procedure Decale(Tableau: in out TopsType; Depart: TopsRange) ;
end Jour1;
