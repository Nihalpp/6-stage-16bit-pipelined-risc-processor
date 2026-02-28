`timescale 1ns / 1ps

module IF #(parameter PC_SIZE=16)
(
    input wire flush,
    input wire stall,
    input wire clock,
    input wire reset,
    input wire [1:0] PCScr, //Selects between PC + 1 and target address 
    input wire [PC_SIZE-1:0] PC_jump,
    input wire [PC_SIZE-1:0] PC_reg_mem, //new
    input wire flag_R0_mem,  //new
    input wire stall_ls,
    input wire stallPC,
    
    input wire rw,  
    input wire reset_memory,
    input wire [PC_SIZE-1:0] PC_write,
    input wire [15:0] instruction_in,
    
    output reg [PC_SIZE-1:0] PC_out,        //Current PC sent out
    output reg [PC_SIZE-1:0] PC_next_out,   //Next PC sent out
    output wire [15:0] instruction_out      //Actual Instruction
);

    reg [PC_SIZE-1:0] PC_in;
    reg [PC_SIZE-1:0] PC_next;
    wire [PC_SIZE-1:0] PC_out_wire;
    wire [15:0] instruction_out_wire;
    //assign PC_next = (stall | stall_ls |stallPC)? PC_next: PC_out_wire + 1;
    always@(posedge clock)begin
     if (reset)
        PC_next <= 0;
     else if (~(stall | stall_ls |stallPC))
        PC_next <= PC_out_wire + 1;
    end
    
always @(*) begin
  if (flag_R0_mem) begin
    PC_in = PC_reg_mem;        // one?cycle “hard jump” from R0
  end
  else begin
    case(PCScr)
      2'b01:    PC_in = PC_jump; 
      default:  PC_in = PC_next;   // covers 2'b00 and 2'b10
    endcase
  end
end


    always@(posedge clock) begin
        if(reset)begin
            PC_out <= 0;
            PC_next_out<=0;
        end
          else if (stall | stall_ls |stallPC)
          begin
            PC_out<=PC_out;
           PC_next_out<=PC_next_out;
            end
        else begin
            PC_out <= PC_out_wire;
            PC_next_out<=PC_next;
        end
    end

    Program_Counter #(.PC_SIZE(PC_SIZE)) PC(
        .clock(clock),
        .reset(reset),
        .PC_in(PC_in),
        .PC_out(PC_out_wire)
    );

    Instruction_Memory #(.PC_SIZE(PC_SIZE)) IM(
        .read_address(PC_out_wire),
        .write_address(PC_write),
        .rw(rw),
        .stall(stall),
        .stall_ls(stall_ls),
        .flush(flush),
        .instruction_out(instruction_out),
        .instruction_in(instruction_in),
        .reset_memory(reset_memory),
        .clock(clock)
    );

endmodule