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
//  Source file: /nobackup/steveri/github/FP-Gen/verif/FPGenControl.vp
//  Source template: FPGenControl
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
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
 * Random generator for fowarding signals
 * 
 * Parameters:
 * * AddWeight, MulWeight, 
 * 
 *  
 * 
 * 
 * Change bar:
 * -----------
 * Date          Author    Description
 * August 6, 2012  sameh06    init version
 * ****************************************************************************/

/*******************************************************************************
 * PARAMETERIZATION
 * ****************************************************************************/
// AddWeight (_GENESIS2_DECLARATION_PRIORITY_) = 40
//
// NOPWeight (_GENESIS2_DECLARATION_PRIORITY_) = 0
//
// MulWeight (_GENESIS2_DECLARATION_PRIORITY_) = 30
//

class FPGenControl_unq1;

   rand FPGenPkg::InstructionType opcode;

   int add_weight = 40;
   int mul_weight = 30;
   int nop_weight = 0;

   constraint pick_inst_type{
      opcode dist {
		   FPGenPkg::FMADD := 100-mul_weight-add_weight-nop_weight, 
		   FPGenPkg::FADD := add_weight, 
		   FPGenPkg::FMUL := mul_weight, 
		   FPGenPkg::NOP := nop_weight
		   };
   }
   
     // C'tor for a Random transaction
     // The constructor also reads user defined, per simulation, weights
     function new();
	if ($test$plusargs("AddWeight")) begin
	   $value$plusargs("AddWeight=%d",  add_weight);
	   $display("%t: FPGenControl_unq1: Runtime input +AddWeight=%d found", $time, add_weight);
	end
	if ($test$plusargs("MulWeight")) begin
	   $value$plusargs("MulWeight=%d",  mul_weight);
	   $display("%t: FPGenControl_unq1: Runtime input +MulWeight=%d found", $time, mul_weight);
	end
	if ($test$plusargs("NOPWeight")) begin
	   $value$plusargs("NOPWeight=%d",  nop_weight);
	   $display("%t: FPGenControl_unq1: Runtime input +NOPWeight=%d found", $time, nop_weight);
	end
     endfunction // new

endclass : FPGenControl_unq1
   
