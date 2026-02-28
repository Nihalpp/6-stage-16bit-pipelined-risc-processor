`timescale 1ns / 1ps

module ALU_Control
(
    input wire [2:0] alu_op,
    input wire [2:0] funct,     // {COMPL, funct3}
    output reg [3:0] alu_control 
);

    parameter ADD = 4'b0000; //add reg a,reg b
    parameter ADDIFC = 4'b0001; //add reg a,reg b if carry
    parameter ADDIFZ = 4'b0010; //add reg a,reg b if zero
    parameter ADDWC = 4'b0011; //add reg a,reg b,carry
    parameter NANDIFC = 4'b0100;
    parameter NANDIFZ = 4'b0110;
    parameter NAND = 4'b1100;
    //parameter NANDWC = 4'b1101;
    parameter COMPAREBEQ = 4'b1110;
    parameter COMPAREBLT = 4'b1101;
    parameter COMPAREBLE = 4'b1111;
    parameter ADDNIL = 4'b0101;
    parameter INCR = 4'b0111;

    always @* begin
        casex(alu_op)
            3'b000: alu_control = ADD;
            3'b001: alu_control = COMPAREBEQ;
            3'b100: alu_control = COMPAREBLT;
            3'b101: alu_control = COMPAREBLE;
            3'b010: casex(funct)
                3'bx00: alu_control = ADD;
                3'bx10: alu_control = ADDIFC;
                3'bx01: alu_control = ADDIFZ;
                3'bx11: alu_control = ADDWC;
                default: alu_control = ADD;
                endcase
            3'b011: casex(funct)
                3'bx00: alu_control = NAND;
//                3'bx10: alu_control = NANDIFC;
                3'bx01: alu_control = NANDIFZ;
                //3'bx11: alu_control = NANDWC;
                default: alu_control = NAND;
                endcase
            3'b110:alu_control = ADDNIL;
            3'b111:alu_control = INCR;
            default: alu_control = ADD;   
        endcase      
    end

endmodule