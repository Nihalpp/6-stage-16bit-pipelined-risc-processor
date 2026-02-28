`timescale 1ns / 1ps

module Instruction_Memory #(parameter PC_SIZE=16, INSTRUCTION_LENGTH=16)
(
    input wire [PC_SIZE-1:0] read_address,
    input wire [PC_SIZE-1:0] write_address,
    input wire rw,stall,flush,   // rw=1 READ, rw=0 WRITE
    input wire reset_memory,
    input wire clock,
    input wire [INSTRUCTION_LENGTH-1:0] instruction_in,
    input wire stall_ls,
    output reg [INSTRUCTION_LENGTH-1:0] instruction_out
);

    reg [INSTRUCTION_LENGTH-1:0] Memory[99:0]; // 1024 - 32bit instructions
    integer i=0;

    always@(posedge clock)begin // Reseting memory
         if(reset_memory)begin
            for(i=0; i<100; i=i+1)begin
                Memory[i] <= 0;
            end
            instruction_out <= 0;
        end 
        
        
        else if (flush) begin
        instruction_out <= 16'b0; // Flush the instruction (NOP - all zeros)
    end
        else begin
            if(rw)begin // READ
                if (stall | stall_ls)
                    instruction_out<=instruction_out;
                    else
                    instruction_out <= Memory[read_address];
                end
            else begin // WRITE
                Memory[write_address] <= instruction_in;
                instruction_out <= 0;
            end
        end
    end

endmodule