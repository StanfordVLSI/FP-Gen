//
//--------------------------------------------------------------------------------
//          THIS FILE WAS AUTOMATICALLY GENERATED BY THE GENESIS2 ENGINE        
//  FOR MORE INFORMATION: OFER SHACHAM (CHIP GENESIS INC / STANFORD VLSI GROUP)
//    !! THIS VERSION OF GENESIS2 IS NOT FOR ANY COMMERCIAL USE !!
//     FOR COMMERCIAL LICENSE CONTACT SHACHAM@ALUMNI.STANFORD.EDU
//--------------------------------------------------------------------------------
//
//  
//	-----------------------------------------------
//	|            Genesis Release Info             |
//	|  $Change: 11904 $ --- $Date: 2013/08/03 $   |
//	-----------------------------------------------
//	
//
//  Source file: /nobackup/steveri/github/FP-Gen/verif/GoldFMA.vp
//  Source template: GoldFMA
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
// Parameter TestDenormals 	= YES
// Parameter FPTransC_Ptr 	= Data structure of type FPTransaction
// Parameter FPTransA_Ptr 	= Data structure of type FPTransaction
// Parameter FPTransRes_Ptr 	= Data structure of type FPTransaction
// Parameter FPTransB_Ptr 	= Data structure of type FPTransaction
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From Command Line input (priority=4):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From XML input (priority=3):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From Config File input (priority=2):
//
// ---------------- End Pre-Generation Pramameters Status Report ----------------

/* *****************************************************************************
 * Description:
 * Gold model with full precision for FP multiplier
 * 
 * Parameters:
 * * FPTransA_Ptr, FPTransB_Ptr, FPTransC_Ptr(pointers to the FP transactions classes generators)
 * * FPTransRes_Ptr (pointer to a result class generator)
 * 
 * 
 * Change bar:
 * -----------
 * Date          Author    Description
 * Feb 5, 2012   jingpu    init version -
 * ****************************************************************************/

/*******************************************************************************
 * PARAMETERIZATION
 * ****************************************************************************/
// FPTransA_Ptr (_GENESIS2_INHERITANCE_PRIORITY_) = 
//	InstancePath:top_FPGen.TestBench.TransGenA (FPTransaction_unq1)
//
// FPTransB_Ptr (_GENESIS2_INHERITANCE_PRIORITY_) = 
//	InstancePath:top_FPGen.TestBench.TransGenB (FPTransaction_unq1)
//
// FPTransC_Ptr (_GENESIS2_INHERITANCE_PRIORITY_) = 
//	InstancePath:top_FPGen.TestBench.TransGenC (FPTransaction_unq1)
//
// FPTransRes_Ptr (_GENESIS2_INHERITANCE_PRIORITY_) = 
//	InstancePath:top_FPGen.TestBench.TransRes (FPTransaction_unq2)
//
// TestDenormals (_GENESIS2_INHERITANCE_PRIORITY_) = YES
//

class GoldFMA_unq1;

   FPTransaction_unq2  Expected = new();
   

   function bit CheckMultResult(FPTransaction_unq2 transRes, FPTransaction_unq2 transExpected);

      // First check flags:
      if (transRes.TransType == FPTransaction_unq2::QuietNaN || transRes.TransType == FPTransaction_unq2::SignalingNaN) begin
	 if (transExpected.TransType == FPTransaction_unq2::QuietNaN || transExpected.TransType == FPTransaction_unq2::SignalingNaN)
	   return 1'b1;
      end
      if (transRes.TransType == FPTransaction_unq2::Inf) begin
	 if (transExpected.TransType == FPTransaction_unq2::Inf)
	   return 1'b1;
      end

      
      if (transRes.TransType == FPTransaction_unq2::Zero) begin
	 if (transExpected.TransType == FPTransaction_unq2::Zero)
	   return 1'b1;
      end
      
      // Normal case
      if (transRes.Sign == transExpected.Sign &&
	  transRes.Exponent == transExpected.Exponent &&
	  transRes.Fraction == transExpected.Fraction ) begin
	 return 1'b1;
      end
      
      // default: Fail
      return 1'b0;

   endfunction // bit


   
   function CalcGold(FPTransaction_unq1 transA, FPTransaction_unq1 transB, FPTransaction_unq1 transC, logic [2:0] rnd);
      // Local Variables
      logic [51:0]    FracExpected;
      logic [10:0]      ExpExpected;
      logic 			      SignExpected, SignProduct, SignInfinity, SignResIsC;
      logic [12:0]      ExpProduct, ExpSum, Exp_offset, Exp_max, ExpC;
      logic [105:0]    ManProduct;
      logic [52:0] 	      ManC;	
      logic [160:0] 	      ManSum, NumShift, ManC4add, ManProduct4add;
      logic 			      msbA, msbB, msbC, denormA, denormB, denormC;
      logic 			      sticky, LSB, guard, IncExpected;
      logic 			      overflow = 0, underflow = 0;

      
     
      
      // init all values:
      FracExpected = '0;
      ExpExpected = '0;
      SignExpected = '0;
     
      
      // First we calculate the expected sign, since it used in both regular and corner cases
      // plus x plus ==> plus; plus x minus ==> minus; minus x minus ==> minus; 
	  SignProduct = transA.Sign ^ transB.Sign;
	  SignInfinity = (transC.TransType == FPTransaction_unq1::Inf) ? transC.Sign : SignProduct;
	  SignResIsC = transC.Sign & (~(transC.TransType == FPTransaction_unq1::Zero) | SignProduct);
      
      // Start with corner cases:
      // 1. Either input is NaN                       Result is NaN
      if (transA.TransType == FPTransaction_unq1::QuietNaN || transA.TransType == FPTransaction_unq1::SignalingNaN || 
	  transB.TransType == FPTransaction_unq1::QuietNaN || transB.TransType == FPTransaction_unq1::SignalingNaN || 
	  transC.TransType == FPTransaction_unq1::QuietNaN || transC.TransType == FPTransaction_unq1::SignalingNaN) begin

	 // FIXME: Shouldn't we also check for qNaN vs. sNaN?
	 Expected.randomize() with { (TransType == FPTransaction_unq2::QuietNaN) && (Sign == 1'b0) && (Inc == 1'b0); };
      end 
      
      // 2. 0*Inf                                     Result is NaN
      //   (A=0 and B=Inf or vice-versa)                            
      else if ( (transA.TransType == FPTransaction_unq1::Zero && transB.TransType == FPTransaction_unq1::Inf) || 
		(transB.TransType == FPTransaction_unq1::Zero && transA.TransType == FPTransaction_unq1::Inf) ) begin

	 // FIXME: Shouldn't we also check for qNaN vs. sNaN?
	 Expected.randomize() with { (TransType == FPTransaction_unq2::QuietNaN) && (Sign == 1'b0) && (Inc == 1'b0); };
      end

	  // 3. AB is +-Inf and C is -+Inf                 Result is NaN
      //   (A=0 and B=Inf or vice-versa)                            
      else if ( (transA.TransType == FPTransaction_unq1::Inf || transB.TransType == FPTransaction_unq1::Inf) && transC.TransType == FPTransaction_unq1::Inf && (SignProduct != transC.Sign)) begin

	 // FIXME: Shouldn't we also check for qNaN vs. sNaN?
	 Expected.randomize() with { (TransType == FPTransaction_unq2::QuietNaN) && (Sign == 1'b0) && (Inc == 1'b0); };
      end
      
	  
	 // next part only for round mode 000, i.e. Round to the nearest
	 
      // 4. Either input is Inf                        Result is signed Inf
      else if (transA.TransType == FPTransaction_unq1::Inf || transB.TransType == FPTransaction_unq1::Inf || transC.TransType == FPTransaction_unq1::Inf) begin
	 Expected.randomize() with { (TransType == FPTransaction_unq2::Inf) && (Sign == SignInfinity) && (Inc == 1'b0); };
      end

      // 5. 0*num or 0*0 or num*o                      Result is C
      else if (transA.TransType == FPTransaction_unq1::Zero || transB.TransType == FPTransaction_unq1::Zero) begin
	 Expected.ForceSignExpFrac(SignResIsC, transC.Exponent, transC.Fraction, 1'b0); 
      end

     
      // Now for the normal case
      else begin
	 // first we find if there is a leading one:
	 msbA = |(transA.Exponent);
	 msbB = |(transB.Exponent);
	 msbC = |(transC.Exponent);
	 denormA = ~msbA;
	 denormB = ~msbB;
	 denormC = ~msbC;
	 

	 /* Now we calculate the product of A and B:
	  * Note that ManProduct was the result of 1.xxx * 1.xxx which means it has
	  * the format zz.xxxxxx. But we nees a z.zxxxxxx format which means we need to do
	  * one RIGHT shift. In addition, we need to shift LEFT all leading zeros
	  * */
	 ManProduct = {msbA, transA.Fraction} * {msbB, transB.Fraction};
	 ManC = {msbC, transC.Fraction};
	 //$display("DEBUG: full man=%h", ManProduct);
	 

	 /* Now for the exponent:
	  * Exp is in 0:2046 which correspond to -1023:1023 ==>
	  * TotalExp is in 0:4092 but we need to subtract 1023 ==>
	  * if TotalExp < 1023 we are at underflow
	  * if TotalExp > 2046+1023 we have overflow
	  * Note that these numbers are for ieee double. In general these are:
	  * Exp range: 0:2^$exp_width-2 ==> 0:2^9 ==> 0:2046
	  * Exp offset: 2^($exp_width-1)-1 ==> 2^10-1 ==> 1023
	  * 
	  * Also, for denorms, exp is saved as 00..0 but it actually represents 1'b1
	  * */
	 ExpProduct = transA.Exponent + transB.Exponent + denormA + denormB;
	 ExpC = transC.Exponent + denormC;
	 Exp_offset = 1023;
	 Exp_max = 2046;
	 //$display("DEBUG: exp=%h", ExpProduct);
	 
//-----------------

	 /* Time to convert the zz.xxxxxx to 1.xxxxxxx AND get rid of leading zeros (if exist)
	  */
	 if (ManProduct[105] == 1'b1) begin
	    ExpProduct +=1; /* this is a shift right by one for exp but no op
			       * required for man */
//	 $display("DEBUG: Exp_offset=%h ExpProduct=%h ManProduct=%b",Exp_offset, ExpProduct,ManProduct);
	 end
	 else if (ManProduct[105:104] == 2'b01) begin
	    ManProduct = {ManProduct[104:0], 1'b0}; /* this is a no shift as far as 
									* exp is concerned */
//	 $display("DEBUG: Exp_offset=%h ExpProduct=%h ManProduct=%b",Exp_offset, ExpProduct,ManProduct);
	 end
	 else begin
	    /* this means that the mantissa starts with 00.xxxxxx 
	     * but note that this is not Zero since this was already checked above.
	     */
	    ManProduct = {ManProduct[104:0], 1'b0}; /* this first one is a no shift as far as 
									* exp is concerned */
//	 $display("DEBUG: Exp_offset=%h ExpProduct=%h ManProduct=%b",Exp_offset, ExpProduct,ManProduct);
	    while (ManProduct[105] == 1'b0) begin	// as long as the lead is 0 AND	   
	       ManProduct = {ManProduct[104:0], 1'b0};
			if(ExpProduct == 0) begin 
				Exp_offset+=1;
			end 
			else begin
				ExpProduct -=1;
			end
//	 $display("DEBUG: Exp_offset=%h ExpProduct=%h ManProduct=%b",Exp_offset, ExpProduct,ManProduct);
	    end
	 end // else: !if(ManProduct[106] == 1'b1)

//----------------------

	 /* Now we do AB+C
	  */
if (transC.Sign == SignProduct) begin
	SignExpected = SignProduct;
	sticky = 1'b0;
	// if C is much larger than AB
	if (ExpC + Exp_offset > ExpProduct + 53 + 1) begin
		ManSum = {ManC, 2'b0, {(106){1'b0}}};
		ExpSum = ExpC + Exp_offset;
		sticky = 1'b1;
	end
	// else if AB is much larger than C
	else if (ExpProduct > ExpC + Exp_offset+ 106 + 1) begin
		ManSum = { ManProduct, 2'b0, {(53){1'b0}}};
		ExpSum = ExpProduct;
		sticky = | (ManC);
	end
	// if C is larger than AB, then left shift C
	else if (ExpC + Exp_offset >= ExpProduct) begin
		ManSum = {1'b0, ManC, 1'b0, {(106){1'b0}}};
		NumShift = {1'b0, ManProduct, 1'b0, {(53){1'b0}}};
//	 $display("DEBUG: ManSum=  %b", ManSum);
//	 $display("DEBUG: NumShift=%b",NumShift);
		NumShift = NumShift >> (ExpC + Exp_offset - ExpProduct);
//	 $display("DEBUG: ManSum=  %b", ManSum);
//	 $display("DEBUG: NumShift=%b",NumShift);
		ManSum += NumShift;
//	 $display("DEBUG: ManSum=  %b", ManSum);
//	 $display("DEBUG: NumShift=%b",NumShift);
		ExpSum = ExpC + Exp_offset + 1;
	end 
	//else AB is larger than C
	else if (ExpC + Exp_offset < ExpProduct) begin
		ManSum = {1'b0, ManProduct, 1'b0, {(53){1'b0}}};
		NumShift = {1'b0, ManC, 1'b0, {(106){1'b0}}};
		NumShift = NumShift >> (ExpProduct - ExpC - Exp_offset);
		ManSum += NumShift;
		ExpSum = ExpProduct + 1;
	end
//	    $display("DEBUG: full man=%h ExpSum=%h Exp_offset=%h", ManSum, ExpSum, Exp_offset);
end // if (transC.Sign == SignProduct)
else begin //if (transC.Sign != SignProduct)
   	sticky = 1'b0;
   // if C=0
   if(ExpC == 1 && ManC == {(53){1'b0}})begin
      ManSum = { ManProduct, 2'b0, {(53){1'b0}}};
      SignExpected = SignProduct;
      ExpSum = ExpProduct;
   end
   else begin
	// if |C| is much larger than |AB|
	if (ExpC + Exp_offset > ExpProduct + 53 + 1) begin
	   ManSum = {ManC, 2'b0, {(106){1'b0}}} - 1;
	   ExpSum = ExpC + Exp_offset;
	   SignExpected = transC.Sign;
	   sticky = 1'b1;
	end
	// else if |AB| is much larger than |C|
	else if (ExpProduct > ExpC + Exp_offset+ 106 + 1) begin
	   sticky = | (ManC);
	   ManSum = { ManProduct, 2'b0, {(53){1'b0}}} - sticky;
	   SignExpected = SignProduct;
	   ExpSum = ExpProduct; 
	end
	// do substration
	else begin
	   // now shift either C or AB
	   if (ExpC + Exp_offset > ExpProduct) begin
	      ManC4add = {1'b0, ManC, 1'b0, {(106){1'b0}}};
	      ManProduct4add = {1'b0, ManProduct, 1'b0, {(53){1'b0}}};
	      ManProduct4add = ManProduct4add >> (ExpC + Exp_offset - ExpProduct);
	      ExpSum = ExpC + Exp_offset + 1;
	   end
	   else begin
	      ManProduct4add = {1'b0, ManProduct, 1'b0, {(53){1'b0}}};
	      ManC4add = {1'b0, ManC, 1'b0, {(106){1'b0}}};
	      ManC4add = ManC4add >> (ExpProduct - ExpC - Exp_offset);
	      ExpSum = ExpProduct + 1;
	   end
	   // now compare |C| and |AB|
	   // if |C| >= |AB|, then sum=C-AB
	   if(ManC4add > ManProduct4add)begin
	      ManSum = ManC4add - ManProduct4add;
	      SignExpected = transC.Sign;
	   end
	   else if(ManC4add < ManProduct4add) begin
	      ManSum = ManProduct4add - ManC4add;
	      SignExpected = SignProduct;
	   end
	   else begin // if |AB| = |C|, then AB+C=0
	      ManSum = 0;
	      SignExpected = SignProduct & transC.Sign;
	   end
	end // else: !if(ExpProduct > ExpC + Exp_offset+ 106 + 1)
   end
end	 
//-----------------

	 /* Get rid of leading zeros of ManSum(if exist)
	  */
	 while (ManSum[160] == 1'b0 && 	// as long as the lead is 0 AND
		   ExpSum > Exp_offset			// exp is still in range
		   ) begin
	       ManSum = {ManSum[159:0], 1'b0};
	       ExpSum -=1;
	 end
//	    $display("DEBUG: full man=%h ExpSum=%h Exp_offset=%h", ManSum, ExpSum, Exp_offset);

//----------------------

	 /* Now we consider the case of exp<exp_offset+1 and try to shift RIGHT
	  * while exp<exp_offset+1 (and while the man is not all zeros)*/
//	 $display("DEBUG: full man=%h", ManSum);
	sticky = sticky | ( |ManSum[106:0]);
	 while (ExpSum <= Exp_offset && 
		ManSum[160:107] != 54'b0) begin
	    sticky = sticky | ManSum[107];
	    ManSum = {1'b0, ManSum[160:1]};
	    ExpSum +=1;
	 end
//	    $display("DEBUG: full man=%h ExpSum=%h Exp_offset=%h", ManSum, ExpSum, Exp_offset);
	 
//----------------------

	 // Finally, sum it all up:
	 overflow = (ExpSum > Exp_max+Exp_offset) ? 1'b1 : 1'b0;
	 underflow = (ExpSum < Exp_offset+1) ? 1'b1 : 1'b0;
	 if (overflow)
	   Expected.randomize() with { (TransType == FPTransaction_unq2::Inf) && (Sign == SignExpected) && (Inc == 1'b0);};
	 else if (underflow) begin
		guard = ManSum[107];
		LSB = ManSum[108];
		IncExpected = guard & (sticky | LSB);
	    Expected.randomize() with { (TransType == FPTransaction_unq2::Zero) && (Sign == SignExpected) && (Inc == IncExpected); };
	 end 
	 else begin
	    ExpExpected = ExpSum - Exp_offset;
	    FracExpected = ManSum[159:108];
		guard = ManSum[107];
		LSB = ManSum[108];
		IncExpected = guard & (sticky | LSB);
	//	$display("DEBUG: guard=%b LSB=%b sticky=%b IncExpected=%b",guard, LSB, sticky, IncExpected);
	    if (ExpExpected==1 && ManSum[160]==1'b0) // Denorm case ==> zero the exp
	      Expected.ForceSignExpFrac(SignExpected, 11'b0, FracExpected, IncExpected);
	    else							  // Normal case
	      Expected.ForceSignExpFrac(SignExpected, ExpExpected, FracExpected, IncExpected);
	 end
      end // End of the "normal" case (no special input)
      
      Expected.CalculateInc();

   endfunction // CalcGold
   
   
		


endclass : GoldFMA_unq1