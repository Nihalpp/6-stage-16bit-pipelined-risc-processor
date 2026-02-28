`timescale 1ns / 1ps

module Imm_Gen
(
    input wire [15:0] instruction,
    output reg [15:0] immediate
);

    always@(*)begin
      immediate = 16'b0;
        casex(instruction[15:12])
            4'b0001: immediate = {{10{instruction[5]}},instruction[5:0]}; 
            4'b0011: immediate = {{7{1'b0}},instruction[8:0]};   
            4'b0100: immediate = {{10{instruction[5]}},instruction[5:0]}; 
            4'b0101: immediate = {{10{instruction[5]}},instruction[5:0]}; 
            4'b011x: immediate = {1'b0,instruction[7:0]}; 
            4'b1000: immediate = {{10{instruction[5]}},instruction[5:0]};
            4'b1001: immediate = {{10{instruction[5]}},instruction[5:0]};
            4'b1010: immediate = {{10{instruction[5]}},instruction[5:0]};
            4'b1011: immediate = {{10{instruction[5]}},instruction[5:0]};
            4'b1101: immediate = {{10{instruction[5]}},instruction[5:0]};
            default: immediate = 16'b0;
        endcase

    end

endmodule