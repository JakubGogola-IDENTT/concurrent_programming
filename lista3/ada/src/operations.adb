package body Operations is
   function Add (A : Integer; B : Integer) return Integer is
   begin
      return A + B;
   end Add;
         
   function Sub (A : Integer; B : Integer) return Integer is
   begin
      return A - B;
   end Sub;
      
   function Mul (A : Integer; B : Integer) return Integer is
   begin
      return A * B;
   end Mul;
     
   function Div (A : Integer; B : Integer) return Integer is
   begin
      if B = 0 then
	 return 0;
      else
	 return A / B;
      end if;
   end Div;
end Operations;
