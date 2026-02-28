`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.04.2025 14:49:27
// Design Name: 
// Module Name: Hazard_Detection_Unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Hazard_Detection_Unit(
   // input  wire [2:0] write_register_EXE_out,
    input  wire        mem_read_EXE,    // load in EX stage?
    input  wire [2:0]  reg_RD_EXE,      // EX stage destination
    input  wire [2:0]  reg_RS1_ID,      // ID stage sources
    input  wire [2:0]  reg_RS2_ID,
    input  wire         branch_EXE,      // branch in EX stage?
    input wire flag_R0,
    //input  wire        zero_EXE,        // branch taken?
    output wire        stall,           // single stall signals
    output wire        flush_IF_ID,      // branch-taken flush
    output wire  flush_IF_ID_EX_RR       //flush for load R0
);

  // load-use hazard ? stall 
  // assign stall       =  1'b0;
                  
assign stall       = mem_read_EXE &&  (((reg_RD_EXE == reg_RS1_ID)  || (reg_RD_EXE == reg_RS2_ID)) && (reg_RD_EXE != 3'b0) );
//(write_register_EXE_out == reg_RS1_ID)  || (write_register_EXE_out == reg_RS2_ID)||
  // branch taken ? flush IF/ID
  assign flush_IF_ID = branch_EXE ;
  assign flush_IF_ID_EX_RR = flag_R0;
  //assign flush_IF_ID = 1'b0;

endmodule
