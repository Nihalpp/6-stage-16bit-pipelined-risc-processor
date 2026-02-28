`timescale 1ns / 1ps

module ALU 
(
    input wire stall_l,
    input wire [15:0] data1,
    input wire [15:0] data2,
    input wire [3:0] ALU_control,
    output reg [15:0] ALU_result,
    output reg zero,
    output reg carry,
    output reg lt,
    output reg eq,
    output reg le
);

    parameter ADD = 4'b0000; //add reg a,reg b
    parameter ADDIFC = 4'b0001; //add reg a,reg b if carry
    parameter ADDIFZ = 4'b0010; //add reg a,reg b if zero
    parameter ADDWC = 4'b0011; //add reg a,reg b,carry
    parameter NANDIFC = 4'b0100;
    parameter NANDIFZ = 4'b0110;
    parameter NAND = 4'b1100;
   // parameter NANDWC = 4'b1101;
    parameter COMPAREBEQ = 4'b1110;
    parameter COMPAREBLT = 4'b1101;
    parameter COMPAREBLE = 4'b1111;
    parameter ADDNIL = 4'b0101;
    parameter INCR = 4'b0111;
    
   always@(*)
    begin
        ALU_result = 16'd0;
        zero       = 1'b0;
        carry      = 1'b0;
        lt         = 1'b0;
        eq         = 1'b0;
        le         = 1'b0;
        case(ALU_control)
            ADD: begin 
                {carry,ALU_result} = data1 + data2;
                zero = (ALU_result==0);
                end
            ADDIFC: begin
                    if(carry) begin
                    {carry,ALU_result} = (data1 + data2) & ({16{carry}});
                    zero = (ALU_result==0);
                    end
                    //else ALU_result = 0;
                    end
            ADDIFZ: begin
                    if(zero) begin
                    {carry,ALU_result} = (data1 + data2) & ({16{zero}});
                    zero = (ALU_result==0);
                    end
                    //else ALU_result = 0;
                    end
            ADDWC:  begin
                    {carry,ALU_result} = data1 + data2 + carry;
                    zero = (ALU_result==0);
                    end
            NAND: begin
                  ALU_result = ~(data1 & data2);
                  zero = (ALU_result==0);
                  end
            NANDIFC: begin 
                     if(carry) begin
                     ALU_result = ~(data1 & data2)& ({16{carry}});
                     zero = (ALU_result==0);
                     end
                     end
            NANDIFZ: begin 
                     if(zero) begin
                     ALU_result = ~(data1 & data2)& ({16{zero}});
                     zero = (ALU_result==0);
                     end
                     end
            COMPAREBEQ:begin
                    // A == B
                    eq = (data1 == data2);
                    end
            COMPAREBLT: begin 
                        // A < B
                        lt = (data1 < data2);
                        end
            COMPAREBLE: begin 
                        // A <= B (i.e. A < B OR A == B)
                        le = (data1 <= data2);
                        end
            ADDNIL: begin 
                if(stall_l)
                    ALU_result = data1 + 16'b1;
            end
            INCR: ALU_result = data1 + 16'b0000000000000001;
            default: ALU_result = 0;
        endcase
    end

endmodule