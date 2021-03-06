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
//  Source file: /nobackup/steveri/github/FP-Gen/verif/FPTransaction.vp
//  Source template: FPTransaction
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
// Parameter ExponentWidth 	= 11
// Parameter FractionWidth 	= 52
// Parameter TestDenormals 	= YES
// Parameter Random 	= NO
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

/*************************************************************************
 ** From Perforce:
 **
 ** $Id$
 ** $DateTime$
 ** $Change$
 ** $Author$
 *************************************************************************/

/* *****************************************************************************
 * Description:
 * Single transaction generator for FP Mult-Acc
 * Multiple constraints are specified and they MUST be turned off/on
 * by the instantiators of the transaction. 
 * "00000000_00000000", // Zero
 * "00080000_00000000", // Denorm #1
 * "000FFFFF_FFFFFFFF", // Denorm #2
 * "00000000_00000001", // Denorm #3
 * "7FF80000_00000000", // NaN (quiet)
 * "7FF000F0_000F0000", // NaN (signalling)
 * "7FEFFFFF_FFFFFFFF", // Max
 * "7FF00000_00000000", // Inf
 * "00100000_00000000", // Min
 * "3FF00000_00000000", // 1.0
 * "3FEFFFFF_FFFFFFFF",  // 0.111111111...
 *     
 * "80000000_00000000", // Zero
 * "80080000_00000000", // Denorm #1
 * "800FFFFF_FFFFFFFF", // Denorm #2
 * "80000000_00000001", // Denorm #3
 * "FFF80000_00000000", // NaN (quiet)
 * "FFF000F0_000F0000", // NaN (signalling)
 * "FFEFFFFF_FFFFFFFF", // Max
 * "FFF00000_00000000", // Inf
 * "80100000_00000000", // Min
 * "BFF00000_00000000", // 1.0
 * "BFEFFFFF_FFFFFFFF"  // 0.111111111...
 * 
 * 
 * Parameters:
 * * FractionWidth, ExponentWidth, Architecture
 * * TestDenormals -- generate denormal transactions? (YES/NO)
 * * Random -- Enables control of transaction distribution weights by parameters (YES/NO)
 *   * If Random == YES then the following are the parameters to control the weights:
 *     SignIsPos_DistWeight, Zero_DistWeight, QuietNaN_DistWeight, SignalingNaN_DistWeight, 
 *     Min_DistWeight, Max_DistWeight, Inf_DistWeight, One_DistWeight, PointOneOneOne_DistWeight, 
 *     EzAndSml_DistWeight, Random_DistWeight
 *     If  TestDenormals == YES the following parameters also exists:
 *       Denorm100_DistWeight, DenormFFF_DistWeight, Denorm001_DistWeight, DenormRnd_DistWeight
 *     If Architecture==Cascade
 *       Inc_DistWeight
 * * NamedTransCtrl -- Enables per transaction module control of weights at runtime ('', 'A'..'Z')
 *  
 * 
 * 
 * Change bar:
 * -----------
 * Date          Author    Description
 * Oct 05, 2011  shacham   init version - test generator for FP Mult-Acc
 * ****************************************************************************/

/*******************************************************************************
 * PARAMETERIZATION
 * ****************************************************************************/
// FractionWidth (_GENESIS2_INHERITANCE_PRIORITY_) = 52
//
// ExponentWidth (_GENESIS2_INHERITANCE_PRIORITY_) = 11
//
// IncEnable (_GENESIS2_DECLARATION_PRIORITY_) = NO
//
// TestDenormals (_GENESIS2_INHERITANCE_PRIORITY_) = YES
//
// Random (_GENESIS2_INHERITANCE_PRIORITY_) = NO
//

class FPTransaction_unq2;
   /* TO ME: Within class definitions, the rand and randc modifiers signal variables 
    * that are to undergo randomization. randc specifies permutation-based randomization, 
    * where a variable will take on all possible values once before any value is repeated. 
    * Variables without modifiers are not randomized. */
   typedef enum {Zero, Denorm100, DenormFFF, Denorm001, DenormRnd, QuietNaN, 
		 SignalingNaN, Min, Max, Inf, One, PointOneOneOne, EzAndSml, Random} FPTransType;
   rand FPTransType TransType;
   
   rand bit [51:0] 	Fraction;
   rand bit [10:0] 	Exponent;
   rand bit 				Sign;
   rand bit 				Inc; // only used to test cascaded architecrures
   
   // --------------------------------------------------------------------------
   // Some setters:
   // --------------------------------------------------------------------------
   function ForceFPNum(logic [63 : 0] num);
      this.ForceSignExpFrac(num[63], 
			    num[62:52], 
			    num[51:0], 
			    1'b0);
      
   endfunction // ForceFPNum
   
   // Kind of C'tor for a regular, NON-Random transaction
   function ForceSignExpFrac(logic Sign, logic [10:0] Exp, 
    			     logic [51:0] Frac, logic Inc);
      this.Fraction = Frac;
      this.Exponent = Exp;
      this.Sign = Sign;
      this.Inc = Inc;
      
      if(Exponent == 11'b0) begin
	 if (Fraction == 52'b0)
	   TransType = Zero;
	 // since we DO care about distinctions within the dnorm range!!!
	 else if(Fraction ==  {1'b1, 51'b0})
	   TransType = Denorm100;
	 else if(Fraction =={(52){1'b1}})
	   TransType = DenormFFF;
	 else if(Fraction =={51'b0, 1'b1})
	   TransType = Denorm001;
	 else
	   TransType = DenormRnd;
      end
      
      else if(Exponent == {(11){1'b1}}) begin
	 if (Fraction == 52'b0)
	   TransType = Inf;
	 else begin
	    if (Fraction[51] == 1'b1)
	      TransType = QuietNaN;
	    else if (Fraction[51] == 1'b0 && Fraction[50:0] != 51'b0)
	      TransType = SignalingNaN;
	    else begin
	      $display("%t: ERROR: FPTransaction constructor encountered an unknown NaN type: Exp=%h, Frac=%h",
		       $time, Exponent, Fraction);
	       $finish(2);
	    end	    
	 end // else: !if(Fraction == 52'b0)
      end // if (Exponent == {(11){1'b1}})
      // if it is actually Max
      else if((Fraction == {(52){1'b1}}) && (Exponent == { {(10){1'b1}}, 1'b0}))  begin
	 TransType = Max;
      end
      // if it is actually Min
      else if((Fraction == 52'b0) && (Exponent == 11'b1))  begin
	 TransType = Min;
      end
      // if it is actually One
      else if((Fraction == 52'b0) && (Exponent ==  {  1'b0, {(10){1'b1}}  }))  begin
	 TransType = One;
      end
      // if it is actually PointOneOneOne
      else if((Fraction ==  {(52){1'b1}} ) && (Exponent ==  {  1'b0, {(9){1'b1}}, 1'b0}))  begin
	 TransType = PointOneOneOne;
      end
      else begin
	 TransType = Random; // since we don't care about distinctions within the allowed range
      end // else: !if(Exponent == {(11){1'b1}})
   endfunction // ForceSignExpFrac
   

   
   // Kind of C'tor for a regular, NON-Random transaction using Mantissa instead of Fraction
   // IMPORTANT: This function was custom built for the FPMult format
   function void FPMultResult_to_FPTrans(logic Sign, logic [12:0] Exp, logic [52:0] Man, 
    		 			 logic NaN, logic Inf, logic Zero);
      
      logic [52:0] 		       ManDenormed;
      logic [12:0] 	       expOffset;
      // Start with clear cut flagged cases:
      // ----------------------------------
      if (NaN) begin // NaN cases
	 this.ForceSignExpFrac(Sign, {(11){1'b1}}, 52'b1, 1'b0); // FIXME: Signaling? maybe Quiet NaN?
	 return;
      end
      if (Inf) begin // Inf cases
	 this.ForceSignExpFrac(Sign, {(11){1'b1}}, 52'b0, 1'b0);
	 return;
      end
      if (Zero) begin // Zero cases
	 this.ForceSignExpFrac(Sign, 11'b0, 52'b0, 1'b0);
	 return;
      end
      /* RSticky no longer used
       if (RSticky) begin // Rsticky cases
       $write("RSticky==1 ==>  ");
      	 //corner case alert: if FP==1.111111 we need Man<=1.0 and Exp<=Exp+1
      	 if (Man == {(53){1'b1}}) begin
	    Man = 53'b1;
	    Exp = Exp + 1;
	    $display("Man==1.111...1 ==> Exp=Exp+1 and Man=1.0");
	 end
	 else begin
	    Man = Man+1;
	    $display("Man!=1.111...1 ==> Man=Man+1");
	 end
      end
*/
      // Move to unflagged cases:
      // --------------------------- 
      if (Man == 53'b0) begin // Zero cases
	 this.ForceSignExpFrac(Sign, 11'b0, 52'b0, 1'b0);
      end
      else if (Exp[12] == 1'b1 || Exp == 13'b0) begin // Negative/Zero  Exp --> Denorm cases
	 
	 $display("%t \t\t The output exponent is negative(%0d). Denormalization is done before check.", $time, -Exp);
	 expOffset = (~Exp + 2'b10);
	 $display("%b", expOffset);
	 ManDenormed = Man >> expOffset;
	 $display("%d %h", expOffset, ManDenormed);
	 if(|(Man<<53-expOffset) || 
	    ManDenormed == 53'b0) //round up ManDenormed if it is sticky
	   ManDenormed = ManDenormed + 53'b1;
	  
	 this.ForceSignExpFrac(Sign, 11'b0, ManDenormed[51:0], 1'b0);
      end
      else if (Exp > 2046) begin // Exponent overflow case
	 this.ForceSignExpFrac(Sign, {(11){1'b1}}, 52'b0, 1'b0);
      end 
      else if (Exp == 13'b1) begin // Denorm and Normal cases
	 /*if (Man[52] == 1'b0) begin  // Denorm
	    this.ForceSignExpFrac(Sign, 11'b0, Man[51:0], 1'b0);
	 end else*/ begin
 	 // Normals (with wxp=1)
	    this.ForceSignExpFrac(Sign, Exp[10:0], Man[51:0], 1'b0);
	 end
      end else if (Exp == {(13){1'b1}}) begin // Inf and NaN cases
	 this.ForceSignExpFrac(Sign, Exp[10:0], Man[51:0], 1'b0);
      end

      // Finally, normal case:
      // ---------------------------
      else begin 		
	 this.ForceSignExpFrac(Sign, Exp[10:0], Man[51:0], 1'b0);
      end
   endfunction // FPMultResult_to_FPTrans



   // This function calculates the Inc value into the FP transaction
   function void CalculateInc();
      if (Inc==0) return;
      else if (TransType==Zero) begin
	 Fraction += 1;
	 TransType = Denorm001;
      end
      else if (TransType==DenormFFF) begin
	 Fraction = 52'b0;
	 Exponent = 11'b1;
	 TransType = Min;
      end
      else if (TransType==Denorm001 || TransType==Denorm100 || TransType==DenormRnd) begin
	 Fraction += 1;
	 if (Fraction == {(52){1'b1}})
	   TransType = DenormFFF;
	 else if (Fraction == {1'b1, 51'b0})
	   TransType = Denorm100;
	 else
	   TransType = DenormRnd;
      end
      else if (TransType==QuietNaN || TransType==SignalingNaN || TransType==Inf) begin
      end
      else if (TransType==Max) begin
	 Fraction = 52'b0;
	 Exponent = {(11){1'b1}};
	 TransType = Inf;
      end
      else if (TransType==PointOneOneOne) begin
	 Fraction = 0;
	 Exponent += 1;
	 TransType = One;
      end
      else if (TransType==Min || TransType==One || TransType==EzAndSml || TransType==Random) begin
	 Fraction += 1;
	 if (Fraction == 52'b0) begin
	    Exponent += 1;
	 end
	 TransType = Random;
	 if ((Fraction == {(52){1'b1}}) && Exponent == {1'b0, {(9){1'b1}}, 1'b0}) begin
	    TransType = PointOneOneOne;
	 end
	 if ((Fraction == 52'b0) && Exponent == {1'b0, {(10){1'b1}}}) begin
	    TransType = One;
	 end
      end // if (TransType==Min || TransType==One || TransType==EzAndSml || TransType==Random)
      Inc = 0;
   endfunction // CalculateInc
   

   // --------------------------------------------------------------------------
   // Some getters:
   // --------------------------------------------------------------------------
   function bit IsPos();
      return Sign == 1'b0;
   endfunction // bit IsPos
   
   function bit IsNeg();
      return Sign == 1'b1;
   endfunction // bit IsPos

   function bit [63 : 0] GetFPNum();
      bit [63 : 0] tmp;
      tmp[63] = this.Sign;
      tmp[62:52] = this.Exponent;
      tmp[51:0] = this.Fraction;
      return tmp;
   endfunction // GetFPNum
   
   function bit IsDenorm();
      return (TransType == Denorm100)||(TransType == DenormFFF)||(TransType == Denorm001)||(TransType == DenormRnd);
   endfunction// bit IsDenorm
   
   function bit IsMin();
      return (TransType == Min);
   endfunction //bit IsMin
   
   // --------------------------------------------------------------------------
   // Constraints for random generation
   // --------------------------------------------------------------------------
   // To make auto generation of special cases easier:
   constraint pick_fraction_val{
      (TransType == Zero) -> 		{ Fraction == 52'b0 };
      (TransType == Denorm100) -> 	{ Fraction == {1'b1, 51'b0} };
      (TransType == DenormFFF) -> 	{ Fraction == {(52){1'b1}} };
      (TransType == Denorm001) -> 	{ Fraction == {51'b0, 1'b1} };
      (TransType == DenormRnd) -> 	{ Fraction != 52'b0 
					  && Fraction != {1'b1, 51'b0} 
					  && Fraction != {(52){1'b1}} 
					  && Fraction != {51'b0, 1'b1} };
      (TransType == QuietNaN) -> 	{ Fraction[51] == 1'b1 };
      (TransType == SignalingNaN) -> 	{ Fraction[51] == 1'b0 && Fraction[50:0] != 51'b0 };
      (TransType == Min) -> 		{ Fraction == 52'b0 };
      (TransType == Max) -> 		{ Fraction == {(52){1'b1}} };
      (TransType == Inf) -> 		{ Fraction == 52'b0 };
      (TransType == One) -> 		{ Fraction == 52'b0 };
      (TransType == PointOneOneOne) -> 	{ Fraction == {(52){1'b1}}  };
      (TransType == EzAndSml) ->	{ Fraction inside {[1:10]} };
      (TransType == Random) -> 		{ 1'b1 /* No constraint */ };
   }
     
   constraint pick_exponent_val{
      (TransType == Zero) -> 		{ Exponent == 11'b0 };
      (TransType == Denorm100) -> 	{ Exponent == 11'b0 };
      (TransType == DenormFFF) -> 	{ Exponent == 11'b0 };
      (TransType == Denorm001) -> 	{ Exponent == 11'b0 };
      (TransType == DenormRnd) -> 	{ Exponent == 11'b0 };
      (TransType == QuietNaN) -> 	{ Exponent == {(11){1'b1}} };
      (TransType == SignalingNaN) -> 	{ Exponent == {(11){1'b1}} };
      (TransType == Min) -> 		{ Exponent == 11'b1 };
      (TransType == Max) -> 		{ Exponent == { {(10){1'b1}}, 1'b0} };
      (TransType == Inf) -> 		{ Exponent == {(11){1'b1}} };
      (TransType == One) -> 		{ Exponent == {  1'b0, {(10){1'b1}}  } };
      (TransType == PointOneOneOne) -> 	{ Exponent == {  1'b0, {(9){1'b1}}, 1'b0} } ;
      (TransType == EzAndSml) ->	{ Exponent[10] == 1'b1 && Exponent[9:2] == 8'b0 };
      (TransType == Random) -> 		{ Exponent != 11'b0 && Exponent != {(11){1'b1}} };//not denorm, not zero, not inf,not nan, BUT could be Max, Min, One or PointOneOneOne!!!
   }

   //workaround for the bug of Random TransType
   function void post_randomize;
      if (TransType == Random) begin
	 
	 // if it is actually Max
	 if((Fraction == {(52){1'b1}}) && (Exponent == { {(10){1'b1}}, 1'b0}))  begin
	    TransType = Max;
	 end
	  // if it is actually Min
	 if((Fraction == 52'b0) && (Exponent == 11'b1))  begin
	    TransType = Min;
	 end
	 // if it is actually One
	 if((Fraction == 52'b0) && (Exponent ==  {  1'b0, {(10){1'b1}}  }))  begin
	    TransType = One;
	 end
	 // if it is actually PointOneOneOne
	 if((Fraction ==  {(52){1'b1}} ) && (Exponent ==  {  1'b0, {(9){1'b1}}, 1'b0}))  begin
	    TransType = PointOneOneOne;
	 end
      end    
   endfunction // if


   
   constraint order1 { 
      solve TransType before Fraction, Exponent, Sign, Inc;
   }

   
endclass : FPTransaction_unq2

