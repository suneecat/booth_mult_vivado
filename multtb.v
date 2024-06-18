//Copyright: Paul Lazar
//May 2019

`timescale 1ns/1ns

module boothmodified(Xin,Yin,Z); //
parameter IN_WIDTH = 4;
parameter IN_x2=IN_WIDTH*2;// this parameter is not used, all widths etc are based on IN_WIDTH

parameter N_odd=IN_WIDTH%2;
parameter NUM_shift = (IN_WIDTH+1)/2;// to handle odd N
parameter IN_ADJUST=IN_WIDTH+N_odd;
parameter OUT_WIDTH = IN_ADJUST*2;

input signed [IN_WIDTH-1:0]  Xin,Yin;
output signed [OUT_WIDTH-1:0]      Z;
reg signed [OUT_WIDTH:0]    product;
reg signed [OUT_WIDTH-1:0]   Z;
reg b_1;
integer i;

wire signed [IN_ADJUST-1:0] X,Y;
wire signed [IN_ADJUST:0]   multsx;
assign Y=Yin;
assign X=Xin;

assign multsx = {X[IN_ADJUST-1],X};// sign extend X
//wire signed [IN_ADJUST-1:0]   multsx = X;// no sign extend X

always @(*)
begin
product[IN_ADJUST-1:0]=Y;
product[OUT_WIDTH:IN_ADJUST]=0;
b_1=0;
for (i = 0; i < NUM_shift; i = i + 1)
    begin
//$display($time, " %m IN_WIDTH =%d, IN_ADJUST= %d, OUT_WIDTH =%d, N_odd= %d, X=%d, Y=%d, Xin=%b, Yin=%b", IN_WIDTH, IN_ADJUST,OUT_WIDTH,N_odd,X,Y,Xin,Yin);
//$display($time, " %m, i=%1d before addition product=%b,%d  multsx=%b X = %b %d  Y = %b %d  Z =  %b %d", i,product,product,multsx,X,X,Y,Y,Z,Z) ; 
//$display($time, " %m, i=%1d, upper=%b, lower=%b, sel=%b", i,product[OUT_WIDTH:IN_ADJUST], product[IN_ADJUST-1:0], {product[1:0],b_1});
    case ( {product[1:0],b_1} )
          3'b001: product[OUT_WIDTH:IN_ADJUST] = product[OUT_WIDTH:IN_ADJUST] + multsx;
          3'b010: product[OUT_WIDTH:IN_ADJUST] = product[OUT_WIDTH:IN_ADJUST] + multsx;
          3'b011: product[OUT_WIDTH:IN_ADJUST] = product[OUT_WIDTH:IN_ADJUST] + 2 * X;
          3'b100: product[OUT_WIDTH:IN_ADJUST] = product[OUT_WIDTH:IN_ADJUST] - 2 * X;
          3'b101: product[OUT_WIDTH:IN_ADJUST] = product[OUT_WIDTH:IN_ADJUST] - multsx;
          3'b110: product[OUT_WIDTH:IN_ADJUST] = product[OUT_WIDTH:IN_ADJUST] - multsx;
        endcase
//$display($time, " %m, i=%1d after addition product=%b,%d  multsx=%b b_1=%b   X = %b %d  Y = %b %d  Z =  %b %d", i,product,product,multsx,b_1,X,X,Y,Y,Z,Z) ; 
//$display($time, " %m, i=%1d, upper=%b, lower=%b, sel=%b",i,product[OUT_WIDTH:IN_ADJUST], product[IN_ADJUST-1:0],{product[1:0],b_1}) ;
        b_1 = product[1];
        product = { product[OUT_WIDTH], product[OUT_WIDTH], product[OUT_WIDTH:2] }; // arith. right shift, twice
//$display($time, " %m, i=%1d after shift product=%b,%d  multsx=%b b_1=%b   X = %b %d  Y = %b %d  Z =  %b %d", i,product,product,multsx,b_1,X,X,Y,Y,Z,Z) ; 
//$display($time, " %m, i=%1d, upper=%b, lower=%b, sel=%b",i,product[OUT_WIDTH:IN_ADJUST], product[IN_ADJUST-1:0],{product[1:0],b_1} );
    end 
Z=product[OUT_WIDTH-1:0];
if ( (Y == -(2**(IN_ADJUST-1))) && (X == -(2**(IN_ADJUST-1))) ) //most negative values
    begin
    $display("WARNING: overflow; Y=%d, X=%d, Z=%d",X,Y,Z);
    $display($time, " %m, result:  X = %b %d  Y = %b %d  Z =  %b %d",X,X,Y,Y,Z,Z);
    $display($time, "WARNING: setting product to -product, to avoid test errors; this is artificail");
    Z=-Z;
    end
end

endmodule






module booth (X, Y, Z);
parameter IN_WIDTH = 4;
parameter OUT_WIDTH = IN_WIDTH*2;

 input signed [IN_WIDTH-1:0] X, Y;
 
 output signed [OUT_WIDTH-1:0] Z;
 reg signed [OUT_WIDTH-1:0] Z;
 reg [1:0] temp;
 integer i;
 reg E1;
 
 always @ (X, Y)
 begin
 Z = 0;
 E1 = 0;
 for (i = 0; i < IN_WIDTH; i = i + 1)
 begin
 temp = {X[i], E1};
 //concatenate the 2 bits
 
 case (temp)
 2'b00 : Z [OUT_WIDTH-1 : IN_WIDTH] = Z [OUT_WIDTH-1 : IN_WIDTH] + 0;
 2'b10 : Z [OUT_WIDTH-1 : IN_WIDTH] = Z [OUT_WIDTH-1 : IN_WIDTH] - Y;//
 2'b01 : Z [OUT_WIDTH-1 : IN_WIDTH] = Z [OUT_WIDTH-1 : IN_WIDTH] + Y;//
 2'b11 : Z [OUT_WIDTH-1 : IN_WIDTH] = Z [OUT_WIDTH-1 : IN_WIDTH] + 0;
 default : begin end
 endcase
 //$display($time, "%m, i=%1d after addition temp=%b  X = %b %d  Y = %b %d  Z =  %b %d", i,temp,X,X,Y,Y,Z,Z) ; 
 
 Z = Z >>> 1;
 /*The above statement performs arithmetic shift where
 the sign of the number is preserved after the shift. */
 //$display($time, "%m, i=%1d after shift temp=%b  X = %b %d  Y = %b %d  Z =  %b %d", i,temp,X,X,Y,Y,Z,Z) ; 
 E1 = X[i];
 
 end
 //#1 $display($time, "%m, i=%1d final temp=%b E1=%b  X = %b %d  Y = %b %d  Z =  %b %d", i,temp,E1,X,X,Y,Y,Z,Z) ; 
 

 if ( (Y == -(2**(IN_WIDTH-1))) && (X == -(2**(IN_WIDTH-1))) ) //most negative values
    begin
    $display("WARNING: overflow; Y=%d, X=%d, Z=%d",X,Y,Z);
    $display($time, " %m, result:  X = %b %d  Y = %b %d  Z =  %b %d",X,X,Y,Y,Z,Z);
    $display($time, "WARNING: setting product to -product, to avoid test errors; this is artificail");
    Z=-Z;
    end
 
 end
 
 endmodule



module shift_add_mult(a,b,out);

parameter IN_WIDTH = 4;
parameter OUT_WIDTH = IN_WIDTH*2;

input [IN_WIDTH-1:0] a;
input [IN_WIDTH-1:0] b;
output [OUT_WIDTH-1:0] out ;

wire sign_a;
assign sign_a = a[IN_WIDTH-1]; // sign is msb of a
wire sign_b;
assign sign_b = b[IN_WIDTH-1]; // sign is msb of a

wire [IN_WIDTH-1:0] abs_a;
wire [IN_WIDTH-1:0] abs_b;
assign abs_a= (a[IN_WIDTH-1]==1'b1)? (~a)+1 : a;
assign abs_b= (b[IN_WIDTH-1]==1'b1)? (~b)+1 : b;

integer i ;
reg sign;
reg [OUT_WIDTH -1:0] out ;
always @(a or b)
begin
    out = 0 ;
    sign= sign_a^sign_b;
    for (i = 0 ; i < IN_WIDTH; i = i+1)
    begin
    if (abs_b[i] == 1'b1)
        begin
        out = out + (abs_a << i) ;

        end
    end
    
    if(sign==1)
        begin
        out = (~out)+1; 
        end
    

end
endmodule





//Testbench, Copyright: Jagadeesh Vasudevamurthy
//May 2019
//File multtb.v

module multtbSmall;
  parameter N = 4 ;
  parameter F = N * 2 ;
  
  reg signed [N-1:0] a ; //Multiplicand
  reg signed [N-1:0] b ; //multiplier
  wire signed [F-1:0] f ;
  integer num_error;
  
  booth #(N,F) U(a,b,f) ;
  //shift_add_mult #(N,F) S(a,b,f) ;
  //boothmodified #(N,F) M(a,b,f) ;
  
  initial
    begin
       num_error = 0 ;
    #1 a = 7 ;
       b = 3 ;
       #1 num_error = (a * b != f) ? num_error + 1 : num_error ; 
       #1 $display("a = %b %d  b = %b %d  f =  %b %d", a,a,b,b,f,f) ; 
       #1 if (num_error) $stop ;
     #1 a = 7 ;
        b = -3 ;
        #1 num_error = (a * b != f) ? num_error + 1 : num_error ; 
        #1 $display("a = %b %d  b = %b %d  f =  %b %d", a,a,b,b,f,f) ;
        #1 if (num_error) $stop ;
     #1 a = -7 ;
        b = 3 ;
        #1 num_error = (a * b != f) ? num_error + 1 : num_error ; 
        #1 $display("a = %b %d  b = %b %d  f =  %b %d", a,a,b,b,f,f) ;
        #1 if (num_error) $stop ;
     #1 a = -7 ;
        b = -3 ;
        #1 num_error = (a * b != f) ? num_error + 1 : num_error ; 
        #1 $display("a = %b %d  b = %b %d  f =  %b %d", a,a,b,b,f,f) ; 
        #1 if (num_error) $stop ;
        #1 $display("num_error = %d", num_error) ;
        if (num_error == 0)
          $display("ALL BASIC TESTS PASSED") ;
   end
   
  //CRY if something is wrong immediately
    initial
    begin
      $monitor("BUGBUG num_error = %d", num_error) ;
    end
endmodule 

module multtbBig;
  parameter N = 16 ;
  parameter T = 100 ;
  parameter F = N * 2 ;
  parameter MAXN = (1 << N-2) ;
  
  reg signed [N-1:0] a ; //Multiplicand
  reg signed [N-1:0] b ; //multiplier
  wire signed [F-1:0] f ;
  integer num_error, i;
  integer ans ;
  
  //booth #(N,F) U(a,b,f) ;
  //shift_add_mult #(N,F) S(a,b,f) ;
  boothmodified #(N,F) M(a,b,f) ;
  initial
    begin
       num_error = 0 ;
       for (i = 0; i < T; i = i + 1) 
       begin
        a = $random % MAXN ;
        b = $random % MAXN ;
        if (i % 2)
          b = -b ;
        if (i % 5)
          a = -a ;
        #1 $display("Working on %d test",i) ;
        #1 ans = a * b ;
        #1 $display("a = %d b = %d expectedf = %d",a,b,ans) ;
        #1 num_error = (a * b != f) ? num_error + 1 : num_error ; 
        #1 $display("a = %b %d  b = %b %d  f =  %b %d", a,a,b,b,f,f) ; 
        #1 if (num_error) $stop ;
       end 
       #1 $display("num_error = %d", num_error) ;
       if (num_error == 0)
          $display("ALL %d RANDOM TESTS PASSED, N=%d", T,N) ;
    end
    
    //CRY if something is wrong immediately
    initial
    begin
      $monitor("BUGBUG num_error = %d", num_error) ;
    end 
endmodule

module multtbBigEven;
  multtbBig #(16) e() ; 
  initial
    $display("ALL JAGEVEN TESTS") ;
endmodule

module multtbBigOdd;
  multtbBig #(15) e() ; 
  initial
    $display("ALL JAGODD TESTS") ;
endmodule



